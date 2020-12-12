#!/bin/bash

dir_to_analyse=$1
declare -a languages=("csharp" "go" "java" "javascript" "php" "python" "ruby")
declare -a ipcs=("grpc" "rpc" "rest")


for i in "${languages[@]}"; do
  for j in "${ipcs[@]}"; do
    grep real "$dir_to_analyse"/*/performance_client/"$i"/"$j"/"$i".txt | awk -F'0m' '{print $2}' | awk -F'.' '{print $1}' >> measurements/time/"$i"_"$j".txt
  done
done