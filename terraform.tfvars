# ==============================================================
# terraform.tfvars
# --------------------------------------------------------------
# This file supplies the ACTUAL VALUES for the variables
# declared in variables.tf.
#
# Terraform automatically reads this file.  It is the place
# where you customise the project without touching any logic.
#
# TIP: Never commit sensitive values (passwords, keys) in this
#      file to version control.  Use environment variables or a
#      secrets manager for those.
# ==============================================================

aws_region   = "eu-north-1"
project_name = "terraform-beginner-project-112790"
bucket_name  = "gowtham-terraform"

# ── YOUR PUBLIC IP ──────────────────────────────────────────────
# Replace with your actual public IP in CIDR /32 notation.
# Find it by running: curl https://checkip.amazonaws.com
# Then append /32, e.g.:  my_ip = "203.0.113.5/32"
my_ip = "157.51.138.73/32"

# ── EC2 CONFIGURATION ───────────────────────────────────────────
# Amazon Linux 2023 AMI for eu-north-1 (free-tier eligible)
ec2_ami           = "ami-0c1ac8a41498c1a9c"
ec2_instance_type = "t3.micro"
