#!/bin/bash

# Load configuration
source /home/opc/MCServers/FaunaCordServer/fabric_server_2/scripts/config.sh

# Exit immediately if any command exits with a non-zero status
set -e

# Function to handle errors
error_handler() {
    echo "$(date) - Error occurred in server_init.sh. Exiting..." >> $LOG_FILE
    exit 1
}

# Trap errors
trap error_handler ERR

# Function to check if the server_keeper.sh script is running
is_server_running() {
    echo "$(date) - Running is_server_running function" >> $LOG_FILE
    pgrep -f "/home/opc/MCServers/FaunaCordServer/fabric_server_2/scripts/server_keeper.sh" > /dev/null 2>&1
}

# move to the right directory 
cd /home/opc/MCServers/FaunaCordServer/fabric_server_2

# Create a new tmux session if it doesn't exist
if ! tmux has-session -t $TMUX_SESSION 2>/dev/null; then
    echo "$(date) - Creating new tmux session: $TMUX_SESSION" >> $LOG_FILE
    tmux new-session -d -s $TMUX_SESSION
    if [ $? -ne 0 ]; then
        echo "$(date) - Failed to create tmux session." >> $LOG_FILE
        exit 1
    fi
else
    echo "$(date) - tmux session $TMUX_SESSION already exists." >> $LOG_FILE
fi

# Check if server_keeper.sh is running
if is_server_running; then
    echo "$(date) - server_keeper.sh is running. Proceeding with stop and restart..." >> $LOG_FILE

    # Run the stop.sh script to stop the server and create a backup
    echo "$(date) - Running server_stop.sh script..." >> $LOG_FILE
    bash /home/opc/MCServers/FaunaCordServer/fabric_server_2/scripts/server_stop.sh
fi

# Start the server with server_keeper.sh script inside tmux
echo "$(date) - Starting the server with server_keeper.sh script..." >> $LOG_FILE
tmux send-keys -t $TMUX_SESSION "bash /home/opc/MCServers/FaunaCordServer/fabric_server_2/scripts/server_keeper.sh" C-m
echo "$(date) - Server started successfully." >> $LOG_FILE

