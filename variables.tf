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
