variable "aws_account_id" {
  description = "AWS account ID that owns the BrandHub production infrastructure"
  type        = string
  default     = "821014378805"

  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_id))
    error_message = "aws_account_id must be a 12-digit AWS account ID."
  }
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "prod"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging, or prod."
  }
}

variable "repository_s3_bucket_name" {
  description = "Private S3 bucket storing Workspace Repository & Client Personal Vault files (5GB Free default + monthly add-ons)"
  type        = string
  default     = "brandhub-media"
}

variable "service_iam_role_name" {
  description = "IAM Role name used by the BrandHub backend runtime (brandhub-business-service)"
  type        = string
  default     = "brandhub-ec2-ecr-pull"
}

variable "additional_allowed_service_role_arns" {
  description = "Optional additional runtime IAM role ARNs allowed to read/write S3 repository objects (never human Dev/Admin users)"
  type        = list(string)
  default     = []
}

variable "allowed_cors_origins" {
  description = "Allowed web origins for Presigned PUT/GET requests to the private S3 repository bucket"
  type        = list(string)
  default = [
    "https://brandhub.vn",
    "https://www.brandhub.vn",
    "http://localhost:3000",
  ]
}
