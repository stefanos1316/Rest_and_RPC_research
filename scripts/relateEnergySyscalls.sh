#!/bin/bash

# Retrieving command-line arguments
ENERGY_DIR_PATH=$1
SYS_CALLS_DIR_PATH=$2
OUTPUT_DIR=$3

# Loop the programming languages and IPCs
for i in `ls ${ENERGY_DIR_PATH}`; do
	for j in `ls ${ENERGY_DIR_PATH}/$i`; do 
		FILE_NAME=$(echo $i".txt")
		
		echo "=======================================>> $i $j and ${SYS_CALLS_DIR_PATH}/$i/$j/${FILE_NAME}}" 
		# Now get the time-stamps and the associated energy usage record
		mkdir -p ${OUTPUT_DIR}"/"$i"/"$j"/"
		TOTAL_SYSCALLS=0
		while read l; do
			#echo $l
			TS=$(echo $l | awk '{print $1}')
			EC=$(echo $l | awk '{print $2}')
			
			# Now grep time-stamps and all the system calls
			echo "TIME STAMP: ${TS}	 ENERGY CONSUMPTION: ${EC}  SYSCALL COUNT		SYSCALL NAME" >> ${OUTPUT_DIR}"/"$i"/"$j"/"${FILE_NAME}
			while read k; do 
				COUNT_TRACE=$(grep ${TS} ${SYS_CALLS_DIR_PATH}/$i/$j/${FILE_NAME} | grep $k | wc -l)
				echo "                                                      "${COUNT_TRACE}"       		"$k >> ${OUTPUT_DIR}"/"$i"/"$j"/"${FILE_NAME}
				TOTAL_SYSCALLS=$((TOTAL_SYSCALLS + COUNT_TRACE))
			done< <(grep ${TS} ${SYS_CALLS_DIR_PATH}/$i/$j/${FILE_NAME} | grep "(" | awk -F "(" '{print $1}' | awk '{print $NF}' | sort -k1,1 -u)

			echo "TOTAL NUMBER OF SYSTEM CALLS	${TOTAL_SYSCALLS}" >> ${OUTPUT_DIR}"/"$i"/"$j"/"${FILE_NAME}
			echo "==============================================================================================================" >> ${OUTPUT_DIR}"/"$i"/"$j"/"${FILE_NAME}

			TOTAL_SYSCALLS=0
		done< "${ENERGY_DIR_PATH}/$i/$j/${FILE_NAME}"
	done
done

echo "Youpiiiii, DONE!!!"

exit
