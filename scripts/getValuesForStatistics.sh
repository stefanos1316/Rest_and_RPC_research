#!/bin/bash

# The $1 can be a directory where all the execution results are located
# such as experinemtn_***_/ where the graph_data directory is found to perform our analysis

# The $2 is to which filename to write the data

results=""
languages="csharp	go	java	javascript	php	python	ruby"
ipc="grpc rest rpc"
files=$2

if [ ${#files[@]} -gt 0 ]; then
   	echo "File already exist..."
	echo Deleting
	rm -rf ${files}/*
fi

for scenario in ${ipc}; do
	pathToData=$(echo $2/${scenario}.txt)
	echo ${languages}  >> ${pathToData}
	for i in `ls $1`; do
		if [ ! -d $1/$i/graph_data ]; then
			bash plotResults.sh -p $1/$i
		fi

		for j in `ls $1/$i`; do
			if [ "$j" == "graph_data" ]; then
				for energy in ${languages}; do
					tmp=""
					tmp=$(grep -w ${energy} $1/${i}/${j}/energy_server.txt | grep -w ${scenario} | awk -F":" '{print $NF}')

					if [ "${tmp}" == "" ]; then
						tmp='0'
					fi
					results=$(echo "${results}	${tmp}")
				done
				echo ${results} >> ${pathToData} 
			
				echo $i"  "${results}
				results=""
			fi
		done
	done
done

echo
echo "Obtained values from $(ls $1 | wc -l) executions..."
echo "Calculating average values..."



exit
