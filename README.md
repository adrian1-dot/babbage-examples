
# babbage examples 
Project to outline the functionalities of the new babbage era consisting of validators and bash scripts. 

## Prerequisite

* [The Plutus Application Framework](https://github.com/input-output-hk/plutus-apps)
* [cardano-node](https://github.com/input-output-hk/cardano-node)
* at least one funded [wallet](https://developers.cardano.org/docs/stake-pool-course/handbook/keys-addresses/)
* one token in the wallet 

## build validators and necessary data to build transactions

* start your cardano-node (pre-production testnet)
* open new terminal and enter your plutus-apps nix-shell with tag 87b647b05902a7cef37340fda9acb175f962f354
* go to the root folder of this repository and run `cabal update` followed by `cabal build`
* go into /testnet/env.sh and change the values to your own 
    - TESTNET can be left as is for pre-production testnet 
    - CLIWALLET is the path where you store your wallet key files (.addr, .vkey, .skey)
    - CS_V2_REFIN currency symbol of a token in your wallet 
    - TN_V2_REFIN corresponding token name 
    - AMOUNT can be left as 5 ada, later used as datum 
    - CS_V2_REFSCR currency symbol of a token in your wallet (other than CS_V2_REFIN)
    - TN_V2_REFSCR corresponding token name
* make it an executable `chmod +x env.sh`
* run ` . env.sh` to mount the variables for this shell 
* go into the /v2 folder and run `./createPlutusData.sh`
    - creates validators, datums, redeemers in /Data folder  
* now you can run the examples provided in the subdirectories
