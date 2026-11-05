variable "aws_account_id" {
  description = "AWS account ID that owns the BrandHub production infrastructure"
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_id))
    error_message = "aws_account_id must be a 12-digit AWS account ID."
  }
}

variable "aws_region" {
  description = "Primary AWS region for S3 frontend bucket"
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

variable "domain_name" {
  description = "Primary root domain for BrandHub frontend"
  type        = string
  default     = "brandhub.id.vn"
}

variable "s3_bucket_name" {
  description = "S3 bucket storing static frontend assets"
  type        = string
  default     = "brandhub-web-prd"
}

variable "google_site_verification" {
  description = "Google Site Verification TXT record value for the root domain"
  type        = string
  default     = "google-site-verification=qc51QJXB99MYCUro3L_KhTl5JpDujW9qIMD9fCPNAFM"
}
