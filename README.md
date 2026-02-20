# pi_stemday
2026 spring PI STEM Day configs

Setup bash scripts for configuring the player and target PIs, for storage and collab.
Player PIs running Raspberry Pi OS 64bit, with captive portal to ssh into their team's specific target pi (red, blue, yellow)
Target PIs running Raspberry Pi OS 64bit in headless mode, connecting via SSH for config and as a host for the players. Players will connect to docker containers broadcasting on specific ports from their captive portal.

Can be run as is and/or have an administrative laptop connecting to the router on the switch via ethernet, with that connected to a VM in bridged mode. This VM is then sent POST commands from the containers when flags are completed as a scoreboard system.
This is optional as most challenges have their own internal scoring.

The 3 target Pis are connected via the switch part of the wireless router. The player Pis connect via Wi-Fi. Using DHCP reservation, the Pi's MAC addresses are given specific IPs, when they ask to connect to the network, DHCP gives them the correct IP for team placement. (Attach a note to each PI for which is which!)

More to follow and sample [network map.](https://github.com/CCRI-Cyberknights/pi_stemday/blob/main/PI%20Map.png)

The 5 challenges:

[OWASP Juice Shop](https://owasp.org/www-project-juice-shop/)

[OWASP WebGoat](https://owasp.org/www-project-webgoat/)

(Sqli-labs)(https://github.com/Audi-1/sqli-labs)-[Running this ARM64 fork](https://hub.docker.com/r/hominsu/sqli-labs)

[The Command Line Murders](https://github.com/veltman/clmystery)

[Cowrie honeypot](https://docs.cowrie.org/en/latest/)