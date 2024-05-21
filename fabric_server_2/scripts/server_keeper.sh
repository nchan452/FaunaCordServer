#!/bin/bash

# Load configuration
source /home/opc/MCServers/FaunaCordServer/fabric_server_2/scripts/config.sh

# Exit immediately if any command exits with a non-zero status
set -e

# Function to handle errors
error_handler() {
    echo "$(date) - Error occurred in server_keeper.sh. Exiting..." >> $LOG_FILE
    exit 1
}

# Trap errors
trap error_handler ERR

# Set JVM options
export JAVA_TOOL_OPTIONS="$JVM_OPTIONS"

# Array to keep track of crash timestamps
crash_timestamps=()

# Function to check crash frequency
check_crash_frequency() {
    local now=$(date +%s)
    crash_timestamps=($(for ts in "${crash_timestamps[@]}"; do
        (( $now - $ts < $TIME_FRAME )) && echo $ts
    done))

    if (( ${#crash_timestamps[@]} >= $CRASH_LIMIT )); then
        echo "Server has crashed ${CRASH_LIMIT} times within the last ${TIME_FRAME} seconds. Stopping restart attempts." >> $LOG_FILE
        exit 1
    fi
}

# move to the right directory 
cd /home/opc/MCServers/FaunaCordServer/fabric_server_2

# Main loop to start and monitor the server
while true; do
    echo "$(date) - Starting the Minecraft server..." >> $LOG_FILE
    sudo nice -n -18 java -Xmx10G -Xms10G -jar $SERVER_JAR_PATH nogui
    
    echo "$(date) - Server closed/crashed... restarting in $RESTART_DELAY seconds!" >> $LOG_FILE
    
    crash_timestamps+=($(date +%s))
    
    check_crash_frequency
    
    sleep $RESTART_DELAY
done

