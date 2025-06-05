#!/bin/bash
#
# run_capture.sh
# Rotate hourly PCAPs on eth0, storing under /home/linux/network-security/pcap_captures

# 1) Define interface and output directory
INTERFACE="eth0"
OUTDIR="/home/linux/network-security/pcap_captures"

# 2) Ensure the output directory exists
mkdir -p "$OUTDIR"

# 3) Run tcpdump (no sudo here; the script itself is run under sudo)
/usr/bin/tcpdump -i "$INTERFACE" \
  -w "$OUTDIR"/"%Y%m%d_%H%M.pcap" \
  -G 60 \
  -W 24
