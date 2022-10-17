{-# LANGUAGE ImportQualifiedPost #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts   #-}
{-# LANGUAGE ScopedTypeVariables #-}

import           Data.Aeson             as Json (encode)
import           Data.String            (fromString)
import           Data.ByteString.Lazy   qualified as LB
import           Prelude
import           System.Environment     (getArgs)
import           Cardano.Api            (scriptDataToJson, ScriptDataJsonSchema(ScriptDataJsonDetailedSchema))
import           Cardano.Api.Shelley    (fromPlutusData)
import qualified PlutusTx

import           V2.ReferenceScriptAtScript (validatorHashOne, OneParam(..))

main :: IO ()
main = do
  [tn', cs', am'] <- getArgs 
  let am = read am'
      tn = fromString tn'
      cs = fromString cs'
      oneParam = OneParam {opSymbol = cs, opTn = tn}
  writeData "Data/unit.json" ()
  writeData "Data/integer.json" (am :: Integer)
  writeData "Data/valHash.json" $ validatorHashOne oneParam
  putStrLn "Done"

writeData :: PlutusTx.ToData a => FilePath -> a -> IO ()
writeData file isData = do
  print file
  LB.writeFile file (toJsonString isData)

toJsonString :: PlutusTx.ToData a => a -> LB.ByteString
toJsonString =
  Json.encode
    . scriptDataToJson ScriptDataJsonDetailedSchema
    . fromPlutusData
    . PlutusTx.toData


