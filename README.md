
# babbage examples 
Project to outline the functionalities of the new babbage era consisting of validators and bash scripts. 

## Prerequisite

* [The Plutus Application Framework](https://github.com/input-output-hk/plutus-apps)
* [cardano-node](https://github.com/input-output-hk/cardano-node)
* [jq](https://stedolan.github.io/jq/download/)
    - Ubuntu: `sudo apt-get install jq`
* at least one funded [wallet](https://developers.cardano.org/docs/stake-pool-course/handbook/keys-addresses/)
* one token in the wallet 

## build validators and necessary data to build transactions

* start your cardano-node (pre-production testnet)
* open new terminal and enter your plutus-apps nix-shell with tag 87b647b05902a7cef37340fda9acb175f962f354
* go to the root folder of this repository and run `cabal update` followed by `cabal build`
* go into /testnet/env.sh and change the values to your own 
    - TESTNET can be left as is for pre-production testnet 
    - CLIWALLET is the path where you store your wallet key files (.addr, .vkey, .skey)
    - CS_V2_REFIN currency symbol of a token in your wallet 
    - TN_V2_REFIN corresponding token name 
    - AMOUNT can be left as 5 ada, later used as datum 
    - CS_V2_REFSCR currency symbol of a token in your wallet (other than CS_V2_REFIN)
    - TN_V2_REFSCR corresponding token name
* make it an executable `chmod +x env.sh`
* run ` . env.sh` to mount the variables for this shell 
* go into the /v2 folder and run `./createPlutusData.sh`
    - creates validators, datums, redeemers in /Data folder  
* now you can run the examples provided in the subdirectories
    - [ReferenceInput](testnet/v2/ReferenceInput/CIP31-reference-inputs.md)
    - [ReferenceScript](testnet/v2/ReferenceScript/CIP33-reference-scripts.md)
    - [InlineDatum](testnet/v2/InlineDatum/CIP32-inline-datums.md)

## What changed on chain 

### ScriptContext 
`data ScriptContext = ScriptContext{scriptContextTxInfo :: TxInfo, scriptContextPurpose :: ScriptPurpose }`

**Nothing changed** 

### TxInfo 

#### V1 

`data TxInfo = TxInfo    
    { txInfoInputs      :: [TxInInfo] -- ^ Transaction inputs    
    , txInfoOutputs     :: [TxOut] -- ^ Transaction outputs    
    , txInfoFee         :: Value -- ^ The fee paid by this transaction.    
    , txInfoMint        :: Value -- ^ The 'Value' minted by this transaction.    
    , txInfoDCert       :: [DCert] -- ^ Digests of certificates included in this transaction    
    , txInfoWdrl        :: [(StakingCredential, Integer)] -- ^ Withdrawals    
    , txInfoValidRange  :: POSIXTimeRange -- ^ The valid range for the transaction.    
    , txInfoSignatories :: [PubKeyHash] -- ^ Signatures provided with the transaction, attested that they all signed the tx    
    , txInfoData        :: [(DatumHash, Datum)]    
    , txInfoId          :: TxId    
    -- ^ Hash of the pending transaction (excluding witnesses)    
    }`

#### V2 

`data TxInfo = TxInfo    
    { txInfoInputs          :: [TxInInfo] -- ^ Transaction inputs    
`**`, txInfoReferenceInputs :: [TxInInfo] -- ^ Transaction reference inputs`**`    
    , txInfoOutputs         :: [TxOut] -- ^ Transaction outputs    
    , txInfoFee             :: Value -- ^ The fee paid by this transaction.    
    , txInfoMint            :: Value -- ^ The 'Value' minted by this transaction.    
    , txInfoDCert           :: [DCert] -- ^ Digests of certificates included in this transaction    
    , txInfoWdrl            :: Map StakingCredential Integer -- ^ Withdrawals    
    , txInfoValidRange      :: POSIXTimeRange -- ^ The valid range for the transaction.    
    , txInfoSignatories     :: [PubKeyHash] -- ^ Signatures provided with the transaction, attested that they all signed the tx    
    , txInfoRedeemers       :: Map ScriptPurpose Redeemer    
    , txInfoData            :: Map DatumHash Datum    
    , txInfoId              :: TxId    
    -- ^ Hash of the pending transaction (excluding witnesses)    
    }`

- `txInfoReferenceInputs` indicated with `--read-only-tx-in-reference` (cardano-cli), only possible with wallet utxos 

### TxInfo 

`-- | An input of a pending transaction.    
data TxInInfo = TxInInfo    
    { txInInfoOutRef   :: TxOutRef    
    , txInInfoResolved :: TxOut    
    }`

**Nothing changed** 

### TxOut 

#### V1 

`data TxOut = TxOut {    
    txOutAddress   :: Address,    
    txOutValue     :: Value,    
    txOutDatumHash :: Maybe DatumHash    
    }`

#### V2 

`data TxOut = TxOut {    
    txOutAddress         :: Address,    
    txOutValue           :: Value,    
`**`txOutDatum           :: OutputDatum,`**`    
`**`txOutReferenceScript :: Maybe ScriptHash`**`    
    }`

- txOutDatum is a new type `data OutputDatum = NoOutputDatum | OutputDatumHash DatumHash | OutputDatum Datum` **OutputDatum** is the new inline-datum 
- txOutReferenceScript is a reference script attached to a transaction output, as input it just tells the node to build the transaction for the referenced script but isn't included in the transaction 







