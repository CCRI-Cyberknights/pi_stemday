#!/bin/bash

# 1. Force the script to run from the correct folder
cd /home/stemday/portal || exit

# 2. Nuke any ghost processes from previous attempts
fuser -k 8080/tcp 2>/dev/null
killall -9 chromium 2>/dev/null

# 3. Give the system a second to completely clear the ports
sleep 2

# 4. Run the Python server completely detached from the execution thread
nohup python3 portal.py > server.log 2>&1 &

# 5. Give the web server 3 seconds to fully bind to port 8080
sleep 3

# 6. Nuke the browser's memory so Juice Shop starts fresh
rm -rf /home/stemday/.config/chromium/Default
rm -rf /home/stemday/.cache/chromium

# 7. Launch the browser
chromium --start-maximized --noerrdialogs --disable-infobars --no-first-run --password-store=basic http://localhost:8080