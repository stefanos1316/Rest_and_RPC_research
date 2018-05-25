#!/bin/bash


LANGUAGES="go java, javascript python"
PROTOCOLS="rest :rpc grpc jax_ws_rpc"

LANGUAGES_ARRAY=($LANGUAGES)
PROTOCOLS_ARRAY=($PROTOCOLS)
STRING=""

echo
echo "[Client] Performance measurements..."

rm ../statistics/client_performance_values.txt
rm ../statistics/client_energy_values.txt
for i in "${PROTOCOLS_ARRAY[@]}"; do
        for j in "${LANGUAGES_ARRAY[@]}"; do
                for k in `ls $1`; do
                        VALUE=""
                        PATH_DATA=$(echo "$1/$k/graph_data/performance_client.txt")


                                VALUE=$(cat ${PATH_DATA} | grep "$i" | grep "$j" | awk -F ":" '{print $4}')

                                if [ -z "${VALUE}" ]; then
                                        break
				fi
			STRING=${STRING}","${VALUE}			
		done
 		echo "Results for $j and $i is ${STRING}" >> ../statistics/client_performance_values.txt
		STRING=""
 	done
done

echo
echo "[Client] Energy measurements..."

for i in "${PROTOCOLS_ARRAY[@]}"; do
        for j in "${LANGUAGES_ARRAY[@]}"; do
                for k in `ls $1`; do
                        VALUE=""
                        PATH_DATA=$(echo "$1/$k/graph_data/energy_client.txt")


                                VALUE=$(cat ${PATH_DATA} | grep "$i" | grep "$j" | awk -F ":" '{print $4}')

                                if [ -z "${VALUE}" ]; then
                                        break
				fi
			STRING=${STRING}","${VALUE}			
		done
 		echo "Results for $j and $i is ${STRING}" >> ../statistics/client_energy_values.txt
		STRING=""
 	done
done


