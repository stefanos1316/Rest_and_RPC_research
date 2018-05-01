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

############################################################################################################################################

# Script for runnig the experiment to collect results for Rest and RPC

# Command line arguments
DIRECTORY_PATH=""
REMOTE_HOST_NAME=""
REMOTE_HOST_ADDRESS=""
SERVER=false
CLIENT=false

OPTIONS=`getopt -o p:n:a:sc --long directoryPath:,remoteHostName:,remoteHostAddress:,server,client -n 'execute.sh' -- "$@"`
eval set -- "$OPTIONS"
while true; do
	case "$1" in 
		-p|--directoryPath) 
			case $2 in 
				*/*) DIRECTORY_PATH=$2 ; shift 2 ;;
				*) >&2 echo "[Error] Directory path is required!" ; shift 2 ;;
			esac ;;
		-n|--remoteHostName) 
			case $2 in 
				*[a-zA-Z0-9]*) REMOTE_HOST_NAME=$2 ; shift 2 ;;
				*) >&2 echo "[Error] Host name is required!" ; shift 2 ;;
			esac ;;
		-a|--remoteHostAddress) 
			case $2 in 
				*\.*\.*\.*) REMOTE_HOST_ADDRESS=$2 ; shift 2 ;;
				*) >&2 echo "[Error] IP address is required!" ; shift 2 ;;
			esac ;;
		-s|--server) SERVER=true ; shift ;;
		-c|--client) CLIENT=true ; shift ;;
		--) shift ; break ;;
		*) >&2 echo "Wrong command line argument, please try again." ; exit 1 ;;
	esac
done

# Create parameters for the directory names
EnergyPerformanceLogDataDate=$(date -u | sed -e 's/ /_/g')
EnergyPerformanceLogDirName="experiment_data_"$EnergyPerformanceLogDataDate

#Before creating directories check if the remote host is acticvated and SSH is running
checkRemoteHostSSH ${REMOTE_HOST_NAME} ${REMOTE_HOST_ADDRESS}

# Create REMOTEHOST is a single variable
REMOTE_HOST==${REMOTE_HOST_NAME}@${REMOTE_HOST_ADDRESS}

# If the script is still running it means ssh connection is fine.
mkdir -p ../reports/$EnergyPerformanceLogDirName
mkdir -p ../reports/$EnergyPerformanceLogDirName/energy_results

SSH_AUTH_SOCK=0 ssh ${REMOTE_HOST} mkdir -p GitHub/Rest_RPC_EM/reports/$EnergyPerformanceLogDirName
SSH_AUTH_SOCK=0 ssh $remoteHost mkdir -p GitHub/Rosetta-Code-Research/Reports/$EnergyPerformanceLogDirName/Energy_Results

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
		for k in `ls ${DIRECTORY_PATH}/${i}/${j}`
		do
			case "$k" in 
				*.go) 
					echo "Executing go's $j 's code"
					if [ ${CLIENT} = true ]; then

						# Start RPi to collect energy consumption
						# A second of delay since the wattsup has it as a startup delay
						SSH_AUTH_SOCK=0 ssh ${REMOTE_HOST} touch GitHub/Rest_RPC_EM/energy_results/$containesTasks/c.txt
						touch  ../reports/

						# Run the wattsup in the background
						SSH_AUTH_SOCK=0 ssh $remoteHost "sh -c 'sudo ./GitHub/Rosetta-Code-Research/watts-up/wattsup ttyUSB0 -s watts >> GitHub/Rosetta-Code-Research/Reports/$EnergyPerformanceLogDirName/Energy_Results/$containesTasks/c.txt' &" &
						
						# Watts Up utility has 2 seconds of delay before start capturing measurements, thus we delay the execution system too				
						sleep 2
				
						# Start the server instance
						time /usr/local/go/bin/go run server.go
						getServerPID=$!

						

						# Start the client
						

						# While our tasks is still running sleep a second and start again
						while  ps -p ${getServerPID} > /dev/null ;
						do
							sleep 1
						done
					
						# Once the client stopped running 
					fi
				 ;;

				*.js) echo "$k is a javascript script" ;;
				*.py) echo "$k is a python script" ;;
				*.*) echo "This should be here..." ;;
			esac
		done
	done
done


exit 1
