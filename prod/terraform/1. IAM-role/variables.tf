variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
  default     = "821014378805"
}

variable "github_org" {
  description = "GitHub Organization allowed to assume the OIDC role"
  type        = string
  default     = "BrandHubOrganization"
}

variable "github_oidc_thumbprints" {
  description = "Thumbprint list for GitHub Actions OIDC provider"
  type        = list(string)
  default     = ["ab9d0263244dd0326eb67015705a667e79cfe998"]
}

variable "frontend_s3_bucket_name" {
  description = "Frontend S3 bucket deployed by GitHub Actions"
  type        = string
  default     = "brandhub-web-prd"
}

variable "ecr_repositories" {
  description = "BrandHub ECR repository names"
  type        = list(string)
  default = [
    "brandhub/ai-service",
    "brandhub/api-gateway",
    "brandhub/business-service",
    "brandhub/publisher-service",
  ]
}

variable "ec2_instance_ids" {
  description = "EC2 instance IDs targeted by AWS SSM rolling deployments"
  type        = list(string)
  default = [
    "i-0761e3bd96ca5d4de",
    "i-07283e8467a059e5a",
  ]
}
