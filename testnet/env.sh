
# environment
export TESTNET='--testnet-magic 1'                                        # pre-production testnet
export CLIWALLET="/home/adrian/cardano/chain/testnet/wallets"             # path to your wallet files 

# Reference Input 
export CS_V2_REFIN='6164d6d7b50bc51f644976d810c16acb1703e095209810ae99eb3f73' # currency symbol you want to use 
export TN_V2_REFIN='v2token'                                                  # correspondig token name 

# Inline Datum
export AMOUNT=5000000 # amount later used as datum 

# Reference Script 
export CS_V2_REFSCR='76dcc82fa594e9365757b43a451c18dbd40f29a5ede29e01f3bada35'
export TN_V2_REFSCR='v2token'


# we need the hex representation, nothing to change 

cabal run Str-to-Tn $TN_V2_REFIN                                              
export TN_V2_REFIN_HEX=$(cat tn)
rm tn

cabal run Str-to-Tn $TN_V2_REFSCR 
export TN_V2_REFSCR_HEX=$(cat tn) 
rm tn

# make bash script executables
cd v2 
chmod +x balance.sh 
chmod +x cbalance.sh 
chmod +x createPlutusData.sh 

cd InlineDatum
chmod +x balance.sh 
chmod +x cbalance.sh 
chmod +x lockInlineDatum.sh 
chmod +x unlockInlineDatum.sh 

cd ../ReferenceScript 
chmod +x balance.sh 
chmod +x cbalance.sh 
chmod +x balanceToFile.sh 
chmod +x cbalanceToFile.sh 
chmod +x lockReferenceScript.sh 
chmod +x unlockReferenceScript.sh 

chmod +x lockRefScrOneTwo.sh 
chmod +x unlockRefScrTwo.sh 

cd ../ReferenceInput 
chmod +x balance.sh 
chmod +x cbalance.sh 
chmod +x lockReferenceInput.sh 
chmod +x unlockReferenceInput.sh 

cd ../..






