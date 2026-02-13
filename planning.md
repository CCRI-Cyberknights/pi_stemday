# STEM Day CTF Architecture & Deployment Plan

## 1. Event Overview
A localized, offline Capture the Flag (CTF) event designed for high school students. The environment runs entirely on a private local area network (LAN) using Raspberry Pi 5 hardware, Dockerized vulnerable applications, and a centralized scoring server.

## 2. Hardware Inventory
* **12x Raspberry Pi 5s** (3 Targets, 9 Players)
* **12x USB-C Power Supplies** (Official Pi 5)
* **12x Micro-SD Cards** (16GB+)
* **1x D-Link DIR-2640 (AC2600) Router**
* **1x Instructor Laptop** (Dual-homed network setup)
* **1x USB Gigabit Ethernet Adapter** (For instructor laptop)

## 3. Network Topology (192.168.1.0/24)
The network relies on strict DHCP Reservations tied to hardware MAC addresses to ensure consistent routing and scoring.

* **Gateway/Router:** `192.168.1.1`
* **Instructor Scoreboard VM:** `192.168.1.50` (Bridged to USB Ethernet)
* **Target Pis (Headless Servers):**
  * Target Red: `192.168.1.10`
  * Target Blue: `192.168.1.20`
  * Target Yellow: `192.168.1.30`
* **Player Pis (Attacker Workstations):**
  * Red Team (Seats 1-3): `192.168.1.101` to `.103`
  * Blue Team (Seats 1-3): `192.168.1.104` to `.106`
  * Yellow Team (Seats 1-3): `192.168.1.107` to `.109`

## 4. Target Pi Architecture (The Payload)
Each Target Pi runs a "Smart Dashboard" and multiple isolated Docker containers so three students can hack the same physical Pi simultaneously without stepping on each other's toes.

### The Smart Dashboard (`app.py`)
A lightweight Flask app running on Port 80. It detects the incoming Player IP address and dynamically generates a personalized menu linking them to their specific container ports.

### The Containers (`docker-compose.yml`)
Each Target Pi runs 9 challenge containers and 1 dashboard container:
* **Seat 1:** Juice Shop (Port 3001), DVWA (Port 8081), CTFd (Port 9001)
* **Seat 2:** Juice Shop (Port 3002), DVWA (Port 8082), CTFd (Port 9002)
* **Seat 3:** Juice Shop (Port 3003), DVWA (Port 8083), CTFd (Port 9003)

### System Protection
After final configuration, each Target Pi will have the **Overlay File System** enabled via `raspi-config` to enforce a "Deep Freeze" read-only state, protecting against accidental system destruction.

## 5. Player Pi Architecture (The Attacker)
Player Pis are cloned from a single "Golden Image" for rapid deployment. 

* **OS:** Raspberry Pi Desktop (64-bit)
* **Pre-installed Tools:** nmap, hydra, curl
* **User Interface:** Hacker-themed wallpaper, `MISSION_BRIEF.txt` on the desktop.
* **Navigation:** Firefox browser with pre-set bookmarks to the Target Pis (`http://192.168.1.10`, etc.).

## 6. Centralized Scoreboard (Instructor Laptop)
The instructor laptop utilizes a "Dual-Homed" setup:
* **Wi-Fi Interface:** Connected to the building/public internet for research and troubleshooting.
* **USB Ethernet Interface:** Connected to the offline CTF LAN.

A lightweight Linux VM (Bridged Adapter) runs a custom Python script (`scoreboard.py`) on `192.168.1.50:80`. 
* **Webhook Integration:** Juice Shop containers automatically POST JSON data to this IP when a student solves a challenge.
* **Console Output:** The Python script parses the JSON, identifies the team via their IP address, and prints live scoring updates to the instructor's terminal.

## 7. Setup & Deployment Workflow
1. **Hardware ID:** Boot all 12 Pis individually, log their MAC addresses, and assign DHCP reservations in the D-Link router.
2. **Player Golden Image:** Build one perfect Player Pi, clone the SD card 8 times using Win32DiskImager.
3. **Target Golden Image:** Build one perfect Target Pi with Docker, `app.py`, and `docker-compose.yml`. Test connections. Clone 2 times.
4. **Target Localization:** Boot the Target clones, run `sudo raspi-config` to change hostnames to `target-blue` and `target-yellow`, update the dashboard color themes.
5. **Deep Freeze:** Enable Overlay File System on all Targets.
