#!/bin/bash

SERVICE_NAME="internet-monitor"
BINARY_PATH="/usr/local/bin/internet-monitor"
LOG_PATH="$HOME/internet_outages.log"

echo "--- Uninstalling $SERVICE_NAME ---"

# 1. Stop and disable the service
echo "Stopping and disabling service..."
sudo systemctl stop $SERVICE_NAME
sudo systemctl disable $SERVICE_NAME

# 2. Remove the service file
echo "Removing systemd service file..."
sudo rm /etc/systemd/system/$SERVICE_NAME.service
sudo systemctl daemon-reload

# 3. Remove the binary
echo "Removing binary from $BINARY_PATH..."
sudo rm $BINARY_PATH

# 4. Optional: Ask to remove logs
read -p "Do you want to delete the log file ($LOG_PATH)? (y/n): " confirm
if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
    rm $LOG_PATH
    echo "Logs deleted."
else
    echo "Logs preserved at $LOG_PATH."
fi

echo "--- Uninstallation Complete ---"

