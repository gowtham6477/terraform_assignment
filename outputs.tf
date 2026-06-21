# ==============================================================
# outputs.tf
# --------------------------------------------------------------
# This file declares OUTPUT VALUES — information Terraform
# prints to your terminal after "terraform apply" succeeds.
#
# Why outputs?
#   • They give you quick access to important IDs/names without
#     hunting through the AWS Console.
#   • Other Terraform modules or CI/CD pipelines can read these
#     outputs programmatically (e.g., to wire services together).
# ==============================================================

# ---------------------------------------------------------------
# Output: bucket_name
# The globally unique name AWS assigned to your S3 bucket.
# ---------------------------------------------------------------
output "bucket_name" {
  description = "The name of the S3 bucket (set via bucket_name variable)."
  value       = aws_s3_bucket.main.bucket
}

# ---------------------------------------------------------------
# Output: vpc_id
# The unique identifier AWS assigned to your Virtual Private Cloud.
# You will need this ID when adding subnets, security groups, etc.
# ---------------------------------------------------------------
output "vpc_id" {
  description = "The ID of the VPC that was created."
  value       = aws_vpc.main.id
}

# ---------------------------------------------------------------
# Output: subnet_id
# The unique identifier of the public subnet inside the VPC.
# ---------------------------------------------------------------
output "subnet_id" {
  description = "The ID of the public subnet that was created."
  value       = aws_subnet.public.id
}

# ---------------------------------------------------------------
# Output: internet_gateway_id
# The ID of the Internet Gateway — the door between your VPC
# and the public internet.
# ---------------------------------------------------------------
output "internet_gateway_id" {
  description = "The ID of the Internet Gateway attached to the VPC."
  value       = aws_internet_gateway.main.id
}

# ---------------------------------------------------------------
# Output: security_group_id
# The ID of the Security Group attached to the EC2 instance.
# Useful for auditing rules or referencing in other resources.
# ---------------------------------------------------------------
output "security_group_id" {
  description = "The ID of the web security group attached to the EC2 instance."
  value       = aws_security_group.web.id
}

# ---------------------------------------------------------------
# Output: ec2_instance_id
# The unique identifier AWS assigned to your EC2 virtual machine.
# ---------------------------------------------------------------
output "ec2_instance_id" {
  description = "The ID of the EC2 web server instance."
  value       = aws_instance.web.id
}

# ---------------------------------------------------------------
# Output: ec2_public_ip
# The public IPv4 address of your EC2 instance.
# Open http://<this-ip> in a browser to see "Hello Terraform".
# Note: it may take 1-2 minutes after apply for the web server
# to finish installing before the page becomes available.
# ---------------------------------------------------------------
output "ec2_public_ip" {
  description = "The public IP address of the EC2 web server. Open http://<this-ip> in your browser."
  value       = aws_instance.web.public_ip
}
