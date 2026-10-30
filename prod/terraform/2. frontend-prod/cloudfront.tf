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
  name                              = "oac-brandhub-web-devtest.s3.ap-southeast-1.amazonaws-muc4sv5cpy1"
  description                       = "Created by CloudFront"
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
  aliases             = [var.domain_name]

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
    response_page_path    = "/index.html"
    error_caching_min_ttl = 10
  }

  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 10
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.frontend.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = {
    Name = "brandhub-web-dev"
  }

  lifecycle {
    prevent_destroy = true
  }
}
