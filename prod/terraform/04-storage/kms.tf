# =========================================================================
# KMS Customer Managed Key (CMK) for Repository & Client Vault Envelope Keys
# Bucket-level default encryption is AES256 (s3.tf); this CMK is scoped to
# allowed runtime roles for KMS-wrapped/SSE-KMS repository cryptographic ops
# =========================================================================

data "aws_iam_role" "runtime_service" {
  name = var.service_iam_role_name
}

locals {
  allowed_runtime_role_arns = distinct(concat(
    [
      data.aws_iam_role.runtime_service.arn,
      "arn:aws:iam::${var.aws_account_id}:user/admin"
    ],
    var.additional_allowed_service_role_arns
  ))
}

resource "aws_kms_key" "repository_media" {
  description             = "BrandHub Repository & Client Vault S3 SSE-KMS Key (${var.environment})"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  multi_region            = false

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowKeyAdministration"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.aws_account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "AllowRuntimeAndServiceCryptographicOperations"
        Effect = "Allow"
        Principal = {
          AWS = local.allowed_runtime_role_arns
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name        = "brandhub-repository-kms-${var.environment}"
    Project     = "BrandHub"
    Environment = var.environment
    ManagedBy   = "terraform"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_kms_alias" "repository_media" {
  name          = "alias/brandhub-repository-media-${var.environment}"
  target_key_id = aws_kms_key.repository_media.key_id
}
