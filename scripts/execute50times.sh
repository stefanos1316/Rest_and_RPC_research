#!/bin/bash

for i in `ls $1`; do
#for i in {0..50}; do
	#bash execute.sh -p ../tasks/ -n pi -a 195.251.251.23 -b sgeorgiou -d 195.251.251.25
	PATH_RE=$(echo "$1/$i/")
	echo ${PATH_RE}
	bash plotResults.sh -p ${PATH_RE}
	#sleep 30
done
