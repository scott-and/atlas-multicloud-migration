# ----------------------------------------------------------------------
# AWS Variables
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

variable "db_username" {
  description = "Username variable for use in atlas db"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Password variable for use in atlas db"
  type        = string
  sensitive   = true
}

variable "sns_email" {
  description = "Email to be used as endpoint for SNS topic"
  type        = string
  sensitive   = true
}

# ----------------------------------------------------------------------
# Azure Variables
# ----------------------------------------------------------------------

variable "azure_subscription_id" {
  description = "Subscription ID for the target service principal"
  type        = string
  sensitive   = true
}

variable "azure_client_id" {
  description = "Client ID of the target service principal"
  type        = string
  sensitive   = true
}

variable "azure_client_secret" {
  description = "Service principal secret"
  type        = string
  sensitive   = true
}

variable "azure_tenant_id" {
  description = "Tenant ID of the service prinicpal"
  type        = string
  sensitive   = true
}