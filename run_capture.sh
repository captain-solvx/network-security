#!/bin/bash

# Set up directory
CAPTURE_DIR="./pcap_captures"
mkdir -p "$CAPTURE_DIR"
chmod 755 "$CAPTURE_DIR"

# Create a timestamped file name
FILENAME="$CAPTURE_DIR/capture-$(date +%Y%m%d%H%M%S).pcap"

# Run tcpdump with 60-second file rotation (test mode)
# Replace -i any with your preferred interface if needed
tcpdump -i any -G 60 -w "$CAPTURE_DIR/capture-%Y%m%d%H%M%S.pcap"

# Fix ownership so Git and you can access the file
sudo chown "$USER:$USER" "$FILENAME"
chmod 644 "$FILENAME"
