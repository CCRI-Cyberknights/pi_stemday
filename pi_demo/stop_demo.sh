#!/bin/bash
echo "[-] Stopping the Cyber Smorgasbord Demo Backend..."

# Detect whether they are using Podman or Docker and run the correct teardown command
if command -v podman-compose &> /dev/null; then
    podman-compose down
else
    docker compose down
fi

echo "[-] Stopping the Captive Portal..."

# Forcefully kill any process bound to the web portal's port
fuser -k 8080/tcp 2>/dev/null

# Specifically target the Python script just to be absolutely sure it stops running in the background
pkill -f demo_portal.py 2>/dev/null

echo "[+] All demo services have been successfully shut down! Your system is clean."