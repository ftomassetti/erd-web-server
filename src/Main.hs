{-# LANGUAGE OverloadedStrings #-}
module Main where

import           Control.Applicative
import           Snap.Core
import           Snap.Util.FileServe
import           Snap.Http.Server
import           Heist (HeistConfig, initHeist, hcTemplateLocations, loadTemplates, hcInterpretedSplices,
	defaultInterpretedSplices)
import Data.Monoid (mempty)


main :: IO ()
main = quickHttpServe site

index :: IO ()
index = do heist <- Heist.initHeist mempty
    	        { hcTemplateLocations = [ loadTemplates "templates" ]
    	  		, hcInterpretedSplices = defaultInterpretedSplices
    	  		}
    	   return heist 

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
