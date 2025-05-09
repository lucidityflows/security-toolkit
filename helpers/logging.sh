#!/bin/bash
# **********************************************************************
# logging.sh - Shared logging functions and color definitions
# **********************************************************************

LOG_DIR="$HOME/Desktop/Logs"
mkdir -p "$LOG_DIR"

RED="\033[0;31m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
ORANGE="\033[0;33m"
NC="\033[0m"

log_info()    { echo -e "${BLUE}[INFO] $1${NC}" | tee -a "$LOG_FILE"; }
log_success() { echo -e "${GREEN}[OK] $1${NC}" | tee -a "$LOG_FILE"; }
log_warn()    { echo -e "${ORANGE}[WARN] $1${NC}" | tee -a "$LOG_FILE"; }
log_error()   { echo -e "${RED}[ERROR] $1${NC}" | tee -a "$LOG_FILE"; }
