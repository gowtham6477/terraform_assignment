#!/bin/bash
# ==============================================================
# user_data.sh
# Bootstrap script — runs ONCE as root on first EC2 boot.
# cloud-init fetches and executes this automatically.
# ==============================================================

# Install Apache web server
dnf install -y httpd

# Fetch metadata values dynamically from within the instance
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
PUBLIC_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4)
INSTANCE_TYPE=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-type)
AMI_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/ami-id)

# Decode and extract the webpage
echo "${html_b64}" | base64 -d | gunzip > /var/www/html/index.html

# Substitute all placeholders dynamically in index.html
sed -i "s/__INSTANCE_ID__/$INSTANCE_ID/g" /var/www/html/index.html
sed -i "s/__PUBLIC_IP__/$PUBLIC_IP/g" /var/www/html/index.html
sed -i "s/__INSTANCE_TYPE__/$INSTANCE_TYPE/g" /var/www/html/index.html
sed -i "s/__AMI_ID__/$AMI_ID/g" /var/www/html/index.html
sed -i "s/__VPC_ID__/${vpc_id}/g" /var/www/html/index.html
sed -i "s/__VPC_CIDR__/${vpc_cidr}/g" /var/www/html/index.html
sed -i "s/__SUBNET_ID__/${subnet_id}/g" /var/www/html/index.html
sed -i "s/__SUBNET_CIDR__/${subnet_cidr}/g" /var/www/html/index.html
sed -i "s/__INTERNET_GATEWAY_ID__/${internet_gateway_id}/g" /var/www/html/index.html
sed -i "s/__SECURITY_GROUP_ID__/${security_group_id}/g" /var/www/html/index.html
sed -i "s/__BUCKET_NAME__/${bucket_name}/g" /var/www/html/index.html
sed -i "s/__AWS_REGION__/${aws_region}/g" /var/www/html/index.html
sed -i "s/__PROJECT_NAME__/${project_name}/g" /var/www/html/index.html

# Start Apache now and enable it on every reboot
systemctl enable --now httpd
