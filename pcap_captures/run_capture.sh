#!/bin/bash
#
# run_capture.sh
# Continuously rotate hourly PCAPs on eth0

INTERFACE="eth0"
OUTDIR="$HOME/pcap_captures"

# Create directory if missing
mkdir -p "$OUTDIR"

# Capture one file per hour, named YYYYMMDD_HH.pcap
# -G 3600: rotate every 3600 seconds
# -W 24: keep up to 24 files
# -w: write to file
sudo tcpdump -i "$INTERFACE" -w "$OUTDIR"/$(date +%Y%m%d_%H).pcap -G 3600 -W 24
