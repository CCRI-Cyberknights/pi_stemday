#!/bin/bash
echo "[+] Starting the Cyber Smorgasbord Demo Backend..."

# Support both docker and podman depending on what is installed
if command -v podman-compose &> /dev/null; then
    podman-compose up -d --build
else
    docker compose up -d --build
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