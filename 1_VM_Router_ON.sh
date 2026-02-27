#!/bin/bash
echo "[+] Enabling IP Forwarding..."
sudo sysctl -w net.ipv4.ip_forward=1
sudo iptables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE
echo "[+] Parrot is now routing traffic. Valve is OPEN."
