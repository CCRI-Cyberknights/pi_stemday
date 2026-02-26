#!/bin/bash
TARGET_IP=$(hostname -I | awk '{print $1}')
echo "Applying anti-cheat firewall for $TARGET_IP..."

if [[ "$TARGET_IP" == *"192.168.2.10"* ]]; then
    P1="192.168.2.101"
    P2="192.168.2.102"
    P3="192.168.2.103"
elif [[ "$TARGET_IP" == *"192.168.2.20"* ]]; then
    P1="192.168.2.104"
    P2="192.168.2.105"
    P3="192.168.2.106"
elif [[ "$TARGET_IP" == *"192.168.2.30"* ]]; then
    P1="192.168.2.107"
    P2="192.168.2.108"
    P3="192.168.2.109"
else
    echo "Unknown Target IP. Skipping firewall."
    exit 1
fi

sudo iptables -F DOCKER-USER
sudo iptables -A DOCKER-USER -s 192.168.2.50 -j RETURN
sudo iptables -A DOCKER-USER -m conntrack --ctstate ESTABLISHED,RELATED -j RETURN

# Station 1 Isolation
for PORT in 3001 8011 8021 2221 2231; do
    sudo iptables -A DOCKER-USER -p tcp -m conntrack --ctorigdstport $PORT -s $P1 -j RETURN
    sudo iptables -A DOCKER-USER -p tcp -m conntrack --ctorigdstport $PORT -j REJECT --reject-with tcp-reset
done

# Station 2 Isolation
for PORT in 3002 8012 8022 2222 2232; do
    sudo iptables -A DOCKER-USER -p tcp -m conntrack --ctorigdstport $PORT -s $P2 -j RETURN
    sudo iptables -A DOCKER-USER -p tcp -m conntrack --ctorigdstport $PORT -j REJECT --reject-with tcp-reset
done

# Station 3 Isolation
for PORT in 3003 8013 8023 2223 2233; do
    sudo iptables -A DOCKER-USER -p tcp -m conntrack --ctorigdstport $PORT -s $P3 -j RETURN
    sudo iptables -A DOCKER-USER -p tcp -m conntrack --ctorigdstport $PORT -j REJECT --reject-with tcp-reset
done

sudo iptables -A DOCKER-USER -j RETURN
echo "Firewall locked down."
