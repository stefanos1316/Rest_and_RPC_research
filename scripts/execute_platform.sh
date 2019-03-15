#!/bin/bash

############################################################################################################################################
#					ALL FUNCTIONS HERE		
############################################################################################################################################

# Check via if the give host is running
function checkRemoteHostSSH {
	#Check if nmap exist on the host, otherwise recommend to install it
	
	echo "Checking instance $1@$2"

	if nmap --version | grep "command not found"; then
		echo "Nmap not found in local host."
		echo "Please install nmap before procceding any further."
		echo "Exiting..."
		exit
	fi

	if nmap -p22 $2 -Pn -oG - | grep -q 22/open; then 
    		echo "Remote Host's $2 SSH is active"
		echo "Procceding normally..."
		echo " "
	else 
    		echo "Remote Host's $2 SSH is not running..."
		echo "Please make sure that is active and try again."
		exit
	fi
}

# Function for help me
function helpMe {

	echo
	echo "-p | --directoryPath [argument]			Is the path where all the test subjects are located."
	echo "-n | --remoteHostNameEM [device name]		The name of the host that will act as an energy monitoring instance."
	echo "-a | --remoteHostAddressEM [device IP]		The IP address of the host that acts as an energy monitoring."
	echo "-b | --remoteHostNameClient [devcice name]	The name of the host that will act as a client instance."
	echo "-d | --remoteHostAddressClient [device IP]	The IP address of the host that acts as a client."
	echo "-t | --straces					Option to collect system calls"
	echo "-r | --resource-usage				Option to print resouce usage informatin such as maximum resident size, context switching, and so on"
	echo "-e | --energy-consumption				Option to obtain energy and run-time performance measurements"
	echo "-h | --help					Print the help me message and exit."
	echo

	exit
}

############################################################################################################################################

# Script for runnig the experiment to collect results for Rest and RPC

# Command line arguments
DIRECTORY_PATH=""
REMOTE_HOST_NAME_EM=""
REMOTE_HOST_ADDRESS_EM=""
REMOTE_HOST_NAME_CLIENT=""
REMOTE_HOST_ADDRESS_CLIENT=""
TRACES_TYPE=""
TRACES_FLAG=false
FLAG=""
EXPERIMENT_TYPE=""
RESOURCE_USAGE_REMOTE=""
RESOURCE_USAGE_LOCAL=""
ENERGY_CONSUMPTION_REMOTE=""
ENERGY_CONSUMPION_LOCAL=""
PERFORMANCE_REMOTE=""
PERFORMANCE_LOCAL=""

OPTIONS=`getopt -o p:n:a:hb:d:t:re --long help,directoryPath:,remoteHostNameEM:,remoteHostNameClient:,remoteHostAddressEM:,remoteHostAddressClient:,straces:,resource-usage,energy-consumption -n 'execute.sh' -- "$@"`
eval set -- "$OPTIONS"
while true; do
	case "$1" in 
		-p|--directoryPath) 
			case $2 in 
				*/*) DIRECTORY_PATH=$2 ; shift 2 ;;
				*) >&2 echo "[Error] Directory path is required!" ; shift 2 ;;
			esac ;;
		-n|--remoteHostNameEM) 
			case $2 in 
				*[a-zA-Z0-9]*) REMOTE_HOST_NAME_EM=$2 ; shift 2 ;;
				*) >&2 echo "[Error] Host name is required!" ; shift 2 ;;
			esac ;;
		-a|--remoteHostAddressEM) 
			case $2 in 
				*\.*\.*\.*) REMOTE_HOST_ADDRESS_EM=$2 ; shift 2 ;;
				*) >&2 echo "[Error] IP address is required!" ; shift 2 ;;
			esac ;;
		-b|--remoteHostNameClient) 
			case $2 in 
				*[a-zA-Z0-9]*) REMOTE_HOST_NAME_CLIENT=$2 ; shift 2 ;;
				*) >&2 echo "[Error] Host name is required!" ; shift 2 ;;
			esac ;;
		-d|--remoteHostAddressClient) 
			case $2 in 
				*\.*\.*\.*) REMOTE_HOST_ADDRESS_CLIENT=$2 ; shift 2 ;;
				*) >&2 echo "[Error] IP address is required!" ; shift 2 ;;
			esac ;;
		-t|--straces)
			TRACES_FLAG=true
			case $2 in 
				network) TRACES_TYPE=$2 ; shift 2 ;;
				syscalls) TRACES_TYPE=$2 ; shift 2 ;;
				*) >&2 echo "[Error] Option not available, consider adding network or syscalls" ; shift 2 ;;
			esac ;;
		-r|--resource-usage)
			FLAG="/usr/bin/time -v" ; EXPERIMENT_TYPE="resource_usage" ; shift ;;
		-e|--energy-consumption)
			FLAG="time" ; EXPERIMENT_TYPE="energy_consumption"; shift ;;
		-h|--help) helpMe ; shift ;;
		--) shift ; break ;;
		*) >&2 echo "Wrong command line argument, please try again." ; exit 1 ;;
	esac
done

# Create parameters for the directory names
EnergyPerformanceLogDataDate=$(date -u | sed -e 's/ /_/g')
EnergyPerformanceLogDirName="experiment_data_"$EnergyPerformanceLogDataDate

#Before creating directories check if the remote host is acticvated and SSH is running
checkRemoteHostSSH ${REMOTE_HOST_NAME_EM} ${REMOTE_HOST_ADDRESS_EM}
checkRemoteHostSSH ${REMOTE_HOST_NAME_CLIENT} ${REMOTE_HOST_ADDRESS_CLIENT}

# Create REMOTEHOST is a single variable for server and em
REMOTE_HOST_EM=${REMOTE_HOST_NAME_EM}@${REMOTE_HOST_ADDRESS_EM}
REMOTE_HOST_CLIENT=${REMOTE_HOST_NAME_CLIENT}@${REMOTE_HOST_ADDRESS_CLIENT}

# Create directories to store results
#if [ "${EXPERIMENT_TYPE}" == "energy_consumption" ]; then
#	mkdir -p ../reports/$EnergyPerformanceLogDirName/energy_consumption
#	mkdir -p ../reports/$EnergyPerformanceLogDirName/performance_server
#	ssh ${REMOTE_HOST_EM} mkdir -p GitHub/Rest_RPC_EM/reports/$EnergyPerformanceLogDirName/energy_consumption
#	ssh ${REMOTE_HOST_CLIENT} mkdir -p GitHub/Rest_RPC_Client/reports/$EnergyPerformanceLogDirName/performance_client
#fi

#if [ "${EXPERIMENT_TYPE}" == "resource_usage" ]; then
#	mkdir -p ../reports/$EnergyPerformanceLogDirName/resource_usage_server
#	ssh ${REMOTE_HOST_EM} mkdir -p GitHub/Rest_RPC_EM/reports/$EnergyPerformanceLogDirName/resource_usage_client
#fi

# Now we will run the experiment and collect out data.
for i in `ls ${DIRECTORY_PATH}`
do
	# This $i has a programming language directory name and $j jas the name of the protocol
	for j in `ls ${DIRECTORY_PATH}/${i}` 
	do
		if [ "$j" = "grpc" -o "$j" = "rest" -o "$j" = "rpc" -o "$j" = "jax_ws_rpc" ]; then
			if [ "${EXPERIMENT_TYPE}" == "energy_consumption" ]; then
				ENERGY_CONSUMPTION_REMOTE="GitHub/Rest_RPC_EM/reports/$EnergyPerformanceLogDirName/energy_consumption/$i/$j"
				PERFORMANCE_REMOTE="GitHub/Rest_RPC_Client/reports/$EnergyPerformanceLogDirName/performance_remote/$i/$j"
				PERFORMANCE_LOCAL="../reports/$EnergyPerformanceLogDirName/performance_local/$i/$j"
				ssh ${REMOTE_HOST_EM} mkdir -p ${ENERGY_CONSUMPTION_REMOTE}
				ssh ${REMOTE_HOST_CLIENT} mkdir -p ${PERFORMANCE_REMOTE}
				mkdir -p ${PERFORMANCE_LOCAL}
			fi

			if [ "${EXPERIMENT_TYPE}" == "resource_usage" ]; then
				RESOURCE_USAGE_REMOTE="GitHub/Rest_RPC_Client/reports/$EnergyPerformanceLogDirName/resource_usage_remote/$i/$j"
				RESOURCE_USAGE_LOCAL="../reports/$EnergyPerformanceLogDirName/resource_usage_local/$i/$j"
				ssh ${REMOTE_HOST_CLIENT} mkdir -p ${RESOURCE_USAGE_REMOTE}
				mkdir -p ${RESOURCE_USAGE_LOCAL}
			fi
		fi


		for k in `ls ${DIRECTORY_PATH}/${i}/${j}`
		do
			# At this point we already reached the source code of a specific implemetation
			case "$i" in
				csharp)
					getServerPID=0
					getClientName=""

					if [ "$j" == "grpc" -a "$k" == "GreeterServer" ]; then
						echo "Executing $j from $i"

						# To obtain energy measurements
						if [ "${EXPERIMENT_TYPE}" == "energy_consumption" ]; then
                            ssh ${REMOTE_HOST_EM} touch ${ENERGY_CONSUMPTION_REMOTE}/csharp.txt
                            touch  ${PERFORMANCE_LOCAL}/csharp.txt
							(time dotnet run -f netcoreapp2.1 -p ${DIRECTORY_PATH}/$i/$j/GreeterServer) 2>> ${PERFORMANCE_LOCAL}/csharp.txt &
							getServerPID=$!

							while true; do
								STATUS=""
								STATUS=$(curl http://195.251.251.27:50051 2>&1 | grep Failed)
								if [ "$STATUS" == "" ]; then
									break
								fi
							done
						
                            # Run the wattsup in the background
                            ssh ${REMOTE_HOST_EM} "sh -c 'sudo ./GitHub/Rest_RPC_EM/watts-up/wattsup ttyUSB0 -s watts >> ${ENERGY_CONSUMPTION_REMOTE}/csharp.txt' &" &
                            sleep 2
							
							# Run grpc's Client
							ssh ${REMOTE_HOST_CLIENT} "bash -c '(time dotnet run -f netcoreapp2.1 -p GitHub/Rest_and_RPC_research/tasks/$i/$j/GreeterClient) 2>> ${PERFORMANCE_REMOTE}/csharp.txt'" &
							getClientName=$(echo "GreeterClient.dll")
							sleep 2
						fi

						if [ "${EXPERIMENT_TYPE}" == "resource_usage" ]; then
							touch ${RESOURCE_USAGE_LOCAL}/csharp.txt
							(${FLAG} dotnet run -f netcoreapp2.1 -p ${DIRECTORY_PATH}/$i/$j/GreeterServer) 2>> ${RESOURCE_USAGE_LOCAL}/csharp.txt &
							getServerPID=$!
							
							while true; do
								STATUS=""
								STATUS=$(curl http://195.251.251.27:50051 2>&1 | grep Failed)
								if [ "$STATUS" == "" ]; then
									break
								fi
							done
							
							# Run grpc's Client
							ssh ${REMOTE_HOST_CLIENT} "bash -c '(${FLAG} dotnet run -f netcoreapp2.1 -p GitHub/Rest_and_RPC_research/tasks/$i/$j/GreeterClient) 2>> ${RESOURCE_USAGE_REMOTE}/csharp.txt'" &
							getClientName=$(echo "GreeterClient.dll")
							sleep 2
						fi

				        
						#Check if remote client is still running
						while ssh ${REMOTE_HOST_CLIENT} ps aux | grep -i ${getClientName} > /dev/null; do
							sleep 1
						done
					
						# Once the client stopped running kill Server and WattsUp?Pro instances.
						ssh ${REMOTE_HOST_EM} sudo pkill wattsup
						echo "[Experiment terminated]"

						REMAINING=$(netstat -lntp 2>/dev/null | awk '{print $7}' | grep dotnet | awk -F "/" '{print $1}')
						kill -9 ${REMAINING}
						sleep 5
					elif [ "$j" == "rest" -a "$k" == "wwwroot" ]; then
						echo "Executing $j from $i"
                        	
						if [ "${EXPERIMENT_TYPE}" == "energy_consumption" ]; then	
							ssh ${REMOTE_HOST_EM} touch ${ENERGY_CONSUMPTION_REMOTE}/csharp.txt
                        	touch  ${PERFORMANCE_LOCAL}/csharp.txt
							(time dotnet ${DIRECTORY_PATH}/$i/$j/bin/Release/netcoreapp2.1/myWebAppp.dll  --urls=http://195.251.251.27:5001) 2>> ${PERFORMANCE_LOCAL}/csharp.txt &
							getServerPID=$!
								
							while true; do
								STATUS=""
								STATUS=$(curl -v --silent http://195.251.251.27:5001 2>&1 | grep Failed)
								if [ "$STATUS" == "" ]; then
									break
								fi
							done

                            ssh ${REMOTE_HOST_EM} "sh -c 'sudo ./GitHub/Rest_RPC_EM/watts-up/wattsup ttyUSB0 -s watts >> ${ENERGY_CONSUMPTION_REMOTE}/csharp.txt' &" &
                            sleep 2

							#Run rest's Client
							ssh ${REMOTE_HOST_CLIENT} "bash -c '(time mono GitHub/Rest_and_RPC_research/tasks/$i/$j/Client.exe) 2>> ${PERFORMANCE_REMOTE}/csharp.txt'" &
							getClientName=$(echo "Client.exe")
						fi

						if [ "${EXPERIMENT_TYPE}" == "resource_usage" ]; then
                        	touch  ${RESOURCE_USAGE_LOCAL}/csharp.txt
							(${FLAG} dotnet ${DIRECTORY_PATH}/$i/$j/bin/Release/netcoreapp2.1/myWebAppp.dll  --urls=http://195.251.251.27:5001) 2>> ${RESOURCE_USAGE_LOCAL}/csharp.txt &
							getServerPID=$!
								
							while true; do
								STATUS=""
								STATUS=$(curl -v --silent http://195.251.251.27:5001 2>&1 | grep Failed)
								if [ "$STATUS" == "" ]; then
									break
								fi
							done
							echo "I am here"
							#Run rest's Client
							ssh ${REMOTE_HOST_CLIENT} "bash -c '(${FLAG} mono GitHub/Rest_and_RPC_research/tasks/$i/$j/Client.exe) 2>> ${RESOURCE_USAGE_REMOTE}/csharp.txt'" &
							getClientName=$(echo "Client.exe")
						fi

						
						#Check if remote client is still running
						while ssh ${REMOTE_HOST_CLIENT} ps aux | grep -i ${getClientName} > /dev/null; do
							sleep 1
						done
					
						# Once the client stopped running kill Server and WattsUp?Pro instances.
						ssh ${REMOTE_HOST_EM} sudo pkill wattsup
						echo "[Experiment termindated]"

						REMAINING=$(netstat -lntp 2>/dev/null | awk '{print $7}' | grep dotnet | awk -F "/" '{print $1}')
						kill -9 ${REMAINING}
						sleep 5
					elif [ "$j" == "rpc" -a "$k" == "sample" ]; then
						echo "Executing $j from $i"
						
						if [ "${EXPERIMENT_TYPE}" == "energy_consumption" ]; then	
							ssh ${REMOTE_HOST_EM} touch ${ENERGY_CONSUMPTION_REMOTE}/csharp.txt
                        	touch  ${PERFORMANCE_LOCAL}/csharp.txt
							(time dotnet run bin/Release/netcoreapp2.0/SimpleRpc.dll --urls=http://195.251.251.27:5001 -p ${DIRECTORY_PATH}/$i/$j/sample/SimpleRpc.Sample.Server/) 2>> ${PERFORMANCE_LOCAL}/csharp.txt &
                            getServerPID=$!
                                                              
							while true; do
								STATUS=""
								STATUS=$(curl -v --silent http://195.251.251.27:5001 2>&1 | grep Failed)
								if [ "$STATUS" == "" ]; then
									break
								fi
							done

                            ssh ${REMOTE_HOST_EM} "sh -c 'sudo ./GitHub/Rest_RPC_EM/watts-up/wattsup ttyUSB0 -s watts >> ${ENERGY_CONSUMPTION_REMOTE}/csharp.txt' &" &
                            sleep 2

                            #Run rest's Client
							ssh ${REMOTE_HOST_CLIENT} "bash -c '(time dotnet run bin/Release/netcoreapp2.0/SimpleRpc.dll -p GitHub/Rest_and_RPC_research/tasks/$i/$j/sample/SimpleRpc.Sample.Client/) 2>> ${PERFORMANCE_REMOTE}/csharp.txt'" &
                            getClientName=$(echo "SimpleRpc.dll")	
						fi

						if [ "${EXPERIMENT_TYPE}" == "resource_usage" ]; then
                        	touch  ${RESOURCE_USAGE_LOCAL}/csharp.txt
							(${FLAG} dotnet run bin/Release/netcoreapp2.0/SimpleRpc.dll --urls=http://195.251.251.27:5001 -p ${DIRECTORY_PATH}/$i/$j/sample/SimpleRpc.Sample.Server/) 2>> ${RESOURCE_USAGE_LOCAL}/csharp.txt &
                            getServerPID=$!
                                                              
							while true; do
								STATUS=""
								STATUS=$(curl -v --silent http://195.251.251.27:5001 2>&1 | grep Failed)
								if [ "$STATUS" == "" ]; then
									break
								fi
							done

                            #Run rest's Client
							ssh ${REMOTE_HOST_CLIENT} "bash -c '(${FLAG} dotnet run bin/Release/netcoreapp2.0/SimpleRpc.dll -p GitHub/Rest_and_RPC_research/tasks/$i/$j/sample/SimpleRpc.Sample.Client/) 2>> ${RESOURCE_USAGE_REMOTE}/csharp.txt'" &
                            getClientName=$(echo "SimpleRpc.dll")	
						fi

						#Check if remote client is still running
						while ssh ${REMOTE_HOST_CLIENT} ps aux | grep -i ${getClientName} > /dev/null; do
							sleep 1
						done
					
						# Once the client stopped running kill Server and WattsUp?Pro instances.
						ssh ${REMOTE_HOST_EM} sudo pkill wattsup
						echo "[Experiment terminated]"

						REMAINING=$(netstat -lntp 2>/dev/null | awk '{print $7}' | grep dotnet | awk -F "/" '{print $1}')
						kill -9 ${REMAINING}
						sleep 5
						exit
					fi
					;;
				php)
					getServerPID=0
					getClientName=""
                                             
					# Start the server for grpc
					if [ "$j" = "grpc" -a "$k" == "server.js" ]; then
						echo "Executing $j from $i"
						if [ "${EXPERIMENT_TYPE}" == "energy_consumption" ]; then
                        	touch  ${PERFORMANCE_LOCAL}/php.txt
							(time node ${DIRECTORY_PATH}/$i/$j/server.js) 2>> ${PERFORMANCE_LOCAL}/php.txt &
							getServerPID=$!
								
							while true; do
								STATUS=""
								STATUS=$(curl http://195.251.251.27:50051 2>&1 | grep Failed)
								if [ "$STATUS" == "" ]; then
									break
								fi
							done

                            # Run the wattsup in the background
							ssh ${REMOTE_HOST_EM} touch ${ENERGY_CONSUMPTION_REMOTE}/php.txt
                            ssh ${REMOTE_HOST_EM} "sh -c 'sudo ./GitHub/Rest_RPC_EM/watts-up/wattsup ttyUSB0 -s watts >> ${ENERGY_CONSUMPTION_REMOTE}/php.txt' &" &
							sleep 2
							
							# Run grpc's Client
							ssh ${REMOTE_HOST_CLIENT} "bash -c '(time bash GitHub/Rest_and_RPC_research/tasks/$i/$j/run_greeter_client.sh) 2>> ${PERFORMANCE_REMOTE}/php.txt'" &
							getClientName=$(echo "run_greeter_client.sh")
				        fi

						if [ "${EXPERIMENT_TYPE}" == "resource_usage" ]; then
                        	touch  ${RESOURCE_USAGE_LOCAL}/php.txt
							(${FLAG} node ${DIRECTORY_PATH}/$i/$j/server.js) 2>> ${RESOURCE_USAGE_LOCAL}/php.txt &
							getServerPID=$!
								
							while true; do
								STATUS=""
								STATUS=$(curl http://195.251.251.27:50051 2>&1 | grep Failed)
								if [ "$STATUS" == "" ]; then
									break
								fi
							done
							
							# Run grpc's Client
							ssh ${REMOTE_HOST_CLIENT} "bash -c '(${FLAG} bash GitHub/Rest_and_RPC_research/tasks/$i/$j/run_greeter_client.sh) 2>> ${RESOURCE_USAGE_REMOTE}/php.txt'" &
							getClientName=$(echo "run_greeter_client.sh")
				        fi	
						
						#Check if remote client is still running
						while ssh ${REMOTE_HOST_CLIENT} ps aux | grep -i ${getClientName} > /dev/null; do
							sleep 1
						done
					
						# Once the client stopped running kill Server and WattsUp?Pro instances.
						ssh ${REMOTE_HOST_EM} sudo pkill wattsup
						echo "[Experiment terminated]"
						
						# Get create PID from go server and remove them
						REMAINING=$(netstat -lntp 2>/dev/null | awk '{print $7}' | grep node | awk -F "/" '{print $1}')
						kill -9 ${REMAINING}
						sleep 5
					elif [ "$j" = "rest" -a "$k" == "app" ]; then
						echo "Executing $j from $i"
						if [ "${EXPERIMENT_TYPE}" == "energy_consumption" ]; then
                        	touch  ${PERFORMANCE_LOCAL}/php.txt
							SERVER_IP_ADDRESS=$(curl http://ifconfig.me/ip)
							(time php ${DIRECTORY_PATH}/$i/$j/artisan serve --host=${SERVER_IP_ADDRESS} --port=8001) 2>> ${PERFORMANCE_LOCAL}/php.txt & 
							getServerPID=$!
								
							while true; do
								STATUS=""
								STATUS=$(curl -v --silent http://195.251.251.27:8001 2>&1 | grep Failed)
								if [ "$STATUS" == "" ]; then
									break
								fi
							done

                            # Run the wattsup in the background
							ssh ${REMOTE_HOST_EM} touch ${ENERGY_CONSUMPTION_REMOTE}/php.txt
                            ssh ${REMOTE_HOST_EM} "sh -c 'sudo ./GitHub/Rest_RPC_EM/watts-up/wattsup ttyUSB0 -s watts >> ${ENERGY_CONSUMPTION_REMOTE}/php.txt' &" &
							sleep 2
							
							# Run grpc's Client
							ssh ${REMOTE_HOST_CLIENT} "bash -c '(time php GitHub/Rest_and_RPC_research/tasks/$i/$j/client/client.php) 2>> ${PERFORMANCE_REMOTE}/php.txt'" &
							getClientName=$(echo "client.php")
				        fi
				        	
						if [ "${EXPERIMENT_TYPE}" == "resource_usage" ]; then
                        	touch  ${RESOURCE_USAGE_LOCAL}/php.txt
							SERVER_IP_ADDRESS=$(curl http://ifconfig.me/ip)
							(${FLAG} php ${DIRECTORY_PATH}/$i/$j/artisan serve --host=${SERVER_IP_ADDRESS} --port=8001) 2>> ${RESOURCE_USAGE_LOCAL}/php.txt & 
							getServerPID=$!
								
							while true; do
								STATUS=""
								STATUS=$(curl -v --silent http://195.251.251.27:8001 2>&1 | grep Failed)
								if [ "$STATUS" == "" ]; then
									break
								fi
							done
							
							# Run grpc's Client
							ssh ${REMOTE_HOST_CLIENT} "bash -c '(${FLAG} php GitHub/Rest_and_RPC_research/tasks/$i/$j/client/client.php) 2>> ${RESOURCE_USAGE_REMOTE}/php.txt'" &
							getClientName=$(echo "client.php")
				        fi

						#Check if remote client is still running
						while ssh ${REMOTE_HOST_CLIENT} ps aux | grep -i ${getClientName} > /dev/null; do
							sleep 1
						done
					
						# Once the client stopped running kill Server and WattsUp?Pro instances.
						ssh ${REMOTE_HOST_EM} sudo pkill wattsup
						echo "[Experiment terminated]"
						REMAINING=$(netstat -lntp 2>/dev/null | awk '{print $7}' | grep php | awk -F "/" '{print $1}')
						kill -9 ${REMAINING}
						sleep 5
					elif [ "$j" == "rpc" -a "$k" == "instructions_rpc.txt" ]; then
						echo "Executing $j from $i"
						if [ "${EXPERIMENT_TYPE}" == "energy_consumption" ]; then
                        	touch  ${PERFORMANCE_LOCAL}/php.txt

                            # Run the wattsup in the background
							ssh ${REMOTE_HOST_EM} touch ${ENERGY_CONSUMPTION_REMOTE}/php.txt
                            ssh ${REMOTE_HOST_EM} "sh -c 'sudo ./GitHub/Rest_RPC_EM/watts-up/wattsup ttyUSB0 -s watts >> ${ENERGY_CONSUMPTION_REMOTE}/php.txt' &" &
							sleep 2
							
							# Run grpc's Client
							ssh ${REMOTE_HOST_CLIENT} "bash -c '(time php GitHub/Rest_and_RPC_research/tasks/$i/$j/client.php) 2>> ${PERFORMANCE_REMOTE}/php.txt'" &
							getClientName=$(echo "client.php")	
				        fi

						if [ "${EXPERIMENT_TYPE}" == "resource_usage" ]; then
                        	touch  ${RESOURCE_USAGE_LOCAL}/php.txt
							
							# Run grpc's Client
							ssh ${REMOTE_HOST_CLIENT} "bash -c '(${FLAG} php GitHub/Rest_and_RPC_research/tasks/$i/$j/client.php) 2>> ${RESOURCE_USAGE_REMOTE}/php.txt'" &
							getClientName=$(echo "client.php")	
				        fi
									
				        #Check if remote client is still running
						while ssh ${REMOTE_HOST_CLIENT} ps aux | grep -i ${getClientName} > /dev/null; do
							sleep 1
						done
					
						# Once the client stopped running kill Server and WattsUp?Pro instances.
						ssh ${REMOTE_HOST_EM} sudo pkill wattsup
						echo "[Experiment terminated]"
					fi
				;;
				ruby)
                    getServerPID=0
					if [ "$j" = "grpc" -a "$k" == "server.ru" ]; then
                        echo "Executing $j from $i"
                        if [ "${EXPERIMENT_TYPE}" == "energy_consumption" ]; then
							ssh ${REMOTE_HOST_EM} touch ${ENERGY_CONSUMPTION_REMOTE}/ruby.txt
                            touch  ${PERFORMANCE_LOCAL}/ruby.txt
						
					        # Start the server
							(time ruby ${DIRECTORY_PATH}/$i/$j/server.ru) 2>> ${PERFORMANCE_LOCAL}/ruby.txt &
							getServerPID=$!
							while true; do
								STATUS=""
								STATUS=$(curl -v --silent http://195.251.251.27:50051/ 2>&1 | grep Failed)
								if [ "${STATUS}" == "" ]; then	
									break
								fi		
							done
						
					 	    # Run the wattsup in the background
                            ssh ${REMOTE_HOST_EM} "sh -c 'sudo ./GitHub/Rest_RPC_EM/watts-up/wattsup ttyUSB0 -s watts >> ${ENERGY_CONSUMPTION_REMOTE}/ruby.txt' &" &
                            sleep 2
					
							# Start the client instance $j is the type of RPC or Rest
							ssh ${REMOTE_HOST_CLIENT} "bash -c '(time ruby GitHub/Rest_and_RPC_research/tasks/$i/$j/client.ru) 2>> ${PERFORMANCE_REMOTE}/ruby.txt'" &
						fi

						if [ "${EXPERIMENT_TYPE}" == "resource_usage" ]; then
                            touch  ${RESOURCE_USAGE_LOCAL}/ruby.txt
						
					        # Start the server
							(${FLAG} ruby ${DIRECTORY_PATH}/$i/$j/server.ru) 2>> ${RESOURCE_USAGE_LOCAL}/ruby.txt &
							getServerPID=$!
							while true; do
								STATUS=""
								STATUS=$(curl -v --silent http://195.251.251.27:50051/ 2>&1 | grep Failed)
								if [ "${STATUS}" == "" ]; then	
									break
								fi		
							done
					
							# Start the client instance $j is the type of RPC or Rest
							ssh ${REMOTE_HOST_CLIENT} "bash -c '(${FLAG} ruby GitHub/Rest_and_RPC_research/tasks/$i/$j/client.ru) 2>> ${RESOURCE_USAGE_REMOTE}/ruby.txt'" &
						fi
				        	
						#Check if remote client is still running
						while ssh ${REMOTE_HOST_CLIENT} ps aux | grep -i client.ru > /dev/null ;
						do
							sleep 1
						done
					
						# Once the client stopped running kill Server and WattsUp?Pro instances.
						ssh ${REMOTE_HOST_EM} sudo pkill wattsup
						echo "[Experiment terminated]"

						REMAINING=$(netstat -lntp 2>/dev/null | awk '{print $7}' | grep ruby | awk -F "/" '{print $1}')
						kill -9 ${REMAINING}
						sleep 5
					fi      
						
					if [ "$j" == "rpc" -a "$k" == "server.ru" ]; then	
                        echo "Executing $j from $i"
                        if [ "${EXPERIMENT_TYPE}" == "energy_consumption" ]; then    
							ssh ${REMOTE_HOST_EM} touch ${ENERGY_CONSUMPTION_REMOTE}/ruby.txt
                            touch  ${PERFORMANCE_LOCAL}/ruby.txt
					
							# Start the server
							(time ruby ${DIRECTORY_PATH}/$i/$j/server.ru) 2>> ${PERFORMANCE_LOCAL}/ruby.txt &
							getServerPID=$!
							while true; do
								STATUS=""
								STATUS=$(curl http://195.251.251.27:8888 2>&1 | grep Failed)
								if [ "${STATUS}" == "" ]; then	
									break
								fi	
							done	
                                                
							# Run the wattsup in the background
                            ssh ${REMOTE_HOST_EM} "sh -c 'sudo ./GitHub/Rest_RPC_EM/watts-up/wattsup ttyUSB0 -s watts >> ${ENERGY_CONSUMPTION_REMOTE}/ruby.txt' &" &
                            sleep 2
					
							# Start the client instance $j is the type of RPC or Rest
							ssh ${REMOTE_HOST_CLIENT} "bash -c '(time ruby GitHub/Rest_and_RPC_research/tasks/$i/$j/client.ru) 2>> ${PERFORMANCE_REMOTE}/ruby.txt'" &
						fi

						if [ "${EXPERIMENT_TYPE}" == "resource_usage" ]; then
                            touch  ${RESOURCE_USAGE_LOCAL}/ruby.txt
					
							# Start the server
							(${FLAG} ruby ${DIRECTORY_PATH}/$i/$j/server.ru) 2>> ${RESOURCE_USAGE_LOCAL}/ruby.txt &
							getServerPID=$!
							while true; do
								STATUS=""
								STATUS=$(curl http://195.251.251.27:8888 2>&1 | grep Failed)
								if [ "${STATUS}" == "" ]; then	
									break
								fi	
							done
					
							# Start the client instance $j is the type of RPC or Rest
							ssh ${REMOTE_HOST_CLIENT} "bash -c '(${FLAG} ruby GitHub/Rest_and_RPC_research/tasks/$i/$j/client.ru) 2>> ${RESOURCE_USAGE_REMOTE}/ruby.txt'" &
						fi
				        
						#Check if remote client is still running
						while ssh ${REMOTE_HOST_CLIENT} ps aux | grep -i client.ru > /dev/null ;
						do
							sleep 1
						done
					
						# Once the client stopped running kill Server and WattsUp?Pro instances.
						ssh ${REMOTE_HOST_EM} sudo pkill wattsup
						echo "[Experiment terminated]"
					
						# Get create PID from go server and remove them
						REMAINING=$(netstat -lntp 2>/dev/null | awk '{print $7}' | grep puma | awk -F "/" '{print $1}')
						kill -9 ${REMAINING}
						kill -9 ${getServerPID}
						sleep 5
						exit
					fi

					if [ "$j" = "rest" -a "$k" = "bin" ]; then
                        echo "Executing $j from $i"
						SERVER_IP_ADDRESS=$(curl http://ifconfig.me/ip)
                        if [ "${EXPERIMENT_TYPE}" == "energy_consumption" ]; then
							ssh ${REMOTE_HOST_EM} touch ${ENERGY_CONSUMPTION_REMOTE}/ruby.txt
                        	touch  ${PERFORMANCE_LOCAL}/ruby.txt

							# Start the server
							cd ${DIRECTORY_PATH}/$i/$j
							(time rails s -b 195.251.251.27 -p 8080) 2>> ../../${PERFORMANCE_LOCAL}/ruby.txt &
							getServerPID=$!
							cd ../../../scripts/

							# Necessary warm up time
							while true; do	
								STATUS=""
								STATUS=$(curl -v --silent http://195.251.251.27:8080/ 2>&1 | grep Failed)
								if [ "${STATUS}" == "" ]; then
									break
								fi
							done
				
							# Run the wattsup in the background
                        	ssh ${REMOTE_HOST_EM} "sh -c 'sudo ./GitHub/Rest_RPC_EM/watts-up/wattsup ttyUSB0 -s watts >> ${PERFORMANCE_LOCAL}/ruby.txt' &" &
                            sleep 2

							# Start the client instance $j is the type of RPC or Rest
                            ssh ${REMOTE_HOST_CLIENT} "bash -c '(time ruby GitHub/Rest_and_RPC_research/tasks/$i/$j/client.ru) 2>> ${PERFORMANCE_REMOTE}/ruby.txt'" &
						fi

						if [ "${EXPERIMENT_TYPE}" == "resource_usage" ]; then
							mkdir -p ${RESOURCE_USAGE_LOCAL}
							ssh ${REMOTE_HOST_CLIENT} mkdir -p ${RESOURCE_USAGE_REMOTE}
							touch  ${RESOURCE_USAGE_LOCAL}/ruby.txt

							# Start the server
							cd ${DIRECTORY_PATH}/$i/$j
							(${FLAG} rails s -b 195.251.251.27 -p 8080) 2>> ../../${RESOURCE_USAGE_LOCAL}/ruby.txt &
							getServerPID=$!
							cd ../../../scripts/
				
							# Necessary warm up time
							while true; do	
								STATUS=""
								STATUS=$(curl -v --silent http://195.251.251.27:8080/ 2>&1 | grep Failed)
								if [ "${STATUS}" == "" ]; then
									break
								fi
							done
				
							# Start the client instance $j is the type of RPC or Rest
                            ssh ${REMOTE_HOST_CLIENT} "bash -c '(${FLAG} ruby GitHub/Rest_and_RPC_research/tasks/$i/$j/client.ru) 2>> ${RESOURCE_USAGE_REMOTE}/ruby.txt'" &
						fi

				        #Check if remote client is still running
						while ssh ${REMOTE_HOST_CLIENT} ps aux | grep -i client.ru > /dev/null ;
						do
							sleep 1
						done
					
						# Once the client stopped running kill Server and WattsUp?Pro instances.
						ssh ${REMOTE_HOST_EM} sudo pkill wattsup
						echo "[Experiment terminated]"

						# Get create PID from go server and remove them
						REMAINING=$(netstat -lntp 2>/dev/null | awk '{print $7}' | grep puma | awk -F "/" '{print $1}')
                        kill -9 ${REMAINING}
						sleep 5
					fi
					;;
				go)
					if [ "$j" = "grpc" -o "$j" = "rest" -o "$j" = "rpc" ]; then
						if [ "$k" = "server.go" ]; then	
							echo "Executing $j from $i"
							if [ "${EXPERIMENT_TYPE}" == "energy_consumption" ]; then	
								ssh ${REMOTE_HOST_EM} touch ${ENERGY_CONSUMPTION_REMOTE}/go.txt
                        		touch  ${PERFORMANCE_LOCAL}/go.txt
								(time go run ${DIRECTORY_PATH}/$i/$j/server.go) 2>> ${PERFORMANCE_LOCAL}/go.txt &
								getServerPID=$!
								
								while true; do
									STATUS=""
									STATUS=$(curl -v --silent http://195.251.251.27:8080 2>&1 | grep Failed)
									if [ "$STATUS" == "" ]; then
										break
									fi
								done

                            	ssh ${REMOTE_HOST_EM} "sh -c 'sudo ./GitHub/Rest_RPC_EM/watts-up/wattsup ttyUSB0 -s watts >> ${ENERGY_CONSUMPTION_REMOTE}/go.txt' &" &
                            	sleep 2

								#Run rest's Client
								ssh ${REMOTE_HOST_CLIENT} "bash -c '(time go run GitHub/Rest_and_RPC_research/tasks/$i/$j/client.go) 2>> ${PERFORMANCE_REMOTE}/go.txt'" &
								getClientName=$(echo "Client.exe")
								sleep 1
							fi

							if [ "${EXPERIMENT_TYPE}" == "resource_usage" ]; then
                        		touch  ${RESOURCE_USAGE_LOCAL}/go.txt
								(${FLAG} go run ${DIRECTORY_PATH}/$i/$j/server.go) 2>> ${RESOURCE_USAGE_LOCAL}/go.txt &
								getServerPID=$!
								
								while true; do
									STATUS=""
									STATUS=$(curl -v --silent http://195.251.251.27:8080 2>&1 | grep Failed)
									if [ "$STATUS" == "" ]; then
										break
									fi
								done

								#Run rest's Client
								ssh ${REMOTE_HOST_CLIENT} "bash -c '(${FLAG} go run GitHub/Rest_and_RPC_research/tasks/$i/$j/client.go) 2>> ${RESOURCE_USAGE_REMOTE}/go.txt'" &
								getClientName=$(echo "Client.exe")
								sleep 1
							fi

							# Check if remote client is still running
							while ssh ${REMOTE_HOST_CLIENT} ps aux | grep -i client.go > /dev/null ;
							do
								sleep 1
							done
					
							# Once the client stopped running kill Server and WattsUp?Pro instances.
							ssh ${REMOTE_HOST_EM} sudo pkill wattsup
							echo "[Experiment terminated]"
						
							# Get create PID from go server and remove them
							REMAINING=$(netstat -lntp 2>/dev/null | awk '{print $7}' | grep server | awk -F "/" '{print $1}')
							kill -9 ${REMAINING}
							sleep 5
						fi
					fi
				 ;;
				javascript) 
					if [ "$j" = "grpc" -o "$j" = "rest" -o "$j" = "rpc" ]; then 
						if [ "$k" = "server.js"  ]; then
							echo "Executing $j from $i"
							if [ "${EXPERIMENT_TYPE}" == "energy_consumption" ]; then	
								ssh ${REMOTE_HOST_EM} touch ${ENERGY_CONSUMPTION_REMOTE}/javascript.txt
                        		touch  ${PERFORMANCE_LOCAL}/javascript.txt
								(time node ${DIRECTORY_PATH}/$i/$j/server.js) 2>> ${PERFORMANCE_LOCAL}/javascript.txt &
								getServerPID=$!
								
								while true; do
									STATUS=""
									STATUS=$(curl -v --silent http://195.251.251.27:8080 2>&1 | grep Failed)
									if [ "$STATUS" == "" ]; then
										break
									fi
								done

                            	ssh ${REMOTE_HOST_EM} "sh -c 'sudo ./GitHub/Rest_RPC_EM/watts-up/wattsup ttyUSB0 -s watts >> ${ENERGY_CONSUMPTION_REMOTE}/javascript.txt' &" &
                            	sleep 2

								#Run rest's Client
								ssh ${REMOTE_HOST_CLIENT} "bash -c '(time node GitHub/Rest_and_RPC_research/tasks/$i/$j/client.js) 2>> ${PERFORMANCE_REMOTE}/javascript.txt'" &
								sleep 1
							fi

							if [ "${EXPERIMENT_TYPE}" == "resource_usage" ]; then
                        		touch  ${RESOURCE_USAGE_LOCAL}/javascript.txt
								(${FLAG} node ${DIRECTORY_PATH}/$i/$j/server.js) 2>> ${RESOURCE_USAGE_LOCAL}/javascript.txt &
								getServerPID=$!
								
								while true; do
									STATUS=""
									STATUS=$(curl -v --silent http://195.251.251.27:8080 2>&1 | grep Failed)
									if [ "$STATUS" == "" ]; then
										break
									fi
								done

								#Run rest's Client
								ssh ${REMOTE_HOST_CLIENT} "bash -c '(${FLAG} node GitHub/Rest_and_RPC_research/tasks/$i/$j/client.js) 2>> ${RESOURCE_USAGE_REMOTE}/go.txt'" &
								sleep 1
							fi
							
							# Check if remote client is still running
							while ssh ${REMOTE_HOST_CLIENT} ps aux | grep -i client.js > /dev/null ;
							do
								sleep 1
							done
					
							# Once the client stopped running kill Server and WattsUp?Pro instances.
							ssh ${REMOTE_HOST_EM} sudo pkill wattsup
							echo "[Experiment terminated]"
						
							# Stop server instance
							REMAINING=$(netstat -lntp 2>/dev/null | awk '{print $7}' | grep node | awk -F "/" '{print $1}')
                            kill -9 ${REMAINING}
							sleep 5
						fi	
					fi
				;;

				python) 
					if [ "$j" = "grpc" -o "$j" = "rest" -o "$j" = "rpc" ]; then 
						if [ "$k" = "server.py"  ]; then
							echo "Executing $j from $i"
							
							if [ "${EXPERIMENT_TYPE}" == "energy_consumption" ]; then
								ssh ${REMOTE_HOST_EM} touch ${ENERGY_CONSUMPTION_REMOTE}/python.txt
                        		touch  ${PERFORMANCE_LOCAL}/python.txt
								(time python ${DIRECTORY_PATH}/$i/$j/server.py) 2>> ${PERFORMANCE_LOCAL}/python.txt &
								getServerPID=$!									

								while true; do	
									STATUS=""
									STATUS=$(curl -v --silent http://195.251.251.27:8080/ 2>&1 | grep Failed)
									if [ "${STATUS}" == "" ]; then
										break
									fi
								done

                            # Run the wattsup in the background
							ssh ${REMOTE_HOST_EM} "sh -c 'sudo ./GitHub/Rest_RPC_EM/watts-up/wattsup ttyUSB0 -s watts >> ${ENERGY_CONSUMPTION_REMOTE}/python.txt' &" &
                            sleep 2

							ssh ${REMOTE_HOST_CLIENT} "bash -c '(time python GitHub/Rest_and_RPC_research/tasks/$i/$j/client.py) 2>> ${PERFORMANCE_REMOTE}/python.txt'" &
							fi

							if [ "${EXPERIMENT_TYPE}" == "resource_usage" ]; then
                        		touch  ${RESOURCE_USAGE_LOCAL}/python.txt
								(${FLAG} python ${DIRECTORY_PATH}/$i/$j/server.py) 2>> ${RESOURCE_USAGE_LOCAL}/python.txt &
								getServerPID=$!									

								while true; do	
									STATUS=""
									STATUS=$(curl -v --silent http://195.251.251.27:8080/ 2>&1 | grep Failed)
									if [ "${STATUS}" == "" ]; then
										break
									fi
								done

							ssh ${REMOTE_HOST_CLIENT} "bash -c '(${FLAG} python GitHub/Rest_and_RPC_research/tasks/$i/$j/client.py) 2>> ${RESOURCE_USAGE_REMOTE}/python.txt'" &
							fi

							# Check if remote client is still running
							while ssh ${REMOTE_HOST_CLIENT} ps aux | grep -i client.py > /dev/null ;
							do
								sleep 1
							done
					
							# Once the client stopped running kill Server and WattsUp?Pro instances.
							ssh ${REMOTE_HOST_EM} sudo pkill wattsup
							echo "[Energy monitoring] Stopped"
						
							# Stop server instance
							REMAINING=$(netstat -lntp 2>/dev/null | awk '{print $7}' | grep python | awk -F "/" '{print $1}')
                                                        kill -9 ${REMAINING}
							sleep 5
						fi	
					fi
				;;
				java)
					# For each java protocol there is a different way to execute it, thus, we use case for such a porpose
					if [ "$j" == "grpc" -a "$k" == "android" ]; then
						echo "Executing $j from $i"
						if [ "${EXPERIMENT_TYPE}" == "energy_consumption" ]; then	
							ssh ${REMOTE_HOST_EM} touch ${ENERGY_CONSUMPTION_REMOTE}/java.txt
                        	touch  ${PERFORMANCE_LOCAL}/java.txt
							(time mvn -f ${DIRECTORY_PATH}/$i/$j/ exec:java -Dexec.mainClass=io.grpc.examples.helloworld.HelloWorldServer) 2>> ${PERFORMANCE_LOCAL}/java.txt &
							getServerPID=$!
								
							while true; do
								STATUS=""
								STATUS=$(curl -v --silent http://195.251.251.27:8080 2>&1 | grep Failed)
								if [ "$STATUS" == "" ]; then
									break
								fi
							done

                            ssh ${REMOTE_HOST_EM} "sh -c 'sudo ./GitHub/Rest_RPC_EM/watts-up/wattsup ttyUSB0 -s watts >> ${ENERGY_CONSUMPTION_REMOTE}/java.txt' &" &
                            sleep 2

							#Run rest's Client
							ssh ${REMOTE_HOST_CLIENT} "bash -c '(time mvn -f GitHub/Rest_and_RPC_research/tasks/$i/$j/ exec:java -Dexec.mainClass=io.grpc.examples.helloworld.HelloWorldClient) 2>> ${PERFORMANCE_REMOTE}/java.txt'" &
							getClientName=$(echo "Client.exe")
							sleep 1
						fi

						if [ "${EXPERIMENT_TYPE}" == "resource_usage" ]; then
                        	touch  ${RESOURCE_USAGE_LOCAL}/java.txt
							(${FLAG} mvn -f ${DIRECTORY_PATH}/$i/$j/ exec:java -Dexec.mainClass=io.grpc.examples.helloworld.HelloWorldServer) 2>> ${RESOURCE_USAGE_LOCAL}/java.txt &
							getServerPID=$!
								
							while true; do
								STATUS=""
								STATUS=$(curl -v --silent http://195.251.251.27:8080 2>&1 | grep Failed)
								if [ "$STATUS" == "" ]; then
									break
								fi
							done

							#Run rest's Client
							ssh ${REMOTE_HOST_CLIENT} "bash -c '(${FLAG} mvn -f GitHub/Rest_and_RPC_research/tasks/$i/$j/ exec:java -Dexec.mainClass=io.grpc.examples.helloworld.HelloWorldClient) 2>> ${RESOURCE_USAGE_REMOTE}/java.txt'" &
							getClientName=$(echo "Client.exe")
							sleep 1
						fi

						# Check if remote client is still running
                        while ssh ${REMOTE_HOST_CLIENT} ps aux | grep -i HelloWorldClient > /dev/null; do
                            sleep 1
                        done

                        REMAINING=$(netstat -lntp 2>/dev/null | awk '{print $7}' | grep java | awk -F "/" '{print $1}')
                        kill -9 ${REMAINING}
						sleep 10
					fi
					
					if [ "$j" == "rest" -a "$k" == "compile.sh" ]; then
						echo "Executing $j from $i"
						if [ "${EXPERIMENT_TYPE}" == "energy_consumption" ]; then	
							ssh ${REMOTE_HOST_EM} touch ${ENERGY_CONSUMPTION_REMOTE}/java.txt
                        	touch  ${PERFORMANCE_LOCAL}/java.txt
							(time bash ../apache-tomcat-9.0.8/bin/catalina.sh start) 2>> ${PERFORMANCE_LOCAL}/java.txt &
							getServerPID=$!
							
							while true; do
								STATUS=""
								STATUS=$(curl -v --silent http://195.251.251.27:8080 2>&1 | grep Failed)
								if [ "$STATUS" == "" ]; then
									break
								fi
							done
							
                            ssh ${REMOTE_HOST_EM} "sh -c 'sudo ./GitHub/Rest_RPC_EM/watts-up/wattsup ttyUSB0 -s watts >> ${ENERGY_CONSUMPTION_REMOTE}/java.txt' &" &
                            sleep 2

							#Run rest's Client
							ssh ${REMOTE_HOST_CLIENT} "bash -c 'cd GitHub/Rest_and_RPC_research/tasks/java/rest/ && (time bash execwquteJavaClient.sh) 2>> ~/${PERFORMANCE_REMOTE}/java.txt'" &
							getClientName=$(echo "Client.exe")
						fi

						if [ "${EXPERIMENT_TYPE}" == "resource_usage" ]; then
							mkdir -p ${RESOURCE_USAGE_LOCAL}
                        	touch  ${RESOURCE_USAGE_LOCAL}/java.txt
							(${FLAG} bash ../apache-tomcat-9.0.8/bin/catalina.sh start) 2>> ${RESOURCE_USAGE_LOCAL}/java.txt &
							getServerPID=$!
								
							while true; do
								STATUS=""
								STATUS=$(curl -v --silent http://195.251.251.27:8080 2>&1 | grep Failed)
								if [ "$STATUS" == "" ]; then
									break
								fi
							done
							
							#Run rest's Client
							ssh ${REMOTE_HOST_CLIENT} "bash -c 'cd GitHub/Rest_and_RPC_research/tasks/java/rest/ && (${FLAG} bash execwquteJavaClient.sh) 2>> ~/${RESOURCE_USAGE_REMOTE}/java.txt'" &
							sleep 1
						fi

						# Check if remote client is still running
                        while ssh ${REMOTE_HOST_CLIENT} ps aux | grep -i execwquteJavaClient.sh > /dev/null ;
                            do
							sleep 1
                        done

						bash ../apache-tomcat-9.0.8/bin/catalina.sh stop
						sleep 5
						exit
					fi
								
					if [ "$j" == "jax_ws_rpc" -a "$k" == "src" ]; then
						echo "Executing $j from $i"
						if [ "${EXPERIMENT_TYPE}" == "energy_consumption" ]; then	
							ssh ${REMOTE_HOST_EM} touch ${ENERGY_CONSUMPTION_REMOTE}/java.txt
                        	touch  ${PERFORMANCE_LOCAL}/java.txt
							(time java -cp ./../tasks/java/jax_ws_rpc/src com.thejavageek.HelloWorldServerPublisher) 2>> ${PERFORMANCE_LOCAL}/java.txt &
							getServerPID=$!
								
							while true; do
								STATUS=""
								STATUS=$(curl -v --silent http://195.251.251.27:8080 2>&1 | grep Failed)
								if [ "$STATUS" == "" ]; then
									break
								fi
							done

                            ssh ${REMOTE_HOST_EM} "sh -c 'sudo ./GitHub/Rest_RPC_EM/watts-up/wattsup ttyUSB0 -s watts >> ${ENERGY_CONSUMPTION_REMOTE}/java.txt' &" &
                            sleep 2

							#Run rest's Client
							ssh ${REMOTE_HOST_CLIENT} "bash -c '(time java -cp ./GitHub/Rest_and_RPC_research/tasks/java/jax_ws_rpc/src com.thejavageek.HelloWorldClient) 2>> ${PERFORMANCE_REMOTE}/java.txt'" &

						fi

						if [ "${EXPERIMENT_TYPE}" == "resource_usage" ]; then	
                        	touch  ${RESOURCE_USAGE_LOCAL}/java.txt
							(${FLAG} java -cp ./../tasks/java/jax_ws_rpc/src com.thejavageek.HelloWorldServerPublisher) 2>> ${RESOURCE_USAGE_LOCAL}/java.txt &
							getServerPID=$!
								
							while true; do
								STATUS=""
								STATUS=$(curl -v --silent http://195.251.251.27:8080 2>&1 | grep Failed)
								if [ "$STATUS" == "" ]; then
									break
								fi
							done

							#Run rest's Client
							ssh ${REMOTE_HOST_CLIENT} "bash -c '(${FLAG} java -cp ./GitHub/Rest_and_RPC_research/tasks/java/jax_ws_rpc/src com.thejavageek.HelloWorldClient) 2>> ${RESOURCE_USAGE_REMOTE}/java.txt'" &
						fi
			
						# Check if remote client is still running
                        while ssh ${REMOTE_HOST_CLIENT} ps -aux | grep -i HelloWorldClient > /dev/null; do
                            sleep 1
                        done
							
						# Once the client stopped running kill Server and WattsUp?Pro instances.
						ssh ${REMOTE_HOST_EM} sudo pkill wattsup
						echo "[Experiment terminated]"

                        REMAINING=$(netstat -lntp 2>/dev/null | awk '{print $7}' | grep java | awk -F "/" '{print $1}')
                        kill -9 ${REMAINING}
						sleep 5
					fi
				;;
			esac
		done
	done
done

# Now transer all the collected data to the server in the related directories
# From client
scp -r ${REMOTE_HOST_CLIENT}:/home/sgeorgiou/GitHub/Rest_RPC_Client/reports/${EnergyPerformanceLogDirName}/performance_client ../reports/${EnergyPerformanceLogDirName}/
# From RPi
scp -r ${REMOTE_HOST_EM}:/home/sgeorgiou/GitHub/Rest_RPC_EM/reports/$EnergyPerformanceLogDirName/energy_consumption ../reports/${EnergyPerformanceLogDirName}/

echo "Transfer done"

exit 1
