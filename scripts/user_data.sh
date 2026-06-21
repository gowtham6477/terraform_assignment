#!/bin/bash
# ==============================================================
# user_data.sh
# Bootstrap script — runs ONCE as root on first EC2 boot.
# cloud-init fetches and executes this automatically.
#
# Kept intentionally simple:
#   - No "set -e" (prevents silent exits on minor errors)
#   - No "dnf update" (avoids long timeouts on fresh instances)
#   - Uses systemctl enable --now (start + enable in one command)
# ==============================================================

# Install Apache web server
dnf install -y httpd

# Write the Hello Terraform page
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Hello Terraform</title>
  <style>
    body {
      font-family: 'Segoe UI', sans-serif;
      text-align: center;
      margin-top: 80px;
      background: #f4f4f4;
    }
    h1 {
      color: #7B42BC;
      font-size: 3rem;
      margin-bottom: 0.5rem;
    }
    p {
      color: #555;
      font-size: 1.2rem;
    }
    .badge {
      display: inline-block;
      margin-top: 20px;
      padding: 6px 16px;
      background: #7B42BC;
      color: white;
      border-radius: 20px;
      font-size: 0.9rem;
    }
  </style>
</head>
<body>
  <h1>&#128640; Hello Terraform</h1>
  <p>Deployed automatically with Terraform on AWS EC2</p>
  <div class="badge">eu-north-1 &middot; t3.micro &middot; Amazon Linux 2023</div>
</body>
</html>
EOF

# Start Apache now and enable it on every reboot
systemctl enable --now httpd
