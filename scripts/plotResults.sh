#!/bin/bash

# This script's responsibility is of creating text files from the collect results in a graph plottable form

if [ "$1" == "--help" ]; then
	echo ""
	echo "Usage of script.createPlottableData"
	echo "==================================="
	echo ""
	echo "-p | --relatedPath	Provide the related path where all the Experimental Data are located."
	echo ""
	exit
fi


# Globals
DIRECTORY_PATH=""


OPTIONS=`getopt -o -p: --long --relatedPath -n 'plotResults.sh' -- "$@"`
eval set -- "$OPTIONS"
while true; do
	case "$1" in 
		-p|--relatedPath) 
			case $2 in 
				*/*) DIRECTORY_PATH=$2 ; shift 2 ;;
				*) >&2 echo "[Error] Directory path is required!" ; shift 2 ;;
			esac ;;
		--) shift ; break ;;
		*) >&2 echo "Wrong command line argument, please try again." ; exit 1 ;;
	esac
done


PATH_TO_REPORT=${DIRECTORY_PATH}
#for z in `ls ${PATH_TO_REPORT}`; do 

	#DIRECTORY_PATH=$(echo "${PATH_TO_REPORT}/$z")

# Create directory where all the adjusted results will be stored
if [ ! -d ${DIRECTORY_PATH}/graph_data ]; then
	mkdir -p ${DIRECTORY_PATH}/graph_data
else
	rm -rf ${DIRECTORY_PATH}/graph_data/*
fi

# At this part we are going to interate through the directories that offers data for energy and performance for the server and client instance.
for i in `ls ${DIRECTORY_PATH}`; do 
	echo "Directory name is $i"
	for j in `ls ${DIRECTORY_PATH}/$i`; do
		echo "Programming language sequence is $j"
		for k in `ls ${DIRECTORY_PATH}/$i/$j`; do
			echo "Protocol is $k"
		
			if [ "$k" == "grpc" -o "$k" == "rest" -o "$k" == "rpc" -o "$k" == "jax_ws_rpc" ]; then

			# Now we are going to read the files, and we are going to act respectivily
			FILE=$(echo "$j.txt")
			case $i in 
				energy_server) 
					TOTAL_CONSUMPTION=0

					while IFS= read -r var; do 
						TOTAL_CONSUMPTION=$(echo ${TOTAL_CONSUMPTION} + $var | bc)
					done < "${DIRECTORY_PATH}/$i/$j/$k/${FILE}"
					echo "Language:$k,Protocol:$j,Energy:${TOTAL_CONSUMPTION}" >> ${DIRECTORY_PATH}/graph_data/energy_server.txt
					;;
				energy_client) 
					TOTAL_CONSUMPTION=0

					while IFS= read -r var; do 
						TOTAL_CONSUMPTION=$(echo ${TOTAL_CONSUMPTION} + $var | bc)
					done < "${DIRECTORY_PATH}/$i/$j/$k/${FILE}"
					echo "Language:$k,Protocol:$j,Energy:${TOTAL_CONSUMPTION}" >> ${DIRECTORY_PATH}/graph_data/energy_client.txt
					;;
				performance_server)
					MINUTES=0
					SECONDS=0
					SYS_MINUTES=0
					SYS_SECONDS=0
					getReal=""
					getReal=$(cat ${DIRECTORY_PATH}/$i/$j/$k/${FILE}| grep "real" )
					

					if [ "$getReal" != "" ]; then
						MINUTES=$( echo $getReal |awk '{print $2}' | awk -F "." '{print $1}' | awk -F "m" '{print $1}')
						SECONDS=$( echo $getReal | awk '{print $2}' | awk -F "." '{print $1}' | awk -F "m" '{print $2}')
					fi
					
					getSys=""
					getSys=$(cat ${DIRECTORY_PATH}/$i/$j/$k/${FILE}| grep "sys")
					
					if [ "$getSys" != "" ]; then 
						SYS_MINUTES=$( echo $getSys | awk '{print $2}' | awk -F "." '{print $1}' | awk -F "m" '{print $1}')
						SYS_SECONDS=$( echo $getSys | awk '{print $2}' | awk -F "." '{print $1}' | awk -F "m" '{print $2}')
					fi
			
					if [ ${SECONDS} -ne 0 -o ${MINUTES} -ne 0 ]; then
						
						MINUTES_TO_SECONDS=$((MINUTES * 60))
						SECONDS=$((SECONDS + MINUTES_TO_SECONDS))
					fi

					DIFFERENCE=0
					if [ ${SYS_SECONDS} -ne 0 -o ${SYS_MINUTES} -ne 0 ]; then
						SYS_MINUTES_TO_SECONDS=$((SYS_MINUTES * 60))
						SYS_SECONDS=$((SYS_SECONDS + SYS_MINUTES_TO_SECONDS))
					
						DIFFERENCE=$((SECONDS / SYS_SECONDS))
					fi

	
					echo "Language:$j,Protocol:$k,Time:${SECONDS}" >> ${DIRECTORY_PATH}/graph_data/performance_server.txt
					echo "Language:$j,Protocol:$k,Time:${SYS_SECONDS},Difference:${DIFFERENCE}" >> ${DIRECTORY_PATH}/graph_data/kernel_server.txt
					;;
				performance_client)
					MINUTES=0
					SECONDS=0
					SYS_MINUTES=0
					SYS_SECONDS=0
					getReal=""
					getReal=$(cat ${DIRECTORY_PATH}/$i/$j/$k/${FILE}| grep "real" )
					

					if [ "$getReal" != "" ]; then
						MINUTES=$( echo $getReal |awk '{print $2}' | awk -F "." '{print $1}' | awk -F "m" '{print $1}')
						SECONDS=$( echo $getReal | awk '{print $2}' | awk -F "." '{print $1}' | awk -F "m" '{print $2}')
					fi
					
					getSys=""
					getSys=$(cat ${DIRECTORY_PATH}/$i/$j/$k/${FILE}| grep "sys")
					
					if [ "$getSys" != "" ]; then 
						SYS_MINUTES=$( echo $getSys | awk '{print $2}' | awk -F "." '{print $1}' | awk -F "m" '{print $1}')
						SYS_SECONDS=$( echo $getSys | awk '{print $2}' | awk -F "." '{print $1}' | awk -F "m" '{print $2}')
					fi
			
					if [ ${SECONDS} -ne 0 -o ${MINUTES} -ne 0 ]; then
						
						MINUTES_TO_SECONDS=$((MINUTES * 60))
						SECONDS=$((SECONDS + MINUTES_TO_SECONDS))
					fi

					DIFFERENCE=0
					if [ ${SYS_SECONDS} -ne 0 -o ${SYS_MINUTES} -ne 0 ]; then
						SYS_MINUTES_TO_SECONDS=$((SYS_MINUTES * 60))
						SYS_SECONDS=$((SYS_SECONDS + SYS_MINUTES_TO_SECONDS))
					
						DIFFERENCE=$((SECONDS / SYS_SECONDS))
					fi
					echo "Language:$j,Protocol:$k,Time:${SECONDS}" >> ${DIRECTORY_PATH}/graph_data/performance_client.txt
					echo "Language:$j,Protocol:$k,Time:${SYS_SECONDS},Difference:${DIFFERENCE}" >> ${DIRECTORY_PATH}/graph_data/kernel_client.txt
					;;
			esac
		fi
		done
	done
done


echo Done, exiting...
exit 1

