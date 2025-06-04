#!/bin/bash
#
# run_capture.sh
# Rotate hourly PCAPs on eth0 and store them under /home/chronos/user/network-security/pcap_captures

# 1) Define the interface and output folder (use absolute paths)
INTERFACE="eth0"
OUTDIR="/home/chronos/user/network-security/pcap_captures"

# 2) Ensure the output directory exists (with your user’s ownership)
mkdir -p "$OUTDIR"
chown chronos:chronos "$OUTDIR"

# 3) Run tcpdump under sudo, writing one file per hour, 24-hour retention
#    -i eth0                              : capture on eth0
#    -w /home/.../%Y%m%d_%H.pcap          : strftime timestamped filename
#    -G 3600                              : rotate every 3600 seconds (1 hour)
#    -W 24                                : keep the last 24 files (delete older)
sudo /usr/sbin/tcpdump -i "$INTERFACE" \
  -w "$OUTDIR"/"%Y%m%d_%H.pcap" \
  -G 3600 \
  -W 24

