#!/bin/bash

# Exit if not running as root (Root is required for HugePages and MSR mod for max performance)
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root (e.g., sudo ./install_mine.sh) to enable max performance optimizations."
  exit
fi

echo "Updating packages and installing prerequisites..."
apt-get update
apt-get install -y wget tar

# Set the XMRig version to download
XMRIG_VERSION="6.21.0"
DOWNLOAD_URL="https://github.com/xmrig/xmrig/releases/download/v${XMRIG_VERSION}/xmrig-${XMRIG_VERSION}-linux-static-x64.tar.gz"

echo "Downloading XMRig v${XMRIG_VERSION}..."
wget $DOWNLOAD_URL -O xmrig.tar.gz

echo "Extracting XMRig..."
tar -zxvf xmrig.tar.gz
cd xmrig-${XMRIG_VERSION}

echo "Configuring HugePages in the OS..."
# Allocating 1280 huge pages (approx 2.5GB of RAM), which is heavily recommended for RandomX
sysctl -w vm.nr_hugepages=1280

echo "Starting XMRig Benchmark..."
# Running an offline benchmark for 1 million hashes to test raw hashrate
./xmrig -a rx --bench=1M
