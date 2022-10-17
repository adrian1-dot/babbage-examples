source ../getTxFunc.sh

getInputTx $1 .. 
WALLETUTXO=${SELECTED_UTXO}

cardano-cli transaction build $TESTNET \
    --babbage-era \
    --change-address $(cat $CLIWALLET/$1.addr) \
    --tx-in $WALLETUTXO \
    --tx-out $(cat ../Data/validatorInlineDatum.addr)+22000000 \
    --tx-out-inline-datum-file ../Data/integer.json \
    --protocol-params-file ../Data/protocol.json \
    --out-file ../tx/tx.body 

cardano-cli transaction sign $TESTNET \
    --tx-body-file ../tx/tx.body \
    --signing-key-file $CLIWALLET/$1.skey \
    --out-file ../tx/tx.signed 

cardano-cli transaction submit $TESTNET \
    --tx-file ../tx/tx.signed 
