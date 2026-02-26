#!/bin/bash

# ===============================================
# Configuration
# ===============================================
PLAYER_USER="stemday"
PLAYER_PASS="cyberknights"
SAVE_DIR="./stemday_screenshots"

# Create the local save directory if it doesn't exist
mkdir -p "$SAVE_DIR"

# ===============================================
# The Screenshot Function
# ===============================================
grab_screen() {
    local NAME=$1
    local IP=$2
    local TIMESTAMP=$(date +"%H%M%S")
    local FILENAME="${NAME}_${TIMESTAMP}.png"
    local REMOTE_TMP="/tmp/spyglass_temp.png"

    echo "--------------------------------------------------"
    echo "[*] Grabbing screenshot from $NAME ($IP)..."
    
    # Check if host is online first
    if ! ping -c 1 -W 1 "$IP" > /dev/null 2>&1; then
        echo "[-] ERROR: Host is OFFLINE. Skipping."
        return
    fi

    # 1. SSH in and take the screenshot
    # We pass XDG_RUNTIME_DIR and WAYLAND_DISPLAY for Pi 5's Wayland, with a fallback to DISPLAY=:0 for X11
    sshpass -p "$PLAYER_PASS" ssh -o StrictHostKeyChecking=no "$PLAYER_USER@$IP" "
        XDG_RUNTIME_DIR=/run/user/1000 WAYLAND_DISPLAY=wayland-1 grim $REMOTE_TMP 2>/dev/null || \
        XDG_RUNTIME_DIR=/run/user/1000 WAYLAND_DISPLAY=wayland-0 grim $REMOTE_TMP 2>/dev/null || \
        DISPLAY=:0 scrot $REMOTE_TMP 2>/dev/null
    "

    # 2. Securely copy the image back to the instructor laptop
    if sshpass -p "$PLAYER_PASS" scp -o StrictHostKeyChecking=no -q "$PLAYER_USER@$IP:$REMOTE_TMP" "$SAVE_DIR/$FILENAME"; then
        echo "[+] Success! Saved to $SAVE_DIR/$FILENAME"
        
        # 3. Delete the temporary file on the Pi to keep it clean
        sshpass -p "$PLAYER_PASS" ssh -o StrictHostKeyChecking=no "$PLAYER_USER@$IP" "rm -f $REMOTE_TMP"
    else
        echo "[-] ERROR: Failed to retrieve screenshot. The screen might be asleep."
    fi
}

# ===============================================
# The Menu
# ===============================================
clear
echo "=========================================="
echo "         STEM Day Spyglass Tool           "
echo "=========================================="
echo "PLAYER PIS (RED):"
echo "1) Red Player 1  (192.168.2.101)"
echo "2) Red Player 2  (192.168.2.102)"
echo "3) Red Player 3  (192.168.2.103)"
echo "------------------------------------------"
echo "PLAYER PIS (BLUE):"
echo "4) Blue Player 1 (192.168.2.104)"
echo "5) Blue Player 2 (192.168.2.105)"
echo "6) Blue Player 3 (192.168.2.106)"
echo "------------------------------------------"
echo "PLAYER PIS (YELLOW):"
echo "7) Yellow Player 1 (192.168.2.107)"
echo "8) Yellow Player 2 (192.168.2.108)"
echo "9) Yellow Player 3 (192.168.2.109)"
echo "------------------------------------------"
echo "10) SNAPSHOT ENTIRE ROOM (All 9 Players)"
echo "0)  Exit"
echo "=========================================="
read -p "Select Device [0-10]: " OPTION

case $OPTION in
    1) grab_screen "Red_1" "192.168.2.101" ;;
    2) grab_screen "Red_2" "192.168.2.102" ;;
    3) grab_screen "Red_3" "192.168.2.103" ;;
    
    4) grab_screen "Blue_1" "192.168.2.104" ;;
    5) grab_screen "Blue_2" "192.168.2.105" ;;
    6) grab_screen "Blue_3" "192.168.2.106" ;;
    
    7) grab_screen "Yellow_1" "192.168.2.107" ;;
    8) grab_screen "Yellow_2" "192.168.2.108" ;;
    9) grab_screen "Yellow_3" "192.168.2.109" ;;
    
    10) 
        echo "Initiating room-wide snapshot..."
        grab_screen "Red_1" "192.168.2.101"
        grab_screen "Red_2" "192.168.2.102"
        grab_screen "Red_3" "192.168.2.103"
        grab_screen "Blue_1" "192.168.2.104"
        grab_screen "Blue_2" "192.168.2.105"
        grab_screen "Blue_3" "192.168.2.106"
        grab_screen "Yellow_1" "192.168.2.107"
        grab_screen "Yellow_2" "192.168.2.108"
        grab_screen "Yellow_3" "192.168.2.109"
        echo "=========================================="
        echo "Room snapshot complete! Check the $SAVE_DIR folder."
        ;;
    0) exit 0 ;;
    *) echo "Invalid option." ;;
esac