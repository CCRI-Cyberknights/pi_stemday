# 🎯 CCRI STEM Day 2026: Offline Cyber Range

Configuration files and bash deployment scripts for the Spring 2026 CCRI STEM Day Capture the Flag (CTF) event. 

This project automates the creation of a fully offline, multi-team cyber range using a cluster of Raspberry Pi 5s. It utilizes Dockerized vulnerable applications and a custom captive portal to give high school students a frictionless, browser-based hacking experience.

## 🏗️ Architecture & Networking

* **Player Pis (Attackers):** Running Raspberry Pi OS (64-bit) Desktop. These connect via Wi-Fi. They boot directly into a custom Python-based captive portal, providing a clean UI to launch web targets or view SSH instructions for their assigned Target Pi (Red, Blue, or Yellow).
* **Target Pis (Victims):** Running Raspberry Pi OS (64-bit) Headless. These are hardwired into the router's switch. They host the vulnerable Docker containers and listen for SSH connections. 
* **Network Control:** The router uses strict DHCP reservations tied to the Pi MAC addresses. When a Pi connects, DHCP automatically assigns its designated team IP. *(Tip: Physically label your Pis!)*
* **Scoreboard (Optional):** The range can run standalone, or an administrative laptop can be connected via ethernet. A bridged VM on the laptop can listen on port 80 for JSON POST webhooks triggered by the containers upon challenge completion.

🗺️ **[View the Network Topology Map](https://github.com/CCRI-Cyberknights/pi_stemday/blob/main/PI%20Map.png)**

## 📦 Container Infrastructure

Each Target Pi runs **15 distinct challenge containers** to support 3 independent players simultaneously without cross-talk. An `iptables` script enforces strict anti-cheat firewall rules to prevent players from accessing other students' instances. 

The container ports end in the player's station number (1, 2, or 3) for isolation:
* **OWASP Juice Shop:** Ports `3001`, `3002`, `3003`
* **SQLi-Labs:** Ports `8011`, `8012`, `8013`
* **OWASP WebGoat:** Ports `8021`, `8022`, `8023`
* **Cowrie (Active Defense):** Ports `2221`, `2222`, `2223` (SSH)
* **CLMystery (Terminal Escape):** Ports `2231`, `2232`, `2233` (SSH)

## ⚔️ The Challenges

Students have access to 5 distinct challenges, ranging from web application exploitation to terminal navigation.

1. **OWASP Juice Shop** - [Player Guide](https://github.com/CCRI-Cyberknights/pi_stemday/blob/main/readme_juice.html)
2. **OWASP WebGoat** - [Player Guide](https://github.com/CCRI-Cyberknights/pi_stemday/blob/main/readme_webgoat.html)
3. **SQLi-Labs** - [Player Guide](https://github.com/CCRI-Cyberknights/pi_stemday/blob/main/readme_sqli.html)
4. **The Command Line Murders** - *(Instructions are hidden inside the container upon SSH login)*
5. **Cowrie Honeypot** - [Player Guide](https://github.com/CCRI-Cyberknights/pi_stemday/blob/main/readme_cowrie.html)

## 📸 Screenshots

*Captive Portal Start Screens:*
* [Red Team - Player 1](https://github.com/CCRI-Cyberknights/pi_stemday/blob/main/red_capture.png)
* [Blue Team - Player 1]() *(Coming Soon)*
* [Yellow Team - Player 1]() *(Coming Soon)*

## 📚 Credits & Upstream Projects

This cyber range is built on the shoulders of incredible open-source projects. If you enjoyed the challenges and want to run them at home or read the official documentation, check out the source repositories below:

* **[OWASP Juice Shop](https://owasp.org/www-project-juice-shop/):** The most modern and sophisticated insecure web application. ([GitHub](https://github.com/juice-shop/juice-shop))
* **[OWASP WebGoat](https://owasp.org/www-project-webgoat/):** A deliberately insecure interactive classroom designed to teach web application security lessons. ([GitHub](https://github.com/WebGoat/WebGoat))
* **[SQLi-Labs](https://github.com/Audi-1/sqli-labs):** A highly detailed, interactive environment specifically focused on mastering database manipulation and SQL Injection. We are using the native [ARM64 Docker Port](https://hub.docker.com/r/hominsu/sqli-labs) by hominsu.
* **[The Command Line Murders](https://github.com/veltman/clmystery):** A brilliant terminal-based murder mystery created by Noah Veltman. (Check the repository for cheat sheets and hints!)
* **[Cowrie Honeypot](https://cowrie.readthedocs.io/):** A medium-to-high interaction SSH and Telnet honeypot designed to log brute force attacks and the shell interaction performed by the attacker. ([GitHub](https://github.com/cowrie/cowrie))