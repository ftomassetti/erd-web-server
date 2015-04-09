{-# LANGUAGE OverloadedStrings #-}
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
import Heist
import Heist.Interpreted
import Text.XmlHtml (Node(TextNode), renderHtmlFragment, Encoding(UTF8))


main :: IO ()
main = quickHttpServe site

billy :: IO ()
billy = eitherT (putStrLn . unlines) return $ do
  heist <- initHeist mempty
    { hcTemplateLocations = [ loadTemplates "templates" ]
    , hcInterpretedSplices = defaultInterpretedSplices
    } 

  Just (output, _) <- renderTemplate heist "billy" 

  liftIO . BS.putStrLn . toByteString $ output

site :: Snap ()
site =
    ifTop (writeBS "hello world") <|>
    route [ ("foo", writeBS "bar")
          , ("echo/:echoparam", echoHandler)
          ] <|>
    dir "static" (serveDirectory ".")

echoHandler :: Snap ()
echoHandler = do
    param <- getParam "echoparam"
    maybe (writeBS "must specify echo/param in URL")
          writeBS param
