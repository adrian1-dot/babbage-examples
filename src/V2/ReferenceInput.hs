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

module V2.ReferenceInput
  ( serializedScriptReferenceInput
  , AssetParam(..)
  ) where

import           Prelude as Pr hiding (($), (.), (==), (&&), (-))
import qualified Data.ByteString.Lazy as LBS
import qualified Data.ByteString.Short as SBS
import           Data.Aeson              (ToJSON, FromJSON)
import           GHC.Generics            (Generic)
import           Codec.Serialise

import           Cardano.Api.Shelley (PlutusScript (..), PlutusScriptV2)
import qualified Plutus.Script.Utils.V2.Typed.Scripts as PUV2 
import           Plutus.V2.Ledger.Api (ScriptContext (..), TxInfo (..), Validator (..), Script, txInInfoResolved, txOutValue, unValidatorScript)
import qualified PlutusTx
import           PlutusTx.Prelude hiding (Semigroup (..), unless)
import           Ledger.Value 
import           Ledger ()


data AssetParam = AssetParam
    { apSymbol   :: CurrencySymbol
    , apTn       :: TokenName
    } deriving (Show, Generic, FromJSON, ToJSON, Pr.Eq, Pr.Ord)

PlutusTx.makeLift ''AssetParam

data TypesReferenceInput

instance PUV2.ValidatorTypes TypesReferenceInput where 
    type DatumType    TypesReferenceInput = () 
    type RedeemerType TypesReferenceInput = ()

{-# INLINABLE mkValidatorReferenceInput #-}
mkValidatorReferenceInput :: AssetParam -> () -> () -> ScriptContext -> Bool
mkValidatorReferenceInput params _ _ ctx = traceIfFalse "wrong amount paid" refHasToken
    where 
        info :: TxInfo
        info = scriptContextTxInfo ctx

        myAssetClass :: AssetClass 
        myAssetClass = assetClass (apSymbol params) (apTn params)

        refHasToken :: Bool 
        refHasToken = 
            let
                ins = [ o
                    | i <- txInfoReferenceInputs info
                    , let o = txInInfoResolved i
                    , assetClassValueOf (txOutValue o) myAssetClass == 1
                    ]
            in
               PlutusTx.Prelude.length ins == 1

typedValidatorReferenceInput :: AssetParam -> PUV2.TypedValidator TypesReferenceInput
typedValidatorReferenceInput = PUV2.mkTypedValidatorParam @TypesReferenceInput
    $$(PlutusTx.compile [||mkValidatorReferenceInput||])
    $$(PlutusTx.compile [|| wrap ||])
    where
        wrap = PUV2.mkUntypedValidator

validatorReferenceInput :: AssetParam -> Validator
validatorReferenceInput = PUV2.validatorScript . typedValidatorReferenceInput

scriptReferenceInput :: AssetParam -> Script
scriptReferenceInput = unValidatorScript . validatorReferenceInput

scriptShortBsReferenceInput :: AssetParam -> SBS.ShortByteString
scriptShortBsReferenceInput params = SBS.toShort . LBS.toStrict . serialise $ scriptReferenceInput params

serializedScriptReferenceInput :: AssetParam -> PlutusScript PlutusScriptV2
serializedScriptReferenceInput = PlutusScriptSerialised . scriptShortBsReferenceInput
