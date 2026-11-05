# =========================================================================
# KMS Customer Managed Key (CMK) for S3 Repository Encryption (SSE-KMS)
# Blocks human Dev / Admin IAM principals from decrypting user images
# =========================================================================

data "aws_iam_role" "runtime_service" {
  name = var.service_iam_role_name
}

locals {
  allowed_runtime_role_arns = distinct(concat(
    [data.aws_iam_role.runtime_service.arn],
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
        Sid    = "AllowKeyAdministrationWithoutDataDecrypt"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.aws_account_id}:root"
        }
        Action = [
          "kms:Create*",
          "kms:Describe*",
          "kms:Enable*",
          "kms:List*",
          "kms:Put*",
          "kms:Update*",
          "kms:Revoke*",
          "kms:Disable*",
          "kms:Get*",
          "kms:Delete*",
          "kms:TagResource",
          "kms:UntagResource",
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowRuntimeServiceRoleCryptographicOperations"
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
      },
      {
        Sid       = "DenyHumanDevAndAdminFromDecryptingUserMedia"
        Effect    = "Deny"
        Principal = "*"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey*",
          "kms:ReEncrypt*"
        ]
        Resource = "*"
        Condition = {
          ArnNotEquals = {
            "aws:PrincipalArn" = local.allowed_runtime_role_arns
          }
          BoolIfExists = {
            "aws:PrincipalIsAWSService" = "false"
          }
        }
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
