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
# Container Recovery Function
# ===============================================
container_recovery_menu() {
    clear
    echo "=========================================="
    echo "       Target Pi Container Recovery       "
    echo "=========================================="
    echo "1) Target Red    (192.168.2.10)"
    echo "2) Target Blue   (192.168.2.20)"
    echo "3) Target Yellow (192.168.2.30)"
    echo "4) ALL Target Pis"
    echo "0) Cancel"
    echo "=========================================="
    read -p "Select Target Pi [0-4]: " target_opt

    if [[ "$target_opt" == "0" ]]; then return; fi

    echo "------------------------------------------"
    echo "Recovery Action:"
    echo "1) Start ONLY crashed/stopped containers (Non-disruptive, auto-detects)"
    echo "2) Surgically restart ONE specific frozen container"
    read -p "Select action [1-2]: " action_opt

    local CMD=""
    local ACTION_MSG=""
    
    if [[ "$action_opt" == "1" ]]; then
        # Check for exited containers, start them if they exist
        CMD="if [ -n \"\$(docker ps -q -f status=exited)\" ]; then echo 'Restarting crashed containers...'; docker start \$(docker ps -q -f status=exited); else echo 'All containers are already running!'; fi"
        ACTION_MSG="Checking for and recovering crashed containers"
    elif [[ "$action_opt" == "2" ]]; then
        if [[ "$target_opt" == "4" ]]; then
            echo "[-] You cannot restart a specific container across ALL Pis at once."
            return
        fi

        echo "------------------------------------------"
        echo "Which Station is experiencing the freeze?"
        echo "1) Station 1"
        echo "2) Station 2"
        echo "3) Station 3"
        read -p "Select Station [1-3]: " station_opt

        if [[ ! "$station_opt" =~ ^[1-3]$ ]]; then 
            echo "[-] Invalid station."
            return
        fi

        echo "------------------------------------------"
        echo "Which Challenge needs a restart?"
        echo "1) Juice Shop"
        echo "2) SQLi-Labs"
        echo "3) WebGoat"
        echo "4) Command Line Murders (clmystery)"
        echo "5) Cowrie Honeypot"
        read -p "Select Challenge [1-5]: " chal_opt

        local app_name=""
        case $chal_opt in
            1) app_name="juice-shop" ;;
            2) app_name="sqli-labs" ;;
            3) app_name="webgoat" ;;
            4) app_name="clmystery" ;;
            5) app_name="cowrie" ;;
            *) echo "[-] Invalid challenge."; return ;;
        esac

        local target_container="${app_name}-${station_opt}"
        CMD="cd /home/$TARGET_USER/cyber_smorgasbord && docker compose restart $target_container"
        ACTION_MSG="Restarting exactly $target_container"
    else
        echo "[-] Invalid action."
        return
    fi

    run_recovery() {
        local NAME=$1
        local IP=$2
        echo "------------------------------------------"
        echo "[*] $ACTION_MSG on $NAME ($IP)..."
        if ! ping -c 1 -W 1 "$IP" > /dev/null 2>&1; then
            echo "[-] ERROR: $NAME is offline or unreachable."
        else
            sshpass -p "$TARGET_PASS" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 "$TARGET_USER@$IP" "$CMD"
            echo "[+] Recovery complete for $NAME."
        fi
    }

    case $target_opt in
        1) run_recovery "Target Red" "192.168.2.10" ;;
        2) run_recovery "Target Blue" "192.168.2.20" ;;
        3) run_recovery "Target Yellow" "192.168.2.30" ;;
        4) 
            run_recovery "Target Red" "192.168.2.10"
            run_recovery "Target Blue" "192.168.2.20"
            run_recovery "Target Yellow" "192.168.2.30"
            ;;
        *) echo "[-] Invalid option." ;;
    esac
}

# ===============================================
# The Main Menu (Now with a loop!)
# ===============================================
while true; do
    clear
    echo "=========================================="
    echo "    Cyber Smorgasbord Power Management    "
    echo "=========================================="
    echo "MASS COMMANDS:"
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
    echo "DOCKER MANAGEMENT:"
    echo "16) Container Recovery Menu (Restart crashed apps)"
    echo "------------------------------------------"
    echo "0) Exit"
    echo "=========================================="
    read -p "Select an option [0-16]: " OPTION

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
        
        16) container_recovery_menu ;;
        
        0) 
            echo "Exiting..."
            exit 0 
            ;;
        *) 
            echo "[-] Invalid option."
            ;;
    esac

    # This pauses the script so you can read the output before the loop clears the screen
    echo ""
    read -p "Press Enter to return to the main menu..."
done