#!/bin/bash
read -p "Enter Pi IP (e.g., 192.168.2.10): " PI_IP

echo "Which type of Pi is this?"
echo "1) Target Pi (stemtarget)"
echo "2) Player Pi (stemday)"
read -p "Select [1-2]: " TYPE_SELECTION

if [ "$TYPE_SELECTION" == "1" ]; then
    SSH_USER="stemtarget"
elif [ "$TYPE_SELECTION" == "2" ]; then
    SSH_USER="stemday"
else
    echo "Invalid selection. Exiting."
    exit 1
fi

echo "[-] Connecting to $SSH_USER@$PI_IP to sever internet..."

ssh -t $SSH_USER@$PI_IP '
    sudo ip route del default via 192.168.2.50 2>/dev/null
    echo "nameserver 192.168.2.1" | sudo tee /etc/resolv.conf > /dev/null
    echo "[-] Internet access removed. Pi is isolated."
'