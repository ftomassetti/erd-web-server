{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
module Main where

import           Control.Applicative
import           Snap.Core
import           Snap.Util.FileServe
import           Snap.Http.Server
import Blaze.ByteString.Builder (toByteString)
import qualified Data.ByteString.Char8 as BS
import Control.Monad.IO.Class (MonadIO(..))
import Control.Monad.Trans.Either
import Data.Monoid (mempty)
import Data.Foldable (forM_)
import Text.XmlHtml (Node(TextNode), renderHtmlFragment, Encoding(UTF8))

import           Data.ByteString (ByteString)
--import           Snap.Snaplet
--import           Snap.Snaplet.Heist
import           Snap.Util.FileServe
------------------------------------------------------------------------------
import           Heist
import qualified Heist.Compiled as C
import           Data.Monoid
import           Data.Maybe
import Control.Lens
import Data.Either.Unwrap

import Text.Karver
import Data.HashMap.Strict (HashMap)
import qualified Data.HashMap.Strict as H
import Data.Text (Text)
import qualified Data.Text.IO as T
import qualified Data.Vector as V
import Data.Text.Encoding

main :: IO ()
main = quickHttpServe site

templateHashMap :: HashMap Text Value
templateHashMap = H.fromList $
  [ ("OB", Literal "{")
  , ("items", List $ V.fromList [ Literal "eggs"
                                , Literal "flour"
                                , Literal "cereal"
                                ])
  ]


getContent :: IO Text
getContent = do tplStr <- T.readFile "templates/index.karver"
                let htmlStr = renderTemplate templateHashMap tplStr
                return htmlStr

viewIndex :: Snap ()
viewIndex = do content <- liftIO getContent
               writeBS $ encodeUtf8 content

--billy :: IO ()
--billy = eitherT (putStrLn . unlines) return $ do
--  heist <- initHeist mem--    { hcTemplateLocations = [ loadTemplates "templates" ]
--    , hcInterpretedSplices = defaultInterpretedSplices
--    }
--
--  Just (output, _) <- renderTemplate heist "billy"
--
--  liftIO . BS.putStrLn . toByteString $ output


site :: Snap ()
site =
    ifTop viewIndex <|>
    route [ ("foo", viewIndex)
          , ("echo/:echoparam", echoHandler)
          ] <|>
    dir "assets" (serveDirectory "assets")

echoHandler :: Snap ()
echoHandler = do
    param <- getParam "echoparam"
    maybe (writeBS "must specify echo/param in URL")
          writeBS param
