{-# LANGUAGE DataKinds #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE DeriveAnyClass        #-}
{-# LANGUAGE DeriveGeneric         #-}
{-# LANGUAGE MultiParamTypeClasses #-}


module V2.InlineDatum
  ( serializedScriptInlineDatum
  ) where

import           Prelude as Pr hiding (($), (.), (==), (&&), (-))
import           Codec.Serialise
import qualified Data.ByteString.Lazy as LBS
import qualified Data.ByteString.Short as SBS
import           Cardano.Api.Shelley (PlutusScript (..), PlutusScriptV2)
import qualified Plutus.Script.Utils.V2.Typed.Scripts as PUV2 
import           Plutus.V2.Ledger.Contexts
import           Plutus.V2.Ledger.Api hiding (adaToken, adaSymbol)
import qualified PlutusTx
import           PlutusTx.Builtins (unsafeDataAsI)
import           PlutusTx.Prelude hiding (Semigroup (..), unless)
import           Ledger (scriptHashAddress)
import           Ledger.Value hiding (adaSymbol, adaToken)
import           Ledger.Ada (adaSymbol, adaToken)


data MyTypesInlineDatum

instance PUV2.ValidatorTypes MyTypesInlineDatum where 
    type DatumType MyTypesInlineDatum = Integer 
    type RedeemerType MyTypesInlineDatum = ()

{-# INLINABLE amInDatum #-}
amInDatum :: TxOut -> Integer
amInDatum o = do
    case txOutDatum o of 
      OutputDatum h -> unsafeDataAsI (getDatum h)
      _             -> traceError "wrong datum type"

{-# INLINABLE mkValidatorInlineDatum #-}
mkValidatorInlineDatum :: Integer -> () -> ScriptContext -> Bool
mkValidatorInlineDatum int _ ctx = traceIfFalse "wrong amount paid" correctOutput &&
                                  traceIfFalse "wrong validatorHash in datum" (outputDatum == int)
    where 
        info :: TxInfo
        info = scriptContextTxInfo ctx

        ownValidatorAddr :: Address 
        ownValidatorAddr = scriptHashAddress $ ownHash ctx

        validatorInlineDatumInput :: TxOut
        validatorInlineDatumInput =
            let
                ins = [ o
                    | i <- txInfoInputs info
                    , let o = txInInfoResolved i
                    , txOutAddress o == ownValidatorAddr
                    ]
            in
                case ins of
                    [o] -> o
                    _   -> traceError "expected exactly one validatorInlineDatum input"


        validatorInlineDatumOutput :: TxOut
        validatorInlineDatumOutput =
            let
                ins = [ i
                    | i <- txInfoOutputs info
                    , txOutAddress i == ownValidatorAddr
                    ]
            in
                case ins of
                    [o] -> o
                    _   -> traceError "expected exactly one validatorInlineDatum output"

        datumAmount :: Integer
        datumAmount = amInDatum validatorInlineDatumInput  

        adaHasValueOf :: Value -> Integer 
        adaHasValueOf val = valueOf val adaSymbol adaToken 

        correctOutput :: Bool 
        correctOutput = adaHasValueOf (txOutValue validatorInlineDatumInput) - datumAmount == adaHasValueOf (txOutValue validatorInlineDatumOutput) 

        outputDatum :: Integer
        outputDatum = amInDatum validatorInlineDatumOutput

typedValidatorInlineDatum :: PUV2.TypedValidator MyTypesInlineDatum
typedValidatorInlineDatum = PUV2.mkTypedValidator @MyTypesInlineDatum
    $$(PlutusTx.compile [||mkValidatorInlineDatum||])
    $$(PlutusTx.compile [|| wrap ||])
    where
        wrap = PUV2.mkUntypedValidator

validatorInlineDatum :: Validator
validatorInlineDatum = PUV2.validatorScript typedValidatorInlineDatum

scriptInlineDatum :: Script
scriptInlineDatum = unValidatorScript validatorInlineDatum

scriptShortBsInlineDatum :: SBS.ShortByteString
scriptShortBsInlineDatum = SBS.toShort . LBS.toStrict $ serialise scriptInlineDatum

serializedScriptInlineDatum :: PlutusScript PlutusScriptV2
serializedScriptInlineDatum = PlutusScriptSerialised scriptShortBsInlineDatum
