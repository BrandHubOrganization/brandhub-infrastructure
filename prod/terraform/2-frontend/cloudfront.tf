# =========================================================
# CloudFront OAC, Viewer Function & Distribution
# =========================================================

locals {
  s3_origin_id          = "${var.s3_bucket_name}.s3.${var.aws_region}.amazonaws.com"
  s3_origin_domain_name = "${var.s3_bucket_name}.s3.${var.aws_region}.amazonaws.com"
  # AWS Managed-CachingOptimized cache policy ID
  managed_caching_optimized_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
}

resource "aws_cloudfront_origin_access_control" "web" {
  name                              = "brandhub-web-prd-oac"
  description                       = "BrandHub frontend S3 origin"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_function" "public_routes" {
  name    = "brandhub-public-routes"
  runtime = "cloudfront-js-2.0"
  comment = "allow public"
  publish = true
  code    = file("${path.module}/functions/brandhub-public-routes.js")
}

resource "aws_cloudfront_distribution" "web" {
  enabled             = true
  is_ipv6_enabled     = true
  http_version        = "http2"
  price_class         = "PriceClass_All"
  default_root_object = "index.html"
  aliases             = var.attach_domain_alias ? [var.domain_name] : []

  origin {
    domain_name              = local.s3_origin_domain_name
    origin_id                = local.s3_origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.web.id
    connection_attempts      = 3
    connection_timeout       = 10
  }

  default_cache_behavior {
    target_origin_id       = local.s3_origin_id
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    cache_policy_id        = local.managed_caching_optimized_policy_id

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.public_routes.arn
    }
  }

  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/app.html"
    error_caching_min_ttl = 10
  }

  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/app.html"
    error_caching_min_ttl = 10
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # Without the alias, CloudFront serves its default *.cloudfront.net certificate.
  viewer_certificate {
    acm_certificate_arn            = var.attach_domain_alias ? aws_acm_certificate_validation.frontend.certificate_arn : null
    ssl_support_method             = var.attach_domain_alias ? "sni-only" : null
    minimum_protocol_version       = var.attach_domain_alias ? "TLSv1.2_2021" : "TLSv1"
    cloudfront_default_certificate = !var.attach_domain_alias
  }

  tags = {
    Name = "brandhub-web-prd"
  }

  lifecycle {
    prevent_destroy = true
  }
}
