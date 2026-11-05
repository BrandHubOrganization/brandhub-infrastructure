output "github_oidc_provider_arn" {
  description = "ARN of the GitHub Actions OIDC Provider"
  value       = aws_iam_openid_connect_provider.github_actions.arn
}

output "github_actions_role_arn" {
  description = "ARN of the GitHub Actions IAM role used for S3/CloudFront/ECR/SSM deployments"
  value       = aws_iam_role.github_actions.arn
}

output "github_actions_role_name" {
  description = "Name of the GitHub Actions IAM role"
  value       = aws_iam_role.github_actions.name
}

output "ec2_ecr_pull_role_arn" {
  description = "ARN of the EC2 IAM role for ECR pull and SSM"
  value       = aws_iam_role.ec2_ecr_pull.arn
}

output "ec2_ecr_pull_instance_profile_name" {
  description = "Name of the EC2 IAM Instance Profile"
  value       = aws_iam_instance_profile.ec2_ecr_pull.name
}

output "ec2_ecr_pull_instance_profile_arn" {
  description = "ARN of the EC2 IAM Instance Profile"
  value       = aws_iam_instance_profile.ec2_ecr_pull.arn
}
