#!/bin/bash

#for i in `ls $1`; do
for i in {0..49}; do
	bash execute_platform.sh -p ../tasks/ -n pi -a 195.251.251.23 -b sgeorgiou -d 195.251.251.22
	#PATH_RE=$(echo "$1/$i/")
	#echo ${PATH_RE}
	#bash plotResults.sh -p ${PATH_RE}
	#sleep 30
	#if [ `expr $i % 10` = 0 ]; then
#		echo "Done with $i repeditions" | mail -s "[Rest and RPC] Execution Notifications" sgeorgiou@aueb.gr
#	fi
done
