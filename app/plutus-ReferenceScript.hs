{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE BlockArguments #-}


import           Prelude
import           Cardano.Api
import           V2.ReferenceScript (serializedScriptReferenceScript)


main :: IO ()
main = writePlutusScript "Data/validatorReferenceScript.plutus" serializedScriptReferenceScript

writePlutusScript :: FilePath -> PlutusScript PlutusScriptV2 -> IO ()
writePlutusScript filename scriptSerial = do
  result <- writeFileTextEnvelope filename Nothing scriptSerial
  case result of
    Left err -> print $ displayError err
    Right () -> return ()


