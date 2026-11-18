# =========================================================================
# Application media buckets used by the services' runtime config
#   S3_BUCKET / S3_BUCKET_NAME (business, ai, image worker) -> brandhubmedia-<account>
#   S3_AI_BUCKET (business)                                 -> brandhub-ai-media-<account>
#   S3_BUCKET for crawler output (ai)                       -> crawler-social-<account>
# The original names are still owned by the locked account 821014378805,
# so every bucket carries this account ID as a suffix.
# =========================================================================

locals {
  app_buckets = {
    media    = "brandhubmedia-${var.aws_account_id}"
    ai_media = "brandhub-ai-media-${var.aws_account_id}"
    crawler  = "crawler-social-${var.aws_account_id}"
  }
}

resource "aws_s3_bucket" "app" {
  for_each = local.app_buckets
  bucket   = each.value

  tags = {
    Name        = each.value
    Project     = "BrandHub"
    Environment = var.environment
    Service     = "app-${each.key}"
    ManagedBy   = "terraform"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_ownership_controls" "app" {
  for_each = aws_s3_bucket.app
  bucket   = each.value.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "app" {
  for_each = aws_s3_bucket.app
  bucket   = each.value.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "app" {
  for_each = aws_s3_bucket.app
  bucket   = each.value.id

  rule {
    bucket_key_enabled = true

    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_cors_configuration" "app_media" {
  bucket = aws_s3_bucket.app["media"].id

  cors_rule {
    allowed_methods = ["GET", "PUT", "HEAD"]
    allowed_origins = var.allowed_cors_origins
    allowed_headers = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_policy" "app" {
  for_each = aws_s3_bucket.app
  bucket   = each.value.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource  = [each.value.arn, "${each.value.arn}/*"]
        Condition = {
          Bool = { "aws:SecureTransport" = "false" }
        }
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.app]
}

# EC2 runtime role (business, publisher, ai on the core EC2).
resource "aws_iam_role_policy" "runtime_app_buckets" {
  name = "brandhub-app-buckets-${var.environment}"
  role = data.aws_iam_role.runtime_service.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket", "s3:GetBucketLocation"]
        Resource = [for b in aws_s3_bucket.app : b.arn]
      },
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
        Resource = [for b in aws_s3_bucket.app : "${b.arn}/*"]
      }
    ]
  })
}

# The Vast.ai image worker runs outside AWS. It gets an IAM user limited to its own prefix.
# The access key is created by a human (console or `aws iam create-access-key`), never by Terraform,
# so the secret never lands in Terraform state.
resource "aws_iam_user" "image_worker" {
  name = "brandhub-image-worker-${var.environment}"

  tags = {
    Project     = "BrandHub"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_iam_user_policy" "image_worker" {
  name = "brandhub-image-worker-s3"
  user = aws_iam_user.image_worker.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = ["s3:ListBucket"]
        Resource  = aws_s3_bucket.app["media"].arn
        Condition = { StringLike = { "s3:prefix" = ["qwen-ambassador/*"] } }
      },
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
        Resource = "${aws_s3_bucket.app["media"].arn}/qwen-ambassador/*"
      }
    ]
  })
}

output "app_bucket_names" {
  description = "Runtime media buckets: set S3_BUCKET(_NAME), S3_AI_BUCKET and the crawler S3_BUCKET to these"
  value       = { for k, b in aws_s3_bucket.app : k => b.bucket }
}

output "image_worker_iam_user" {
  description = "IAM user for the Vast.ai image worker; create its access key manually"
  value       = aws_iam_user.image_worker.name
}
