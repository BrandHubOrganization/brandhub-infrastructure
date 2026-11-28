# =========================================================
# Security Group Attachment Map (see ec2.tf):
#   aws_security_group.brandhub_core       ("brandhub-core-sg")       -> api_gateway EC2   (172.31.27.199)
#   aws_security_group.brandhub_service    ("brandhub-service-sg")    -> core_services EC2 (172.31.24.149)
#   aws_security_group.brandhub_ai         ("brandhub-ai-sg")         -> ai EC2            (172.31.20.60)
#   aws_security_group.brandhub_crawl      ("brandhub-crawl-sg")      -> crawl EC2         (172.31.20.50)
#   aws_security_group.brandhub_edit_video ("brandhub-edit-video-sg") -> edit_video EC2    (172.31.20.80)
#
# Note: Historical AWS SG names are preserved (`brandhub_core` = public API Gateway host,
# `brandhub_service` = private Core Services host) so Terraform never replaces existing SGs.
# =========================================================

# =========================================================
# 1. API Gateway Security Group (attached to `api_gateway` EC2)
# =========================================================

resource "aws_security_group" "brandhub_core" {
  name        = "brandhub-core-sg"
  description = "Security group for BrandHub Core EC2, allowing SSH, HTTP, and HTTPS access only."
  vpc_id      = data.aws_vpc.brandhub.id

  tags = {
    Name        = "brandhub-core-sg"
    Project     = "BrandHub"
    Environment = var.environment
    Service     = "backend"
    ManagedBy   = "terraform"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "core_ssh" {
  security_group_id = aws_security_group.brandhub_core.id
  description       = "Admin SSH"
  cidr_ipv4         = var.admin_ip
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "core_http_ipv4" {
  security_group_id = aws_security_group.brandhub_core.id
  description       = "Redirect HTTPS"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "core_https_ipv4" {
  security_group_id = aws_security_group.brandhub_core.id
  description       = "API BrandHub"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

# Kept because these rules already exist on brandhub-core-sg.
resource "aws_vpc_security_group_ingress_rule" "core_http_ipv6" {
  security_group_id = aws_security_group.brandhub_core.id
  cidr_ipv6         = "::/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "core_https_ipv6" {
  security_group_id = aws_security_group.brandhub_core.id
  cidr_ipv6         = "::/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "core_all_outbound" {
  security_group_id = aws_security_group.brandhub_core.id
  description       = "Allow all outbound traffic"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# =========================================================
# 2. Core Services Security Group (attached to `core_services` EC2)
#    Runs Business (8081), Publisher (8083), PostgreSQL, Redis (6379),
#    RabbitMQ (5672), ChromaDB (8000), crawl-gate (8084), and db-backup.
# =========================================================

resource "aws_security_group" "brandhub_service" {
  name        = "brandhub-service-sg"
  description = "Security group for BrandHub internal services, allowing SSH and API Gateway access to Business and Publisher services."
  vpc_id      = data.aws_vpc.brandhub.id

  tags = {
    Name        = "brandhub-service-sg"
    Project     = "BrandHub"
    Environment = var.environment
    Service     = "internal-services"
    ManagedBy   = "terraform"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "service_ssh" {
  security_group_id = aws_security_group.brandhub_service.id
  description       = "Admin SSH"
  cidr_ipv4         = var.admin_ip
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

# API Gateway EC2 -> Business Service on core EC2
resource "aws_vpc_security_group_ingress_rule" "business_from_gateway" {
  security_group_id            = aws_security_group.brandhub_service.id
  description                  = "Allow API Gateway to access Business Service"
  referenced_security_group_id = aws_security_group.brandhub_core.id
  from_port                    = 8081
  to_port                      = 8081
  ip_protocol                  = "tcp"
}

# API Gateway EC2 -> Publisher Service on core EC2
resource "aws_vpc_security_group_ingress_rule" "publisher_from_gateway" {
  security_group_id            = aws_security_group.brandhub_service.id
  description                  = "Allow API Gateway to access Publisher Service"
  referenced_security_group_id = aws_security_group.brandhub_core.id
  from_port                    = 8083
  to_port                      = 8083
  ip_protocol                  = "tcp"
}

# API Gateway EC2 -> Redis on core EC2
resource "aws_vpc_security_group_ingress_rule" "redis_from_gateway" {
  security_group_id            = aws_security_group.brandhub_service.id
  description                  = "Gateway access to Redis on service EC2"
  referenced_security_group_id = aws_security_group.brandhub_core.id
  from_port                    = 6379
  to_port                      = 6379
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "service_all_outbound" {
  security_group_id = aws_security_group.brandhub_service.id
  description       = "Allow all outbound traffic"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# =========================================================
# 3. Crawl Security Group (attached to `crawl` EC2, no public ingress)
# =========================================================

resource "aws_security_group" "brandhub_crawl" {
  name        = "brandhub-crawl-sg"
  description = "Security group for BrandHub Crawl EC2, private API only."
  vpc_id      = data.aws_vpc.brandhub.id

  tags = {
    Name        = "brandhub-crawl-sg"
    Project     = "BrandHub"
    Environment = var.environment
    Service     = "crawl"
    ManagedBy   = "terraform"
  }
}

resource "aws_vpc_security_group_ingress_rule" "crawl_ssh" {
  security_group_id = aws_security_group.brandhub_crawl.id
  description       = "Admin SSH"
  cidr_ipv4         = var.admin_ip
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "crawl_all_outbound" {
  security_group_id = aws_security_group.brandhub_crawl.id
  description       = "Allow all outbound traffic"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# crawl-gate on core EC2 -> crawler management API on crawl EC2.
resource "aws_vpc_security_group_ingress_rule" "crawl_api_from_ai" {
  security_group_id            = aws_security_group.brandhub_crawl.id
  description                  = "Core crawl-gate access to crawler API"
  referenced_security_group_id = aws_security_group.brandhub_service.id
  from_port                    = 8084
  to_port                      = 8084
  ip_protocol                  = "tcp"
}

# Crawl EC2 -> RabbitMQ and Redis on core EC2.
resource "aws_vpc_security_group_ingress_rule" "rabbitmq_from_crawl" {
  security_group_id            = aws_security_group.brandhub_service.id
  description                  = "Crawler access to RabbitMQ"
  referenced_security_group_id = aws_security_group.brandhub_crawl.id
  from_port                    = 5672
  to_port                      = 5672
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "redis_from_crawl" {
  security_group_id            = aws_security_group.brandhub_service.id
  description                  = "Crawler access to Redis"
  referenced_security_group_id = aws_security_group.brandhub_crawl.id
  from_port                    = 6379
  to_port                      = 6379
  ip_protocol                  = "tcp"
}

# =========================================================
# 4. AI Security Group (attached to dedicated `ai` EC2, no public ingress)
# =========================================================

resource "aws_security_group" "brandhub_ai" {
  name        = "brandhub-ai-sg"
  description = "Security group for BrandHub AI EC2, private API only."
  vpc_id      = data.aws_vpc.brandhub.id

  tags = {
    Name        = "brandhub-ai-sg"
    Project     = "BrandHub"
    Environment = var.environment
    Service     = "ai"
    ManagedBy   = "terraform"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ai_ssh" {
  security_group_id = aws_security_group.brandhub_ai.id
  description       = "Admin SSH"
  cidr_ipv4         = var.admin_ip
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "ai_all_outbound" {
  security_group_id = aws_security_group.brandhub_ai.id
  description       = "Allow all outbound traffic"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# Callers of the AI API (8082): Business (core EC2), API Gateway, and Crawler.
resource "aws_vpc_security_group_ingress_rule" "ai_api_from_service" {
  security_group_id            = aws_security_group.brandhub_ai.id
  description                  = "Business access to AI API"
  referenced_security_group_id = aws_security_group.brandhub_service.id
  from_port                    = 8082
  to_port                      = 8082
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "ai_api_from_gateway" {
  security_group_id            = aws_security_group.brandhub_ai.id
  description                  = "Gateway access to AI API"
  referenced_security_group_id = aws_security_group.brandhub_core.id
  from_port                    = 8082
  to_port                      = 8082
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "ai_api_from_crawl" {
  security_group_id            = aws_security_group.brandhub_ai.id
  description                  = "Crawler access to AI API"
  referenced_security_group_id = aws_security_group.brandhub_crawl.id
  from_port                    = 8082
  to_port                      = 8082
  ip_protocol                  = "tcp"
}

# AI EC2 -> crawl-gate on core EC2 (172.31.24.149:8084) and direct fallback to crawl EC2.
resource "aws_vpc_security_group_ingress_rule" "crawl_gate_from_ai" {
  security_group_id            = aws_security_group.brandhub_service.id
  description                  = "AI EC2 access to crawl-gate on core EC2"
  referenced_security_group_id = aws_security_group.brandhub_ai.id
  from_port                    = 8084
  to_port                      = 8084
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "crawl_api_from_ai_ec2" {
  security_group_id            = aws_security_group.brandhub_crawl.id
  description                  = "AI EC2 access to crawler API"
  referenced_security_group_id = aws_security_group.brandhub_ai.id
  from_port                    = 8084
  to_port                      = 8084
  ip_protocol                  = "tcp"
}

# AI EC2 -> Redis, RabbitMQ, and ChromaDB on core EC2.
resource "aws_vpc_security_group_ingress_rule" "redis_from_ai" {
  security_group_id            = aws_security_group.brandhub_service.id
  description                  = "AI access to Redis"
  referenced_security_group_id = aws_security_group.brandhub_ai.id
  from_port                    = 6379
  to_port                      = 6379
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "rabbitmq_from_ai" {
  security_group_id            = aws_security_group.brandhub_service.id
  description                  = "AI access to RabbitMQ"
  referenced_security_group_id = aws_security_group.brandhub_ai.id
  from_port                    = 5672
  to_port                      = 5672
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "chromadb_from_ai" {
  security_group_id            = aws_security_group.brandhub_service.id
  description                  = "AI access to ChromaDB"
  referenced_security_group_id = aws_security_group.brandhub_ai.id
  from_port                    = 8000
  to_port                      = 8000
  ip_protocol                  = "tcp"
}

# =========================================================
# 5. Edit Video Security Group (attached to `edit_video` EC2, no public ingress)
#    Nginx on API Gateway proxies https://api.brandhub.id.vn/edit-video/ -> 8095.
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
