#!/bin/bash

INSTANCES=50
TOTAL=0
TOTAL_GRPC_GO=0
TOTAL_RPC_GO=0
TOTAL_REST_GO=0
TOTAL_GRPC_JAVA=0
TOTAL_JAX_JAVA=0
TOTAL_REST_JAVA=0
TOTAL_GRPC_JS=0
TOTAL_RPC_JS=0
TOTAL_REST_JS=0
TOTAL_GRPC_PY=0
TOTAL_RPC_PY=0
TOTAL_REST_PY=0

echo "[Client] Energy Measurements..."

		for i in `ls $1`; do
			PATH_RE=$(echo "$1/$i/graph_data/energy_client.txt")
			VALUE_GRPC_GO=$(cat ${PATH_RE} | grep "grpc" | grep "go" | awk -F ":" '{print $4}')
			echo "${PATH_RE} -> ${VALUE_GRPC_GO}" >> log.txt
			TOTAL_GRPC_GO=$(echo ${TOTAL_GRPC_GO} + ${VALUE_GRPC_GO} | bc)

			VALUE_RPC_GO=$(cat ${PATH_RE} | grep ":rpc" | grep "go" | awk -F ":" '{print $4}')
			echo "${PATH_RE} -> ${VALUE_RPC_GO}" >> log.txt
			TOTAL_RPC_GO=$(echo ${TOTAL_RPC_GO} + ${VALUE_RPC_GO} | bc)
			
			VALUE_REST_GO=$(cat ${PATH_RE} | grep "rest" | grep "go" | awk -F ":" '{print $4}')
			echo "${PATH_RE} -> ${VALUE_REST_GO}" >> log.txt
			TOTAL_REST_GO=$(echo ${TOTAL_REST_GO} + ${VALUE_REST_GO} | bc)


			# JAVA
			VALUE_GRPC_JAVA=$(cat ${PATH_RE} | grep "grpc" | grep "java," | awk -F ":" '{print $4}')
			echo "${PATH_RE} -> ${VALUE_GRPC_JAVA}" >> log.txt
			TOTAL_GRPC_JAVA=$(echo ${TOTAL_GRPC_JAVA} + ${VALUE_GRPC_JAVA} | bc)

			VALUE_REST_JAVA=$(cat ${PATH_RE} | grep "rest" | grep "java," | awk -F ":" '{print $4}')
			echo "${PATH_RE} -> ${VALUE_REST_JAVA}" >> log.txt
			TOTAL_REST_JAVA=$(echo ${TOTAL_REST_JAVA} + ${VALUE_REST_JAVA} | bc)
			
			VALUE_JAX_JAVA=$(cat ${PATH_RE} | grep "jax_ws_rpc" | grep "java," | awk -F ":" '{print $4}')
			echo "${PATH_RE} -> ${VALUE_JAX_JAVA}" >> log.txt
			TOTAL_JAX_JAVA=$(echo ${TOTAL_JAX_JAVA} + ${VALUE_JAX_JAVA} | bc)
			
			
			# JS
			VALUE_GRPC_JS=$(cat ${PATH_RE} | grep "grpc" | grep "javascript" | awk -F ":" '{print $4}')
			echo "${PATH_RE} -> ${VALUE_GRPC_JS}" >> log.txt
			TOTAL_GRPC_JS=$(echo ${TOTAL_GRPC_JS} + ${VALUE_GRPC_JS} | bc)

			VALUE_REST_JS=$(cat ${PATH_RE} | grep "rest" | grep "javascript" | awk -F ":" '{print $4}')
			echo "${PATH_RE} -> ${VALUE_REST_JS}" >> log.txt
			TOTAL_REST_JS=$(echo ${TOTAL_REST_JS} + ${VALUE_REST_JS} | bc)
			
			VALUE_RPC_JS=$(cat ${PATH_RE} | grep ":rpc" | grep "javascript" | awk -F ":" '{print $4}')
			echo "${PATH_RE} -> ${VALUE_RPC_JS}" >> log.txt
			TOTAL_RPC_JS=$(echo ${TOTAL_RPC_JS} + ${VALUE_RPC_JS} | bc)


			# PY
			VALUE_GRPC_PY=$(cat ${PATH_RE} | grep "grpc" | grep "python" | awk -F ":" '{print $4}')
			echo "${PATH_RE} -> ${VALUE_GRPC_PY}" >> log.txt
			TOTAL_GRPC_PY=$(echo ${TOTAL_GRPC_PY} + ${VALUE_GRPC_PY} | bc)

			VALUE_REST_PY=$(cat ${PATH_RE} | grep "rest" | grep "python" | awk -F ":" '{print $4}')
			echo "${PATH_RE} -> ${VALUE_REST_PY}" >> log.txt
			TOTAL_REST_PY=$(echo ${TOTAL_REST_PY} + ${VALUE_REST_PY} | bc)
			
			VALUE_RPC_PY=$(cat ${PATH_RE} | grep ":rpc" | grep "python" | awk -F ":" '{print $4}')
			echo "${PATH_RE} -> ${VALUE_RPC_PY}" >> log.txt
			TOTAL_RPC_PY=$(echo ${TOTAL_RPC_PY} + ${VALUE_RPC_PY} | bc)
	
		done
			echo "Energy Consumption..."

			AVERAGE=$(echo ${TOTAL_GRPC_GO} / ${INSTANCES} | bc -l)
			echo "Average EC of Go for gRPC for 50 records is ${AVERAGE}"
			AVERAGE=$(echo ${TOTAL_RPC_GO} / ${INSTANCES} | bc -l)
			echo "Average EC of Go for RPC for 50 records is ${AVERAGE}"
			AVERAGE=$(echo ${TOTAL_REST_GO} / ${INSTANCES} | bc -l)
			echo "Average EC of Go for REST for 50 records is ${AVERAGE}"

			AVERAGE=$(echo ${TOTAL_GRPC_JAVA} / ${INSTANCES} | bc -l)
			echo "Average EC of Java for gRPC for 50 records is ${AVERAGE}"
			AVERAGE=$(echo ${TOTAL_JAX_JAVA} / ${INSTANCES} | bc -l)
			echo "Average EC of Java for Jax WS RPC for 50 records is ${AVERAGE}"
			AVERAGE=$(echo ${TOTAL_REST_JAVA} / ${INSTANCES} | bc -l)
			echo "Average EC of JAVA for REST for 50 records is ${AVERAGE}"

			AVERAGE=$(echo ${TOTAL_GRPC_JS} / ${INSTANCES} | bc -l)
			echo "Average EC of JS for gRPC for 50 records is ${AVERAGE}"
			AVERAGE=$(echo ${TOTAL_REST_JS} / ${INSTANCES} | bc -l)
			echo "Average EC of JS for REST for 50 records is ${AVERAGE}"
			AVERAGE=$(echo ${TOTAL_RPC_JS} / ${INSTANCES} | bc -l)
			echo "Average EC of JS for RPC for 50 records is ${AVERAGE}"

			AVERAGE=$(echo ${TOTAL_GRPC_PY} / ${INSTANCES} | bc -l)
			echo "Average EC of PY for gRPC for 50 records is ${AVERAGE}"
			AVERAGE=$(echo ${TOTAL_REST_PY} / ${INSTANCES} | bc -l)
			echo "Average EC of PY for REST for 50 records is ${AVERAGE}"
			AVERAGE=$(echo ${TOTAL_RPC_PY} / ${INSTANCES} | bc -l)
			echo "Average EC of PY for RPC for 50 records is ${AVERAGE}"



LANGUAGES="go java, javascript python"
PROTOCOLS="rest :rpc grpc jax_ws_rpc"

LANGUAGES_ARRAY=($LANGUAGES)
PROTOCOLS_ARRAY=($PROTOCOLS)

AVERAGE=0
TOTAL=0

echo 
echo "[Client] Performance measurements..."

for i in "${PROTOCOLS_ARRAY[@]}"; do 
	for j in "${LANGUAGES_ARRAY[@]}"; do 
		for k in `ls $1`; do 
			VALUE=0
			PATH_DATA=$(echo "$1/$k/graph_data/performance_client.txt")
	
			if [ "$i" = "jax_ws_rpc" -a "$j" != "java," ]; then
				break
			else
				VALUE=$(cat ${PATH_DATA} | grep "$i" | grep "$j" | awk -F ":" '{print $4}')
				
				if [ -z "${VALUE}" ]; then
					break
				fi
			fi


			TOTAL=$((TOTAL + VALUE))
		done
		AVERAGE=$((TOTAL / INSTANCES))
		echo "Average Time of $j for $i is ${AVERAGE}"
		TOTAL=0
	done
done

TOTAL=0

echo 
echo "[Server] Performance measurements..."

for i in "${PROTOCOLS_ARRAY[@]}"; do 
	for j in "${LANGUAGES_ARRAY[@]}"; do 
		for k in `ls $1`; do 
			VALUE=0
			PATH_DATA=$(echo "$1/$k/graph_data/performance_server.txt")
	
			if [ "$i" = "jax_ws_rpc" -a "$j" != "java," ]; then
				break
			else
				VALUE=$(cat ${PATH_DATA} | grep "$i" | grep "$j" | awk -F ":" '{print $4}')
				
				if [ -z "${VALUE}" ]; then
					break
				fi
			fi


			TOTAL=$((TOTAL + VALUE))
		done
		AVERAGE=$((TOTAL / INSTANCES))
		echo "Average Time of $j for $i is ${AVERAGE}"
		TOTAL=0
	done
done

TOTAL=0

echo 
echo "[Server] Energy measurements..."

for i in "${PROTOCOLS_ARRAY[@]}"; do 
	for j in "${LANGUAGES_ARRAY[@]}"; do 
		for k in `ls $1`; do 
			VALUE=0
			PATH_DATA=$(echo "$1/$k/graph_data/energy_server.txt")
	
			if [ "$i" = "jax_ws_rpc" -a "$j" != "java," ]; then
				break
			else
				VALUE=$(cat ${PATH_DATA} | grep "$i" | grep "$j" | awk -F ":" '{print $4}')
				
				if [ -z "${VALUE}" ]; then
					break
				fi
			fi


			TOTAL=$(echo ${TOTAL} + ${VALUE} | bc)
		done
		AVERAGE=$( echo ${TOTAL} / ${INSTANCES} | bc -l)
		echo "Average Time of $j for $i is ${AVERAGE}"
		TOTAL=0
	done
done

exit
