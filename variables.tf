# Project input variables.

# Target AWS region.
variable "aws_region" {
  description = "The AWS region where all resources will be created."
  type        = string
  default     = "eu-north-1"
}

# Project identifier tag.
variable "project_name" {
  description = "A short name for this project, used to tag and name resources."
  type        = string
  default     = "terraform-beginner-project"
}

# Globally unique S3 bucket name.
variable "bucket_name" {
  description = "The globally unique name for the S3 bucket."
  type        = string
  default     = "gowtham-terraform"
}

# Administrator public IP in CIDR notation.
variable "my_ip" {
  description = "Your public IP address in CIDR notation (e.g. '203.0.113.5/32'). Used to restrict SSH access to your machine only."
  type        = string
}

# Amazon Linux 2023 AMI ID.
variable "ec2_ami" {
  description = "AMI ID for the EC2 instance. Defaults to Amazon Linux 2023 in eu-north-1."
  type        = string
  default     = "ami-0c1ac8a41498c1a9c"
}

# EC2 hardware instance type.
variable "ec2_instance_type" {
  description = "EC2 instance type. t3.micro is free-tier eligible."
  type        = string
  default     = "t3.micro"
}
