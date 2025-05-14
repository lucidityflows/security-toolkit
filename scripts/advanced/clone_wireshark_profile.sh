l#!/bin/bash
# **********************************************************************
# clone_wireshark_profile.sh
# Description:
#   - Clones an existing Wireshark profile to a new profile name
#   - Supports both system Wireshark profiles and toolkit templates
# **********************************************************************

RED="\033[0;31m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
NC="\033[0m"

WIRESHARK_PROFILE_PATH="$HOME/Library/Application Support/Wireshark/profiles"
TOOLKIT_PROFILE_PATH="$HOME/SecurityToolkit/profiles"

echo -e "${BLUE}[INPUT] Clone source type?${NC}"
echo "1) Wireshark Live Profile"
echo "2) Toolkit Template"
read -p "Choose 1 or 2: " choice

if [[ "$choice" == "1" ]]; then
  SOURCE_ROOT="$WIRESHARK_PROFILE_PATH"
elif [[ "$choice" == "2" ]]; then
  SOURCE_ROOT="$TOOLKIT_PROFILE_PATH"
else
  echo -e "${RED}[ERROR] Invalid option.${NC}"
  exit 1
fi

echo -e "${BLUE}[INPUT] Enter the name of the profile to clone:${NC}"
read -r source

if [[ ! -d "$SOURCE_ROOT/$source" ]]; then
  echo -e "${RED}[ERROR] Source profile '$source' not found in $SOURCE_ROOT.${NC}"
  exit 1
fi

echo -e "${BLUE}[INPUT] Enter the name for the new cloned profile:${NC}"
read -r destination

if [[ -d "$WIRESHARK_PROFILE_PATH/$destination" ]]; then
  echo -e "${RED}[ERROR] Profile '$destination' already exists.${NC}"
  exit 1
fi

cp -R "$SOURCE_ROOT/$source" "$WIRESHARK_PROFILE_PATH/$destination"
echo -e "${GREEN}[CLONED] '$source' -> '$destination'${NC}"

read -n 1 -s -r -p $'\nPress any key to continue...'
echo