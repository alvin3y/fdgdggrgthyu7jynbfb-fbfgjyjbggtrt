#!/bin/bash

echo "=========================================================="
echo "      INTERNAL-TO-EXTERNAL CONNECTIVITY AUDIT"
echo "=========================================================="

# 1. FIND YOUR PUBLIC IDENTITY
echo -e "\n[1] PUBLIC IP DISCOVERY"
# This tells us the IP the world sees when this workspace talks to the internet
PUBLIC_IP=$(curl -s https://ifconfig.me)
echo "Your Workspace Public IP: $PUBLIC_IP"
# Check who owns this IP (AWS, Google, or your Company)
echo "IP Provider Info:"
curl -s "https://ipinfo.io/$PUBLIC_IP/org"

# 2. CHECK FOR INBOUND VISIBILITY
echo -e "\n[2] INBOUND SERVICE SCAN"
# Check if an SSH server is running (Standard way to tunnel into a workspace)
if command -v ss &> /dev/null; then
    ss -lnt | grep -E ":22|:2222" && echo "✅ SSH Server detected (Potential Tunnel Entrance)"
fi

# 3. IDENTIFY CLOUD PROVIDER
echo -e "\n[3] INFRASTRUCTURE IDENTIFICATION"
if [ -f /sys/class/dmi/id/product_name ]; then
    cat /sys/class/dmi/id/product_name | xargs echo "Machine Type:"
fi

# 4. TEST OUTBOUND TUNNELING CAPABILITY
echo -e "\n[4] TUNNELING FEASIBILITY TEST"
# Can this workspace "dial out" to a tunnel service?
timeout 2 bash -c "</dev/tcp/google.com/443" &>/dev/null
if [ $? -eq 0 ]; then
    echo "✅ Outbound connection possible. (You could use a Reverse Tunnel)"
else
    echo "❌ Outbound traffic restricted."
fi

# 5. LOCATE THE PROXY'S ACTUAL LOCATION
echo -e "\n[5] PROXY PROXIMITY"
# Trace how many 'hops' away the proxy is
if command -v traceroute &> /dev/null; then
    traceroute -n proxy | head -n 5
else
    echo "Traceroute not installed. Checking internal ARP table:"
    arp -a | grep "proxy"
fi

echo -e "\n=========================================================="
echo "                   AUDIT COMPLETE"
echo "=========================================================="
