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
  description = "The name of the S3 bucket that was created."
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
