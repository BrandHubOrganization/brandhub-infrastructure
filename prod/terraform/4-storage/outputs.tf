output "repository_s3_bucket_name" {
  description = "Name of the private S3 bucket for Workspace Repository and Client Vault"
  value       = aws_s3_bucket.repository.bucket
}

output "repository_s3_bucket_arn" {
  description = "ARN of the private S3 bucket for Workspace Repository and Client Vault"
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
  description = "KMS Key Alias for Repository SSE-KMS"
  value       = aws_kms_alias.repository_media.name
}
