# ----------------------------------------------------------------------
# Input Variables
# ----------------------------------------------------------------------

variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project identifier used in resource names"
  type        = string
  default     = "atlas-tf"
}