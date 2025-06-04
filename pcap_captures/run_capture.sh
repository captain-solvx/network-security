#!/bin/bash
#
# run_capture.sh
# Continuously rotate hourly PCAPs on eth0

INTERFACE="eth0"
USER_HOME="/home/chronos/user"
OUTDIR="$USER_HOME/network-security/pcap_captures"

# Ensure the correct directory under your user’s home
mkdir -p "$OUTDIR"

# Run tcpdump as root, but write into your user’s folder
# -G 3600       : rotate every 3600 seconds (1 hour)
# -W 24         : keep a sliding window of 24 files
# -w "$OUTDIR/%Y%m%d_%H.pcap": strftime pattern
sudo tcpdump -i "$INTERFACE" \
  -w "$OUTDIR/%Y%m%d_%H.pcap" \
  -G 3600 \
  -W 24
