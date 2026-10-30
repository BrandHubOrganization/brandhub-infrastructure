variable "aws_account_id" {
  description = "AWS account ID that owns the BrandHub production infrastructure"
  type        = string

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

variable "admin_ip" {
  description = "Public CIDR allowed to SSH into BrandHub EC2 instances"
  type        = string

  validation {
    condition     = can(cidrhost(var.admin_ip, 0))
    error_message = "admin_ip must be a valid CIDR, for example 171.225.184.133/32."
  }
}

variable "vpc_id" {
  description = "Existing BrandHub VPC ID"
  type        = string
}

variable "subnet_id" {
  description = "Existing subnet ID for BrandHub EC2 instances"
  type        = string
}

variable "instances" {
  description = "BrandHub EC2 instances"

  type = map(object({
    name             = string
    ami              = string
    instance_type    = string
    key_name         = string
    root_volume_size = optional(number, 30)
    root_volume_type = optional(string, "gp3")
  }))
}
