#!/bin/bash

# Load configuration
source /home/opc/MCServers/FaunaCordServer/fabric_server_2/scripts/config.sh

# Exit immediately if any command exits with a non-zero status
set -e

# Function to handle errors
error_handler() {
    echo "$(date) - Error occurred in server_stop.sh. Exiting..." >> $LOG_FILE
    exit 1
}

# Trap errors
trap error_handler ERR

# Function to send a command to the Minecraft server
send_command() {
    tmux send-keys -t $TMUX_SESSION "$1" C-m
}

# Announce the server stop and restart
echo "$(date) - Announcing server stop..." >> $LOG_FILE
send_command "say Server will restart in 5 minutes. Please prepare to disconnect."
sleep 240

send_command "say Server will restart in 1 minute. Please prepare to disconnect."
sleep 50

send_command "say Server will restart in 10 seconds."
sleep 5
send_command "say Server will restart in 5 seconds."
sleep 1
send_command "say Server will restart in 4 seconds."
sleep 1
send_command "say Server will restart in 3 seconds."
sleep 1
send_command "say Server will restart in 2 seconds."
sleep 1
send_command "say Server will restart in 1 second."
sleep 1

# Stop the Minecraft server
echo "$(date) - Stopping the Minecraft server..." >> $LOG_FILE
send_command "stop"

# Wait to ensure the server has stopped
sleep 10

# Stop the server_keeper.sh script
echo "$(date) - Stopping the server_keeper.sh script..." >> $LOG_FILE
server_keeper_script_pid=$(pgrep -f "./server_keeper.sh")
if [ ! -z "$server_keeper_script_pid" ]; then
    kill $server_keeper_script_pid
    echo "$(date) - server_keeper.sh script stopped successfully." >> $LOG_FILE
else
    echo "$(date) - server_keeper.sh script not running or already stopped." >> $LOG_FILE
fi

# Create a backup of the server directory
echo "$(date) - Creating a backup of the server directory..." >> $LOG_FILE
mkdir -p $BACKUP_DIR
cd /home/opc/MCServers/FaunaCordServer
sudo tar -czf $BACKUP_DIR/fabric_server_2_backup_$(date +'%Y%m%d_%H%M%S').tar.gz ./fabric_server_2

# Clean the log file
echo "$(date) - Cleaning the log file..." >> $LOG_FILE
> $LOG_FILE
echo "$(date) - Log file cleaned..." >> $LOG_FILE

# Delete backups older than 2 days
echo "$(date) - Deleting backups older than 2 days..." >> $LOG_FILE
sudo find $BACKUP_DIR -type f -name 'fabric_server_2_backup_*.tar.gz' -mtime +2 -exec rm {} \;

echo "$(date) - Server stop process completed." >> $LOG_FILE


