#!/bin/bash

#for i in `ls $1`; do
for i in {0..50}; do
	bash execute.sh -p ../tasks/ -n pi -a 195.251.251.23 -b sgeorgiou -d 195.251.251.25
	#PATH=$(echo "$1/$i/")
	#echo ${PATH}
	#bash plotResults.sh -p ${PATH}
	sleep 30
done
