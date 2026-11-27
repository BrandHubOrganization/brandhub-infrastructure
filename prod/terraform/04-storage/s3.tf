# =========================================================================
# Unified BrandHub Media & Repository S3 Bucket (brandhub-media-134875421878)
# - Default bucket SSE: AES256 (bucket_key_enabled = true)
# - Public read (s3:GetObject) ONLY on /image/* (avatars, logos, banners)
# - Private Workspace Repository & Client Personal Vault objects (repository/*,
#   repository-staging/*, staging/*, client-vault/*) are restricted to runtime
#   IAM roles and protected by pre-S3 AWS Encryption SDK / KMS envelope keys
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
  # image/* serves avatars, logos, banners as public S3 URLs; repository/* remains strictly private via bucket policy + KMS
  block_public_policy     = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_server_side_encryption_configuration" "repository" {
  bucket = aws_s3_bucket.repository.id

  rule {
    bucket_key_enabled = true

    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
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
    id     = "cleanup-unconfirmed-repository-staging-uploads"
    status = "Enabled"

    filter {
      prefix = "repository-staging/"
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
        Sid    = "AllowRuntimeServiceAndAdminAccess"
        Effect = "Allow"
        Principal = {
          AWS = local.allowed_runtime_role_arns
        }
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListMultipartUploadParts",
          "s3:AbortMultipartUpload",
          "s3:GetBucketVersioning",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads"
        ]
        Resource = [
          aws_s3_bucket.repository.arn,
          "${aws_s3_bucket.repository.arn}/*"
        ]
      },
      {
        Sid       = "PublicReadImages"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.repository.arn}/image/*"
      }
    ]
  })
}
