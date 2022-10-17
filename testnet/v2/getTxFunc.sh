
function getInputTx() {
	BALANCE_FILE=/tmp/walletBalances.txt
	rm -f $BALANCE_FILE
	if [ -z "$1" ]
	then
		read -p 'Wallet Name: ' SELECTED_WALLET_NAME
	else
		echo 'Wallet Name: ' $1
		SELECTED_WALLET_NAME=$1
	fi
        if [ -z "$2" ]
        then
	     ./balance.sh $SELECTED_WALLET_NAME > $BALANCE_FILE
        else
             ./$2/balance.sh $SELECTED_WALLET_NAME > $BALANCE_FILE
        fi
	SELECTED_WALLET_ADDR=$(cat $WALLET/$SELECTED_WALLET_NAME.addr)
	cat $BALANCE_FILE
	read -p 'TX row number: ' TMP
	TX_ROW_NUM="$(($TMP+2))"
	TX_ROW=$(sed "${TX_ROW_NUM}q;d" $BALANCE_FILE)
	SELECTED_UTXO="$(echo $TX_ROW | awk '{ print $1 }')#$(echo $TX_ROW | awk '{ print $2 }')"
	SELECTED_UTXO_LOVELACE=$(echo $TX_ROW | awk '{ print $3 }')
	SELECTED_UTXO_TOKENS=$(echo $TX_ROW | awk '{ print $6 }')
}

function getContractInputTx() {
	BALANCE_FILE=/tmp/contractBalances.txt
	rm -f $BALANCE_FILE
	if [ -z "$1" ]
	then
		read -p 'Contract Name: ' SELECTED_CONTRACT_NAME
	else
		echo 'Contract Name: ' $1
		SELECTED_CONTRACT_NAME=$1
	fi
        if [ -z "$2" ]
        then 
	      ./cbalance.sh $SELECTED_CONTRACT_NAME Data > $BALANCE_FILE
        else
              ./$2/cbalance.sh $SELECTED_CONTRACT_NAME .. > $BALANCE_FILE
        fi
	SELECTED_CONTRACT_ADDR=$(cat $SELECTED_CONTRACT_NAME.addr)
	cat $BALANCE_FILE
	read -p 'TX row number: ' TMP
	TX_ROW_NUM="$(($TMP+2))"
	TX_ROW=$(sed "${TX_ROW_NUM}q;d" $BALANCE_FILE)
	SELECTED_UTXO_CONTRACT="$(echo $TX_ROW | awk '{ print $1 }')#$(echo $TX_ROW | awk '{ print $2 }')"
	SELECTED_UTXO_LOVELACE=$(echo $TX_ROW | awk '{ print $3 }')
	SELECTED_UTXO_TOKENS=$(echo $TX_ROW | awk '{ print $6 }')
}
