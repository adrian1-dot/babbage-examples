cardano-cli query utxo $TESTNET --address $(cat ../Data/validatorReferenceScript$1.addr) --out-file validatorReferenceScript$1.utxos

cat validatorReferenceScript$1.utxos 
