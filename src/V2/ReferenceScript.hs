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


module V2.ReferenceScript
  ( serializedScriptReferenceScript 
  ) where

import           Prelude as Pr hiding (($), (.), (==), (&&), (-))

import           Cardano.Api.Shelley (PlutusScript (..), PlutusScriptV2)

import           Codec.Serialise
import qualified Data.ByteString.Lazy as LBS
import qualified Data.ByteString.Short as SBS

import qualified Plutus.Script.Utils.V2.Typed.Scripts as PUV2 
import           Plutus.V2.Ledger.Contexts
import           Plutus.V2.Ledger.Api hiding (adaToken, adaSymbol)
import qualified PlutusTx
import           PlutusTx.Prelude hiding (Semigroup (..), unless)



data MyTypesReferenceScript

instance PUV2.ValidatorTypes MyTypesReferenceScript where
    type DatumType MyTypesReferenceScript = ()
    type RedeemerType MyTypesReferenceScript = ()

{-# INLINABLE mkValidatorReferenceScript #-}
mkValidatorReferenceScript :: () -> () -> ScriptContext -> Bool
mkValidatorReferenceScript _ _ ctx = traceIfFalse "reference script missing" outputHasRefScr 
    where 
        info :: TxInfo
        info = scriptContextTxInfo ctx

        ownValHashB :: BuiltinByteString
        ownValHashB = case ownHash ctx of 
                        (ValidatorHash b) -> b 

        outputHasRefScr :: Bool 
        outputHasRefScr =  
            let
                ins = [ i
                    | i <- txInfoOutputs info
                    , isJust (txOutReferenceScript i)
                    ]
            in
              case ins of 
                [o] -> case txOutReferenceScript o of
                           Just ob -> getScriptHash ob == ownValHashB
                           Nothing -> traceError "failed BuiltinByteString"
                _   -> traceError "expected exactly one reference script in outputs"

typedValidatorReferenceScript :: PUV2.TypedValidator MyTypesReferenceScript
typedValidatorReferenceScript = PUV2.mkTypedValidator @MyTypesReferenceScript
    $$(PlutusTx.compile [||mkValidatorReferenceScript||])
    $$(PlutusTx.compile [|| wrap ||])
    where
        wrap = PUV2.mkUntypedValidator

validatorReferenceScript :: Validator
validatorReferenceScript = PUV2.validatorScript typedValidatorReferenceScript

scriptReferenceScript :: Script
scriptReferenceScript = unValidatorScript validatorReferenceScript

scriptShortBsReferenceScript :: SBS.ShortByteString
scriptShortBsReferenceScript = SBS.toShort . LBS.toStrict $ serialise scriptReferenceScript 

serializedScriptReferenceScript :: PlutusScript PlutusScriptV2
serializedScriptReferenceScript = PlutusScriptSerialised scriptShortBsReferenceScript

