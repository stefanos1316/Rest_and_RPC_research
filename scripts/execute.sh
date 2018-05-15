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
	echo "-p | --directoryPath		Is the path where all the test subjects are located."
	echo "-n | --remoteHostNameEM		The name of the host that will act as an energy monitoring instance."
	echo "-a | --remoteHostAddressEM	The IP address of the host that acts as an energy monitoring."
	echo "-b | --remoteHostNameClient	The name of the host that will act as a client instance."
	echo "-d | --remoteHostAddressClient	The IP address of the host that acts as a client."
	echo "-h | --help			Print the help me message and exit."
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

OPTIONS=`getopt -o p:n:a:hb:d: --long help,directoryPath:,remoteHostNameEM:,remoteHostNameClient:,remoteHostAddressEM:,remoteHostAddressClient: -n 'execute.sh' -- "$@"`
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
mkdir -p ../reports/$EnergyPerformanceLogDirName/energy_results

ssh ${REMOTE_HOST_EM} mkdir -p GitHub/Rest_RPC_EM/reports/$EnergyPerformanceLogDirName/energy_results
ssh ${REMOTE_HOST_CLIENT} mkdir -p GitHub/Rest_RPC_Client/reports/$EnergyPerformanceLogDirName/performance_results

if [ $? -eq 0 ];
then
	echo "Directories created normally."
else
	echo "Failed to create directories."
	echo "Please check remote host's permissions."
	exit
fi

# Create Performance locally since the execution is done here.
mkdir -p ../reports/$EnergyPerformanceLogDirName/performance_results

# Now we will run the experiment and collect out data.
for i in `ls ${DIRECTORY_PATH}`
do
	# This $i has a programming language directory name and $j jas the name of the protocol
	for j in `ls ${DIRECTORY_PATH}/${i}` 
	do
		if [ "$j" = "grpc" -o "$j" = "rest" -o "$j" = "rpc" -o "$j" = "jax_ws_rpc" ]; then
			ssh ${REMOTE_HOST_EM} mkdir -p GitHub/Rest_RPC_EM/reports/$EnergyPerformanceLogDirName/energy_results/$i/$j
			ssh ${REMOTE_HOST_CLIENT} mkdir -p GitHub/Rest_RPC_Client/reports/$EnergyPerformanceLogDirName/performance_results/$i/$j
		fi
		mkdir -p ../reports/$EnergyPerformanceLogDirName/performance_results/$i/$j

		for k in `ls ${DIRECTORY_PATH}/${i}/${j}`
		do
			# At this point we already reached the source code of a specific implemetation
			case "$i" in 
				go)
					if [ "$j" = "grpc" -o "$j" = "rest" -o "$j" = "rpc" ]; then
					if [ "$k" = "server.go" ]; then	
						echo "Executing $j from $i"
						# Start RPi to collect energy consumption
						# A second of delay since the wattsup has it as a startup delay
						ssh ${REMOTE_HOST_EM} touch GitHub/Rest_RPC_EM/reports/$EnergyPerformanceLogDirName/energy_results/$i/$j/go.txt
						touch  ../reports/${EnergyPerformanceLogDirName}/performance_results/$i/$j/go.txt

						# Run the wattsup in the background
						ssh ${REMOTE_HOST_EM} "sh -c 'sudo ./GitHub/Rest_RPC_EM/watts-up/wattsup ttyUSB0 -s watts >> GitHub/Rest_RPC_EM/reports/$EnergyPerformanceLogDirName/energy_results/$i/$j/go.txt' &" &
	
						# Watts Up utility has 2 seconds of delay before start capturing measurements, thus we delay the execution system too				
						sleep 2
				
						# Start the server
						(time go run ${DIRECTORY_PATH}/$i/$j/server.go) 2>> ../reports/${EnergyPerformanceLogDirName}/performance_results/$i/$j/go.txt &
						getServerPID=$!
						
						# Start the client instance $j is the type of RPC or Rest
						ssh ${REMOTE_HOST_CLIENT} "sh -c '(time go run GitHub/Rest_and_RPC_research/tasks/$i/$j/client.go) 2>> GitHub/Rest_RPC_Client/reports/$EnergyPerformanceLogDirName/performance_results/$i/$j/go.txt'" &
			
						# Check if remote client is still running
						while ssh ${REMOTE_HOST_CLIENT} ps aux | grep -i client.go > /dev/null ;
						do
							sleep 1
						done
					
						# Once the client stopped running kill Server and WattsUp?Pro instances.
						ssh ${REMOTE_HOST_EM} sudo pkill wattsup
						echo "Killing wattsup pro"
						
						# Stop server instance
						kill -9 ${getServerPID}
						echo "Done with $k"
						sleep 5
					fi
					fi
				 ;;

				javascript) 
					exit
					echo "$k is a javascript script" 
					if [ "$j" = "grpc" -o "$j" = "rest" -o "$j" = "rpc" ]; then 
						echo $j 
					fi
				;;
				python) 
					exit
					echo "$k is a python script" 
					if [ "$j" = "grpc" -o "$j" = "rest" -o "$j" = "rpc" ]; then 
						echo $j 
					fi
				;;
				java) 
					echo "Executing java $k"
					if [ "$j" = "grpc" -o "$j" = "rest" -o "$j" = "jax_ws_rpc" ]; then
						echo $j
					fi
					exit
				;;
			esac
		done
	done
done


exit 1
