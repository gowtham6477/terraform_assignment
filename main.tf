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
      version = "~> 5.0" # Use any 5.x release — stable & modern
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
# DATA SOURCE — LATEST AMAZON LINUX 2023 AMI
# --------------------------------------------------------------
# Instead of hard-coding an AMI ID (which can become stale),
# we look up the LATEST Amazon Linux 2023 AMI at plan time.
# AWS publishes new AMIs regularly with security patches.
#
# owners = ["amazon"] → official AWS-owned images only
# al2023-ami-*-x86_64 → matches any AL2023 64-bit AMI
# The most_recent = true picks the newest one automatically.
# ==============================================================
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
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
  # Use the dedicated bucket_name variable (must be globally unique).
  bucket = var.bucket_name

  # Tags are key-value pairs attached to AWS resources.
  # They are completely optional but considered best practice.
  tags = {
    Name        = var.bucket_name
    Environment = "dev"                        # Useful when you have dev/staging/prod
    ManagedBy   = "Terraform"                  # Signals this was NOT created by hand
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
  vpc_id                  = aws_vpc.main.id # Link this subnet to our VPC above
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a" # e.g. eu-north-1a
  map_public_ip_on_launch = true

  tags = {
    Name      = "${var.project_name}-public-subnet"
    Type      = "Public"
    ManagedBy = "Terraform"
    Project   = var.project_name
  }
}


# ==============================================================
# RESOURCE 4 — INTERNET GATEWAY (IGW)
# --------------------------------------------------------------
# An Internet Gateway is the DOOR between your VPC and the
# public internet.  Without it, no traffic can flow in or out
# of your VPC — even if resources have public IPs.
#
# Think of it as the front gate of a gated community:
#   • The VPC is the community (private, self-contained).
#   • The IGW is the gate that lets residents (EC2 instances)
#     drive out to the city (internet) and back.
#
# One IGW attaches to exactly one VPC and is highly available
# by design — AWS manages the underlying infrastructure for you.
# ==============================================================
resource "aws_internet_gateway" "main" {
  # Attach this gateway to our VPC defined above.
  vpc_id = aws_vpc.main.id

  tags = {
    Name      = "${var.project_name}-igw"
    ManagedBy = "Terraform"
    Project   = var.project_name
  }
}


# ==============================================================
# RESOURCE 5 — ROUTE TABLE
# --------------------------------------------------------------
# A Route Table is a set of ROUTING RULES that tell AWS where
# to send network traffic leaving a subnet.
#
# Analogy: think of route tables as a GPS in each subnet.
# When a packet leaves an EC2 instance, AWS checks the route
# table and follows the matching rule.
#
# Default local route (automatic):
#   10.0.0.0/16 → local   (traffic within the VPC stays local)
#
# We add one custom rule:
#   0.0.0.0/0   → igw     (ALL other traffic goes to internet)
#
# 0.0.0.0/0 means "any IP address" — it is the default route,
# equivalent to the "use this road for everything else" rule.
# ==============================================================
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  # Default route: send all internet-bound traffic through the IGW.
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name      = "${var.project_name}-public-rt"
    ManagedBy = "Terraform"
    Project   = var.project_name
  }
}


# ==============================================================
# RESOURCE 6 — ROUTE TABLE ASSOCIATION
# --------------------------------------------------------------
# A Route Table Association LINKS a specific subnet to a
# specific route table.
#
# Why is this needed?
#   Every subnet automatically uses the VPC's "main" route table
#   unless you explicitly associate it with a different one.
#   The main table has NO internet route — so traffic would be
#   silently dropped.
#
#   By associating our public subnet with the route table we
#   just created (which has the 0.0.0.0/0 → IGW rule), all
#   EC2 instances in that subnet can reach the internet.
#
# This is what makes a subnet truly "public."
# ==============================================================
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}


# ==============================================================
# RESOURCE 7 — SECURITY GROUP
# --------------------------------------------------------------
# A Security Group (SG) acts as a VIRTUAL FIREWALL for your
# EC2 instances.  It controls which traffic is ALLOWED in
# (ingress) and out (egress).
#
# Key characteristics:
#   • Stateful — if you allow inbound traffic, the response is
#     automatically allowed back (no need for a matching egress
#     rule for every inbound rule you create).
#   • Default-deny — anything not explicitly allowed is blocked.
#   • Attached per resource (not per subnet or VPC).
#
# Our rules:
#   Ingress port 22  (SSH)  from var.my_ip  → lets YOU log in
#   Ingress port 80  (HTTP) from 0.0.0.0/0  → public web access
#   Egress  all traffic     to   0.0.0.0/0  → outbound unrestricted
# ==============================================================
resource "aws_security_group" "web" {
  name        = "${var.project_name}-web-sg"
  description = "Allow SSH from my IP, HTTP from anywhere, and all outbound traffic"
  vpc_id      = aws_vpc.main.id

  # ── Inbound rule 1: SSH ──────────────────────────────────────
  # Port 22 is the standard port for SSH (Secure Shell).
  # Restricting to your IP is a best practice — never open
  # SSH to the whole internet (0.0.0.0/0) in production.
  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  # ── Inbound rule 2: HTTP ─────────────────────────────────────
  # Port 80 is standard HTTP.  Opening it to 0.0.0.0/0 lets
  # anyone on the internet reach the web server on our EC2.
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ── Outbound rule: all traffic ───────────────────────────────
  # Allow the instance to reach out anywhere (install packages,
  # call APIs, etc.).  protocol "-1" means "all protocols."
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "${var.project_name}-web-sg"
    ManagedBy = "Terraform"
    Project   = var.project_name
  }
}


# ==============================================================
# RESOURCE 8 — EC2 INSTANCE
# --------------------------------------------------------------
# EC2 (Elastic Compute Cloud) is a virtual machine (server)
# running in the AWS data centre.  This is where your code,
# website, or application actually runs.
#
# ami (Amazon Machine Image):
#   A pre-baked disk snapshot — the OS + software the instance
#   boots from.  The AMI ID comes from var.ec2_ami (defined in
#   variables.tf) and points to Amazon Linux 2023 in eu-north-1,
#   which is free-tier eligible.
#
# instance_type = "t3.micro":
#   Defines CPU and RAM.  t3.micro = 2 vCPU, 1 GB RAM.
#   It is AWS free-tier eligible (750 hours/month for 12 months).
#
# subnet_id:
#   Placing the instance in our public subnet ensures it gets
#   a public IP (because map_public_ip_on_launch = true on the
#   subnet).
#
# associate_public_ip_address = true:
#   Explicitly requests a public IPv4 address so the instance is
#   directly reachable from the internet.
#
# vpc_security_group_ids:
#   Attaches our Security Group firewall rules to the instance.
#
# user_data:
#   A shell script that runs ONCE when the instance first boots.
#   We use it to install Apache and serve our HTML page.
#   Detailed explanation below the resource block.
# ==============================================================
resource "aws_instance" "web" {
  # Use the data source AMI — always the latest Amazon Linux 2023.
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = var.ec2_instance_type

  # Place the instance in our public subnet inside the VPC.
  subnet_id = aws_subnet.public.id

  # Explicitly assign a public IP so the instance is reachable
  # from the internet (works together with the IGW + route table).
  associate_public_ip_address = true

  # Attach the Security Group that allows SSH (22) and HTTP (80).
  vpc_security_group_ids = [aws_security_group.web.id]

  # Automatically replace the instance whenever user_data changes.
  # Without this, Terraform updates the metadata but the script
  # does not re-run on an already-running instance.
  user_data_replace_on_change = true

  # Allow both IMDSv1 and IMDSv2 so cloud-init can always fetch
  # user_data regardless of the token requirement setting.
  # "optional" means IMDSv2 tokens are accepted but not required.
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"
  }

  # ── user_data: Bootstrap Script ──────────────────────────────
  # This bash script is base64-encoded and stored in the EC2
  # instance metadata endpoint.  The AWS cloud-init service
  # fetches it and runs it as root the very first time the
  # instance boots — before you can even SSH in.
  #
  # <<-EOF ... EOF is a Terraform "heredoc" — a convenient way
  # to write a multi-line string directly in HCL.
  #
  # Steps performed automatically on first boot:
  #   1. dnf update -y      → patch all OS packages
  #   2. dnf install httpd  → install Apache web server
  #   3. echo ...           → write a minimal HTML page
  #   4. systemctl start    → start Apache right away
  #   5. systemctl enable   → auto-start Apache on every reboot
  # user_data: Bootstrap script executed once on first boot by cloud-init.
  # Using file() reads scripts/user_data.sh at plan time and passes it
  # as a plain string. The AWS provider base64-encodes it automatically.
  # This avoids ALL heredoc / quoting / whitespace issues completely.
  user_data = file("${path.module}/scripts/user_data.sh")

  tags = {
    Name      = "${var.project_name}-web-server"
    ManagedBy = "Terraform"
    Project   = var.project_name
  }
}
