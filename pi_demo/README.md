# 🎯 Cyber Smorgasbord: Demo in a Box

Welcome to the local testing environment for the CCRI STEM Day Cyber Range! This standalone package contains 5 distinct cybersecurity challenges running in isolated containers.

## Prerequisites
To run this demo, your Linux environment must have:
* Python 3
* Docker (and `docker compose`) OR Podman (and `podman-compose`)

## How to Start the Demo
1. Open your terminal and navigate to this folder.
2. Make the launch script executable:
   `chmod +x start_demo.sh`
3. Run the launch script:
   `./start_demo.sh`

The script will automatically build the backend containers and launch the front-end Captive Portal. If your browser does not open automatically, navigate to `http://127.0.0.1:8080`.

## How to Stop the Demo
When you are done testing, simply run the teardown script in this folder to spin down the containers and free up your system resources:
`./stop_demo.sh`