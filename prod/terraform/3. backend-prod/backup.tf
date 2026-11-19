# =========================================================
# Postgres pg_dump backups (no EBS snapshots)
# Written daily by brandhub-pg-backup.timer on the service EC2.
# =========================================================

resource "aws_s3_bucket" "db_backup" {
  bucket = var.db_backup_bucket_name

  tags = {
    Name        = var.db_backup_bucket_name
    Project     = "BrandHub"
    Environment = var.environment
    Service     = "db-backup"
    ManagedBy   = "terraform"
  }
}

resource "aws_s3_bucket_public_access_block" "db_backup" {
  bucket = aws_s3_bucket.db_backup.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "db_backup" {
  bucket = aws_s3_bucket.db_backup.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "db_backup" {
  bucket = aws_s3_bucket.db_backup.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "db_backup" {
  bucket = aws_s3_bucket.db_backup.id

  rule {
    id     = "expire-old-dumps"
    status = "Enabled"

    filter {
      prefix = "postgres/"
    }

    expiration {
      days = var.db_backup_retention_days
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
  }
}

resource "aws_s3_bucket_policy" "db_backup" {
  bucket = aws_s3_bucket.db_backup.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.db_backup.arn,
          "${aws_s3_bucket.db_backup.arn}/*",
        ]
        Condition = {
          Bool = { "aws:SecureTransport" = "false" }
        }
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.db_backup]
}

# EC2 role may only add new dumps; it cannot list, read or delete them.
resource "aws_iam_role_policy" "ec2_db_backup_put" {
  name = "brandhub-db-backup-put"
  role = "brandhub-ec2-ecr-pull"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject"]
        Resource = "${aws_s3_bucket.db_backup.arn}/postgres/*"
      }
    ]
  })
}

output "db_backup_bucket" {
  value = aws_s3_bucket.db_backup.bucket
}
