#!/bin/bash

for j in `ls $1`
do
	for k in `ls $1/$j`
	do
		for l in `ls $1/$j/$k`
		do
			FILE_PATH=$(echo "$1/$j/$k/$l")
			NEW_FILE_PATH=$(echo "$1/$j/$k/summary.txt")
			TOTAL=0

			echo "PERCENTAGE	SYSCALL			TIME" >> ${NEW_FILE_PATH}

			# Get total time spend
			while read i 
			do
				TIME=$(cat ${FILE_PATH} | grep $i | awk '{print $NF}'| grep "<0.*>$" | tr -d "<>" | paste -sd+ | bc)
				TIME=$(echo 0${TIME})
				TOTAL=$(bc <<<"$TOTAL+$TIME")
			done < <(cat ${FILE_PATH} | grep "(" | awk -F "(" '{print $1}' | sort -k1,1 -u)

			# Print table with results
			while read i 
			do
				TIME=$(cat ${FILE_PATH} | grep $i | awk '{print $NF}'| grep "<0.*>$" | tr -d "<>" | paste -sd+ | bc)
				TIME=$(echo 0${TIME})
	
				#Get percentage
				ARITHMITIS=$(bc <<< "100*${TIME}")
				PERCENTAGE=$(echo "scale=2; ((${ARITHMITIS} / ${TOTAL}))" | bc)
				echo "${PERCENTAGE}		$i			${TIME}" >> ${NEW_FILE_PATH}
			done < <(cat ${FILE_PATH} | grep "(" | awk -F "(" '{print $1}' | sort -k1,1 -u)
		done
	done
done
