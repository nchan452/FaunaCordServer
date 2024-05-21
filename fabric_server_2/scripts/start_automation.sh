#!/bin/bash

# Load configuration
source /home/opc/MCServers/FaunaCordServer/fabric_server_2/scripts/config.sh

# Define the cron job
cron_job="0 0 * * * /home/opc/MCServers/FaunaCordServer/fabric_server_2/scripts/server_init.sh"

# Function to schedule the server_init.sh script with cron
schedule_cron() {
    (crontab -l 2>/dev/null | grep -Fv "$cron_job"; echo "$cron_job") | crontab -
    echo "$(date) - Scheduled server_init.sh with cron." >> $LOG_FILE
}

# Function to check if cron job is already scheduled
is_cron_scheduled() {
    crontab -l 2>/dev/null | grep -F "$cron_job" > /dev/null 2>&1
}

# Schedule the server_init.sh script with cron if not already scheduled
if is_cron_scheduled; then
    echo "$(date) - Cron job already scheduled." >> $LOG_FILE
else
    schedule_cron
fi

# Run the server_init.sh script immediately to start the server
echo "$(date) - Running server_init.sh immediately." >> $LOG_FILE
bash /home/opc/MCServers/FaunaCordServer/fabric_server_2/scripts/server_init.sh

