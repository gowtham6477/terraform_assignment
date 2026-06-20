# ==============================================================
# main.tf
# --------------------------------------------------------------
# This is the HEART of the Terraform project.
# It describes every cloud resource we want to create on AWS.
#
# Terraform reads this file and figures out what API calls to
# make to AWS on your behalf — no clicking in the Console needed!
# ==============================================================


# ==============================================================
# TERRAFORM BLOCK
# --------------------------------------------------------------
# Declares the minimum Terraform version required and pins the
# AWS provider to a specific version so the code stays stable.
# ==============================================================
terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"   # Use any 5.x release — stable & modern
    }
  }
}


# ==============================================================
# PROVIDER BLOCK — AWS
# --------------------------------------------------------------
# A "provider" is a plugin that knows how to talk to a specific
# cloud platform.  Here we tell Terraform:
#   "Use the AWS plugin and point it at the Stockholm region."
#
# The region value comes from variables.tf so it is easy to
# change without touching this file.
# ==============================================================
provider "aws" {
  region = var.aws_region
}


# ==============================================================
# RESOURCE 1 — S3 BUCKET
# --------------------------------------------------------------
# Amazon S3 (Simple Storage Service) is object storage in the
# cloud.  Think of it as a folder on the internet where you can
# store ANY type of file — images, logs, backups, static websites.
#
# Key points:
#   • Bucket names must be GLOBALLY unique across all AWS accounts.
#   • We append a random suffix later if needed; here we keep it
#     simple by using the project name as the bucket name.
#   • Tags help you identify, organise, and filter resources in
#     the AWS Console (like labels on a folder).
# ==============================================================
resource "aws_s3_bucket" "main" {
  # The bucket name must be lowercase, no spaces, no underscores.
  # We use the project_name variable to keep it consistent.
  bucket = var.project_name

  # Tags are key-value pairs attached to AWS resources.
  # They are completely optional but considered best practice.
  tags = {
    Name        = "${var.project_name}-bucket"  # Human-friendly display name
    Environment = "dev"                          # Useful when you have dev/staging/prod
    ManagedBy   = "Terraform"                   # Signals this was NOT created by hand
    Project     = var.project_name
  }
}


# ==============================================================
# RESOURCE 2 — VPC (Virtual Private Cloud)
# --------------------------------------------------------------
# A VPC is your own PRIVATE, ISOLATED section of the AWS network.
# Imagine it as renting a plot of land: AWS owns the city (the
# global network), but inside your plot you control the streets,
# buildings, and who gets in.
#
# CIDR block 10.0.0.0/16 means:
#   • The VPC can contain IP addresses from 10.0.0.0 → 10.0.255.255
#   • That is 65,536 possible IP addresses — plenty to grow into.
#
# enable_dns_support   = true → AWS resolves domain names inside VPC
# enable_dns_hostnames = true → EC2 instances get a DNS hostname
#                               (needed later when we add servers)
# ==============================================================
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name      = "${var.project_name}-vpc"
    ManagedBy = "Terraform"
    Project   = var.project_name
  }
}


# ==============================================================
# RESOURCE 3 — PUBLIC SUBNET
# --------------------------------------------------------------
# A Subnet is a SUBDIVISION of a VPC — like dividing your plot
# of land into smaller sections for different purposes.
#
#   Public subnet  → resources here CAN talk to the internet
#   Private subnet → resources here are isolated (databases, etc.)
#
# CIDR block 10.0.1.0/24 means:
#   • This subnet gets IPs from 10.0.1.0 → 10.0.1.255
#   • That is 256 addresses (AWS reserves 5, so 251 are usable).
#   • It is a smaller slice WITHIN the VPC's 10.0.0.0/16 range.
#
# availability_zone:
#   AWS regions are split into multiple data-centres (zones).
#   eu-north-1a is the first zone in Stockholm.
#   Specifying it explicitly avoids unpredictable zone selection.
#
# map_public_ip_on_launch = true:
#   Any EC2 instance launched here automatically gets a public IP
#   so it can be reached from the internet (we'll add that later).
# ==============================================================
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id   # Link this subnet to our VPC above
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"   # e.g. eu-north-1a
  map_public_ip_on_launch = true

  tags = {
    Name      = "${var.project_name}-public-subnet"
    Type      = "Public"
    ManagedBy = "Terraform"
    Project   = var.project_name
  }
}
