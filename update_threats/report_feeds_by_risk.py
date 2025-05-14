#!/usr/bin/env python3
# **********************************************************************
# report_feeds_by_risk.py
# Description:
#   - Loads feeds.yaml and merged output files
#   - Outputs a risk_summary.csv sorted by risk level
#   - Optional: HTML summary (future)
# **********************************************************************

import yaml
import os
import csv
from collections import defaultdict

# Paths
yaml_path = "feeds/feeds.yaml"
ip_path = "feeds/merged_active_ips.txt"
domain_path = "feeds/merged_domains.txt"
csv_out = "feeds/logs/risk_summary.csv"

# Load YAML
with open(yaml_path, 'r') as f:
    config = yaml.safe_load(f)

feeds = config.get('feeds', [])
risk_map = defaultdict(list)

# Group feeds by risk
for feed in feeds:
    if not feed.get('enabled', False): continue
    risk = feed.get('risk', 'unknown').lower()
    name = feed.get('name')
    risk_map[risk].append(name)

# Collect data
def load_lines(path):
    if not os.path.exists(path): return []
    with open(path) as f:
        return sorted(set(line.strip() for line in f if line.strip()))

ips = load_lines(ip_path)
domains = load_lines(domain_path)

# Write CSV
os.makedirs(os.path.dirname(csv_out), exist_ok=True)
with open(csv_out, 'w', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(["Risk Level", "Feed Source", "Indicator Type", "Indicator Count"])
    for risk, names in risk_map.items():
        for name in names:
            if "ip" in name:
                writer.writerow([risk, name, "ip", len(ips)])
            else:
                writer.writerow([risk, name, "domain", len(domains)])

print(f"[OK] Wrote CSV summary to: {csv_out}")