# [CIP32](https://cips.cardano.org/cips/cip32/)

## What is an inline datum?
An inline datum, is a datum that exists at a transaction output. We no longer have to include a datum within our transaction for our plutus spending scripts. Instead we can specify the transaction output where our datum exists to be used in conjunction with our Plutus spending script. This reduces the overall size of our transaction.

## how to use 

1. `./lockInlineDatum yourWalletName` locks 22 ada at the contract with an inline datum attached 
   - choose one utxo with only ada 
2. `./cbalance.sh` shows utxos at the contract and the datum in readable form 
3. `./unlockInlineDatum yourWalletName` unlocks the amount defined in the datum and locks the rest again with the same datum 
   - first utxo only ada 
   - second utxo just one from the contract 
   - can be repeated as long as there is an utxo with more than 2 Ada at the contract

*Note: 2 ada will remain forever at the contract*

## [validator](../../../src/V2/InlineDatum.hs) 
Is valid if the datum integer is the difference between contract input and output and the datum is same. 
