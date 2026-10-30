output "route53_zone_id" {
  description = "Route53 Hosted Zone ID for brandhub.id.vn"
  value       = aws_route53_zone.brandhub_public.zone_id
}

output "route53_name_servers" {
  description = "Authoritative name servers for brandhub.id.vn"
  value       = aws_route53_zone.brandhub_public.name_servers
}

output "s3_bucket_name" {
  description = "Frontend S3 bucket name"
  value       = aws_s3_bucket.web.bucket
}

output "s3_bucket_arn" {
  description = "Frontend S3 bucket ARN"
  value       = aws_s3_bucket.web.arn
}

output "cloudfront_distribution_id" {
  description = "CloudFront Distribution ID"
  value       = aws_cloudfront_distribution.web.id
}

output "cloudfront_distribution_arn" {
  description = "CloudFront Distribution ARN"
  value       = aws_cloudfront_distribution.web.arn
}

output "cloudfront_domain_name" {
  description = "CloudFront Distribution domain name"
  value       = aws_cloudfront_distribution.web.domain_name
}

output "acm_certificate_arn" {
  description = "ACM Certificate ARN in us-east-1"
  value       = aws_acm_certificate.frontend.arn
}
