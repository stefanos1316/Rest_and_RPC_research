#!/bin/bash

# The $1 can be a directory where all the execution results are located
# such as experinemtn_***_/ where the graph_data directory is found to perform our analysis

# The $2 is to which filename to write the data

pathToData=$2
results=""
languages="csharp	go	java	javascript	php	python	ruby"
ipc="grpc rest rpc"

if [ -f ${pathToData} ]; then
   	echo "File already exist..."
	echo Deleting
	rm ${pathToData}
fi

echo ${languages}  >> ${pathToData}

for i in `ls $1`; do
	bash plotResults.sh -p $1/$i
	for j in `ls $1/$i`; do
		if [ "$j" == "graph_data" ]; then
			for scenario in ${ipc}; do
				for energy in ${languages}; do
					tmp=""
					tmp=$(grep -w ${energy} $1/${i}/${j}/energy_server.txt | grep -w ${scenario} | awk -F":" '{print $NF}')

					if [ "${tmp}" == "" ]; then
						tmp='0'
					fi
					results=$(echo "${results}	${tmp}")
				done
				echo ${results} >> ${pathToData} 
				results=""
			done
		fi
	done
done

exit
