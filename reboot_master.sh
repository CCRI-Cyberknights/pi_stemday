#!/bin/bash

# ===============================================
# Credentials Configuration
# ===============================================
TARGET_USER="stemtarget"
TARGET_PASS='P@55w0rd!1'

PLAYER_USER="stemday"
PLAYER_PASS='cyberknights'

# ===============================================
# The Reboot Function
# ===============================================
reboot_pi() {
    local NAME=$1
    local IP=$2
    local USER=$3
    local PASS=$4

    echo "[*] Sending reboot command to $NAME ($IP)..."
    
    # Ping Check
    if ! ping -c 1 -W 1 "$IP" > /dev/null 2>&1; then
        echo "[-] ERROR: $NAME is offline or unreachable."
        return
    fi

    # Execute the reboot. We send the errors to /dev/null because the SSH connection 
    # dropping forcefully during a reboot sometimes throws a harmless error text.
    sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 "$USER@$IP" "sudo reboot" > /dev/null 2>&1
    
    echo "[+] $NAME is rebooting safely."
}

# ===============================================
# Mass Reboot Functions
# ===============================================
reboot_all_targets() {
    echo "=========================================="
    echo "Rebooting All Target Pis..."
    reboot_pi "Target Red" "192.168.2.10" "$TARGET_USER" "$TARGET_PASS"
    reboot_pi "Target Blue" "192.168.2.20" "$TARGET_USER" "$TARGET_PASS"
    reboot_pi "Target Yellow" "192.168.2.30" "$TARGET_USER" "$TARGET_PASS"
}

reboot_all_players() {
    echo "=========================================="
    echo "Rebooting All Player Pis..."
    for i in {101..109}; do
        reboot_pi "Player 192.168.2.$i" "192.168.2.$i" "$PLAYER_USER" "$PLAYER_PASS"
    done
}

# ===============================================
# The Menu
# ===============================================
clear
echo "=========================================="
echo "    Cyber Smorgasbord Power Management    "
echo "=========================================="
echo "MASS REBOOT COMMANDS:"
echo "1) Reboot ALL Target Pis (Red, Blue, Yellow)"
echo "2) Reboot ALL Player Pis (All 9 Stations)"
echo "3) Reboot ENTIRE ROOM (All 12 Devices)"
echo "------------------------------------------"
echo "INDIVIDUAL TARGET PIS:"
echo "4) Target Red    (192.168.2.10)"
echo "5) Target Blue   (192.168.2.20)"
echo "6) Target Yellow (192.168.2.30)"
echo "------------------------------------------"
echo "INDIVIDUAL PLAYER PIS:"
echo "7)  Red Player 1    (192.168.2.101)"
echo "8)  Red Player 2    (192.168.2.102)"
echo "9)  Red Player 3    (192.168.2.103)"
echo "10) Blue Player 1   (192.168.2.104)"
echo "11) Blue Player 2   (192.168.2.105)"
echo "12) Blue Player 3   (192.168.2.106)"
echo "13) Yellow Player 1 (192.168.2.107)"
echo "14) Yellow Player 2 (192.168.2.108)"
echo "15) Yellow Player 3 (192.168.2.109)"
echo "------------------------------------------"
echo "0) Exit"
echo "=========================================="
read -p "Select an option [0-15]: " OPTION

case $OPTION in
    1) reboot_all_targets ;;
    2) reboot_all_players ;;
    3) 
        reboot_all_targets
        reboot_all_players
        ;;
    4) reboot_pi "Target Red" "192.168.2.10" "$TARGET_USER" "$TARGET_PASS" ;;
    5) reboot_pi "Target Blue" "192.168.2.20" "$TARGET_USER" "$TARGET_PASS" ;;
    6) reboot_pi "Target Yellow" "192.168.2.30" "$TARGET_USER" "$TARGET_PASS" ;;
    
    7) reboot_pi "Red Player 1" "192.168.2.101" "$PLAYER_USER" "$PLAYER_PASS" ;;
    8) reboot_pi "Red Player 2" "192.168.2.102" "$PLAYER_USER" "$PLAYER_PASS" ;;
    9) reboot_pi "Red Player 3" "192.168.2.103" "$PLAYER_USER" "$PLAYER_PASS" ;;
    
    10) reboot_pi "Blue Player 1" "192.168.2.104" "$PLAYER_USER" "$PLAYER_PASS" ;;
    11) reboot_pi "Blue Player 2" "192.168.2.105" "$PLAYER_USER" "$PLAYER_PASS" ;;
    12) reboot_pi "Blue Player 3" "192.168.2.106" "$PLAYER_USER" "$PLAYER_PASS" ;;
    
    13) reboot_pi "Yellow Player 1" "192.168.2.107" "$PLAYER_USER" "$PLAYER_PASS" ;;
    14) reboot_pi "Yellow Player 2" "192.168.2.108" "$PLAYER_USER" "$PLAYER_PASS" ;;
    15) reboot_pi "Yellow Player 3" "192.168.2.109" "$PLAYER_USER" "$PLAYER_PASS" ;;
    
    0) exit 0 ;;
    *) echo "Invalid option." ;;
esac