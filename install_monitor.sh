#!/bin/bash

# Define variables
SERVICE_NAME="internet-monitor"
BINARY_NAME="internet-monitor"
INSTALL_PATH="/usr/local/bin/$BINARY_NAME"
LOG_PATH="$HOME/internet_outages.log"
USER_NAME=$(whoami)

echo "--- Installing $SERVICE_NAME ---"

# 1. Build the Go program
if [ -f "uptime_monitor.go" ]; then
    echo "Compiling Go program..."
    go build -o $BINARY_NAME uptime_monitor.go
else
    echo "Error: uptime_monitor.go not found!"
    exit 1
fi

# 2. Move binary to system path
echo "Moving binary to $INSTALL_PATH..."
sudo mv $BINARY_NAME $INSTALL_PATH

# 3. Create the systemd service file
echo "Creating systemd service..."
sudo bash -c "cat > /etc/systemd/system/$SERVICE_NAME.service <<EOF
[Unit]
Description=Internet Connection Monitor
After=network.target

[Service]
ExecStart=$INSTALL_PATH
WorkingDirectory=$HOME
Nice=-10
User=$USER_NAME
Restart=always

[Install]
WantedBy=multi-user.target
EOF"

# 4. Start the service
echo "Starting service..."
sudo systemctl daemon-reload
sudo systemctl enable $SERVICE_NAME
sudo systemctl start $SERVICE_NAME

echo "--- Installation Complete! ---"
echo "Logs will be written to: $LOG_PATH"

