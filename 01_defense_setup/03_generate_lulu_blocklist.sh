#!/bin/bash
# **********************************************************************
# 03_generate_lulu_blocklist.sh
# Description:
#   - Converts a deduplicated list of IPs into LuLu-compatible blocklist JSON
#   - Saves to ~/Library/Application Support/LuLu/lulu_blocklist.json
#   - Can be reused across pipelines for modular JSON generation
# **********************************************************************

# Import logging colors
source "$HOME/SecurityToolkit/_helpers/logging_colors.sh"

# Ask for confirmation
read -p "Do you wish to generate the LuLu blocklist JSON now? (y/n): " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
  echo -e "${ORANGE}[ABORTED] User cancelled LuLu blocklist generation.${NC}"
  exit 1
fi

# Paths
MERGED_IP_LIST="$HOME/SecurityToolkit/threat_feeds/active_ips.txt"
LULU_BLOCKLIST="$HOME/Library/Application Support/LuLu/lulu_blocklist.json"

# Check if source exists
if [[ ! -f "$MERGED_IP_LIST" ]]; then
  echo -e "${RED}[ERROR] IP list not found: $MERGED_IP_LIST${NC}"
  exit 1
fi

# Generate JSON
echo -e "${BLUE}[INFO] Generating LuLu blocklist JSON...${NC}"
{
  echo '['
  awk '{print "  {\"remote\": \""$1"\", \"action\": \"block\"},"}' "$MERGED_IP_LIST" | sed '$ s/,$//'
  echo ']'
} > "$LULU_BLOCKLIST"

echo -e "${GREEN}[OK] LuLu blocklist written to: $LULU_BLOCKLIST${NC}"

# Pause
read -n 1 -s -r -p $'\nPress any key to continue...'
echo