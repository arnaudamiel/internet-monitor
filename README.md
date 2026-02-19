# Internet Monitor

A lightweight, Go-based tool to monitor internet connection reliability and log outages. It is designed to run as a background service on Linux systems using systemd.

## Features

- **Reliable Detection**: Uses a threshold of 5 consecutive failures (1-second intervals) to avoid false positives due to network jitter.
- **Dual Targets**: Pings Google DNS (`8.8.8.8`) and Cloudflare DNS (`1.1.1.1`) via TCP to ensure accuracy.
- **Automatic Logging**: Records the start time and total duration of every detected outage to `~/internet_outages.log`.
- **Systemd Integration**: Includes scripts for easy installation and uninstallation as a persistent system service.

## Prerequisites

- **Go**: Required for compiling the monitor from source.
- **Linux/Systemd**: The installation scripts are designed for systemd-based Linux distributions.

## Installation

To build and install the monitor as a system service:

1. Clone the repository.
2. Run the installation script:
   ```bash
   ./install_monitor.sh
   ```
   *Note: This script will require `sudo` privileges to move the binary and create the systemd service.*

The monitor will be compiled, moved to `/usr/local/bin/`, and started as a service named `internet-monitor`.

## Usage

### Monitoring Logs
Outages are logged in your home directory:
```bash
tail -f ~/internet_outages.log
```

### Managing the Service
You can check the status of the monitor using `systemctl`:
```bash
systemctl status internet-monitor
```

To stop or start the service manually:
```bash
sudo systemctl stop internet-monitor
sudo systemctl start internet-monitor
```

## Uninstallation

To stop the service and remove all related files (except logs, which are optional):
```bash
./uninstall_monitor.sh
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
