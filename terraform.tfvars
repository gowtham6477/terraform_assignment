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
