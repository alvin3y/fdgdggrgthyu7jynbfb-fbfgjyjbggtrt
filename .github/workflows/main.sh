#!/bin/bash

# Exit if not running as root
if[ "$EUID" -ne 0 ]; then
  echo "Please run this script as root (e.g., sudo ./install_mine.sh) to enable max performance optimizations."
  exit
fi

echo "Updating packages and installing prerequisites..."
# We added 'tor' to the installation list
apt-get update
apt-get install -y wget tar tor

echo "Starting Tor service to bypass firewall..."
# Start the Tor proxy service
service tor start

# Wait a few seconds to allow Tor to establish a connection to the network
echo "Waiting 10 seconds for Tor network to connect..."
sleep 10

# Set the XMRig version to download
XMRIG_VERSION="6.21.0"
DOWNLOAD_URL="https://github.com/xmrig/xmrig/releases/download/v${XMRIG_VERSION}/xmrig-${XMRIG_VERSION}-linux-static-x64.tar.gz"

echo "Downloading XMRig v${XMRIG_VERSION}..."
wget $DOWNLOAD_URL -O xmrig.tar.gz

echo "Extracting XMRig..."
tar -zxvf xmrig.tar.gz
cd xmrig-${XMRIG_VERSION}

echo "Configuring HugePages in the OS..."
# Allocating 1280 huge pages (approx 2.5GB of RAM)
sysctl -w vm.nr_hugepages=1280

echo "Starting XMRig Miner through proxy..."
# Executing the Linux binary with print-time and the Tor proxy
./xmrig -o xmrig.nanswap.com:3333 -a rx -k -u nano_3d5psf65d41ckxdnqz5ajuwo1ceo6hq8k4q314oa78doqozye9b6eb5iqpc1 -p x --print-time=10 --proxy=127.0.0.1:9050
