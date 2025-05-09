#!/bin/bash
# **********************************************************************
# 01_setup_wireshark_profile.sh
# Description:
#   - Installs the MalwareHunter profile into Wireshark
#   - Uses centralized logging helper for cleaner code
# **********************************************************************

read -p "[?] Do you want to run this step: Install MalwareHunter Wireshark profile? (y/n): " CONFIRM
if [[ "$CONFIRM" != "y" ]]; then
  echo "[!] Skipping Wireshark profile setup..."
  exit 0
fi

source "$(dirname "$0")/helpers/logging.sh"
LOG_FILE="$LOG_DIR/01_setup_wireshark_profile.log"

log_info "Installing Wireshark MalwareHunter profile..."

PROFILE_DIR="$HOME/Library/Application Support/Wireshark/Profiles/MalwareHunter"
mkdir -p "$PROFILE_DIR"

log_info "Writing display filters..."
cat > "$PROFILE_DIR/dfilters" <<EOF
dns.qry.name contains "icloud.com" or dns.qry.name contains "akadns.net" or
dns.qry.name contains "mzstatic.com" or dns.qry.name contains "spotify.com" or
dns.qry.name contains "scdn.co" or
tls.handshake.extensions_server_name contains "apple" or
tls.handshake.extensions_server_name contains "google" or
tls.handshake.extensions_server_name contains "cdn" or
icmp or arp.opcode == 2 or
tcp.port == 853 or udp.port == 853 or
udp.port == 5353 or udp.port == 5355
EOF

log_info "Copying final colorfilters and profile files..."
cp "$(dirname "$0")/colorfilters" "$PROFILE_DIR/colorfilters"
cp "$(dirname "$0")/addr_resolve_dns_servers" "$PROFILE_DIR/addr_resolve_dns_servers"
cp "$(dirname "$0")/cfilters" "$PROFILE_DIR/cfilters"
cp "$(dirname "$0")/extcap.cfg" "$PROFILE_DIR/extcap.cfg"

log_info "Writing preferences..."
cat > "$PROFILE_DIR/preferences" <<EOF
gui.column.format: "No.", "%m", "Time", "%t", "Source", "%s", "Destination", "%d", "Protocol", "%p", "Length", "%L", "Info", "%i"
gui.window_title: "MalwareHunter - Wireshark Profile"
EOF

log_success "MalwareHunter profile installed to: $PROFILE_DIR"

echo ""
read -p "[→] Press Enter to continue to the next step..."
