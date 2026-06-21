# Terraform settings block.
terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# AWS provider configuration block.
provider "aws" {
  region = var.aws_region
}

# Query latest AL2023 AMI.
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

# S3 storage bucket.
resource "aws_s3_bucket" "main" {
  bucket = var.bucket_name

  # Resource tags.
  tags = {
    Name        = var.bucket_name
    Environment = "dev"
    ManagedBy   = "Terraform"
    Project     = var.project_name
  }
}

# Virtual Private Cloud.
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

# Public subnet.
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name      = "${var.project_name}-public-subnet"
    Type      = "Public"
    ManagedBy = "Terraform"
    Project   = var.project_name
  }
}

# Internet gateway connection.
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name      = "${var.project_name}-igw"
    ManagedBy = "Terraform"
    Project   = var.project_name
  }
}

# Public route table.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

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

# Associate subnet to route table.
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security group configuration.
resource "aws_security_group" "web" {
  name        = "${var.project_name}-web-sg"
  description = "Allow SSH from my IP, HTTP from anywhere, and all outbound traffic"
  vpc_id      = aws_vpc.main.id

  # Inbound rule: SSH from authorized IP.
  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  # Inbound rule: HTTP from anywhere.
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rule: allow all traffic.
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

# EC2 instance web server.
resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = var.ec2_instance_type
  subnet_id     = aws_subnet.public.id

  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.web.id]

  # Auto-replace on user_data changes.
  user_data_replace_on_change = true

  # Enable IMDSv1 fallback for cloud-init compatibility.
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"
  }

  # Instance user data template.
  user_data = templatefile("${path.module}/scripts/user_data.sh", {
    vpc_id              = aws_vpc.main.id
    vpc_cidr            = aws_vpc.main.cidr_block
    subnet_id           = aws_subnet.public.id
    subnet_cidr         = aws_subnet.public.cidr_block
    internet_gateway_id = aws_internet_gateway.main.id
    security_group_id   = aws_security_group.web.id
    bucket_name         = var.bucket_name
    aws_region          = var.aws_region
    project_name        = var.project_name
    html_b64            = file("${path.module}/scripts/index.html.b64")
  })

  tags = {
    Name      = "${var.project_name}-web-server"
    ManagedBy = "Terraform"
    Project   = var.project_name
  }
}
