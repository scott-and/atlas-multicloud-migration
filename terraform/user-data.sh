#!/bin/bash
set -e

dnf install -y nginx

systemctl start nginx

systemctl enable nginx

TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

HOSTNAME=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/hostname)

echo "Hello from $HOSTNAME" > /usr/share/nginx/html/index.html