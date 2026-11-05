# =========================================================================
# Attach Repository S3 + KMS Permissions to Runtime Service IAM Role
# =========================================================================

resource "aws_iam_role_policy" "runtime_repository_s3_kms" {
  name = "brandhub-repository-s3-kms-${var.environment}"
  role = data.aws_iam_role.runtime_service.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowRepositoryS3BucketOperations"
        Effect = "Allow"
        Action = [
          "s3:GetBucketVersioning",
          "s3:ListBucket"
        ]
        Resource = aws_s3_bucket.repository.arn
      },
      {
        Sid    = "AllowRepositoryS3ObjectOperations"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "${aws_s3_bucket.repository.arn}/*"
      },
      {
        Sid    = "AllowRepositoryKmsKeyOperations"
        Effect = "Allow"
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = aws_kms_key.repository_media.arn
      }
    ]
  })
}
