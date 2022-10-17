{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE BlockArguments #-}


import           Prelude
import           System.Environment
import           Cardano.Api
import           Data.String        (fromString)
import           V2.ReferenceInput  (serializedScriptReferenceInput, AssetParam (..))


main :: IO ()
main = do
  [cs', tn'] <- getArgs
  let cs = fromString cs'
      tn = fromString tn'
      assetParam = AssetParam cs tn 
  writePlutusScript "Data/validatorReferenceInput.plutus" (serializedScriptReferenceInput assetParam)

writePlutusScript :: FilePath -> PlutusScript PlutusScriptV2 -> IO ()
writePlutusScript filename scriptSerial  = do
  result <- writeFileTextEnvelope filename Nothing scriptSerial
  case result of
    Left err -> print $ displayError err
    Right () -> return ()


