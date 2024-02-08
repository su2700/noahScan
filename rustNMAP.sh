#!/bin/bash

# Get user inputs
target_ip="$1"  # First input: IP address
target_name="$2"  # Second input: Target name

# Run RustScan to find open ports
open_ports=$(rustscan -a "$target_ip" | grep "^ *[0-9]" | cut -d '/' -f 1 | tr '\n' ',')

# Print the open ports
echo "Open ports for $target_name ($target_ip): $open_ports"

# Run Nmap on the open ports
nmap -p "$open_ports" "$target_ip"

echo "Scanning completed for target: $target_name ($target_ip)"
