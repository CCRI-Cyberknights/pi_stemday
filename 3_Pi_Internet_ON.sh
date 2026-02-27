#!/bin/bash

# ===============================================
# Configuration
# ===============================================
GATEWAY_IP="192.168.2.50"  # Your Parrot OS Laptop IP

# Credentials (Synced with deploy_master.sh)
TARGET_USER="stemtarget"
TARGET_PASS="P@55w0rd!1"
PLAYER_USER="stemday"
PLAYER_PASS="cyberknights"

# ===============================================
# The Injection Function
# ===============================================
enable_internet() {
    local NAME=$1
    local IP=$2
    local USER=$3
    local PASS=$4

    echo "--------------------------------------------------"
    echo "[*] Targeting: $NAME ($IP)"
    
    # Check if host is online first
    if ! ping -c 1 -W 1 "$IP" > /dev/null 2>&1; then
        echo "[-] ERROR: Host is OFFLINE. Skipping."
        return
    fi

    # Use sshpass to auto-type the password and run the network commands
    sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -t "$USER@$IP" "
        echo '[-] Removing default gateway...'
        sudo ip route del default 2>/dev/null
        
        echo '[-] Pointing traffic to Parrot OS ($GATEWAY_IP)...'
        sudo ip route add default via $GATEWAY_IP
        
        echo '[-] Setting DNS to Google (8.8.8.8)...'
        echo 'nameserver 8.8.8.8' | sudo tee /etc/resolv.conf > /dev/null
        
        echo '[+] verification ping:'
        ping -c 2 google.com
    "
}

# ===============================================
# The Menu
# ===============================================
clear
echo "=========================================="
echo "      Internet Access Control Panel       "
echo "      Gateway: $GATEWAY_IP            "
echo "=========================================="
echo "TARGET PIS:"
echo "1)  Target Red    (192.168.2.10)"
echo "2)  Target Blue   (192.168.2.20)"
echo "3)  Target Yellow (192.168.2.30)"
echo "------------------------------------------"
echo "PLAYER PIS (RED):"
echo "4)  Red Player 1  (192.168.2.101)"
echo "5)  Red Player 2  (192.168.2.102)"
echo "6)  Red Player 3  (192.168.2.103)"
echo "------------------------------------------"
echo "PLAYER PIS (BLUE):"
echo "7)  Blue Player 1 (192.168.2.104)"
echo "8)  Blue Player 2 (192.168.2.105)"
echo "9)  Blue Player 3 (192.168.2.106)"
echo "------------------------------------------"
echo "PLAYER PIS (YELLOW):"
echo "10) Yellow Player 1 (192.168.2.107)"
echo "11) Yellow Player 2 (192.168.2.108)"
echo "12) Yellow Player 3 (192.168.2.109)"
echo "------------------------------------------"
echo "13) ENABLE ALL 12 DEVICES (Mass Update)"
echo "0)  Exit"
echo "=========================================="
read -p "Select Device [0-13]: " OPTION

case $OPTION in
    1) enable_internet "Target Red" "192.168.2.10" "$TARGET_USER" "$TARGET_PASS" ;;
    2) enable_internet "Target Blue" "192.168.2.20" "$TARGET_USER" "$TARGET_PASS" ;;
    3) enable_internet "Target Yellow" "192.168.2.30" "$TARGET_USER" "$TARGET_PASS" ;;
    
    4) enable_internet "Red Player 1" "192.168.2.101" "$PLAYER_USER" "$PLAYER_PASS" ;;
    5) enable_internet "Red Player 2" "192.168.2.102" "$PLAYER_USER" "$PLAYER_PASS" ;;
    6) enable_internet "Red Player 3" "192.168.2.103" "$PLAYER_USER" "$PLAYER_PASS" ;;
    
    7) enable_internet "Blue Player 1" "192.168.2.104" "$PLAYER_USER" "$PLAYER_PASS" ;;
    8) enable_internet "Blue Player 2" "192.168.2.105" "$PLAYER_USER" "$PLAYER_PASS" ;;
    9) enable_internet "Blue Player 3" "192.168.2.106" "$PLAYER_USER" "$PLAYER_PASS" ;;
    
    10) enable_internet "Yellow Player 1" "192.168.2.107" "$PLAYER_USER" "$PLAYER_PASS" ;;
    11) enable_internet "Yellow Player 2" "192.168.2.108" "$PLAYER_USER" "$PLAYER_PASS" ;;
    12) enable_internet "Yellow Player 3" "192.168.2.109" "$PLAYER_USER" "$PLAYER_PASS" ;;
    
    13) 
        echo "Starting Mass Injection..."
        enable_internet "Target Red" "192.168.2.10" "$TARGET_USER" "$TARGET_PASS"
        enable_internet "Target Blue" "192.168.2.20" "$TARGET_USER" "$TARGET_PASS"
        enable_internet "Target Yellow" "192.168.2.30" "$TARGET_USER" "$TARGET_PASS"
        
        # Loop through players
        for i in {101..109}; do
            enable_internet "Player $i" "192.168.2.$i" "$PLAYER_USER" "$PLAYER_PASS"
        done
        ;;
    0) exit 0 ;;
    *) echo "Invalid option." ;;
esac