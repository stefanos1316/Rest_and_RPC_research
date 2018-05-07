#!/bin/bash


############################################################################################################################################
#					ALL FUNCTIONS HERE		
############################################################################################################################################

# Check via if the give host is running
function checkRemoteHostSSH {
	#Check if nmap exist on the host, otherwise recommend to install it
	if nmap --version | grep "command not found"; then
		echo "Nmap not found in local host."
		echo "Please install nmap before procceding any further."
		echo "Exiting..."
		exit
	fi

	if nmap -p22 $2 -oG - | grep -q 22/open; then 
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
	echo "-b | --remoteHostNameAServer	The name of the host that will act as a server instance."
	echo "-d | --remoteHostAddressServer	The IP address of the host that acts as a server."
	echo "-h | --help			Print the help me message and exit."
	echo "-s | --server			Take measurements from the server instance."
	echo "-c | --client			Take measurements from the client instance."
	echo

	exit
}

############################################################################################################################################

# Script for runnig the experiment to collect results for Rest and RPC


# Command line arguments
DIRECTORY_PATH=""
REMOTE_HOST_NAME_EM=""
REMOTE_HOST_ADDRESS_EM=""
REMOTE_HOST_NAME_SERVER=""
REMOTE_HOST_ADDRESS_SERVER=""
SERVER=false
CLIENT=false

OPTIONS=`getopt -o p:n:a:schb:d: --long help,directoryPath:,remoteHostNameEM:,remoteHostNameServer:,remoteHostAddressEM:,remoteHostAddressServer:,server,client -n 'execute.sh' -- "$@"`
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
		-b|--remoteHostNameServer) 
			case $2 in 
				*[a-zA-Z0-9]*) REMOTE_HOST_NAME_SERVER=$2 ; shift 2 ;;
				*) >&2 echo "[Error] Host name is required!" ; shift 2 ;;
			esac ;;
		-d|--remoteHostAddressServer) 
			case $2 in 
				*\.*\.*\.*) REMOTE_HOST_ADDRESS_SERVER=$2 ; shift 2 ;;
				*) >&2 echo "[Error] IP address is required!" ; shift 2 ;;
			esac ;;
		-s|--server) SERVER=true; shift ;;
		-c|--client) CLIENT=true; shift ;;
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
checkRemoteHostSSH ${REMOTE_HOST_NAME_SERVER} ${REMOTE_HOST_ADDRESS_SERVER}

# Create REMOTEHOST is a single variable for server and em
REMOTE_HOST_EM=${REMOTE_HOST_NAME_EM}@${REMOTE_HOST_ADDRESS_EM}
REMOTE_HOST_SERVER=${REMOTE_HOST_NAME_SERVER}@${REMOTE_HOST_ADDRESS_SERVER}

# If the script is still running it means ssh connection is fine.
mkdir -p ../reports/$EnergyPerformanceLogDirName/energy_results

ssh ${REMOTE_HOST_EM} mkdir -p ~/GitHub/Rest_RPC_EM/reports/$EnergyPerformanceLogDirName/energy_results
ssh ${REMOTE_HOST_SERVER} mkdir -p ~/GitHub/Rest_RPC_Server/reports/$EnergyPerformanceLogDirName/performance_results

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
	for j in `ls ${DIRECTORY_PATH}/${i}` 
	do
		ssh ${REMOTE_HOST_EM} mkdir -p ~/GitHub/Rest_RPC_EM/reports/$EnergyPerformanceLogDirName/energy_results/$j
		ssh ${REMOTE_HOST_SERVER} mkdir -p ~/GitHub/Rest_RPC_Server/reports/$EnergyPerformanceLogDirName/performance_results/$j
		mkdir -p ../reports/$EnergyPerformanceLogDirName/performance_results/$j

		for k in `ls ${DIRECTORY_PATH}/${i}/${j}`
		do
			# At this point we already reached the source code of a specific implemetation
			case "$k" in 
				*.go) 
					echo "Executing go's $j 's code"

					# Now we are going to retrieve measurements from Server Instance
					if [  ${SERVER} = true ]; then
						# Start RPi to collect energy consumption
						# A second of delay since the wattsup has it as a startup delay
						ssh ${REMOTE_HOST_EM} touch ~/GitHub/Rest_RPC_EM/reports/$EnergyPerformanceLogDirName/energy_results/$j/go.txt
						touch  ../reports/${EnergyPerformanceLogDirName}/performance_results/$j/go.txt

						# Run the wattsup in the background
						ssh ${REMOTE_HOST_EM} "sh -c 'sudo ./GitHub/Rest_RPC_EM/watts-up/wattsup ttyUSB0 -s watts >> ~/GitHub/Rest_RPC_EM/reports/$EnergyPerformanceLogDirName/energy_results/$j/go.txt' &" &
						
						# Watts Up utility has 2 seconds of delay before start capturing measurements, thus we delay the execution system too				
						sleep 2
				
						# Test until this part
						sleep 5 
						exit

						# Start the server instance $j is the type of RPC or Rest
						ssh ${REMOTE_HOST_SERVER} "sh -c './GitHub/Rest_RPC_Server/go/$j/server.go'"
						
						# Start the client
						exec=$(time /usr/local/go/bin/go run client.go)
						eval $exec &
						getClientID=$!
						

						# While our tasks is still running sleep a second and start again
						while  ps -p ${getClientPID} > /dev/null ;
						do
							sleep 1
						done
					
						# Once the client stopped running kill Server and WattsUp?Pro instances.
						ssh ${REMOTE_HOST_EM} sudo pkill wattsup
						ssh ${REMOTE_HOST_SERVER} sudo kill -9  		
					fi
				 ;;

				*.js) 
					echo "$k is a javascript script" 
				;;
				*.py) echo "$k is a python script" ;;
				*.*) echo "This should be here..." ;;
			esac
		done
	done
done


exit 1
