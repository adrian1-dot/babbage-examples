# [CIP31](https://cips.cardano.org/cips/cip31/)

## What is a read only reference input
In the case where we are not using a reference input to reference another transaction input (at a Plutus script address), we can specify a read only reference input that is simply exposed in the Plutus script context.

## how to use 

1. `./lockRferenceInput yourWalltName` locks 25 Ada at contract 
   - choose one utxo with only ada 
2. `./balance.sh yourWalletName` shows utxos at given wallet name save the transaction hash of your token utxo 
3. `./unlockReferenceInput.sh yourWalletName` will unlock all ada from contract utxo 
   - first utxo only ada 
   - second utxo the utxo with your token defined in the env.sh file used as reference utxo (not consumed)
   - third utxo just one from the contract 
4. use `./balance.sh` again and compare the transaction hash, it hasn't changed 
5. other commands 
   -`./cbalance` shows balance at contract

## [validator](/../../../V2/ReferenceInput.hs) 
Is valid if the reference input has the token, invalid if the token is a normal input.
