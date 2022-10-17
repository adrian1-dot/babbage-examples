source ../getTxFunc.sh

getInputTx $1 ..
WALLETUTXO=${SELECTED_UTXO}

getInputTx $1 ..
WALLETUTXOT=${SELECTED_UTXO}

getContractInputTx ReferenceInput ..

CTWOUTXO=${SELECTED_UTXO_CONTRACT}

cardano-cli transaction build $TESTNET \
    --babbage-era \
    --change-address $(cat $CLIWALLET/$1.addr) \
    --tx-in-collateral $WALLETUTXO \
    --tx-in $CTWOUTXO \
    --tx-in-script-file ../Data/validatorReferenceInput.plutus \
    --tx-in-datum-file ../Data/unit.json \
    --tx-in-redeemer-file ../Data/unit.json \
    --read-only-tx-in-reference $WALLETUTXOT \
    --protocol-params-file ../Data/protocol.json \
    --out-file ../tx/tx.body 

cardano-cli transaction sign $TESTNET \
    --tx-body-file ../tx/tx.body \
    --signing-key-file $CLIWALLET/$1.skey \
    --out-file ../tx/tx.signed 

cardano-cli transaction submit $TESTNET \
    --tx-file ../tx/tx.signed 


