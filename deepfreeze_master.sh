#!/bin/bash

# ===============================================
# Credentials Configuration
# ===============================================
TARGET_USER="stemtarget"
TARGET_PASS='P@55w0rd!1'

PLAYER_USER="stemday"
PLAYER_PASS='cyberknights'

# ===============================================
# The Deep Freeze Function
# ===============================================
toggle_freeze() {
    local NAME=$1
    local IP=$2
    local USER=$3
    local PASS=$4
    local STATE=$5
    local DO_REBOOT=$6

    echo "--------------------------------------------------"
    if [ "$STATE" == "enable" ]; then
        echo "[*] ENABLING Deep Freeze (Read-Only) on $NAME ($IP)..."
    else
        echo "[*] DISABLING Deep Freeze (Read-Write) on $NAME ($IP)..."
    fi
    
    # Ping Check
    if ! ping -c 1 -W 1 "$IP" > /dev/null 2>&1; then
        echo "[-] ERROR: $NAME is offline or unreachable."
        return
    fi

    # Native Raspberry Pi OS commands to toggle the Overlay File System
    local CMD=""
    if [ "$STATE" == "enable" ]; then
        CMD="sudo raspi-config nonint enable_overlayfs"
    else
        CMD="sudo raspi-config nonint disable_overlayfs"
    fi

    # Apply the setting
    sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 "$USER@$IP" "$CMD"
    
    echo "[+] Setting applied to $NAME."

    # Process the automatic reboot if requested
    if [[ "$DO_REBOOT" =~ ^[Yy]$ ]]; then
        echo "[*] Rebooting $NAME to lock in changes..."
        sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 "$USER@$IP" "sudo reboot" > /dev/null 2>&1
    fi
}

apply_mass() {
    local GROUP=$1
    local STATE=$2
    local DO_REBOOT=$3

    if [[ "$GROUP" == "targets" || "$GROUP" == "all" ]]; then
        toggle_freeze "Target Red" "192.168.2.10" "$TARGET_USER" "$TARGET_PASS" "$STATE" "$DO_REBOOT"
        toggle_freeze "Target Blue" "192.168.2.20" "$TARGET_USER" "$TARGET_PASS" "$STATE" "$DO_REBOOT"
        toggle_freeze "Target Yellow" "192.168.2.30" "$TARGET_USER" "$TARGET_PASS" "$STATE" "$DO_REBOOT"
    fi

    if [[ "$GROUP" == "players" || "$GROUP" == "all" ]]; then
        for i in {101..109}; do
            toggle_freeze "Player 192.168.2.$i" "192.168.2.$i" "$PLAYER_USER" "$PLAYER_PASS" "$STATE" "$DO_REBOOT"
        done
    fi
}

# ===============================================
# The Main Menu
# ===============================================
while true; do
    clear
    echo "=========================================="
    echo "     Deep Freeze (OverlayFS) Manager      "
    echo "=========================================="
    echo "MASS COMMANDS:"
    echo "1) Apply to ALL Target Pis (Red, Blue, Yellow)"
    echo "2) Apply to ALL Player Pis (All 9 Stations)"
    echo "3) Apply to ENTIRE ROOM (All 12 Devices)"
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

    if [[ "$OPTION" == "0" ]]; then
        echo "Exiting..."
        exit 0
    fi

    # Validate main menu option before asking further questions
    if [[ ! "$OPTION" =~ ^([1-9]|1[0-5])$ ]]; then
        echo "[-] Invalid option."
        sleep 2
        continue
    fi

    echo "------------------------------------------"
    echo "Select Action:"
    echo "1) ENABLE Deep Freeze (Read-Only Mode)"
    echo "2) DISABLE Deep Freeze (Read-Write Mode)"
    read -p "Select [1-2]: " STATE_OPT

    STATE="enable"
    if [[ "$STATE_OPT" == "2" ]]; then 
        STATE="disable"
    elif [[ "$STATE_OPT" != "1" ]]; then
        echo "[-] Invalid action."
        sleep 2
        continue
    fi

    echo "------------------------------------------"
    read -p "Reboot devices immediately to apply changes? (y/n): " DO_REBOOT

    case $OPTION in
        1) apply_mass "targets" "$STATE" "$DO_REBOOT" ;;
        2) apply_mass "players" "$STATE" "$DO_REBOOT" ;;
        3) apply_mass "all" "$STATE" "$DO_REBOOT" ;;
        
        4) toggle_freeze "Target Red" "192.168.2.10" "$TARGET_USER" "$TARGET_PASS" "$STATE" "$DO_REBOOT" ;;
        5) toggle_freeze "Target Blue" "192.168.2.20" "$TARGET_USER" "$TARGET_PASS" "$STATE" "$DO_REBOOT" ;;
        6) toggle_freeze "Target Yellow" "192.168.2.30" "$TARGET_USER" "$TARGET_PASS" "$STATE" "$DO_REBOOT" ;;
        
        7) toggle_freeze "Red Player 1" "192.168.2.101" "$PLAYER_USER" "$PLAYER_PASS" "$STATE" "$DO_REBOOT" ;;
        8) toggle_freeze "Red Player 2" "192.168.2.102" "$PLAYER_USER" "$PLAYER_PASS" "$STATE" "$DO_REBOOT" ;;
        9) toggle_freeze "Red Player 3" "192.168.2.103" "$PLAYER_USER" "$PLAYER_PASS" "$STATE" "$DO_REBOOT" ;;
        
        10) toggle_freeze "Blue Player 1" "192.168.2.104" "$PLAYER_USER" "$PLAYER_PASS" "$STATE" "$DO_REBOOT" ;;
        11) toggle_freeze "Blue Player 2" "192.168.2.105" "$PLAYER_USER" "$PLAYER_PASS" "$STATE" "$DO_REBOOT" ;;
        12) toggle_freeze "Blue Player 3" "192.168.2.106" "$PLAYER_USER" "$PLAYER_PASS" "$STATE" "$DO_REBOOT" ;;
        
        13) toggle_freeze "Yellow Player 1" "192.168.2.107" "$PLAYER_USER" "$PLAYER_PASS" "$STATE" "$DO_REBOOT" ;;
        14) toggle_freeze "Yellow Player 2" "192.168.2.108" "$PLAYER_USER" "$PLAYER_PASS" "$STATE" "$DO_REBOOT" ;;
        15) toggle_freeze "Yellow Player 3" "192.168.2.109" "$PLAYER_USER" "$PLAYER_PASS" "$STATE" "$DO_REBOOT" ;;
    esac

    echo ""
    read -p "Press Enter to return to the main menu..."
done