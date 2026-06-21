# ==============================================================
# variables.tf
# --------------------------------------------------------------
# This file declares all the INPUT VARIABLES for our project.
#
# Think of variables like "settings" or "parameters" you can
# change without touching the main code.  Instead of hard-coding
# "eu-north-1" inside main.tf, we define it here and reference
# it everywhere — making the project reusable and clean.
# ==============================================================

# ---------------------------------------------------------------
# Variable: aws_region
# Which AWS data-centre region should we deploy resources into?
# eu-north-1 = Stockholm, Sweden
# ---------------------------------------------------------------
variable "aws_region" {
  description = "The AWS region where all resources will be created."
  type        = string
  default     = "eu-north-1"
}

# ---------------------------------------------------------------
# Variable: project_name
# A short label that gets attached to every resource so you can
# easily identify them in the AWS Console later.
# ---------------------------------------------------------------
variable "project_name" {
  description = "A short name for this project, used to tag and name resources."
  type        = string
  default     = "terraform-beginner-project"
}

# ---------------------------------------------------------------
# Variable: bucket_name
# The globally unique name for the S3 bucket.
# Must be lowercase, no spaces, no underscores.
# Kept separate from project_name so you can name the bucket
# independently of the rest of the infrastructure.
# ---------------------------------------------------------------
variable "bucket_name" {
  description = "The globally unique name for the S3 bucket."
  type        = string
  default     = "gowtham-terraform"
}

# ---------------------------------------------------------------
# Variable: my_ip
# Your public IP address in CIDR notation (e.g. "203.0.113.5/32").
# Used to restrict SSH access to ONLY your machine.
# /32 means "this exact single IP address".
#
# Find your current public IP at: https://checkip.amazonaws.com
# or run: curl https://checkip.amazonaws.com
# ---------------------------------------------------------------
variable "my_ip" {
  description = "Your public IP address in CIDR notation (e.g. '203.0.113.5/32'). Used to restrict SSH access to your machine only."
  type        = string
  # No default — you MUST set this in terraform.tfvars so SSH is
  # not accidentally left open to the whole internet.
}

# ---------------------------------------------------------------
# Variable: ec2_ami
# The Amazon Machine Image (AMI) ID — the disk image your EC2
# instance boots from.  AMI IDs are REGION-SPECIFIC.
#
# Default: Amazon Linux 2023 in eu-north-1 (free-tier eligible).
# To find the latest AMI for your region:
#   aws ec2 describe-images \
#     --owners amazon \
#     --filters "Name=name,Values=al2023-ami-*-x86_64" \
#     --query "Images | sort_by(@, &CreationDate)[-1].ImageId" \
#     --region eu-north-1
# ---------------------------------------------------------------
variable "ec2_ami" {
  description = "AMI ID for the EC2 instance. Defaults to Amazon Linux 2023 in eu-north-1."
  type        = string
  default     = "ami-0c1ac8a41498c1a9c" # Amazon Linux 2023, eu-north-1, free-tier eligible
}

# ---------------------------------------------------------------
# Variable: ec2_instance_type
# The hardware profile for the EC2 instance.
#   t3.micro = 2 vCPU, 1 GB RAM — AWS free-tier eligible.
# ---------------------------------------------------------------
variable "ec2_instance_type" {
  description = "EC2 instance type. t3.micro is free-tier eligible."
  type        = string
  default     = "t3.micro"
}
