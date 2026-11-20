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
    key_name         = optional(string)
    private_ip       = optional(string)
    root_volume_size = optional(number, 30)
    root_volume_type = optional(string, "gp3")
    # Sleeps when idle and is started again by a request (wake/) or a schedule.
    wake_on_request = optional(bool, false)
  }))
}

variable "db_backup_bucket_name" {
  description = "S3 bucket for daily DB dumps (postgres, redis, chroma, mongo, neo4j)"
  type        = string
  default     = "brandhub-db-backup-prd-134875421878"
}

variable "db_backup_retention_days" {
  description = "Days to keep each db-backup dump (tagged retention=daily) in S3"
  type        = number
  default     = 1
}

variable "crawl_schedule_times" {
  description = "Local times (Asia/Ho_Chi_Minh, HH:MM) when a scheduled crawl starts; the crawl EC2 wakes crawl_wake_lead_minutes earlier"
  type        = list(string)
  default     = ["02:00"]

  validation {
    condition     = alltrue([for t in var.crawl_schedule_times : can(regex("^([01][0-9]|2[0-3]):[0-5][0-9]$", t))])
    error_message = "crawl_schedule_times entries must be HH:MM."
  }
}

variable "crawl_wake_lead_minutes" {
  description = "Minutes before each crawl_schedule_times entry that EventBridge starts the crawl EC2"
  type        = number
  default     = 10

  validation {
    condition     = var.crawl_wake_lead_minutes >= 1 && var.crawl_wake_lead_minutes < 1440
    error_message = "crawl_wake_lead_minutes must be between 1 and 1439."
  }
}
