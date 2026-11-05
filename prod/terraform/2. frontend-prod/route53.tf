# =========================================================
# Route53 Public Hosted Zone & Frontend Records
# =========================================================

resource "aws_route53_zone" "brandhub_public" {
  name    = var.domain_name
  comment = ""

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route53_record" "frontend_ipv4" {
  zone_id = aws_route53_zone.brandhub_public.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.web.domain_name
    zone_id                = aws_cloudfront_distribution.web.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "frontend_ipv6" {
  zone_id = aws_route53_zone.brandhub_public.zone_id
  name    = var.domain_name
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.web.domain_name
    zone_id                = aws_cloudfront_distribution.web.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "google_site_verification" {
  zone_id = aws_route53_zone.brandhub_public.zone_id
  name    = var.domain_name
  type    = "TXT"
  ttl     = 300
  records = [var.google_site_verification]
}

resource "aws_route53_record" "acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.frontend.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 300
  type            = each.value.type
  zone_id         = aws_route53_zone.brandhub_public.zone_id
}
