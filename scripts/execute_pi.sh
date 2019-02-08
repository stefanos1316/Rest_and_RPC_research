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
	echo "-t | --straces [argument]				Option to get traces such as syscalls or network calls"
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

OPTIONS=`getopt -o p:n:a:hb:d:t: --long help,directoryPath:,remoteHostNameEM:,remoteHostNameClient:,remoteHostAddressEM:,remoteHostAddressClient:,straces: -n 'execute.sh' -- "$@"`
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

# If the script is still running it means ssh connection is fine.
mkdir -p ../reports/$EnergyPerformanceLogDirName/energy_server

ssh ${REMOTE_HOST_EM} mkdir -p GitHub/Rest_RPC_EM/reports/$EnergyPerformanceLogDirName/energy_server
ssh ${REMOTE_HOST_CLIENT} mkdir -p GitHub/Rest_RPC_Client/reports/$EnergyPerformanceLogDirName/performance_client

if [ $? -eq 0 ];
then
	echo "Directories created normally."
else
	echo "Failed to create directories."
	echo "Please check remote host's permissions."
	exit
fi

# Create Performance locally since the execution is done here.
mkdir -p ../reports/$EnergyPerformanceLogDirName/performance_server

# Now we will run the experiment and collect out data.
for i in `ls ${DIRECTORY_PATH}`
do
	# This $i has a programming language directory name and $j jas the name of the protocol
	for j in `ls ${DIRECTORY_PATH}/${i}` 
	do
		if [ "$j" = "grpc" -o "$j" = "rest" -o "$j" = "rpc" -o "$j" = "jax_ws_rpc" ]; then
			ssh ${REMOTE_HOST_EM} mkdir -p GitHub/Rest_RPC_EM/reports/$EnergyPerformanceLogDirName/energy_server/$i/$j
			ssh ${REMOTE_HOST_CLIENT} mkdir -p GitHub/Rest_RPC_Client/reports/$EnergyPerformanceLogDirName/performance_client/$i/$j
		fi
		mkdir -p ../reports/$EnergyPerformanceLogDirName/performance_server/$i/$j

		for k in `ls ${DIRECTORY_PATH}/${i}/${j}`
		do
			# At this point we already reached the source code of a specific implemetation
			case "$i" in
				csharp)
					getServerPID=0
					getClientName=""

					if [ "$j" == "1grpc" -a "$k" == "GreeterServer" ]; then
						echo "Executing $j from $i"
                                        	ssh ${REMOTE_HOST_EM} touch GitHub/Rest_RPC_EM/reports/$EnergyPerformanceLogDirName/energy_server/$i/$j/csharp.txt
                                        	touch  ../reports/${EnergyPerformanceLogDirName}/performance_server/$i/$j/csharp.txt
						(time dotnet run -f netcoreapp2.1 -p ${DIRECTORY_PATH}/$i/$j/GreeterServer) 2>> ../reports/${EnergyPerformanceLogDirName}/performance_server/$i/$j/csharp.txt &
						getServerPID=$!
						
                                                # Run the wattsup in the background
                                                ssh ${REMOTE_HOST_EM} "sh -c 'sudo ./GitHub/Rest_RPC_EM/watts-up/wattsup ttyUSB0 -s watts >> GitHub/Rest_RPC_EM/reports/$EnergyPerformanceLogDirName/energy_server/$i/$j/csharp.txt' &" &
                                                sleep 2

						# Run grpc's Client
						ssh ${REMOTE_HOST_CLIENT} "bash -c '(time dotnet run -f netcoreapp2.1 -p GitHub/Rest_and_RPC_research/tasks/$i/$j/GreeterClient) 2>> GitHub/Rest_RPC_Client/reports/$EnergyPerformanceLogDirName/performance_client/$i/$j/csharp.txt'" &
						getClientName=$(echo "GreeterClient.dll")
						sleep 2
				        
						#Check if remote client is still running
						while ssh ${REMOTE_HOST_CLIENT} ps aux | grep -i ${getClientName} > /dev/null; do
							sleep 1
						done
					
						# Once the client stopped running kill Server and WattsUp?Pro instances.
						ssh ${REMOTE_HOST_EM} sudo pkill wattsup
						echo "[Energy Monitoring] Stopped"

						REMAINING=$(netstat -lntp 2>/dev/null | awk '{print $7}' | grep dotnet | awk -F "/" '{print $1}')
						kill -9 ${REMAINING}
						sleep 5

					elif [ "$j" == "rest" -a "$k" == "wwwroot" ]; then
						echo "Executing $j from $i"
                                        	ssh ${REMOTE_HOST_EM} touch GitHub/Rest_RPC_EM/reports/$EnergyPerformanceLogDirName/energy_server/$i/$j/csharp.txt
                                        	touch  ../reports/${EnergyPerformanceLogDirName}/performance_server/$i/$j/csharp.txt
						(time dotnet ${DIRECTORY_PATH}/$i/$j/bin/Release/netcoreapp2.1/myWebAppp.dll  --urls=http://195.251.251.27:5001) 2>> ../reports/${EnergyPerformanceLogDirName}/performance_server/$i/$j/csharp.txt &
						getServerPID=$!
								
						while true; do
							STATUS=""
							STATUS=$(curl -v --silent http://195.251.251.27:5001 2>&1 | grep Failed)
							if [ "$STATUS" == "" ]; then
								break
							fi
						done

                                                ssh ${REMOTE_HOST_EM} "sh -c 'sudo ./GitHub/Rest_RPC_EM/watts-up/wattsup ttyUSB0 -s watts >> GitHub/Rest_RPC_EM/reports/$EnergyPerformanceLogDirName/energy_server/$i/$j/csharp.txt' &" &
                                                sleep 2

						#Run rest's Client
						ssh ${REMOTE_HOST_CLIENT} "bash -c '(time mono GitHub/Rest_and_RPC_research/tasks/$i/$j/Client.exe) 2>> GitHub/Rest_RPC_Client/reports/$EnergyPerformanceLogDirName/performance_client/$i/$j/csharp.txt'" &
						getClientName=$(echo "Client.exe")
						
						#Check if remote client is still running
						while ssh ${REMOTE_HOST_CLIENT} ps aux | grep -i ${getClientName} > /dev/null; do
							sleep 1
						done
					
						# Once the client stopped running kill Server and WattsUp?Pro instances.
						ssh ${REMOTE_HOST_EM} sudo pkill wattsup
						echo "[Energy Monitoring] Stopped"

						REMAINING=$(netstat -lntp 2>/dev/null | awk '{print $7}' | grep dotnet | awk -F "/" '{print $1}')
						kill -9 ${REMAINING}
						sleep 5

					elif [ "$j" == "rpc" -a "$k" == "sample" ]; then
						echo "Executing $j from $i"
                                        	ssh ${REMOTE_HOST_EM} touch GitHub/Rest_RPC_EM/reports/$EnergyPerformanceLogDirName/energy_server/$i/$j/csharp.txt
                                        	touch  ../reports/${EnergyPerformanceLogDirName}/performance_server/$i/$j/csharp.txt

						(time dotnet run bin/Release/netcoreapp2.0/SimpleRpc.dll --urls=http://195.251.251.27:5001 -p ${DIRECTORY_PATH}/$i/$j/sample/SimpleRpc.Sample.Server/) 2>> ../reports/${EnergyPerformanceLogDirName}/performance_server/$i/$j/csharp.txt &
                                               	getServerPID=$!
                                                              
						while true; do
							STATUS=""
							STATUS=$(curl -v --silent http://195.251.251.27:5001 2>&1 | grep Failed)
							if [ "$STATUS" == "" ]; then
								break
							fi
						done

                                                ssh ${REMOTE_HOST_EM} "sh -c 'sudo ./GitHub/Rest_RPC_EM/watts-up/wattsup ttyUSB0 -s watts >> GitHub/Rest_RPC_EM/reports/$EnergyPerformanceLogDirName/energy_server/$i/$j/csharp.txt' &" &
                                                sleep 2

                                                #Run rest's Client
						ssh ${REMOTE_HOST_CLIENT} "bash -c '(time dotnet run bin/Release/netcoreapp2.0/SimpleRpc.dll -p GitHub/Rest_and_RPC_research/tasks/$i/$j/sample/SimpleRpc.Sample.Client/) 2>> GitHub/Rest_RPC_Client/reports/$EnergyPerformanceLogDirName/performance_client/$i/$j/csharp.txt'" &
                                                getClientName=$(echo "SimpleRpc.dll")	
						
						#Check if remote client is still running
						while ssh ${REMOTE_HOST_CLIENT} ps aux | grep -i ${getClientName} > /dev/null; do
							sleep 1
						done
					
						# Once the client stopped running kill Server and WattsUp?Pro instances.
						ssh ${REMOTE_HOST_EM} sudo pkill wattsup
						echo "[Energy Monitoring] Stopped"

						REMAINING=$(netstat -lntp 2>/dev/null | awk '{print $7}' | grep dotnet | awk -F "/" '{print $1}')
						kill -9 ${REMAINING}
						sleep 5
					fi
					;;
				1php)
					getServerPID=0
					getClientName=""
                                             
					# Start the server for grpc
					if [ "$j" = "grpc" -a "$k" == "server.js" ]; then
						echo "Executing $j from $i"
						# Run grpc's server 
						(time node ${DIRECTORY_PATH}/$i/$j/server.js) 2>> ../reports/${EnergyPerformanceLogDirName}/performance_server/$i/$j/php.txt &
						getServerPID=$!
								
						while true; do
							STATUS=""
							STATUS=$(curl http://195.251.251.27:50051 2>&1 | grep Failed)
							if [ "$STATUS" == "" ]; then
								break
							fi
						done
                                                		
						ssh ${REMOTE_HOST_EM} touch GitHub/Rest_RPC_EM/reports/$EnergyPerformanceLogDirName/energy_server/$i/$j/php.txt
                                                touch  ../reports/${EnergyPerformanceLogDirName}/performance_server/$i/$j/php.txt

                                                # Run the wattsup in the background
                                                ssh ${REMOTE_HOST_EM} "sh -c 'sudo ./GitHub/Rest_RPC_EM/watts-up/wattsup ttyUSB0 -s watts >> GitHub/Rest_RPC_EM/reports/$EnergyPerformanceLogDirName/energy_server/$i/$j/php.txt' &" &
						sleep 2

						# Run grpc's Client
						ssh ${REMOTE_HOST_CLIENT} "bash -c '(time bash GitHub/Rest_and_RPC_research/tasks/$i/$j/run_greeter_client.sh) 2>> GitHub/Rest_RPC_Client/reports/$EnergyPerformanceLogDirName/performance_client/$i/$j/php.txt'" &
						getClientName=$(echo "run_greeter_client.sh")
				        	
						#Check if remote client is still running
						while ssh ${REMOTE_HOST_CLIENT} ps aux | grep -i ${getClientName} > /dev/null; do
							sleep 1
						done
					
						# Once the client stopped running kill Server and WattsUp?Pro instances.
						ssh ${REMOTE_HOST_EM} sudo pkill wattsup
						echo "[Energy monitoring] Stopped"
						
						# Get create PID from go server and remove them
						REMAINING=$(netstat -lntp 2>/dev/null | awk '{print $7}' | grep node | awk -F "/" '{print $1}')
						kill -9 ${REMAINING}

					elif [ "$j" = "rest" -a "$k" == "app" ]; then
						echo "Executing $j from $i"
						SERVER_IP_ADDRESS=$(curl http://ifconfig.me/ip)
						(time php ${DIRECTORY_PATH}/$i/$j/artisan serve --host=${SERVER_IP_ADDRESS} --port=8001) 2>> ../reports/${EnergyPerformanceLogDirName}/performance_server/$i/$j/php.txt & 
						getServerPID=$!
								
						while true; do
							STATUS=""
							STATUS=$(curl -v --silent http://195.251.251.27:8001 2>&1 | grep Failed)
							if [ "$STATUS" == "" ]; then
								break
							fi
						done
                                                		
						ssh ${REMOTE_HOST_EM} touch GitHub/Rest_RPC_EM/reports/$EnergyPerformanceLogDirName/energy_server/$i/$j/php.txt
                                                touch  ../reports/${EnergyPerformanceLogDirName}/performance_server/$i/$j/php.txt

                                                # Run the wattsup in the background
                                                ssh ${REMOTE_HOST_EM} "sh -c 'sudo ./GitHub/Rest_RPC_EM/watts-up/wattsup ttyUSB0 -s watts >> GitHub/Rest_RPC_EM/reports/$EnergyPerformanceLogDirName/energy_server/$i/$j/php.txt' &" &
                                                sleep 2

						ssh ${REMOTE_HOST_CLIENT} "bash -c '(time php GitHub/Rest_and_RPC_research/tasks/$i/$j/client/client.php) 2>> GitHub/Rest_RPC_Client/reports/$EnergyPerformanceLogDirName/performance_client/$i/$j/php.txt'" &
						getClientName=$(echo "client.php")
				        	
						#Check if remote client is still running
						while ssh ${REMOTE_HOST_CLIENT} ps aux | grep -i ${getClientName} > /dev/null; do
							sleep 1
						done
					
						# Once the client stopped running kill Server and WattsUp?Pro instances.
						ssh ${REMOTE_HOST_EM} sudo pkill wattsup
						echo "[Energy monitoring] Stopped"
						REMAINING=$(netstat -lntp 2>/dev/null | awk '{print $7}' | grep php | awk -F "/" '{print $1}')
						kill -9 ${REMAINING}

					elif [ "$j" == "rpc" -a "$k" == "instructions_rpc.txt" ]; then
						echo "Executing $j from $i"
						ssh ${REMOTE_HOST_EM} touch GitHub/Rest_RPC_EM/reports/$EnergyPerformanceLogDirName/energy_server/$i/$j/php.txt
                                                touch  ../reports/${EnergyPerformanceLogDirName}/performance_server/$i/$j/php.txt

                                                # Run the wattsup in the background
                                                ssh ${REMOTE_HOST_EM} "sh -c 'sudo ./GitHub/Rest_RPC_EM/watts-up/wattsup ttyUSB0 -s watts >> GitHub/Rest_RPC_EM/reports/$EnergyPerformanceLogDirName/energy_server/$i/$j/php.txt' &" &
                                                sleep 2

						ssh ${REMOTE_HOST_CLIENT} "bash -c '(time php7.0 GitHub/Rest_and_RPC_research/tasks/$i/$j/client.php) 2>> GitHub/Rest_RPC_Client/reports/$EnergyPerformanceLogDirName/performance_client/$i/$j/php.txt'" &
						getClientName=$(echo "client.php")				
					
	
				        	#Check if remote client is still running
						while ssh ${REMOTE_HOST_CLIENT} ps aux | grep -i ${getClientName} > /dev/null; do
							sleep 1
						done
					
						# Once the client stopped running kill Server and WattsUp?Pro instances.
						ssh ${REMOTE_HOST_EM} sudo pkill wattsup
						echo "[Energy monitoring] Stopped"
						
						# Get create PID from go server and remove them
						REMAINING=$(netstat -lntp 2>/dev/null | awk '{print $7}' | grep php | awk -F "/" '{print $1}')
						kill -9 ${REMAINING}
						sleep 5
					fi
				;;
				1ruby)
                                        getServerPID=0
					if [ "$j" = "grpc" -a "$k" == "server.ru" ]; then
                                                echo "Executing $j from $i"
                                                ssh ${REMOTE_HOST_EM} touch GitHub/Rest_RPC_EM/reports/$EnergyPerformanceLogDirName/energy_server/$i/$j/ruby.txt
                                                touch  ../reports/${EnergyPerformanceLogDirName}/performance_server/$i/$j/ruby.txt
						
					        # Start the server
						(time /home/pi/.rvm/bin/ruby-rvm-env ${DIRECTORY_PATH}/$i/$j/server.ru) 2>> ../reports/${EnergyPerformanceLogDirName}/performance_server/$i/$j/ruby.txt &
						getServerPID=$!
						while true; do
							STATUS=""
							STATUS=$(curl -v --silent http://195.251.251.27:50051/ 2>&1 | grep Failed)
							if [ "${STATUS}" == "" ]; then	
								break
							fi		
						done
						
					        # Run the wattsup in the background
                                                ssh ${REMOTE_HOST_EM} "sh -c 'sudo ./GitHub/Rest_RPC_EM/watts-up/wattsup ttyUSB0 -s watts >> GitHub/Rest_RPC_EM/reports/$EnergyPerformanceLogDirName/energy_server/$i/$j/ruby.txt' &" &
                                                sleep 2
					
						# Start the client instance $j is the type of RPC or Rest
						ssh ${REMOTE_HOST_CLIENT} "bash -c '(time /home/pi/.rvm/bin/ruby-rvm-env GitHub/Rest_and_RPC_research/tasks/$i/$j/client.ru) 2>> GitHub/Rest_RPC_Client/reports/$EnergyPerformanceLogDirName/performance_client/$i/$j/ruby.txt'" &
						
				        	#Check if remote client is still running
						while ssh ${REMOTE_HOST_CLIENT} ps aux | grep -i client.ru > /dev/null ;
						do
							sleep 1
						done
					
						# Once the client stopped running kill Server and WattsUp?Pro instances.
						ssh ${REMOTE_HOST_EM} sudo pkill wattsup
						echo "[Energy Monitoring] Stopped"

						REMAINING=$(netstat -lntp 2>/dev/null | awk '{print $7}' | grep ruby | awk -F "/" '{print $1}')
						kill -9 ${REMAINING}
					
					fi      
						
					if [ "$j" == "rpc" -a "$k" == "server.ru" ]; then	
                                                echo "Executing $j from $i"
                                                ssh ${REMOTE_HOST_EM} touch GitHub/Rest_RPC_EM/reports/$EnergyPerformanceLogDirName/energy_server/$i/$j/ruby.txt
                                                touch  ../reports/${EnergyPerformanceLogDirName}/performance_server/$i/$j/ruby.txt
					
						# Start the server
						(time /home/pi/.rvm/bin/ruby-rvm-env ${DIRECTORY_PATH}/$i/$j/server.ru) 2>> ../reports/${EnergyPerformanceLogDirName}/performance_server/$i/$j/ruby.txt &
						getServerPID=$!
						while true; do
							STATUS=""
							STATUS=$(curl http://195.251.251.27:8888)
							if [ "${STATUS}" == "" ]; then	
								break
							fi	
						done	
                                                
						# Run the wattsup in the background
                                                ssh ${REMOTE_HOST_EM} "sh -c 'sudo ./GitHub/Rest_RPC_EM/watts-up/wattsup ttyUSB0 -s watts >> GitHub/Rest_RPC_EM/reports/$EnergyPerformanceLogDirName/energy_server/$i/$j/ruby.txt' &" &
                                                sleep 2
					
						# Start the client instance $j is the type of RPC or Rest
						ssh ${REMOTE_HOST_CLIENT} "bash -c '(time /home/pi/.rvm/bin/ruby-rvm-env GitHub/Rest_and_RPC_research/tasks/$i/$j/client.ru) 2>> GitHub/Rest_RPC_Client/reports/$EnergyPerformanceLogDirName/performance_client/$i/$j/ruby.txt'" &
						
				        	#Check if remote client is still running
						while ssh ${REMOTE_HOST_CLIENT} ps aux | grep -i client.ru > /dev/null ;
						do
							sleep 1
						done
					
						# Once the client stopped running kill Server and WattsUp?Pro instances.
						ssh ${REMOTE_HOST_EM} sudo pkill wattsup
						echo "[Energy Monitoring] Stopped"
					
						# Get create PID from go server and remove them
						REMAINING=$(netstat -lntp 2>/dev/null | awk '{print $7}' | grep ruby-mri | awk -F "/" '{print $1}')
						kill -9 ${REMAINING}

						sleep 5
					fi

					if [ "$j" = "rest" -a "$k" = "bin" ]; then

                                                echo "Executing $j from $i"
						SERVER_IP_ADDRESS=$(curl http://ifconfig.me/ip)
                                                ssh ${REMOTE_HOST_EM} touch GitHub/Rest_RPC_EM/reports/$EnergyPerformanceLogDirName/energy_server/$i/$j/ruby.txt
                                                touch  ../reports/${EnergyPerformanceLogDirName}/performance_server/$i/$j/ruby.txt

						# Start the server
						cd ${DIRECTORY_PATH}/$i/$j
						(time rails s -b 195.251.251.27 -p 8080) 2>> ~/GitHub/Rest_and_RPC_research/reports/${EnergyPerformanceLogDirName}/performance_server/$i/$j/ruby.txt &
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
                                                ssh ${REMOTE_HOST_EM} "sh -c 'sudo ./GitHub/Rest_RPC_EM/watts-up/wattsup ttyUSB0 -s watts >> GitHub/Rest_RPC_EM/reports/$EnergyPerformanceLogDirName/energy_server/$i/$j/ruby.txt' &" &
                                                sleep 2
						# Start the client instance $j is the type of RPC or Rest
                                                ssh ${REMOTE_HOST_CLIENT} "bash -c '(time ruby GitHub/Rest_and_RPC_research/tasks/$i/$j/client.ru) 2>> GitHub/Rest_RPC_Client/reports/$EnergyPerformanceLogDirName/performance_client/$i/$j/ruby.txt'" &

				        	#Check if remote client is still running
						while ssh ${REMOTE_HOST_CLIENT} ps aux | grep -i client.ru > /dev/null ;
						do
							sleep 1
						done
					
						# Once the client stopped running kill Server and WattsUp?Pro instances.
						ssh ${REMOTE_HOST_EM} sudo pkill wattsup
						echo "[Energy Monitoring] Stopped"

						# Get create PID from go server and remove them
						REMAINING=$(netstat -lntp 2>/dev/null | awk '{print $7}' | grep puma | awk -F "/" '{print $1}')
                                                kill -9 ${REMAINING}
						sleep 5

					fi

					;;
				1go)
					if [ "$j" = "grpc" -o "$j" = "rest" -o "$j" = "rpc" ]; then
					if [ "$k" = "server.go" ]; then	
						echo "Executing $j from $i"
						# Start RPi to collect energy consumption
						# A second of delay since the wattsup has it as a startup delay
						ssh ${REMOTE_HOST_EM} touch GitHub/Rest_RPC_EM/reports/$EnergyPerformanceLogDirName/energy_server/$i/$j/go.txt
						touch  ../reports/${EnergyPerformanceLogDirName}/performance_server/$i/$j/go.txt

						# Run the wattsup in the background
						ssh ${REMOTE_HOST_EM} "sh -c 'sudo ./GitHub/Rest_RPC_EM/watts-up/wattsup ttyUSB0 -s watts  >> GitHub/Rest_RPC_EM/reports/$EnergyPerformanceLogDirName/energy_server/$i/$j/go.txt' &" &
	
						# Watts Up utility has 2 seconds of delay before start capturing measurements, thus we delay the execution system too				
						sleep 2
						getServerPID=0
						# Start the server
						if [ "${TRACES_FLAG}" = "true" ]; then 
							case ${TRACES_TYPE} in 
								network) 
									mkdir -p ../reports/${EnergyPerformanceLogDirName}/network_traces/$i/$j
									(strace -fte trace=network go run ${DIRECTORY_PATH}/$i/$j/server.go) 2>> ../reports/${EnergyPerformanceLogDirName}/network_traces/$i/$j/go.txt &
									getServerPID=$!
									# Start the client instance $j is the type of RPC or Rest
									
									ssh ${REMOTE_HOST_CLIENT} mkdir -p GitHub/Rest_RPC_Client/reports/$EnergyPerformanceLogDirName/network_traces/$i/$j
									ssh ${REMOTE_HOST_CLIENT} "sh -c '(strace -f -e trace=network -c go run GitHub/Rest_and_RPC_research/tasks/$i/$j/client.go) 2>> GitHub/Rest_RPC_Client/reports/$EnergyPerformanceLogDirName/network_traces/$i/$j/go.txt'" &
								;;
								syscalls)
									mkdir -p ../reports/${EnergyPerformanceLogDirName}/syscall_traces/$i/$j
									(strace -fte 'trace=!futex,wait4,waitid,epoll_wait,pselect6' go run ${DIRECTORY_PATH}/$i/$j/server.go) 2>> ../reports/${EnergyPerformanceLogDirName}/syscall_traces/$i/$j/go.txt &
									getServerPID=$!
									
									# Start the client instance $j is the type of RPC or Rest
									ssh ${REMOTE_HOST_CLIENT} mkdir -p GitHub/Rest_RPC_Client/reports/$EnergyPerformanceLogDirName/syscall_traces/$i/$j
									ssh ${REMOTE_HOST_CLIENT} "sh -c '(strace -fte 'trace=!futex,wait4,waitid,epoll_wait,pselect6' go run GitHub/Rest_and_RPC_research/tasks/$i/$j/client.go) 2>> GitHub/Rest_RPC_Client/reports/$EnergyPerformanceLogDirName/syscall_traces/$i/$j/go.txt'" &
								;;
							esac
						else
							(time go run ${DIRECTORY_PATH}/$i/$j/server.go) 2>> ../reports/${EnergyPerformanceLogDirName}/performance_server/$i/$j/go.txt &
							getServerPID=$!

							sleep 2

							# Start the client instance $j is the type of RPC or Rest
							ssh ${REMOTE_HOST_CLIENT} "bash -c '(time /usr/local/go/bin/go run GitHub/Rest_and_RPC_research/tasks/$i/$j/client.go) 2>> GitHub/Rest_RPC_Client/reports/$EnergyPerformanceLogDirName/performance_client/$i/$j/go.txt'" &
							sleep 1
						fi
						
			
						# Check if remote client is still running
						while ssh ${REMOTE_HOST_CLIENT} ps aux | grep -i client.go > /dev/null ;
						do
							sleep 1
						done
					
						# Once the client stopped running kill Server and WattsUp?Pro instances.
						ssh ${REMOTE_HOST_EM} sudo pkill wattsup
						echo "Killing wattsup pro"
						
						# Stop server instance
						pkill -P ${getServerPID}
						echo "Killing server processes"
						
						# Get create PID from go server and remove them
						REMAINING=$(netstat -lntp 2>/dev/null | awk '{print $7}' | grep server | awk -F "/" '{print $1}')
						kill -9 ${REMAINING}
						sleep 5
					fi
					fi
				 ;;

				1javascript) 
					if [ "$j" = "grpc" -o "$j" = "rest" -o "$j" = "rpc" ]; then 
						if [ "$k" = "server.js"  ]; then
							echo "Executing $j from $i"
							ssh ${REMOTE_HOST_EM} touch GitHub/Rest_RPC_EM/reports/$EnergyPerformanceLogDirName/energy_server/$i/$j/javascript.txt
                                                	touch  ../reports/${EnergyPerformanceLogDirName}/performance_server/$i/$j/javascript.txt

                                                	# Run the wattsup in the background
                                                	ssh ${REMOTE_HOST_EM} "sh -c 'sudo ./GitHub/Rest_RPC_EM/watts-up/wattsup ttyUSB0 -s watts >> GitHub/Rest_RPC_EM/reports/$EnergyPerformanceLogDirName/energy_server/$i/$j/javascript.txt' &" &

                                                	# Watts Up utility has 2 seconds of delay before start capturing measurements, thus we delay the execution system too
                                                	sleep 2
							getServerPID=0

                                                	# Start the server
							if [ "${TRACES_FLAG}" = "true" ]; then
								case ${TRACES_TYPE} in 
									network) 
										mkdir -p ../reports/${EnergyPerformanceLogDirName}/network_traces/$i/$j
										(strace -f -e trace=network -T node ${DIRECTORY_PATH}/$i/$j/server.js) 2>> ../reports/${EnergyPerformanceLogDirName}/network_traces/$i/$j/javascript.txt &
										getServerPID=$!
										# Start the client instance $j is the type of RPC or Rest
									
										ssh ${REMOTE_HOST_CLIENT} mkdir -p GitHub/Rest_RPC_Client/reports/$EnergyPerformanceLogDirName/network_traces/$i/$j
										ssh ${REMOTE_HOST_CLIENT} "sh -c '(strace -f -e trace=network -c node GitHub/Rest_and_RPC_research/tasks/$i/$j/client.js) 2>> GitHub/Rest_RPC_Client/reports/$EnergyPerformanceLogDirName/network_traces/$i/$j/javascript.txt'" &
										;;
									syscalls)
										mkdir -p ../reports/${EnergyPerformanceLogDirName}/syscall_traces/$i/$j
										(strace -fte 'trace=!futex,wait4,waitid,epoll_wait,pselect6' node ${DIRECTORY_PATH}/$i/$j/server.js) 2>> ../reports/${EnergyPerformanceLogDirName}/syscall_traces/$i/$j/javascript.txt &
										getServerPID=$!
									
										# Start the client instance $j is the type of RPC or Rest
										ssh ${REMOTE_HOST_CLIENT} mkdir -p GitHub/Rest_RPC_Client/reports/$EnergyPerformanceLogDirName/syscall_traces/$i/$j
										ssh ${REMOTE_HOST_CLIENT} "sh -c '(strace -fte 'trace=!futex,wait4,waitid,epoll_wait,pselect6' node GitHub/Rest_and_RPC_research/tasks/$i/$j/client.js) 2>> GitHub/Rest_RPC_Client/reports/$EnergyPerformanceLogDirName/syscall_traces/$i/$j/javascript.txt'" &
										;;
								esac
							else
								(time node ${DIRECTORY_PATH}/$i/$j/server.js) 2>> ../reports/${EnergyPerformanceLogDirName}/performance_server/$i/$j/javascript.txt &		
								getServerPID=$!									
								sleep 2
								# Start the client instance $j is the type of RPC or Rest
								ssh ${REMOTE_HOST_CLIENT} "bash -c '(time node GitHub/Rest_and_RPC_research/tasks/$i/$j/client.js) 2>> GitHub/Rest_RPC_Client/reports/$EnergyPerformanceLogDirName/performance_client/$i/$j/javascript.txt'" &
								sleep 2
							fi

							# Check if remote client is still running
							while ssh ${REMOTE_HOST_CLIENT} ps aux | grep -i client.js > /dev/null ;
							do
								sleep 1
							done
					
							# Once the client stopped running kill Server and WattsUp?Pro instances.
							ssh ${REMOTE_HOST_EM} sudo pkill wattsup
							echo "Killing wattsup pro"
						
							# Stop server instance
							REMAINING=$(netstat -lntp 2>/dev/null | awk '{print $7}' | grep node | awk -F "/" '{print $1}')
                                                        kill -9 ${REMAINING}
							echo "Done with $k"
							sleep 5
						fi	
					fi
				;;
				1python) 
					if [ "$j" = "grpc" -o "$j" = "rest" -o "$j" = "rpc" ]; then 
						if [ "$k" = "server.py"  ]; then
							echo "Executing $j from $i"
							ssh ${REMOTE_HOST_EM} touch GitHub/Rest_RPC_EM/reports/$EnergyPerformanceLogDirName/energy_server/$i/$j/python.txt
                                                	touch  ../reports/${EnergyPerformanceLogDirName}/performance_server/$i/$j/python.txt

                                                	# Run the wattsup in the background
                                                	ssh ${REMOTE_HOST_EM} "sh -c 'sudo ./GitHub/Rest_RPC_EM/watts-up/wattsup ttyUSB0 -s watts >> GitHub/Rest_RPC_EM/reports/$EnergyPerformanceLogDirName/energy_server/$i/$j/python.txt' &" &

                                                	# Watts Up utility has 2 seconds of delay before start capturing measurements, thus we delay the execution system too
                                                	sleep 2
							getServerPID=0

                                                	# Start the server
							if [ "${TRACES_FLAG}" = "true" ]; then
								case ${TRACES_TYPE} in 
									network) 
										mkdir -p ../reports/${EnergyPerformanceLogDirName}/network_traces/$i/$j
										(strace -f -e trace=network -T python ${DIRECTORY_PATH}/$i/$j/server.py) 2>> ../reports/${EnergyPerformanceLogDirName}/network_traces/$i/$j/python.txt &
										getServerPID=$!
										# Start the client instance $j is the type of RPC or Rest
									
										ssh ${REMOTE_HOST_CLIENT} mkdir -p GitHub/Rest_RPC_Client/reports/$EnergyPerformanceLogDirName/network_traces/$i/$j
										ssh ${REMOTE_HOST_CLIENT} "sh -c '(strace -f -e trace=network -c python GitHub/Rest_and_RPC_research/tasks/$i/$j/client.py) 2>> GitHub/Rest_RPC_Client/reports/$EnergyPerformanceLogDirName/network_traces/$i/$j/python.txt'" &
										;;
									syscalls)
										mkdir -p ../reports/${EnergyPerformanceLogDirName}/syscall_traces/$i/$j
										(strace -fte 'trace=!futex,wait4,waitid,epoll_wait,pselect6' python ${DIRECTORY_PATH}/$i/$j/server.py) 2>> ../reports/${EnergyPerformanceLogDirName}/syscall_traces/$i/$j/python.txt &
										getServerPID=$!
									
										# Start the client instance $j is the type of RPC or Rest
										ssh ${REMOTE_HOST_CLIENT} mkdir -p GitHub/Rest_RPC_Client/reports/$EnergyPerformanceLogDirName/syscall_traces/$i/$j
										ssh ${REMOTE_HOST_CLIENT} "sh -c '(strace -fte 'trace=!futex,wait4,waitid,epoll_wait,pselect6' python GitHub/Rest_and_RPC_research/tasks/$i/$j/client.py) 2>> GitHub/Rest_RPC_Client/reports/$EnergyPerformanceLogDirName/syscall_traces/$i/$j/python.txt'" &
										;;
								esac
							else

								(time python ${DIRECTORY_PATH}/$i/$j/server.py) 2>> ../reports/${EnergyPerformanceLogDirName}/performance_server/$i/$j/python.txt &
								getServerPID=$!									
								sleep 3
								if [ "$j" == "rpc" ]; then
								# Start the client instance $j is the type of RPC or Rest
									ssh ${REMOTE_HOST_CLIENT} "bash -c '(time python3.6 GitHub/Rest_and_RPC_research/tasks/$i/$j/client.py) 2>> GitHub/Rest_RPC_Client/reports/$EnergyPerformanceLogDirName/performance_client/$i/$j/python.txt'" &
								else
									ssh ${REMOTE_HOST_CLIENT} "bash -c '(time python GitHub/Rest_and_RPC_research/tasks/$i/$j/client.py) 2>> GitHub/Rest_RPC_Client/reports/$EnergyPerformanceLogDirName/performance_client/$i/$j/python.txt'" &
								fi
							fi

							# Check if remote client is still running
							while ssh ${REMOTE_HOST_CLIENT} ps aux | grep -i client.py > /dev/null ;
							do
								sleep 1
							done
					
							# Once the client stopped running kill Server and WattsUp?Pro instances.
							ssh ${REMOTE_HOST_EM} sudo pkill wattsup
							echo "Killing wattsup pro"
						
							# Stop server instance
							REMAINING=$(netstat -lntp 2>/dev/null | awk '{print $7}' | grep python | awk -F "/" '{print $1}')
                                                        kill -9 ${REMAINING}
							echo "Done with $k"
							sleep 5
						fi	
					fi
				;;
			java1)
					if [ "$j" = "grpc" -o "$j" = "rest" -o "$j" = "jax_ws_rpc" ]; then
						echo "Executing $j from $i"
				
						# At this point we are in the main directory where all the java files are locate such as src, target, and pom.xmls.
						ssh ${REMOTE_HOST_EM} touch GitHub/Rest_RPC_EM/reports/$EnergyPerformanceLogDirName/energy_server/$i/$j/java.txt
						touch  ../reports/${EnergyPerformanceLogDirName}/performance_server/$i/$j/java.txt

						# Run the wattsup in the background
						ssh ${REMOTE_HOST_EM} "sh -c 'sudo ./GitHub/Rest_RPC_EM/watts-up/wattsup ttyUSB0 -s watts  >> GitHub/Rest_RPC_EM/reports/$EnergyPerformanceLogDirName/energy_server/$i/$j/java.txt' &" &
	
						# Watts Up utility has 2 seconds of delay before start capturing measurements, thus we delay the execution system too				
						sleep 2					
						getServerPID=0

						# For each java protocol there is a different way to execute it, thus, we use case for such a porpose
						case "$j" in			
							grpc)
								if [ "$k" = "android" ]; then
									if [ "${TRACES_FLAG}" = "true" ]; then
										case ${TRACES_TYPE} in 
											network) 
												mkdir -p ../reports/${EnergyPerformanceLogDirName}/network_traces/$i/$j
												(strace -f -e trace=network -T mvn -f ${DIRECTORY_PATH}/$i/$j/ exec:java -Dexec.mainClass=io.grpc.examples.helloworld.HelloWorldServer) 2>> ../reports/${EnergyPerformanceLogDirName}/network_traces/$i/$j/java.txt &
												getServerPID=$!
												# Start the client instance $j is the type of RPC or Rest
									
												ssh ${REMOTE_HOST_CLIENT} mkdir -p GitHub/Rest_RPC_Client/reports/$EnergyPerformanceLogDirName/network_traces/$i/$j
												ssh ${REMOTE_HOST_CLIENT} "sh -c '(strace -f -e trace=network -c mvn -f GitHub/Rest_and_RPC_research/tasks/$i/$j/ exec:java -Dexec.mainClass=io.grpc.examples.helloworld.HelloWorldClient) 2>> GitHub/Rest_RPC_Client/reports/$EnergyPerformanceLogDirName/network_traces/$i/$j/java.txt'" &
												;;
											syscalls)
												mkdir -p ../reports/${EnergyPerformanceLogDirName}/syscall_traces/$i/$j
												(strace -fte 'trace=!futex,wait4,waitid,epoll_wait,pselect6' mvn -f ${DIRECTORY_PATH}/$i/$j/ exec:java -Dexec.mainClass=io.grpc.examples.helloworld.HelloWorldServer ) 2>> ../reports/${EnergyPerformanceLogDirName}/syscall_traces/$i/$j/java.txt &
												getServerPID=$!
									
												# Start the client instance $j is the type of RPC or Rest
												ssh ${REMOTE_HOST_CLIENT} mkdir -p GitHub/Rest_RPC_Client/reports/$EnergyPerformanceLogDirName/syscall_traces/$i/$j
												ssh ${REMOTE_HOST_CLIENT} "sh -c '(strace -fte 'trace=!futex,wait4,waitid,epoll_wait,pselect6' mvn -f GitHub/Rest_and_RPC_research/tasks/$i/$j/ exec:java -Dexec.mainClass=io.grpc.examples.helloworld.HelloWorldClient) 2>> GitHub/Rest_RPC_Client/reports/$EnergyPerformanceLogDirName/syscall_traces/$i/$j/java.txt'" &
												;;
										esac
									else
										(time mvn -f ${DIRECTORY_PATH}/$i/$j/ exec:java -Dexec.mainClass=io.grpc.examples.helloworld.HelloWorldServer) 2>> ../reports/${EnergyPerformanceLogDirName}/performance_server/$i/$j/java.txt &
										sleep 15
										getServerPID=$!

										# Now start the remote client by entering the path where it is located
										ssh ${REMOTE_HOST_CLIENT} "bash -c '(time /opt/apache-maven-3.2.5/bin/mvn -f GitHub/Rest_and_RPC_research/tasks/$i/$j/ exec:java -Dexec.mainClass=io.grpc.examples.helloworld.HelloWorldClient) 2>> GitHub/Rest_RPC_Client/reports/$EnergyPerformanceLogDirName/performance_client/$i/$j/java.txt'" &
										sleep 1
									fi

									# Check if remote client is still running
                                                                        while ssh ${REMOTE_HOST_CLIENT} ps aux | grep -i execwquteJavaClient.sh > /dev/null ;
                                                                        do
                                                                                sleep 1
                                                                        done

                                                                        # Stop server instance
                                                                       	kill -9 ${getServerPID}
                                                                        echo "Done with $k"
                                                                        REMAINING=$(netstat -lntp 2>/dev/null | awk '{print $7}' | grep java | awk -F "/" '{print $1}')
                                                                        kill -9 ${REMAINING}
									sleep 5
									
								fi
							;;
							1rest)
								if [ "$k" = "REST_server" ]; then
									mkdir -p ../reports/${EnergyPerformanceLogDirName}/syscall_traces/$i/$j
									#(strace -fte 'trace=!futex,wait4,waitid,epoll_wait,pselect6' bash ../apache-tomcat-9.0.8/bin/catalina.sh start) 2>> ../reports/${EnergyPerformanceLogDirName}/syscall_traces/$i/$j/java.txt &
									(time bash ../apache-tomcat-9.0.8/bin/catalina.sh start) 2>> ../reports/${EnergyPerformanceLogDirName}/performance_server/$i/$j/java.txt &
									sleep 2
									#response=$(curl http://195.251.251.27:8080/RESTfulServer/rest/hello/Testing)
									#if [ "${response}" == "Jersey say : Testing" ]; then
									#	echo "Apache tomcat working and RESTfulServer deployed"
									#else
								#		&>2 echo "Error, apache tomcat may not run or RESTfulServer may not be deployed"
								#		exit
								#	fi

									if [ "${TRACES_FLAG}" = "true" ]; then
										case ${TRACES_TYPE} in
											network) 
												mkdir -p ../reports/${EnergyPerformanceLogDirName}/network_traces/$i/$j
												ssh ${REMOTE_HOST_CLIENT} mkdir -p GitHub/Rest_RPC_Client/reports/$EnergyPerformanceLogDirName/network_traces/$i/$j

												ssh ${REMOTE_HOST_CLIENT} "sh -c 'cd GitHub/Rest_and_RPC_research/tasks/java/rest/ && (strace -f -e trace=network -c bash execwquteJavaClient.sh) 2>> ~/GitHub/Rest_RPC_Client/reports/${EnergyPerformanceLogDirName}/network_traces/$i/$j/java.txt && cd ~/'" &
												;;
											syscalls) 
												mkdir -p ../reports/${EnergyPerformanceLogDirName}/syscall_traces/$i/$j
												ssh ${REMOTE_HOST_CLIENT} mkdir -p GitHub/Rest_RPC_Client/reports/$EnergyPerformanceLogDirName/syscall_traces/$i/$j
												ssh ${REMOTE_HOST_CLIENT} "sh -c 'cd GitHub/Rest_and_RPC_research/tasks/java/rest/ && (strace -fte 'trace=!futex,wait4,waitid,epoll_wait,pselect6' bash execwquteJavaClient.sh) 2>> ~/GitHub/Rest_RPC_Client/reports/${EnergyPerformanceLogDirName}/syscall_traces/$i/$j/java.txt && cd ~/'" &
												;;
										esac
									else
										# Starting remote client,
										ssh ${REMOTE_HOST_CLIENT} "bash -c 'cd GitHub/Rest_and_RPC_research/tasks/java/rest/ && (time bash execwquteJavaClient.sh) 2>> ~/GitHub/Rest_RPC_Client/reports/${EnergyPerformanceLogDirName}/performance_client/$i/$j/java.txt && cd ~/'" &
										sleep 1
									fi

									 # Check if remote client is still running
                                                                        while ssh ${REMOTE_HOST_CLIENT} ps aux | grep -i execwquteJavaClient.sh > /dev/null ;
                                                                        do
                                                                                sleep 1
                                                                        done

									bash ../apache-tomcat-9.0.8/bin/catalina.sh stop

                                                                        # Stop server instance
                                                                       	#kill -9 ${getServerPID}
                                                                        echo "Done with $k"
                                                                        sleep 5

								fi
							;;
							1jax_ws_rpc) 
								if [ "$k" = "src" ]; then

									getServerPID=0
									# Start server java -cp ./src com.thejavageek.HelloWorldServerPublisher
									if [ "${TRACES_FLAG}" = "true" ]; then
										case ${TRACES_TYPE} in 
											network) 
												mkdir -p ../reports/${EnergyPerformanceLogDirName}/network_traces/$i/$j
												(strace -f -e trace=network -T java -cp ./GitHub/Rest_and_RPC_research/tasks/java/jax_ws_rpc/src com.thejavageek.HelloWorldClient) 2>> ../reports/${EnergyPerformanceLogDirName}/network_traces/$i/$j/java.txt &
												getServerPID=$!
												# Start the client instance $j is the type of RPC or Rest
									
												ssh ${REMOTE_HOST_CLIENT} mkdir -p GitHub/Rest_RPC_Client/reports/$EnergyPerformanceLogDirName/network_traces/$i/$j
												ssh ${REMOTE_HOST_CLIENT} "sh -c '(strace -f -e trace=network -c mvn -f GitHub/Rest_and_RPC_research/tasks/$i/$j/ exec:java -Dexec.mainClass=io.grpc.examples.helloworld.HelloWorldClient) 2>> GitHub/Rest_RPC_Client/reports/$EnergyPerformanceLogDirName/network_traces/$i/$j/java.txt'" &
												;;
											syscalls)
												mkdir -p ../reports/${EnergyPerformanceLogDirName}/syscall_traces/$i/$j
												(strace -fte 'trace=!futex,waitid,wait4,epoll_wait,pselect6' java -cp ~/GitHub/Rest_and_RPC_research/tasks/java/jax_ws_rpc/src com.thejavageek.HelloWorldServerPublisher) 2>> ../reports/${EnergyPerformanceLogDirName}/syscall_traces/$i/$j/java.txt &
												getServerPID=$!
									
												# Start the client instance $j is the type of RPC or Rest
												ssh ${REMOTE_HOST_CLIENT} mkdir -p GitHub/Rest_RPC_Client/reports/$EnergyPerformanceLogDirName/syscall_traces/$i/$j
												ssh ${REMOTE_HOST_CLIENT} "sh -c '(strace -fte 'trace=!futex,wait4,waitid,epoll_wait,pselect6' java -cp ./GitHub/Rest_and_RPC_research/tasks/java/jax_ws_rpc/src com.thejavageek.HelloWorldClient) 2>> GitHub/Rest_RPC_Client/reports/$EnergyPerformanceLogDirName/syscall_traces/$i/$j/java.txt'" &
												;;
										esac
									else
										(time java -cp ./../tasks/java/jax_ws_rpc/src com.thejavageek.HelloWorldServerPublisher) 2>> ../reports/${EnergyPerformanceLogDirName}/performance_server/$i/$j/java.txt &
										getServerPID=$!
										sleep 2
										# Start client java -cp ./src com.thejavageek.HelloWorldClient 
										ssh ${REMOTE_HOST_CLIENT} "bash -c '(time java -cp ./GitHub/Rest_and_RPC_research/tasks/java/jax_ws_rpc/src com.thejavageek.HelloWorldClient) 2>> GitHub/Rest_RPC_Client/reports/$EnergyPerformanceLogDirName/performance_client/$i/$j/java.txt'" &
										sleep 5
									fi	 
										# Check if remote client is still running
                                                                        	while ssh ${REMOTE_HOST_CLIENT} ps -aux | grep -i HelloWorldClient > /dev/null ;
                                                                        	do
                                                                                	sleep 1
                                                                        	done
								

                                                                        # Stop server instance
                                                                        kill -9 ${getServerPID}
									echo "Killing server processes"
                                                        		REMAINING=$(netstat -lntp 2>/dev/null | awk '{print $7}' | grep java | awk -F "/" '{print $1}')
                        			                        kill -9 ${REMAINING}
									sleep 5
								fi	
							;;
						esac

						# Once the client stopped running kill Server and WattsUp?Pro instances.
						ssh ${REMOTE_HOST_EM} sudo pkill wattsup
						echo "Killing wattsup pro"		
					fi
				;;
			esac
		done
	done
done

# Now transer all the collected data to the server in the related directories
# From client
scp -r ${REMOTE_HOST_CLIENT}:/home/pi/GitHub/Rest_RPC_Client/reports/${EnergyPerformanceLogDirName}/performance_client ../reports/${EnergyPerformanceLogDirName}/
# From RPi
scp -r ${REMOTE_HOST_EM}:/home/pi/GitHub/Rest_RPC_EM/reports/$EnergyPerformanceLogDirName/energy_server ../reports/${EnergyPerformanceLogDirName}/

echo "Transfer done"

exit 1
