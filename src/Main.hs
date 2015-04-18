{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
module Main where

import           Control.Applicative
import           Snap.Core
import           Snap.Util.FileServe
import           Snap.Http.Server
import qualified Data.ByteString.Char8 as BS
import Control.Monad.IO.Class (MonadIO(..))
import Control.Monad.Trans.Either
import Data.Monoid (mempty)
import Data.Foldable (forM_)

import           Data.ByteString (ByteString)
import           Snap.Util.FileServe
import           Data.Monoid
import           Data.Maybe

import Data.HashMap.Strict (HashMap)
import qualified Data.HashMap.Strict as H
import Data.Text (Text)
import qualified Data.Text.IO as T
import qualified Data.Vector as V
import Data.Text.Encoding
import qualified Data.ByteString as DBS
import System.IO
import Parse
import ER
import ErdMain
import qualified Data.ByteString.Lazy          as BL
import qualified Data.ByteString.Lazy.Internal as BLI
import qualified Data.GraphViz.Types.Generalised as G
import qualified Data.Text.Lazy as L
import Data.Knob
import Data.GraphViz.Commands
import System.Random

main :: IO ()
main = quickHttpServe site

viewIndex :: Snap ()
viewIndex = do content <- liftIO $ DBS.readFile "templates/index.karver"
               writeBS $ content

processErCode :: String -> IO (Either String ByteString)
processErCode code = do
    -- the name we pass to loadERFromText does not really matter
    res :: Either String ER <- loadERFromText "generated_image.png" (L.pack code)
    case res of
        Left err -> do return $ Left err
        Right er -> do
            let dotted :: G.DotGraph L.Text = dotER er
            let getData handle = do bytes <- BS.hGetContents handle
                                    return bytes
            let fmt :: GraphvizOutput = Png
            gvizRes :: ByteString <- graphvizWithHandle Dot dotted fmt getData
            return $ Right gvizRes

toStrictBS = BS.concat . BL.toChunks

escape [] = []
escape ('"':s) = "\\\"" ++ escape(s)
escape (c:s) = [c] ++ escape(s)

generate :: Snap ()
generate = do
    lContent :: BL.ByteString <- getRequestBody
    let mContent = toStrictBS lContent
    liftIO $ putStrLn "(Processing generate request)"
    res <- liftIO $ processRequest mContent
    case res of Left errorMsg -> writeBS $ BS.pack $ "{ \"error\" : \"" ++ (escape errorMsg) ++ "\" }"
                Right image -> do
                    randomId :: Int <- liftIO $ randomIO
                    let fileName = "generated/diagram_" ++ (show randomId) ++ ".png"
                    liftIO $ BS.writeFile fileName image
                    writeBS $ BS.pack  $ "{ \"image\" : \"" ++ fileName ++ "\" }"
                    return ()
    liftIO $ putStrLn "  Done."
 where processRequest :: BS.ByteString -> IO (Either String ByteString)
       processRequest bContent = do
         let content :: String = BS.unpack bContent
         es :: Either String ByteString <- liftIO $ processErCode content
         return es

site :: Snap ()
site =
    ifTop viewIndex <|>
    route [ ("generate", generate)
          ] <|>
    dir "assets" (serveDirectory "assets") <|>
    dir "generated" (serveDirectory "generated")
