# =========================================================================
# Private S3 Bucket for Workspace Repository & Client Personal Vault
# Default 5 GB Free per Account + Monthly Add-ons
# Zero Public Access + Explicit Deny for Dev/Admin on repository/* objects
# =========================================================================

resource "aws_s3_bucket" "repository" {
  bucket = var.repository_s3_bucket_name

  tags = {
    Name        = var.repository_s3_bucket_name
    Project     = "BrandHub"
    Environment = var.environment
    ManagedBy   = "terraform"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_ownership_controls" "repository" {
  bucket = aws_s3_bucket.repository.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "repository" {
  bucket = aws_s3_bucket.repository.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "repository" {
  bucket = aws_s3_bucket.repository.id

  rule {
    bucket_key_enabled = true

    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.repository_media.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_cors_configuration" "repository" {
  bucket = aws_s3_bucket.repository.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD", "PUT"]
    allowed_origins = var.allowed_cors_origins
    expose_headers  = ["ETag", "x-amz-version-id"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "repository" {
  bucket = aws_s3_bucket.repository.id

  rule {
    id     = "cleanup-unconfirmed-staging-uploads"
    status = "Enabled"

    filter {
      prefix = "staging/"
    }

    expiration {
      days = 2
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
  }

  rule {
    id     = "abort-incomplete-multipart-uploads-global"
    status = "Enabled"

    filter {}

    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
  }
}

resource "aws_s3_bucket_policy" "repository" {
  bucket = aws_s3_bucket.repository.id

  depends_on = [aws_s3_bucket_public_access_block.repository]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyInsecureHttpTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.repository.arn,
          "${aws_s3_bucket.repository.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      },
      {
        Sid    = "AllowRuntimeServiceRoleRepositoryAccess"
        Effect = "Allow"
        Principal = {
          AWS = local.allowed_runtime_role_arns
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:GetBucketVersioning",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.repository.arn,
          "${aws_s3_bucket.repository.arn}/*"
        ]
      },
      {
        Sid       = "DenyWrongRepositoryEncryptionKey"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.repository.arn}/*"
        Condition = {
          StringNotEquals = {
            "s3:x-amz-server-side-encryption-aws-kms-key-id" = aws_kms_key.repository_media.arn
          }
        }
      },
      {
        Sid       = "DenyHumanDevAndAdminFromReadingUserRepositoryMedia"
        Effect    = "Deny"
        Principal = "*"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ]
        Resource = [
          "${aws_s3_bucket.repository.arn}/repository/*",
          "${aws_s3_bucket.repository.arn}/staging/*",
          "${aws_s3_bucket.repository.arn}/repository-staging/*",
          "${aws_s3_bucket.repository.arn}/client-vault/*"
        ]
        Condition = {
          ArnNotEquals = {
            "aws:PrincipalArn" = local.allowed_runtime_role_arns
          }
        }
      }
    ]
  })
}
