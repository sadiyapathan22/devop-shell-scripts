#!/bin/bash

<<disclaimer
This is just for infotainment purpose
disclaimer

#This is function definition
function is_loyal() {
read -p "$1 ne mud ke kise dekha : " bandi

if [[ $bandi == "daya bhabhi" ]];
then 
	echo "$1 is loyal"
else
	read -p "$1 ka pyar % " pyar
	if [[ $pyar -ge 100 ]];
	then
        	echo "$1 is loyal"	
	else
		echo "$1 is not loyal"
	fi
fi 
}

#This is function call
is_loyal "tom"


