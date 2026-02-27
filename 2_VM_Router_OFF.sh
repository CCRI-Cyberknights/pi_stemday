#!/bin/bash
echo "[-] Disabling IP Forwarding..."
sudo sysctl -w net.ipv4.ip_forward=0
sudo iptables -t nat -D POSTROUTING -o enp0s3 -j MASQUERADE
echo "[-] Parrot routing disabled. Valve is CLOSED."
