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
import qualified Data.ByteString as DBS

main :: IO ()
main = quickHttpServe site

viewIndex :: Snap ()
viewIndex = do content <- liftIO $ DBS.readFile "templates/index.karver"
               writeBS $ content

generate :: Snap ()
generate = do mContent :: Maybe ByteString <- getParam "code"
              let bContent :: ByteString = fromJust mContent
              liftIO $ putStrLn $ BS.unpack bContent
              writeBS $ "CIAO"

site :: Snap ()
site =
    ifTop viewIndex <|>
    route [ ("generate", generate)
          ] <|>
    dir "assets" (serveDirectory "assets")
