apt update
apt upgrade

apt install ubuntu-drivers-common
ubuntu-drivers devices
apt install "<<DRIVER NAME FROM THE OUTPUT ABOVE>>>"
reboot now
nvidia-smi # check driver installation
apt install gcc && gcc -v


"Step 7: Install CUDA toolkit Ubuntu
We will now head to the NVIDIA CUDA download website to get the latest CUDA toolkit for Ubuntu.
The website will navigate you through the right package to download as well as the commands to
execute to complete the CUDA toolkit installation."

reboot now

nano ~/.bashrc
export PATH=/usr/local/cuda/bin${PATH:+:${PATH}}
export LD_LIBRARY_PATH=/usr/local/cuda-<<PUT YOUR CUDA VERSION>>/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}

source ~/.bashrc && nvcc -V


apt install ffmpeg
apt install sox
apt install python3-dev

apt install python3-venv
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt


----

#!/bin/bash

# Update package lists and upgrade existing packages
apt update && apt upgrade -y

# Install ubuntu-drivers-common to manage drivers
apt install -y ubuntu-drivers-common

# List available drivers and choose appropriate one (latest, server build)
ubuntu-drivers devices

# Install the selected driver
apt install -y "PUT_YOUR_REQUIRED_DRIVER_VERSION_HERE"

# Reboot to apply driver changes
reboot now

# After reboot, verify NVIDIA driver installation
nvidia-smi

# Install essential development tools
apt install -y gcc
gcc -v

# Install CUDA Toolkit (manual installation required, follow instructions from NVIDIA's website)

# After CUDA Toolkit installation, update environment variables
CUDA_VERSION="<<PUT_YOUR_CUDA_VERSION_HERE>>"
echo 'export PATH=/usr/local/cuda/bin${PATH:+:${PATH}}' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/usr/local/cuda-${CUDA_VERSION}/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}' >> ~/.bashrc
source ~/.bashrc

# Verify CUDA installation
nvcc -V

# Install additional utilities
apt install -y ffmpeg sox python3-dev python3-venv

# Set up Python virtual environment
python3 -m venv venv
source venv/bin/activate

# Install Python dependencies from requirements file
pip install -r requirements.txt

ufw allow 7860
python src/webui.py


apt install nginx
cd /etc/nginx/sites-enabled && nano aicovers-static-files
COPY nginx config
nano aicovers-api && COPY nginx config
service nginx restart


ufw allow 8001
ufw allow 5000

gunicorn -w 3 --bind 0.0.0.0:5001 src.api:app

apt install supervisor

rm /etc/supervisor/conf.d/aicovers_api.conf && nano /etc/supervisor/conf.d/aicovers_api.conf
COPY content

mkdir /var/log/aicovers_api
touch /var/log/aicovers_api/aicovers_api.log

supervisorctl reload && cat /var/log/aicovers_api/aicovers_api.log && supervisorctl status


rm /etc/supervisor/conf.d/aicovers_worker.conf && nano /etc/supervisor/conf.d/aicovers_worker.conf
COPY content

mkdir /var/log/aicovers_worker
touch /var/log/aicovers_worker/aicovers_worker.log

supervisorctl reload && cat /var/log/aicovers_worker/aicovers_worker.log && supervisorctl status
tail -f /var/log/aicovers_worker/aicovers_worker.log


apt install certbot python3-certbot-nginx
certbot --nginx -d files.aicovers.lightingwayou.com