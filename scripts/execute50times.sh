#!/bin/bash

for i in {0..50}; do
	bash execute.sh -p ../tasks/ -n pi -a 195.251.251.23 -b sgeorgiou -d 195.251.251.25
	sleep 30
done
