# =========================================================
# BrandHub Edit Video Security Group (no public ingress)
# Nginx on the gateway proxies https://api.brandhub.id.vn/edit-video/ to 8095.
# =========================================================

resource "aws_security_group" "brandhub_edit_video" {
  name        = "brandhub-edit-video-sg"
  description = "Security group for BrandHub Edit Video EC2, gateway access only."
  vpc_id      = data.aws_vpc.brandhub.id

  tags = {
    Name        = "brandhub-edit-video-sg"
    Project     = "BrandHub"
    Environment = var.environment
    Service     = "edit-video"
    ManagedBy   = "terraform"
  }
}

resource "aws_vpc_security_group_ingress_rule" "edit_video_from_gateway" {
  security_group_id            = aws_security_group.brandhub_edit_video.id
  description                  = "Gateway Nginx access to Edit Video API"
  referenced_security_group_id = aws_security_group.brandhub_core.id
  from_port                    = 8095
  to_port                      = 8095
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "edit_video_all_outbound" {
  security_group_id = aws_security_group.brandhub_edit_video.id
  description       = "Allow all outbound traffic (Claude, EditAtlas MCP, ECR)"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
