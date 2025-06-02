
#!/usr/bin/env python3
"""
suricata_summary.py
Generate a daily summary of Suricata alerts from EVE JSON logs.
"""

import os
import json
import gzip
import datetime
from collections import Counter

# Optional: Install geoip2 via pip: pip install geoip2
# Place the GeoLite2-Country.mmdb in a known location (e.g. ~/GeoLite2-Country.mmdb)
from geoip2.database import Reader as GeoIP2Reader

# ==== CONFIGURE THESE PATHS ====
LOG_DIR = os.path.expanduser("~/suricata/logs")
GEOIP_DB_PATH = os.path.expanduser("~/GeoLite2-Country.mmdb")
# ===============================

def find_latest_eve_file(log_dir):
    """
    Returns the path to yesterday's gzipped eve JSON if present,
    otherwise returns the live eve.json if exists.
    """
    yesterday = datetime.datetime.now() - datetime.timedelta(days=1)
    date_str = yesterday.strftime("%F")
    gzipped = os.path.join(log_dir, f"eve_{date_str}.json.gz")
    if os.path.isfile(gzipped):
        return gzipped, True
    live = os.path.join(log_dir, "eve.json")
    if os.path.isfile(live):
        return live, False
    return None, False

def parse_eve(eve_path, is_gzipped):
    """
    Parse the EVE JSON file and count signatures and destinations.
    """
    sig_counts = Counter()
    dest_counts = Counter()

    # Open the file (gzip if needed)
    if is_gzipped:
        f = gzip.open(eve_path, "rt")
    else:
        f = open(eve_path, "r")

    for line in f:
        try:
            evt = json.loads(line)
        except json.JSONDecodeError:
            continue
        if evt.get("event_type") == "alert":
            sig = evt["alert"].get("signature", "UNKNOWN")
            sig_counts[sig] += 1
            dst = evt.get("dest_ip", None)
            if dst:
                dest_counts[dst] += 1

    f.close()
    return sig_counts, dest_counts

def geolocate_top_ips(dest_counts, top_n=5):
    """
    Use GeoIP2 to look up country codes for the top_n destinations.
    Returns a dict: { ip: country_code }
    """
    geo_info = {}
    if not os.path.isfile(GEOIP_DB_PATH):
        return {ip: "??" for ip, _ in dest_counts.most_common(top_n)}

    reader = GeoIP2Reader(GEOIP_DB_PATH)
    for ip, _ in dest_counts.most_common(top_n):
        try:
            rec = reader.country(ip)
            geo_info[ip] = rec.country.iso_code
        except Exception:
            geo_info[ip] = "??"
    reader.close()
    return geo_info

def main():
    eve_file, gzipped = find_latest_eve_file(LOG_DIR)
    if eve_file is None:
        print("No EVE JSON file found in", LOG_DIR)
        return

    sig_counts, dest_counts = parse_eve(eve_file, gzipped)
    top_sigs = sig_counts.most_common(5)
    top_dests = dest_counts.most_common(5)
    geo_info = geolocate_top_ips(dest_counts, top_n=5)

    today = datetime.datetime.now().strftime("%F")
    print(f"\n=== Suricata Summary for {today} ===\n")

    print("Top 5 Alert Signatures:")
    if top_sigs:
        for sig, count in top_sigs:
            print(f"  {count:6}  {sig}")
    else:
        print("  No alerts logged.")

    print("\nTop 5 External IPs Contacted:")
    if top_dests:
        for ip, count in top_dests:
            cc = geo_info.get(ip, "??")
            print(f"  {count:6}  {ip}  ({cc})")
    else:
        print("  No external IPs logged.")

    print("\n")

if __name__ == "__main__":
    main()
