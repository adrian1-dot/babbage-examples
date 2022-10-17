# [CIP33](https://cips.cardano.org/cips/cip33/)

## What is a reference script?
A reference script is a script that exists at a particular transaction output. It can be used to witness, for example, a UTxO at the corresponding script address of said reference script. This is useful because the script does not have to be included in the transaction anymore, which significantly reduces the transaction size.

## how to use 

### reference script at wallet 

1. `./lockReferenceScript.sh yourWalletName` will lock 2 Ada at a validator and creates a reference script utxo with an attached datum hash at your own wallet.
   - you have to choose one utxo without tokens 
2. `./balanceToFile.sh yourWalletName` shows utxos at given wallet name, you will find one with a reference script attached
3. `./unlockReferenceScript.sh yourWalletName` unlock contract utxo and creates a reference script utxo at your own wallet.
   - first utxo only ada
   - second utxo the one with the datum hash  
   - third utxo is from the contract, same hash as second 
4. other commands
   - `./balance.sh yourWalletName` shows utxos at given wallet name 
   - `./cbalance.sh` shows utxos at contract
   - `./cbalanceToFile` shows contract utxos, you will not find one with a reference script attached  

### reference script at script 

1. `./lockRefScrOneTwo yourWalletName` will lock one token at validator one with an integer as datum hash and ~36 Ada at validator two with validator one as reference script attached and validator hash one as datum hash 
   - first utxo only ada with around 40 Ada 
   - second utxo your token defined in the env.sh file
2. `./cbalanceToFile.sh Two` shows utxos at validator two with validator one as script reference 
   - `./cbalanceToFiles.sh One` shows utxos at validator one without reference script but a token as value 
3. `./unlockRefScrTwo.sh yourWalletName` unlocks amount defined in validator one datum, locks the rest again at validator two (same datum and reference script)
   - first utxo form your wallet, just ada (used for fees and collateral) 
   - second utxo from validator one, should have the token 
   - third utxo from validator two (same hash as second) 
4. other commands 
   - `./lockRefScrTwo.sh yourWalletName` locks ~36 Ada at validator Two (without locking a new token)
   - `./lockRefScrTwoAgain.sh yourWalletName` consumes validator Two utxo and creates new output with more Ada (used to fund reference script utxo again)

**Note: token will be locked forever** 

## validator 

### [reference script at wallet](../../../src/V2/ReferenceScript.hs) 

Is valid if one output creates a reference script of the current validator. 

### [reference script at script](../../../src/V2/referenceScriptAtScript.hs) 
#### validator one 

Is valid if input and output has correct token and datum hash not changed. 

#### validator two 

Is valid if datum stays the same, reference script from validator one is created and validator input and output changed amount defined in datum validator one or output is more than input. 

