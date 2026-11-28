output "repository_s3_bucket_name" {
  description = "Name of the unified S3 bucket for BrandHub media, Workspace Repository, and Client Vault"
  value       = aws_s3_bucket.repository.bucket
}

output "repository_s3_bucket_arn" {
  description = "ARN of the unified S3 bucket for BrandHub media, Workspace Repository, and Client Vault"
  value       = aws_s3_bucket.repository.arn
}

output "repository_kms_key_id" {
  description = "KMS Key ID for REPOSITORY_SYSTEM_S3_KMS_KEY_ID"
  value       = aws_kms_key.repository_media.key_id
}

output "repository_kms_key_arn" {
  description = "KMS Key ARN for REPOSITORY_SYSTEM_S3_KMS_KEY_ID"
  value       = aws_kms_key.repository_media.arn
}

output "repository_kms_alias" {
  description = "KMS Key Alias for Repository cryptographic operations"
  value       = aws_kms_alias.repository_media.name
}

output "app_bucket_names" {
  description = "Additional runtime buckets (crawler)"
  value       = { for k, b in aws_s3_bucket.app : k => b.bucket }
}

output "image_worker_iam_user" {
  description = "IAM user for the Vast.ai worker; create its access key manually"
  value       = aws_iam_user.image_worker.name
}
