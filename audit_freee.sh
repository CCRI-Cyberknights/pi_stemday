#!/bin/bash

# List of all IPs (Target Red, Blue, Green + 9 Players)
PI_IPS=(
  "192.168.2.10" "192.168.2.20" "192.168.2.30" 
  "192.168.2.101" "192.168.2.102" "192.168.2.103"
  "192.168.2.104" "192.168.2.105" "192.168.2.106"
  "192.168.2.107" "192.168.2.108" "192.168.2.109"
)

echo "==============================================="
echo "   CCRI STEM Day: Deep Freeze Security Audit   "
echo "==============================================="

for ip in "${PI_IPS[@]}"; do
    # 1. Determine the correct user for this IP
    if [[ "$ip" == "192.168.2.10" || "$ip" == "192.168.2.20" || "$ip" == "192.168.2.30" ]]; then
        SSH_USER="stemtarget"
    else
        SSH_USER="stemday"
    fi

    # 2. Check if the Pi is even awake first
    if ping -c 1 -W 1 "$ip" > /dev/null; then
        # Check the mount status of the root filesystem
        # We look for 'overlay' which indicates the RAM shield is active
        STATUS=$(ssh -o ConnectTimeout=2 -o StrictHostKeyChecking=no "$SSH_USER@$ip" "mount | grep 'on / type overlay' > /dev/null && echo 'LOCKED' || echo 'UNPROTECTED'")
        
        if [ "$STATUS" == "LOCKED" ]; then
            echo -e "[$ip] ($SSH_USER) \033[0;32mSAFE\033[0m (Deep Freeze is ON)"
        else
            echo -e "[$ip] ($SSH_USER) \033[0;31mWARNING\033[0m (Drive is Writeable!)"
        fi
    else
        echo -e "[$ip] \033[0;33mOFFLINE\033[0m (Cannot reach device)"
    fi
done
echo "==============================================="