cardano-cli query utxo $TESTNET --address $(cat $CLIWALLET/$1.addr) --out-file $1.utxos

cat $1.utxos
