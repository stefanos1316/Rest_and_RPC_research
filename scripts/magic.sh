#!/bin/bash
TOTAL=0
echo "SYSCALL			TIME		PERCENTAGE"
while read i 
do
	TIME=$(cat $1 | grep $i | awk '{print $NF}'| grep "<0.*>$" | tr -d "<>" | paste -sd+ | bc)
	TIME=$(echo 0${TIME})
	TOTAL=$(bc <<<"$TOTAL+$TIME")
	#TOTAL=$(echo "$TOTAL + $TIME" | bc)
	echo "$i			${TIME}"
done < <(cat $1 | grep "(" | awk -F "(" '{print $1}' | sort -k1,1 -u)

echo ${TOTAL}
