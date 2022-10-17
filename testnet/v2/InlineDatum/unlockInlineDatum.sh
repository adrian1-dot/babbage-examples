source ../getTxFunc.sh

getInputTx $1 ..
WALLETUTXO=${SELECTED_UTXO}

getContractInputTx InlineDatum .. 

CONUTXO=${SELECTED_UTXO_CONTRACT}
CONAM=${SELECTED_UTXO_LOVELACE}

NEWVALCON=$(expr $CONAM - ${AMOUNT})


cardano-cli transaction build $TESTNET \
    --babbage-era \
    --change-address $(cat $CLIWALLET/$1.addr) \
    --tx-in-collateral $WALLETUTXO \
    --tx-in $CONUTXO \
    --tx-in-script-file ../Data/validatorInlineDatum.plutus \
    --tx-in-inline-datum-present \
    --tx-in-redeemer-file ../Data/unit.json \
    --tx-out $(cat ../Data/validatorInlineDatum.addr)+$NEWVALCON \
    --tx-out-inline-datum-file ../Data/integer.json \
    --protocol-params-file ../Data/protocol.json \
    --out-file ../tx/tx.body 

cardano-cli transaction sign $TESTNET \
    --tx-body-file ../tx/tx.body \
    --signing-key-file $CLIWALLET/$1.skey \
    --out-file ../tx/tx.signed 

cardano-cli transaction submit $TESTNET \
    --tx-file ../tx/tx.signed 
