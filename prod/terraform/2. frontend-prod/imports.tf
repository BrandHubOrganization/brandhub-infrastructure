# =========================================================
# Existing Route53 Hosted Zone & Records
# =========================================================

import {
  to = aws_route53_zone.brandhub_public
  id = "Z05162771CDXOXNDXG0PY"
}

import {
  to = aws_route53_record.frontend_ipv4
  id = "Z05162771CDXOXNDXG0PY_brandhub.id.vn_A"
}

import {
  to = aws_route53_record.frontend_ipv6
  id = "Z05162771CDXOXNDXG0PY_brandhub.id.vn_AAAA"
}

import {
  to = aws_route53_record.google_site_verification
  id = "Z05162771CDXOXNDXG0PY_brandhub.id.vn_TXT"
}

import {
  to = aws_route53_record.acm_validation["brandhub.id.vn"]
  id = "Z05162771CDXOXNDXG0PY__3cd70fbafab2103b436e5a0eb6925064.brandhub.id.vn._CNAME"
}


# =========================================================
# Existing S3 Bucket & Security Configuration
# =========================================================

import {
  to = aws_s3_bucket.web
  id = "brandhub-web-prd"
}

import {
  to = aws_s3_bucket_ownership_controls.web
  id = "brandhub-web-prd"
}

import {
  to = aws_s3_bucket_public_access_block.web
  id = "brandhub-web-prd"
}

import {
  to = aws_s3_bucket_server_side_encryption_configuration.web
  id = "brandhub-web-prd"
}

import {
  to = aws_s3_bucket_policy.web
  id = "brandhub-web-prd"
}


# =========================================================
# Existing ACM Certificate (us-east-1)
# =========================================================

import {
  to = aws_acm_certificate.frontend
  id = "arn:aws:acm:us-east-1:821014378805:certificate/c43f6142-8a25-48d7-bef7-e7ee706f0e10"
}


# =========================================================
# Existing CloudFront OAC, Function & Distribution
# =========================================================

import {
  to = aws_cloudfront_origin_access_control.web
  id = "E1I5UN4QDQ2U45"
}

import {
  to = aws_cloudfront_function.public_routes
  id = "brandhub-public-routes"
}

import {
  to = aws_cloudfront_distribution.web
  id = "E4BAXJI176PI5"
}
