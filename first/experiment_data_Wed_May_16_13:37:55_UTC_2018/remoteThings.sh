#!/bin/bash

for i in `ls $1`; do 
	for j in `ls $1/$i`; do
		FILE=$(echo "$i.txt")
		cat $1/$i/$j/${FILE} | sed '/^strace/ d' > tmp
		cat tmp > $1/$i/$j/${FILE}
	done
done
