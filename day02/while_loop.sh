#!/bin/bash

num=1

while [[ $num -le 5 ]]
do
	if (( $num%2==0 ));
	then
		echo "$num is even"
		
	fi
	num=$((num+1))
done
