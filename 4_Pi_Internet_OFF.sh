#!/bin/bash

# ===============================================
# Configuration
# ===============================================
GATEWAY_IP="192.168.2.50"  # Your Parrot OS Laptop IP
LOCAL_DNS="192.168.2.1"    # Internal DNS (No outside access)

# Credentials
TARGET_USER="stemtarget"
TARGET_PASS="P@55w0rd!1"
PLAYER_USER="stemday"
PLAYER_PASS="cyberknights"

# ===============================================
# The Kill Function
# ===============================================
disable_internet() {
    local NAME=$1
    local IP=$2
    local USER=$3
    local PASS=$4

    echo "--------------------------------------------------"
    echo "[*] Isolation Target: $NAME ($IP)"
    
    if ! ping -c 1 -W 1 "$IP" > /dev/null 2>&1; then
        echo "[-] ERROR: Host is OFFLINE. Skipping."
        return
    fi

    # Use sshpass to sever the connection
    sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -t "$USER@$IP" "
        echo '[-] Severing Gateway link to $GATEWAY_IP...'
        sudo ip route del default via $GATEWAY_IP 2>/dev/null
        
        echo '[-] Resetting DNS to internal only...'
        echo 'nameserver $LOCAL_DNS' | sudo tee /etc/resolv.conf > /dev/null
        
        echo '[+] Verification: Testing external ping (Should fail)...'
        if ping -c 1 -W 2 8.8.8.8 > /dev/null 2>&1; then
            echo -e '\033[0;31m[!] WARNING: Internet is STILL ACTIVE!\033[0m'
        else
            echo -e '\033[0;32m[+] SUCCESS: Device is isolated.\033[0m'
        fi
    "
}

# ===============================================
# The Menu
# ===============================================
clear
echo "=========================================="
echo "      STEM Day: Internet KILL SWITCH      "
echo "      Current Gateway: $GATEWAY_IP        "
echo "=========================================="
echo "TARGET PIS:"
echo "1)  Target Red    (192.168.2.10)"
echo "2)  Target Blue   (192.168.2.20)"
echo "3)  Target Yellow (192.168.2.30)"
echo "------------------------------------------"
echo "PLAYER PIS:"
echo "4)  Red Players   (101-103)"
echo "5)  Blue Players  (104-106)"
echo "6)  Yellow Players(107-109)"
echo "------------------------------------------"
echo "7)  KILL ALL 12 DEVICES (Mass Isolation)"
echo "0)  Exit"
echo "=========================================="
read -p "Select [0-7]: " OPTION

case $OPTION in
    1) disable_internet "Target Red" "192.168.2.10" "$TARGET_USER" "$TARGET_PASS" ;;
    2) disable_internet "Target Blue" "192.168.2.20" "$TARGET_USER" "$TARGET_PASS" ;;
    3) disable_internet "Target Yellow" "192.168.2.30" "$TARGET_USER" "$TARGET_PASS" ;;
    
    4) for i in {101..103}; do disable_internet "Red Player $i" "192.168.2.$i" "$PLAYER_USER" "$PLAYER_PASS"; done ;;
    5) for i in {104..106}; do disable_internet "Blue Player $i" "192.168.2.$i" "$PLAYER_USER" "$PLAYER_PASS"; done ;;
    6) for i in {107..109}; do disable_internet "Yellow Player $i" "192.168.2.$i" "$PLAYER_USER" "$PLAYER_PASS"; done ;;
    
    7) 
        echo "!!!! STARTING MASS ISOLATION !!!!"
        disable_internet "Target Red" "192.168.2.10" "$TARGET_USER" "$TARGET_PASS"
        disable_internet "Target Blue" "192.168.2.20" "$TARGET_USER" "$TARGET_PASS"
        disable_internet "Target Yellow" "192.168.2.30" "$TARGET_USER" "$TARGET_PASS"
        for i in {101..109}; do
            disable_internet "Player $i" "192.168.2.$i" "$PLAYER_USER" "$PLAYER_PASS"
        done
        ;;
    0) exit 0 ;;
    *) echo "Invalid option." ;;
esac