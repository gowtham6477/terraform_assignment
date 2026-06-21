# Project output variables.

# Unique S3 bucket name.
output "bucket_name" {
  description = "The name of the S3 bucket (set via bucket_name variable)."
  value       = aws_s3_bucket.main.bucket
}

# Deployed VPC ID.
output "vpc_id" {
  description = "The ID of the VPC that was created."
  value       = aws_vpc.main.id
}

# Public subnet ID.
output "subnet_id" {
  description = "The ID of the public subnet that was created."
  value       = aws_subnet.public.id
}

# Internet Gateway ID.
output "internet_gateway_id" {
  description = "The ID of the Internet Gateway attached to the VPC."
  value       = aws_internet_gateway.main.id
}

# Security group ID.
output "security_group_id" {
  description = "The ID of the web security group attached to the EC2 instance."
  value       = aws_security_group.web.id
}

# EC2 instance ID.
output "ec2_instance_id" {
  description = "The ID of the EC2 web server instance."
  value       = aws_instance.web.id
}

# Public IP address.
output "ec2_public_ip" {
  description = "The public IP address of the EC2 web server. Open http://<this-ip> in your browser."
  value       = aws_instance.web.public_ip
}
