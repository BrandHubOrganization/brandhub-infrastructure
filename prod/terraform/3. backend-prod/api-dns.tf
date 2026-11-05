data "aws_route53_zone" "brandhub_public" {
  name         = "brandhub.id.vn."
  private_zone = false
}

resource "aws_route53_record" "api" {
  zone_id = data.aws_route53_zone.brandhub_public.zone_id
  name    = "api.brandhub.id.vn"
  type    = "A"
  ttl     = 60
  records = [aws_instance.brandhub["api_gateway"].public_ip]
}
