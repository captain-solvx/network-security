
#!/bin/bash
#
# suricata_start.sh
# Rotates yesterday’s EVE log, then starts Suricata with custom rules.
#

# 1) Ensure the log directory exists
mkdir -p ~/suricata/logs

# 2) Rotate yesterday’s eve.json (if it exists)
YESTERDAY=$(date -d "yesterday" +%F)
if [ -f ~/suricata/logs/eve.json ]; then
  gzip -c ~/suricata/logs/eve.json > ~/suricata/logs/eve_${YESTERDAY}.json.gz
  rm ~/suricata/logs/eve.json
fi

# 3) Kill any existing Suricata processes (so we can restart cleanly)
sudo pkill suricata

# 4) Launch Suricata
#    -i eth0                   : capture interface (replace eth0 if different)
#    -c /etc/suricata/suricata.yaml : config file
#    -S ~/suricata/rules/custom.rules : custom rules
#    --set eve-log-dir=~/suricata/logs : direct EVE JSON here
#    -l ~/suricata/logs             : log directory for fast.log etc.

sudo suricata \
  -i eth0 \
  -c /etc/suricata/suricata.yaml \
  -S ~/suricata/rules/custom.rules \
  --set eve-log-dir=~/suricata/logs \
  -l ~/suricata/logs \
  > ~/suricata/logs/fast.log 2>&1 &

echo "Suricata started at $(date). Logs: ~/suricata/logs/"
