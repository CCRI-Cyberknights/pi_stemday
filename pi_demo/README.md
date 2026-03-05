# 🎯 Cyber Smorgasbord: Demo in a Box

Welcome to the local testing environment for the CCRI STEM Day Cyber Range! This standalone package contains 5 distinct cybersecurity challenges running in isolated containers.

You can view the full source code, networking architecture, and live event deployment scripts at our official GitHub repository: [CCRI-Cyberknights/pi_stemday](https://github.com/CCRI-Cyberknights/pi_stemday).

## Prerequisites
To run this demo, your Linux environment must have Python 3 installed. 
*Note: If you do not have Docker or Podman installed, the launch script will automatically download and install Docker for you.*

## How to Start the Demo
1. Open your terminal and navigate to this extracted folder.
2. Make the scripts executable (you only need to do this once):
   `chmod +x start_demo.sh stop_demo.sh`
3. Run the launch script:
   `./start_demo.sh`

*If the script needs to install Docker, it will prompt you for your `sudo` (administrator) password. It will also use `sudo` to launch the containers for the first time.*

The script will automatically build the backend containers and launch the front-end Captive Portal. If your browser does not open automatically, navigate to `http://127.0.0.1:8080`.

## How to Stop the Demo
When you are done testing, simply run the teardown script in this folder to spin down the containers, close the web server, and free up your system resources:
`./stop_demo.sh`