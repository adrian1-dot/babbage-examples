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



module V2.ReferenceScriptAtScript
  ( serializedScriptOne 
  , serializedScriptTwo
  , OneParam(..)
  , validatorHashOne
  ) where

import           Prelude as Pr hiding (($), (.), (==), (&&), (-), (||), (>))

import           Cardano.Api.Shelley (PlutusScript (..), PlutusScriptV2)

import           Codec.Serialise
import qualified Data.ByteString.Lazy as LBS
import qualified Data.ByteString.Short as SBS

import qualified Plutus.Script.Utils.V2.Typed.Scripts as PUV2 
import           Plutus.V2.Ledger.Contexts
import           Plutus.V2.Ledger.Api hiding (adaToken, adaSymbol)
import qualified PlutusTx
import           PlutusTx.Builtins (unsafeDataAsI, unsafeDataAsB)
import           PlutusTx.Prelude hiding (Semigroup (..), unless)
import           Ledger (scriptHashAddress, scriptHash)
import           Ledger.Value hiding (adaSymbol, adaToken)
import           Ledger.Ada (adaSymbol, adaToken)

import                  Data.Aeson              (ToJSON, FromJSON)
import                  GHC.Generics            (Generic)

data OneParam = OneParam
    { opSymbol   :: CurrencySymbol
    , opTn       :: TokenName
    } deriving (Show, Generic, FromJSON, ToJSON, Pr.Eq, Pr.Ord)

PlutusTx.makeLift ''OneParam

data MyTypesOne

instance PUV2.ValidatorTypes MyTypesOne where
    type DatumType MyTypesOne = Integer
    type RedeemerType MyTypesOne = ()

{-# INLINABLE amInDatum #-}
amInDatum :: TxOut -> TxInfo -> Integer
amInDatum o i = do
    case txOutDatum o of 
      OutputDatumHash h -> case findDatum h i of 
                             Just d -> unsafeDataAsI (getDatum d)
                             _      -> traceError "no datum found"
      _                 -> traceError "wrong datum type"

{-# INLINABLE mkValidatorOne #-}
mkValidatorOne :: OneParam -> Integer -> () -> ScriptContext -> Bool
mkValidatorOne params am _ ctx = traceIfFalse "input token missing" inputHasToken                   &&
                                 traceIfFalse "output token missing" outputHasToken                 && 
                                 traceIfFalse "datum value changed"  (outputDatum == am)           
    where 
        info :: TxInfo
        info = scriptContextTxInfo ctx
        
        ownInput :: TxOut
        ownInput = case findOwnInput ctx of
            Nothing -> traceError "input token missing"
            Just i  -> txInInfoResolved i

        inputHasToken :: Bool
        inputHasToken = valueOf (txOutValue ownInput) (opSymbol params) (opTn params) == 1

        ownOutput :: TxOut
        ownOutput = case getContinuingOutputs ctx of
            [o] -> o
            _   -> traceError "expected exactly one output at scriptOne"

        outputHasToken :: Bool
        outputHasToken = valueOf (txOutValue ownOutput) (opSymbol params) (opTn params) == 1

        outputDatum :: Integer 
        outputDatum = amInDatum ownOutput info


typedValidatorOne :: OneParam -> PUV2.TypedValidator MyTypesOne
typedValidatorOne = PUV2.mkTypedValidatorParam @MyTypesOne
    $$(PlutusTx.compile [||mkValidatorOne||])
    $$(PlutusTx.compile [|| wrap ||])
    where
        wrap = PUV2.mkUntypedValidator

validatorOne :: OneParam -> Validator
validatorOne = PUV2.validatorScript . typedValidatorOne

scriptOne :: OneParam -> Script
scriptOne = unValidatorScript . validatorOne

validatorHashOne :: OneParam -> ScriptHash
validatorHashOne = scriptHash . scriptOne

scriptShortBsOne :: OneParam -> SBS.ShortByteString
scriptShortBsOne params = SBS.toShort . LBS.toStrict . serialise $ scriptOne params

serializedScriptOne :: OneParam -> PlutusScript PlutusScriptV2
serializedScriptOne = PlutusScriptSerialised . scriptShortBsOne

data MyTypesTwo

instance PUV2.ValidatorTypes MyTypesTwo where
    type DatumType MyTypesTwo = ValidatorHash
    type RedeemerType MyTypesTwo = ()


{-# INLINABLE datumValidatorHash #-}
datumValidatorHash :: TxOut -> TxInfo -> ValidatorHash
datumValidatorHash o i = do
           case txOutDatum o of 
              OutputDatumHash h -> case findDatum h i of 
                                      Just d -> ValidatorHash (unsafeDataAsB (getDatum d))
                                      _      -> traceError "no datum found"
              _                 -> traceError "wrong datum type"

{-# INLINABLE mkValidatorTwo #-}
mkValidatorTwo :: ValidatorHash -> () -> ScriptContext -> Bool
mkValidatorTwo vh _ ctx = traceIfFalse "wrong amount paid" (correctOutput || outMoreThanIn)  &&
                          traceIfFalse "wrong validatorHash in datum" (outputDatum == vh)    &&
                          traceIfFalse "reference script to validator missing" refScrCreated 
    where 
        info :: TxInfo
        info = scriptContextTxInfo ctx

        ownValidatorAddr :: Address 
        ownValidatorAddr = scriptHashAddress $ ownHash ctx
        
        valHashAsB:: BuiltinByteString
        valHashAsB = case vh of 
                        (ValidatorHash b) -> b 

        refScrCreated :: Bool 
        refScrCreated = case txOutReferenceScript ownOutput of 
                           Just sh -> getScriptHash sh == valHashAsB
                           _       -> traceError "txOut ReferenceScript failed"

        inputFromAddr :: Address -> TxOut
        inputFromAddr addr =
            let
                ins = [ o
                    | i <- txInfoInputs info
                    , let o = txInInfoResolved i
                    , txOutAddress o == addr
                    ]
            in
                case ins of
                    [o] -> o
                    _   -> traceError "expected exactly one input from validator"

        ownOutput :: TxOut
        ownOutput =
            let
                ins = [ i
                    | i <- txInfoOutputs info
                    , txOutAddress i == ownValidatorAddr
                    ]
            in
                case ins of
                    [o] -> o
                    _   -> traceError "expected exactly one validatorTwo output"

        inputOne :: TxOut 
        inputOne = inputFromAddr (scriptHashAddress vh)

        inputTwo :: TxOut 
        inputTwo = inputFromAddr ownValidatorAddr

        validatorOneAmount :: Integer
        validatorOneAmount = amInDatum inputOne info 

        adaHasValueOf :: Value -> Integer 
        adaHasValueOf val = valueOf val adaSymbol adaToken 

        correctOutput :: Bool 
        correctOutput = adaHasValueOf (txOutValue inputTwo) - validatorOneAmount == adaHasValueOf (txOutValue ownOutput)

        outMoreThanIn :: Bool 
        outMoreThanIn = adaHasValueOf (txOutValue ownOutput) > adaHasValueOf (txOutValue inputTwo)

        outputDatum :: ValidatorHash
        outputDatum = datumValidatorHash ownOutput info

typedValidatorTwo :: PUV2.TypedValidator MyTypesTwo
typedValidatorTwo = PUV2.mkTypedValidator @MyTypesTwo
    $$(PlutusTx.compile [||mkValidatorTwo||])
    $$(PlutusTx.compile [|| wrap ||])
    where
        wrap = PUV2.mkUntypedValidator

validatorTwo :: Validator
validatorTwo = PUV2.validatorScript typedValidatorTwo

scriptTwo :: Script
scriptTwo = unValidatorScript validatorTwo

scriptShortBsTwo :: SBS.ShortByteString
scriptShortBsTwo = SBS.toShort . LBS.toStrict $ serialise scriptTwo

serializedScriptTwo :: PlutusScript PlutusScriptV2
serializedScriptTwo = PlutusScriptSerialised scriptShortBsTwo
