#!/bin/bash
echo "[+] Starting the Cyber Smorgasbord Demo Backend..."

# Detect container engines and install Docker if both are missing
if command -v podman-compose &> /dev/null; then
    echo "[*] Podman detected. Booting containers..."
    podman-compose up -d --build
elif command -v docker &> /dev/null && docker compose version &> /dev/null; then
    echo "[*] Docker detected. Booting containers..."
    docker compose up -d --build
else
    echo "[-] No container engine found. Installing Docker..."
    echo "[*] You may be prompted for your sudo password."
    
    # Check OS to route to the correct installation method
    if grep -qi "kali" /etc/os-release 2>/dev/null; then
        echo "[*] Kali Linux detected. Using native APT repositories..."
        sudo apt-get update
        # Kali natively hosts docker.io. We try for the v2 plugin first, fallback to v1
        sudo apt-get install -y docker.io docker-compose-plugin || sudo apt-get install -y docker.io docker-compose
        sudo systemctl enable --now docker
    elif grep -qi "suse" /etc/os-release 2>/dev/null; then
        echo "[*] openSUSE detected. Using native Zypper repositories..."
        sudo zypper refresh
        sudo zypper install -y docker docker-compose
        sudo systemctl enable --now docker
    else
        # Download and run the official Docker install script for other distros like Ubuntu/Mint
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        rm get-docker.sh
    fi
    
    echo "[*] Docker installed successfully!"
    echo "[*] Booting containers (using sudo for the initial fresh install)..."
    
    # Launch fallback: Check if the system uses the new plugin or the old hyphenated command
    if sudo docker compose version &> /dev/null; then
        sudo docker compose up -d --build
    else
        sudo docker-compose up -d --build
    fi
fi

echo "[+] Launching the Captive Portal..."
# Kill any old python servers running on 8080 just in case
fuser -k 8080/tcp 2>/dev/null
nohup python3 demo_portal.py > server.log 2>&1 &

sleep 3
echo "[+] Demo is LIVE!"
echo "======================================================="
echo "Open your web browser and go to: http://127.0.0.1:8080"
echo "======================================================="

# Try to open the browser automatically in the background, completely muting all output
nohup xdg-open http://127.0.0.1:8080 > /dev/null 2>&1 &