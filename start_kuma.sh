#!/bin/bash

clear
echo "=========================================="
echo "      Starting Uptime Kuma Monitor        "
echo "=========================================="

# 1. Navigate to the correct subdirectory
if [ -d "kuma_monitor" ]; then
    cd kuma_monitor
else
    echo "[-] ERROR: Could not find the kuma_monitor folder. Are you running this from the main pi_stemday directory?"
    exit 1
fi

# 2. Start the Kuma container natively with Podman
echo "[*] Spinning up the Kuma container..."

if podman container exists uptime-kuma; then
    # If the container is just asleep, wake it up
    podman start uptime-kuma > /dev/null
else
    # If it has never been built, create it using the exact parameters from your compose file
    podman run -d \
      --name uptime-kuma \
      -p 3001:3001 \
      -v "$(pwd)/kuma-data:/app/data" \
      --restart unless-stopped \
      docker.io/louislam/uptime-kuma:1 > /dev/null
fi

# 3. Wait for the web server to initialize
echo "[*] Waiting 5 seconds for the dashboard to initialize..."
sleep 5

# 4. Launch the default web browser
echo "[+] Opening Kuma dashboard..."
xdg-open "http://localhost:3001" > /dev/null 2>&1

echo "=========================================="
echo "[+] Kuma is live! Keeping an eye on the room for you."
echo "=========================================="