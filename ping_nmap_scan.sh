#!/bin/bash

if [ "$1" == "" ] || [ "$2" == "" ]; then
    echo "Usage: ./nmap_scans.sh [IP address] [machine name]"
    echo "Example: ./nmap_scans.sh 192.168.1.10 MyServer"
else
    if nmap -sn "$1" | grep "Host is up" &> /dev/null; then
        echo "Host $1 ($2) is reachable. Starting first Nmap scan..."

        openTCPports=$(sudo rustscan -a "$1" | grep "^ *[0-9]" | cut -d '/' -f 1 | tr '\n' ',' | sed 's/,%//')
        echo "Open TCP Ports from Rustscan: $openTCPports"

        #openTCPports=$(sudo nmap -p- "$1" | grep "^ *[0-9]" | cut -d '/' -f 1 | tr '\n' ',')
        #echo "Open TCP Ports: $openTCPports"

        sudo nmap -sV -p "$openTCPports" "$1" -oN "$2.nmap1"
        echo "First scan results saved to $2.nmap1"

        rustscan -a "$1" -p "$openTCPports" > "$2.rustScan"
        echo "First rustscan results saved to $2.rustScan"

        echo "Starting second Nmap scan on open ports..."
        sudo nmap -sT -sV -sC -O -p "$openTCPports" "$1" -oN "$2.nmap2"
        echo "Second scan results saved to $2.nmap2"

        echo "Starting third Nmap UDP scan..."
        sudo nmap -sU -p- "$1" -oN "$2.nmap3"
        echo "Third scan results saved to $2.nmap3"

        echo "Starting fourth Nmap vulnerability scan..."
        sudo nmap --script=vuln -p "$openTCPports" "$1" -oN "$2.nmap4"
        echo "Fourth scan results saved to $2.nmap4"
    else
        echo "Host $1 ($2) is not reachable. Exiting."
        exit 1
    fi
fi
