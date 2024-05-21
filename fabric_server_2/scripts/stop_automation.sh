#!/bin/bash

# Load configuration
source /home/opc/MCServers/FaunaCordServer/fabric_server_2/scripts/config.sh

# Define the cron job
cron_job="0 0 * * * /home/opc/MCServers/FaunaCordServer/fabric_server_2/scripts/server_init.sh"

# Function to unschedule the cron task created by start_automation.sh
unschedule_cron() {
    (crontab -l 2>/dev/null | grep -Fv "$cron_job") | crontab -
    echo "$(date) - Unscheduled server_init.sh from cron." >> $LOG_FILE
}

# Function to check if the server is running
is_server_running() {
    pgrep -f "/home/opc/MCServers/FaunaCordServer/fabric_server_2/scripts/server_keeper.sh" > /dev/null 2>&1
}

# Unschedule the cron task
unschedule_cron

# Run the server_stop.sh script if the server is running
if is_server_running; then
    echo "$(date) - Server is running. Running server_stop.sh." >> $LOG_FILE
    bash /home/opc/MCServers/FaunaCordServer/fabric_server_2/scripts/server_stop.sh
else
    echo "$(date) - Server is not running. Nothing to stop." >> $LOG_FILE
fi

