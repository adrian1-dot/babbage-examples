source ../getTxFunc.sh

getInputTx $1 ..
WALLETUTXO=${SELECTED_UTXO}

getInputTx $1 ..
WALLETUTXO1=${SELECTED_UTXO}


getContractInputTx ReferenceScript ..
CONEUTXO=${SELECTED_UTXO_CONTRACT}

cardano-cli transaction build $TESTNET \
    --babbage-era \
    --change-address $(cat $CLIWALLET/$1.addr) \
    --tx-in-collateral $WALLETUTXO \
    --tx-in $WALLETUTXO1 \
    --tx-in $CONEUTXO \
    --spending-tx-in-reference $WALLETUTXO \
    --spending-plutus-script-v2 \
    --spending-reference-tx-in-datum-file ../Data/unit.json \
    --spending-reference-tx-in-redeemer-file ../Data/unit.json \
    --tx-out $(cat $CLIWALLET/tpropwallet.addr)+11460290 \
    --tx-out-reference-script-file ../Data/validatorReferenceScript.plutus \
    --tx-out-datum-hash-value $(cat ../Data/unit.json) \
    --protocol-params-file ../Data/protocol.json \
    --out-file ../tx/tx.body 

cardano-cli transaction sign $TESTNET \
    --tx-body-file ../tx/tx.body \
    --signing-key-file $CLIWALLET/$1.skey \
    --out-file ../tx/tx.signed 

cardano-cli transaction submit $TESTNET \
    --tx-file ../tx/tx.signed 
