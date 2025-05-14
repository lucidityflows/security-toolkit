#!/bin/bash
# **********************************************************************
# install_profile_package.sh
# Description:
#   - Master setup for Wireshark profile deployment
#   - Installs layout, merges modular filters, manages assets
#   - Integrates threat feed update using feeds.yaml
# **********************************************************************

RED="\033[0;31m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
ORANGE="\033[0;33m"
NC="\033[0m"

PROFILE_BASE_PATH="$HOME/Library/Application Support/Wireshark/profiles"
ASSET_DIR="$HOME/SecurityToolkit/profiles"
FEED_SCRIPT="$HOME/SecurityToolkit/update_threats/update_feeds_from_yaml.sh"

# Prompt for profile name
echo -e "${BLUE}[INPUT] Enter the profile name to create or update:${NC}"
read -r PROFILE_NAME

TARGET_PROFILE="$PROFILE_BASE_PATH/$PROFILE_NAME"
SOURCE_PROFILE="$ASSET_DIR/$PROFILE_NAME"

# Verify source exists
if [[ ! -d "$SOURCE_PROFILE" ]]; then
  echo -e "${RED}[ERROR] Profile source not found: $SOURCE_PROFILE${NC}"
  exit 1
fi

# Create target directories
mkdir -p "$TARGET_PROFILE"
mkdir -p "$TARGET_PROFILE/layout"
mkdir -p "$TARGET_PROFILE/filters"

# PHASE 1: Copy layout files
echo -e "${BLUE}[PHASE 1] Copying layout...${NC}"
cp "$SOURCE_PROFILE/layout/preferences" "$TARGET_PROFILE/" 2>/dev/null
cp "$SOURCE_PROFILE/layout/recent_common" "$TARGET_PROFILE/" 2>/dev/null

# PHASE 2: Merge colorfilters
echo -e "${BLUE}[PHASE 2] Installing colorfilters...${NC}"
> "$TARGET_PROFILE/colorfilters"
for filter_file in "$SOURCE_PROFILE/filters"/*.colorfilters; do
  [[ -f "$filter_file" ]] && cat "$filter_file" >> "$TARGET_PROFILE/colorfilters"
  echo -e "${GREEN}[OK] Merged: $(basename "$filter_file")${NC}"
done

# PHASE 3: Merge display filters
echo -e "${BLUE}[PHASE 3] Installing display filters...${NC}"
> "$TARGET_PROFILE/display_filters"
for display_file in "$SOURCE_PROFILE/filters"/*.display_filters; do
  [[ -f "$display_file" ]] && cat "$display_file" >> "$TARGET_PROFILE/display_filters"
  echo -e "${GREEN}[OK] Merged: $(basename "$display_file")${NC}"
done

# PHASE 4: Update threat feeds
if [[ -x "$FEED_SCRIPT" ]]; then
  echo -e "${BLUE}[PHASE 4] Updating threat feeds via feeds.yaml...${NC}"
  bash "$FEED_SCRIPT"
else
  echo -e "${ORANGE}[SKIP] Threat feed updater not found or not executable.${NC}"
fi

# STUB PHASE 5
echo -e "${ORANGE}[STUB] Phase 5: Interactive layout customization to be added.${NC}"

# PHASE 6: Optional Launch
echo -e "${BLUE}Do you want to launch Wireshark now with profile '$PROFILE_NAME'? (y/n):${NC}"
read -r launch
if [[ "$launch" =~ ^[Yy]$ ]]; then
  echo -e "${GREEN}[LAUNCH] Launching Wireshark with profile: $PROFILE_NAME${NC}"
  open -a Wireshark --args -P "$PROFILE_NAME"
else
  echo -e "${ORANGE}[SKIP] Launch skipped.${NC}"
fi

read -n 1 -s -r -p $'\nPress any key to finish...'
echo