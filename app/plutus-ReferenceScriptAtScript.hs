{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE BlockArguments #-}


import           Prelude
import           System.Environment
import           Cardano.Api
import           Data.String            (fromString)

import           V2.ReferenceScriptAtScript (serializedScriptOne, OneParam(..), serializedScriptTwo)


main :: IO ()
main = do
  [cs', tn'] <- getArgs
  let cs = fromString cs'
      tn = fromString tn'
      oneParam = OneParam cs tn
  writePlutusScript "Data/validatorReferenceScriptOne.plutus" (serializedScriptOne oneParam)
  writePlutusScript "Data/validatorReferenceScriptTwo.plutus" serializedScriptTwo

writePlutusScript :: FilePath -> PlutusScript PlutusScriptV2 -> IO ()
writePlutusScript filename scriptSerial = do
  result <- writeFileTextEnvelope filename Nothing scriptSerial
  case result of
    Left err -> print $ displayError err
    Right () -> return ()

