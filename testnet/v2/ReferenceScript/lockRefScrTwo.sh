source ../getTxFunc.sh

getInputTx $1 ..
WALLETUTXO=${SELECTED_UTXO}

getContractInputTx ReferenceScriptOne ..
CON_ONE_UTXO=${SELECTED_UTXO_CONTRACT}

cardano-cli transaction build $TESTNET \
    --babbage-era \
    --change-address $(cat $CLIWALLET/$1.addr) \
    --tx-in-collateral $WALLETUTXO \
    --tx-in $WALLETUTXO \
    --tx-in $CON_ONE_UTXO \
    --tx-in-script-file ../Data/validatorReferenceScriptOne.plutus \
    --tx-in-datum-file ../Data/integer.json \
    --tx-in-redeemer-file ../Data/unit.json \
    --tx-out $(cat ../Data/validatorReferenceScriptOne.addr)+2000000"+1 ${CS_V2_REFSCR}.${TN_V2_REFSCR_HEX}" \
    --tx-out-datum-hash "$(cat ../Data/dhashInteger)" \
    --tx-out $(cat ../Data/validatorReferenceScriptTwo.addr)+35925610 \
    --tx-out-reference-script-file ../Data/validatorReferenceScriptOne.plutus \
    --tx-out-datum-hash "$(cat ../Data/dhashValHash)" \
    --protocol-params-file ../Data/protocol.json \
    --out-file ../tx/tx.body 

cardano-cli transaction sign $TESTNET \
    --tx-body-file ../tx/tx.body \
    --signing-key-file $CLIWALLET/$1.skey \
    --out-file ../tx/tx.signed 

cardano-cli transaction submit $TESTNET \
    --tx-file ../tx/tx.signed 
