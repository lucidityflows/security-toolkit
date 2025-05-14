#!/bin/bash
# **********************************************************************
# update_feeds_from_yaml.sh
# Description:
#   - Parses enhanced feeds.yaml (risk, tags, auth)
#   - Downloads enabled feeds with optional auth headers
#   - Deduplicates and merges IPs/domains to output files
# **********************************************************************

RED="\033[0;31m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
ORANGE="\033[0;33m"
NC="\033[0m"

YAML_FILE="feeds/feeds.yaml"
TMP_DIR="/tmp/feed_merge_$$"
mkdir -p "$TMP_DIR"

echo -e "${BLUE}[INFO] Starting threat feed update...${NC}"

# Extract output paths
output_ips=$(grep 'merged_ips:' "$YAML_FILE" | awk '{print $2}')
output_domains=$(grep 'merged_domains:' "$YAML_FILE" | awk '{print $2}')
output_log=$(grep 'logs:' "$YAML_FILE" | awk '{print $2}')
mkdir -p "$(dirname "$output_ips")" "$(dirname "$output_domains")" "$(dirname "$output_log")"

> "$TMP_DIR/ips.txt"
> "$TMP_DIR/domains.txt"
> "$output_log"

# Parse each feed block
awk '
  /- name:/       {feed=++f; name=$2}
  /url:/          {url=$2}
  /type:/         {type=$2}
  /enabled:/      {enabled=$2}
  /risk:/         {risk=$2}
  /tags:/         {tags=$0}
  /auth:/         {getline; header=$0}
  enabled=="true" {print name "|" url "|" type "|" risk "|" tags "|" header}
' "$YAML_FILE" | while IFS='|' read -r name url type risk tags auth_header; do
  echo -e "${BLUE}[FETCH] $name ($type, $risk) from $url${NC}"

  curl_opts="-fsSL"
  if [[ "$auth_header" == Authorization* ]]; then
    curl_opts="$curl_opts -H \"$auth_header\""
  fi

  eval curl $curl_opts \"$url\" -o \"$TMP_DIR/$name.txt\"
  if [[ $? -ne 0 ]]; then
    echo -e "${RED}[ERROR] Failed: $name (${url})${NC}" >> "$output_log"
    continue
  fi

  echo -e "${GREEN}[OK] Downloaded: $name${NC}" >> "$output_log"

  if [[ "$type" == "ip" ]]; then
    grep -Eo '([0-9]{1,3}\\.){3}[0-9]{1,3}' "$TMP_DIR/$name.txt" >> "$TMP_DIR/ips.txt"
  elif [[ "$type" == "domain" ]]; then
    grep -Eo '([a-zA-Z0-9.-]+\\.[a-zA-Z]{2,})' "$TMP_DIR/$name.txt" >> "$TMP_DIR/domains.txt"
  fi
done

# Deduplicate
sort -u "$TMP_DIR/ips.txt" > "$output_ips"
sort -u "$TMP_DIR/domains.txt" > "$output_domains"

echo -e "${GREEN}[DONE] Feeds updated.${NC}"
echo -e "${GREEN}IPs: $output_ips${NC}"
echo -e "${GREEN}Domains: $output_domains${NC}"
echo -e "${GREEN}Log: $output_log${NC}"

rm -rf "$TMP_DIR"
read -n 1 -s -r -p $'\nPress any key to continue...'
echo