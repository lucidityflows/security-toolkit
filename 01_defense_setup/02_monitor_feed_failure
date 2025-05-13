#!/bin/bash
# **********************************************************************
# 02_monitor_feed_failures.sh
# Description:
#   - Parses previous feed update logs
#   - Identifies any feed sources that failed 3 or more times
#   - Alerts the user with color-coded output
#   - Follows script startup/exit confirmation conventions
# **********************************************************************

# Load color definitions
source "$HOME/SecurityToolkit/_helpers/logging_colors.sh"

# Ask user to proceed
read -p "Do you wish to check for recurring threat feed failures? (y/n): " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
  echo -e "${ORANGE}[ABORTED] User cancelled feed failure check.${NC}"
  exit 1
fi

# Log directory and pattern
LOG_DIR="$HOME/SecurityToolkit/threat_feeds"
LOG_PATTERN="feed_update_*.log"

# Temporary store for failures
declare -A FAIL_COUNT

echo -e "${BLUE}[INFO] Scanning logs for failed feed fetches...${NC}"

# Parse all logs
for log in "$LOG_DIR"/$LOG_PATTERN; do
  while IFS= read -r line; do
    if [[ "$line" =~ \[ERROR\]\ Failed\ to\ fetch\ (https?://[^ ]+) ]]; then
      url="${BASH_REMATCH[1]}"
      ((FAIL_COUNT["$url"]++))
    fi
  done < "$log"
done

# Display results
if [[ ${#FAIL_COUNT[@]} -eq 0 ]]; then
  echo -e "${GREEN}[OK] No recurring feed failures detected.${NC}"
else
  echo -e "${RED}[WARNING] Repeated feed failures detected:${NC}"
  for feed in "${!FAIL_COUNT[@]}"; do
    count=${FAIL_COUNT[$feed]}
    if (( count >= 3 )); then
      echo -e "${RED}  - $feed failed $count times${NC}"
    else
      echo -e "${ORANGE}  - $feed failed $count times (below threshold)${NC}"
    fi
  done
fi

# Final prompt to continue
read -n 1 -s -r -p $'\nPress any key to continue...'
echo