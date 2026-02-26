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
    
    # Ping Check
    if ! ping -c 1 -W 2 "$ip" > /dev/null 2>&1; then
        echo "[-] ERROR: Target Pi at $ip is offline or unreachable. Skipping."
        return 1
    fi
    
    # Clean overwrite
    run_ssh "$ip" "$TARGET_USER" "$TARGET_PASS" "rm -rf /home/$TARGET_USER/cyber_smorgasbord && mkdir -p /home/$TARGET_USER/cyber_smorgasbord"
    
    # ==========================================
    # GENERATE THE SMART FIREWALL LOCALLY
    # ==========================================
    echo "[+] Generating Smart Anti-Cheat Firewall..."
    cat << 'EOF' > firewall.sh
#!/bin/bash
TARGET_IP=$(hostname -I | awk '{print $1}')
echo "Applying anti-cheat firewall for $TARGET_IP..."

if [[ "$TARGET_IP" == *"192.168.2.10"* ]]; then
    P1="192.168.2.101"
    P2="192.168.2.102"
    P3="192.168.2.103"
elif [[ "$TARGET_IP" == *"192.168.2.20"* ]]; then
    P1="192.168.2.104"
    P2="192.168.2.105"
    P3="192.168.2.106"
elif [[ "$TARGET_IP" == *"192.168.2.30"* ]]; then
    P1="192.168.2.107"
    P2="192.168.2.108"
    P3="192.168.2.109"
else
    echo "Unknown Target IP. Skipping firewall."
    exit 1
fi

sudo iptables -F DOCKER-USER
sudo iptables -A DOCKER-USER -s 192.168.2.50 -j RETURN
sudo iptables -A DOCKER-USER -m conntrack --ctstate ESTABLISHED,RELATED -j RETURN

# Station 1 Isolation
for PORT in 3001 8011 8021 2221 2231; do
    sudo iptables -A DOCKER-USER -p tcp -m conntrack --ctorigdstport $PORT -s $P1 -j RETURN
    sudo iptables -A DOCKER-USER -p tcp -m conntrack --ctorigdstport $PORT -j REJECT --reject-with tcp-reset
done

# Station 2 Isolation
for PORT in 3002 8012 8022 2222 2232; do
    sudo iptables -A DOCKER-USER -p tcp -m conntrack --ctorigdstport $PORT -s $P2 -j RETURN
    sudo iptables -A DOCKER-USER -p tcp -m conntrack --ctorigdstport $PORT -j REJECT --reject-with tcp-reset
done

# Station 3 Isolation
for PORT in 3003 8013 8023 2223 2233; do
    sudo iptables -A DOCKER-USER -p tcp -m conntrack --ctorigdstport $PORT -s $P3 -j RETURN
    sudo iptables -A DOCKER-USER -p tcp -m conntrack --ctorigdstport $PORT -j REJECT --reject-with tcp-reset
done

sudo iptables -A DOCKER-USER -j RETURN
echo "Firewall locked down."
EOF

    # ==========================================
    # PUSH AND EXECUTE
    # ==========================================
    run_scp "$ip" "$TARGET_USER" "$TARGET_PASS" "docker-compose.yml" "/home/$TARGET_USER/cyber_smorgasbord/docker-compose.yml"
    run_scp "$ip" "$TARGET_USER" "$TARGET_PASS" "firewall.sh" "/home/$TARGET_USER/cyber_smorgasbord/firewall.sh"
    sshpass -p "$TARGET_PASS" scp -r -o StrictHostKeyChecking=no -o ConnectTimeout=5 "clmystery" "$TARGET_USER@$ip:/home/$TARGET_USER/cyber_smorgasbord/"
    
    echo "[+] Starting Docker containers and applying firewall on $ip..."
    
    # Start Docker and execute the firewall script instantly
    run_ssh "$ip" "$TARGET_USER" "$TARGET_PASS" "cd /home/$TARGET_USER/cyber_smorgasbord && docker compose up -d --build --remove-orphans && chmod +x firewall.sh && sudo ./firewall.sh"

    # Time sync to the Admin Laptop
    run_ssh "$ip" "$TARGET_USER" "$TARGET_PASS" "sudo sed -i 's/^#NTP=/NTP=192.168.2.50/' /etc/systemd/timesyncd.conf"
    run_ssh "$ip" "$TARGET_USER" "$TARGET_PASS" "sudo systemctl restart systemd-timesyncd"

    # CRON Update: Rebuild containers and re-apply the firewall on every reboot
    run_ssh "$ip" "$TARGET_USER" "$TARGET_PASS" "(crontab -l 2>/dev/null | grep -v 'cyber_smorgasbord'; echo '@reboot sleep 15 && cd /home/$TARGET_USER/cyber_smorgasbord && docker compose down -v && docker compose up -d && sleep 10 && sudo ./firewall.sh') | crontab -"
    
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

    # 1. Wipe old SSH keys to prevent "REMOTE HOST IDENTIFICATION HAS CHANGED" errors
    echo "[+] Wiping stale SSH known_hosts..."
    run_ssh "$ip" "$PLAYER_USER" "$PLAYER_PASS" "rm -f /home/$PLAYER_USER/.ssh/known_hosts"
    
    # 2. Create the clean directories
    run_ssh "$ip" "$PLAYER_USER" "$PLAYER_PASS" "mkdir -p /home/$PLAYER_USER/portal /home/$PLAYER_USER/.config/autostart /home/$PLAYER_USER/Desktop"
    
    # 3. Push the core portal files
    run_scp "$ip" "$PLAYER_USER" "$PLAYER_PASS" "portal.py" "/home/$PLAYER_USER/portal/"
    run_scp "$ip" "$PLAYER_USER" "$PLAYER_PASS" "start_kiosk.sh" "/home/$PLAYER_USER/portal/"
    
    # Push the HTML READMEs
    run_scp "$ip" "$PLAYER_USER" "$PLAYER_PASS" "readme_juice.html" "/home/$PLAYER_USER/portal/"
    run_scp "$ip" "$PLAYER_USER" "$PLAYER_PASS" "readme_webgoat.html" "/home/$PLAYER_USER/portal/"
    run_scp "$ip" "$PLAYER_USER" "$PLAYER_PASS" "readme_sqli.html" "/home/$PLAYER_USER/portal/"
    run_scp "$ip" "$PLAYER_USER" "$PLAYER_PASS" "readme_cowrie.html" "/home/$PLAYER_USER/portal/"
    
    # 4. Push the shortcut to Autostart (for booting) AND Desktop (for manual clicking)
    run_scp "$ip" "$PLAYER_USER" "$PLAYER_PASS" "portal.desktop" "/home/$PLAYER_USER/.config/autostart/portal.desktop"
    run_scp "$ip" "$PLAYER_USER" "$PLAYER_PASS" "portal.desktop" "/home/$PLAYER_USER/Desktop/Start_Range.desktop"
    
    # 5. Set execution permissions (Crucial for the Desktop icon to work)
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
    run_ssh "$ip" "$PLAYER_USER" "$PLAYER_PASS" "DISPLAY=:0 pcmanfm --set-wallpaper /home/$PLAYER_USER/Pictures/cyberknights_matrix.jpg > /dev/null 2>&1"
    
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