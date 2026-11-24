variable "aws_account_id" {
  description = "AWS account ID that owns the BrandHub production infrastructure"
  type        = string
  default     = "134875421878"

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
  description = "Unified BrandHub media & private repository S3 bucket (public /image/* assets, AI worker outputs, and encrypted Workspace Repository & Client Vault objects)"
  type        = string
  default     = "brandhub-media-134875421878"
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
  description = "Allowed web origins for browser GET/HEAD/PUT requests to the BrandHub media & repository bucket"
  type        = list(string)
  default = [
    "https://brandhub.id.vn",
    "https://www.brandhub.id.vn",
    "http://localhost:3000",
  ]
}
