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
    
    # Download and run the official Docker install script
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    rm get-docker.sh
    
    echo "[*] Docker installed successfully!"
    echo "[*] Booting containers (using sudo for the initial fresh install)..."
    sudo docker compose up -d --build
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

# Try to open the browser automatically (works on most Linux desktop environments)
xdg-open http://127.0.0.1:8080 2>/dev/null || true
