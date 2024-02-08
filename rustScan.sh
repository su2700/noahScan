#!/bin/bash

if [ "$1" == "" ] || [ "$2" == "" ]; then
    echo "Usage: ./rustscan_scans.sh [IP address] [machine name]"
    echo "Example: ./rustscan_scans.sh 192.168.1.10 MyServer"
    exit 1
else
    IP_ADDRESS="$1"
    MACHINE_NAME="$2"

    # Check if the host is reachable
    if rustscan -a "$IP_ADDRESS" | grep "Open" &> /dev/null; then
        echo "Host $IP_ADDRESS ($MACHINE_NAME) is reachable. Starting RustScan..."
        
        # Get open TCP ports
        open_ports=$(rustscan -a "$target_ip" | grep "^ *[0-9]" | cut -d '/' -f 1 | tr '\n' ',' | sed 's/,%//')        echo "Open TCP Ports: $openTCPports"
        
        # First scan
        rustscan -a "$IP_ADDRESS" -p "$openTCPports" > "$MACHINE_NAME.rustScan1"
        echo "First scan results saved to $MACHINE_NAME.rustScan1.txt"
        
        # Second scan
        echo "Starting second RustScan on open ports..."
        rustscan -a "$IP_ADDRESS" -p "$openTCPports" -A -sC > "$MACHINE_NAME.rustScan2"
        echo "Second scan results saved to $MACHINE_NAME.rustScan2.txt"

        # Third scan (UDP scan with Nmap)
        echo "Starting third Nmap UDP scan..."
        sudo nmap -sU -p 1-65535 "$IP_ADDRESS" -oN "$MACHINE_NAME.udpScan3"
        echo "Third scan results saved to $MACHINE_NAME.udpScan3"

        echo "Starting fourth RustScan vulnerability scan..."
        # Use Nmap for vulnerability scanning with scripts (modify as needed)
        sudo nmap -p "$openTCPports" --script vuln -oN "$MACHINE_NAME.rustScan4.txt"
        echo "Fourth scan results saved to $MACHINE_NAME.rustScan4.txt"
    else
        echo "Host $IP_ADDRESS ($MACHINE_NAME) is not reachable. Exiting."
        exit 1
    fi
fi
