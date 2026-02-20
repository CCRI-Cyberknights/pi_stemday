#!/bin/bash

# ===============================================
# Credentials Configuration
# ===============================================

# Target Pi Credentials
TARGET_USER="stemtarget"
TARGET_PASS="P@55w0rd!1"

# Player Pi Credentials
PLAYER_USER="stemday"
PLAYER_PASS="cyberknights"

# Target Pi IPs
TARGET_RED="192.168.2.10"
TARGET_BLUE="192.168.2.20"
TARGET_YELLOW="192.168.2.30"

# Player Pi IPs Array
PLAYER_IPS=(
    "192.168.2.101" # red-player1
    "192.168.2.102" # red-player2
    "192.168.2.103" # red-player3
    "192.168.2.104" # blue-player1
    "192.168.2.105" # blue-player2
    "192.168.2.106" # blue-player3
    "192.168.2.107" # yellow-player1
    "192.168.2.108" # yellow-player2
    "192.168.2.109" # yellow-player3
)

# ===============================================
# Functions
# ===============================================

# Function to run SSH commands silently with specific credentials and a 5-second timeout
run_ssh() {
    local ip=$1
    local user=$2
    local pass=$3
    local cmd=$4
    sshpass -p "$pass" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 "$user@$ip" "$cmd"
}

# Function to securely copy files with specific credentials and a 5-second timeout
run_scp() {
    local ip=$1
    local user=$2
    local pass=$3
    local src=$4
    local dest=$5
    sshpass -p "$pass" scp -o StrictHostKeyChecking=no -o ConnectTimeout=5 "$src" "$user@$ip:$dest"
}

deploy_target_pi() {
    local ip=$1
    echo "==============================================="
    echo "Deploying to Target Pi: $ip..."
    
    # Ping Check: Send 1 ping, wait max 2 seconds for a reply
    if ! ping -c 1 -W 2 "$ip" > /dev/null 2>&1; then
        echo "[-] ERROR: Target Pi at $ip is offline or unreachable. Skipping."
        return 1
    fi
    
    # Clean overwrite: Delete the old directory and recreate it using the new username
    run_ssh "$ip" "$TARGET_USER" "$TARGET_PASS" "rm -rf /home/$TARGET_USER/cyber_smorgasbord && mkdir -p /home/$TARGET_USER/cyber_smorgasbord"
    
    # Push the new docker-compose.yml
    run_scp "$ip" "$TARGET_USER" "$TARGET_PASS" "docker-compose.yml" "/home/$TARGET_USER/cyber_smorgasbord/docker-compose.yml"
    
    # Push the Command Line Murders build folder recursively
    sshpass -p "$TARGET_PASS" scp -r -o StrictHostKeyChecking=no -o ConnectTimeout=5 "clmystery" "$TARGET_USER@$ip:/home/$TARGET_USER/cyber_smorgasbord/"
    
    # Pull and deploy the containers with orphan cleanup
    echo "[+] Starting Docker containers on $ip..."
    run_ssh "$ip" "$TARGET_USER" "$TARGET_PASS" "cd /home/$TARGET_USER/cyber_smorgasbord && docker compose up -d --remove-orphans"

    # Point the Target Pi's time sync directly at the Parrot OS laptop
    run_ssh "$ip" "$TARGET_USER" "$TARGET_PASS" "sudo sed -i 's/^#NTP=/NTP=192.168.2.50/' /etc/systemd/timesyncd.conf"
    
    # Restart the background service silently
    run_ssh "$ip" "$TARGET_USER" "$TARGET_PASS" "sudo systemctl restart systemd-timesyncd"

    # Force Docker to destroy and rebuild all containers from the cyber_smorgasbord folder on reboot
    run_ssh "$ip" "$TARGET_USER" "$TARGET_PASS" "(crontab -l 2>/dev/null | grep -v 'cyber_smorgasbord'; echo '@reboot sleep 15 && cd /home/$TARGET_USER/cyber_smorgasbord && docker compose down -v && docker compose up -d') | crontab -"
    
    echo "[+] Target Pi $ip deployment complete!"
}

deploy_player_pi() {
    local ip=$1
    echo "==============================================="
    echo "Deploying to Player Pi: $ip..."
    
    # Ping Check
    if ! ping -c 1 -W 2 "$ip" > /dev/null 2>&1; then
        echo "[-] ERROR: Player Pi at $ip is offline or unreachable. Skipping."
        return 1
    fi
    
    # 1. Create the clean directories
    run_ssh "$ip" "$PLAYER_USER" "$PLAYER_PASS" "mkdir -p /home/$PLAYER_USER/portal /home/$PLAYER_USER/.config/autostart /home/$PLAYER_USER/Desktop"
    
    # 2. Push the core portal files
    run_scp "$ip" "$PLAYER_USER" "$PLAYER_PASS" "portal.py" "/home/$PLAYER_USER/portal/"
    run_scp "$ip" "$PLAYER_USER" "$PLAYER_PASS" "start_kiosk.sh" "/home/$PLAYER_USER/portal/"
    
    # Push the HTML READMEs
    run_scp "$ip" "$PLAYER_USER" "$PLAYER_PASS" "readme_juice.html" "/home/$PLAYER_USER/portal/"
    run_scp "$ip" "$PLAYER_USER" "$PLAYER_PASS" "readme_webgoat.html" "/home/$PLAYER_USER/portal/"
    run_scp "$ip" "$PLAYER_USER" "$PLAYER_PASS" "readme_cowrie.html" "/home/$PLAYER_USER/portal/"
    
    # 3. Push the shortcut to Autostart (for booting) AND Desktop (for manual clicking)
    run_scp "$ip" "$PLAYER_USER" "$PLAYER_PASS" "portal.desktop" "/home/$PLAYER_USER/.config/autostart/portal.desktop"
    run_scp "$ip" "$PLAYER_USER" "$PLAYER_PASS" "portal.desktop" "/home/$PLAYER_USER/Desktop/Start_Range.desktop"
    
    # 4. Set execution permissions (Crucial for the Desktop icon to work)
    run_ssh "$ip" "$PLAYER_USER" "$PLAYER_PASS" "chmod +x /home/$PLAYER_USER/portal/start_kiosk.sh"
    run_ssh "$ip" "$PLAYER_USER" "$PLAYER_PASS" "chmod +x /home/$PLAYER_USER/Desktop/Start_Range.desktop"

    # Point the Pi's time sync directly at the Parrot OS laptop
    run_ssh "$ip" "$PLAYER_USER" "$PLAYER_PASS" "sudo sed -i 's/^#NTP=/NTP=192.168.2.50/' /etc/systemd/timesyncd.conf"
    
    # Restart the background service silently
    run_ssh "$ip" "$PLAYER_USER" "$PLAYER_PASS" "sudo systemctl restart systemd-timesyncd"

    # Push the custom wallpaper and fix the Debian display permissions
    run_ssh "$ip" "$PLAYER_USER" "$PLAYER_PASS" "mkdir -p /home/$PLAYER_USER/Pictures"
    run_scp "$ip" "$PLAYER_USER" "$PLAYER_PASS" "cyberknights_matrix.jpg" "/home/$PLAYER_USER/Pictures/"
    
    # Explicitly grant the display manager read access to the image and directory
    run_ssh "$ip" "$PLAYER_USER" "$PLAYER_PASS" "chmod 755 /home/$PLAYER_USER/Pictures"
    run_ssh "$ip" "$PLAYER_USER" "$PLAYER_PASS" "chmod 644 /home/$PLAYER_USER/Pictures/cyberknights_matrix.jpg"
    
    # Automatically set the background image
    run_ssh "$ip" "$PLAYER_USER" "$PLAYER_PASS" "pcmanfm --set-wallpaper /home/$PLAYER_USER/Pictures/cyberknights_matrix.jpg"
    
    echo "[+] Player Pi $ip deployment complete! Changes take effect on next reboot."
}

deploy_all_player_pis() {
    echo "Starting mass deployment to all Player Pis..."
    for ip in "${PLAYER_IPS[@]}"; do
        deploy_player_pi "$ip"
    done
    echo "Mass deployment to all 9 Player Pis complete!"
}

# ===============================================
# Interactive Menu
# ===============================================

clear
echo "==============================================="
echo "   CCRI STEM Day Master Deployment Script      "
echo "==============================================="
echo "1) Deploy to a SINGLE TARGET Pi (Docker)"
echo "2) Deploy to a SINGLE PLAYER Pi (Captive Portal)"
echo "3) Deploy to ALL 9 PLAYER Pis (Mass Update)"
echo "4) Exit"
echo "==============================================="
read -p "Select an option [1-4]: " option

case $option in
    1)
        read -p "Enter the IP of the Target Pi (e.g., $TARGET_RED): " target_ip
        deploy_target_pi "$target_ip"
        ;;
    2)
        read -p "Enter the IP of the Player Pi (e.g., 192.168.2.101): " player_ip
        deploy_player_pi "$player_ip"
        ;;
    3)
        deploy_all_player_pis
        ;;
    4)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo "Invalid option."
        ;;
esac