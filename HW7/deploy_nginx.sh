#!/bin/bash

# Security settings for script:
set -eu

# Load variables
echo "=== Loading variables from .env file ==="
source .env


# Installing Nginx, stopping default service and configuring Firewall
echo "=== Step 0: Installing NGNIX ==="
sudo apt update
sudo apt install nginx gettext-base -y

# Stopping default service
echo "=== Step 0.1: Stopping default nginx service ==="
sudo systemctl stop nginx || true
sudo systemctl disable nginx || true

# Configuring Firewall
echo "=== Step 0.2: Configuring Firewall ==="
echo "Opening port 22 for SSH"
sudo ufw allow 22/tcp
echo "Opening port ${PORT1} for Nginx"
sudo ufw allow "${PORT1}"/tcp
echo "Opening port ${PORT2} for Nginx"
sudo ufw allow "${PORT2}"/tcp
echo "Enabling firewall"
sudo ufw --force enable


# Add folders
## Port 1
echo "=== Step 1: Creating folders for ${PORT1} ==="
sudo mkdir -p /etc/nginx/sites/port${PORT1}
sudo mkdir -p /var/log/nginx/sites/port${PORT1}
sudo mkdir -p /var/www/port${PORT1}/html

## Port 2
echo "=== Step 1.1: Creating folders for ${PORT2} ==="
sudo mkdir -p /etc/nginx/sites/port${PORT2}
sudo mkdir -p /var/log/nginx/sites/port${PORT2}
sudo mkdir -p /var/www/port${PORT2}/html


# Creating HTML pages
## For port 1
echo "=== Step 2: Creating HTML pages for ${PORT1} ==="
sudo sh -c "echo '<h1>Welcome to nginx! (Port ${PORT1} is WORKING!!!)</h1>' > /var/www/port${PORT1}/html/index.html"

## For port 2
echo "=== Step 2.1: Creating HTML pages for ${PORT2} ==="
sudo sh -c "echo '<h1>Welcome to nginx! (Port ${PORT2} is WORKING!!!)</h1>' > /var/www/port${PORT2}/html/index.html"


# Add nginx.conf
## For port 1
echo "=== Step 3: Adding configuration nginx.conf for ${PORT1} ==="
export PORT=${PORT1}
envsubst '\$PORT' < nginx.conf.template > nginx.conf
sudo cp nginx.conf /etc/nginx/sites/port${PORT1}/nginx.conf
rm nginx.conf

## For port 2
echo "=== Step 3.1: Adding configuration nginx.conf for ${PORT2} ==="
export PORT=${PORT2}
envsubst '\$PORT' < nginx.conf.template > nginx.conf
sudo cp nginx.conf /etc/nginx/sites/port${PORT2}/nginx.conf
rm nginx.conf


# Creating systemd unit file
## For port 1
echo "=== Step 4: Creating systemd unit file for ${PORT1} ==="
export PORT=${PORT1}
envsubst '\$PORT' < nginx.service.template > nginx-port${PORT1}.service
sudo cp nginx-port${PORT1}.service /etc/systemd/system/nginx-port${PORT1}.service
rm nginx-port${PORT1}.service

## For port 2
echo "=== Step 4.1: Creating systemd unit file for ${PORT2} ==="
export PORT=${PORT2}
envsubst '\$PORT' < nginx.service.template > nginx-port${PORT2}.service
sudo cp nginx-port${PORT2}.service /etc/systemd/system/nginx-port${PORT2}.service
rm nginx-port${PORT2}.service


# Restart and activation services
echo "=== Step 5: Restarting daemon ==="
sudo systemctl daemon-reload

## For port 1
echo "=== Step 5.1: Enable and restart NGINX for ${PORT1} ==="
sudo systemctl enable nginx-port${PORT1}.service
sudo systemctl restart nginx-port${PORT1}.service

## For port 2
echo "=== Step 5.2: Enable and restart NGINX for ${PORT2} ==="
sudo systemctl enable nginx-port${PORT2}.service
sudo systemctl restart nginx-port${PORT2}.service


# Check
## Check for port 1
echo "=== Step 6: Examination ==="
echo "Checking Port ${PORT1}:"
curl -L http://127.0.0.1:${PORT1}
echo ""

## Check for port 2
echo "Checking Port ${PORT2}:"
curl -L http://127.0.0.1:${PORT2}
echo ""

echo "=== All checks completed! Congratulations!!! ==="