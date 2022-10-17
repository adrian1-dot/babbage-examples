
# general
cardano-cli query protocol-parameters $TESTNET --out-file Data/protocol.json

cabal run data-v2 ${TN_V2_REFSCR} ${CS_V2_REFSCR} ${AMOUNT} 

# reference input 
cabal run plutus-ReferenceInput ${CS_V2_REFIN} ${TN_V2_REFIN}

cardano-cli address build --payment-script-file Data/validatorReferenceInput.plutus $TESTNET --out-file Data/validatorReferenceInput.addr 

cardano-cli transaction hash-script-data --script-data-file Data/unit.json > Data/dhashUnit

# reference script 
cabal run plutus-ReferenceScript

cardano-cli address build --payment-script-file Data/validatorReferenceScript.plutus $TESTNET --out-file Data/validatorReferenceScript.addr 

## reference script at script 
cabal run plutus-ReferenceScriptAtScript ${CS_V2_REFSCR} ${TN_V2_REFSCR}

cardano-cli address build --payment-script-file Data/validatorReferenceScriptOne.plutus $TESTNET --out-file Data/validatorReferenceScriptOne.addr 

cardano-cli address build --payment-script-file Data/validatorReferenceScriptTwo.plutus $TESTNET --out-file Data/validatorReferenceScriptTwo.addr 

cardano-cli transaction policyid --script-file Data/validatorReferenceScriptOne.plutus > pol.one 

cat Data/valHash.json | jq --arg nvh $(cat pol.one) '.bytes = $nvh' > Data/valHash.json

rm pol.one

cardano-cli transaction hash-script-data --script-data-file Data/integer.json > Data/dhashInteger

cardano-cli transaction hash-script-data --script-data-file Data/valHash.json > Data/dhashValHash

# inline datum 
cabal run plutus-InlineDatum

cardano-cli address build --payment-script-file Data/validatorInlineDatum.plutus $TESTNET --out-file Data/validatorInlineDatum.addr 



