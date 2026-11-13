# =========================================================
# BrandHub Backend / Core Security Group
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

  description = "Admin SSH"

  cidr_ipv4   = var.admin_ip
  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "core_http_ipv4" {
  security_group_id = aws_security_group.brandhub_core.id

  description = "Redirect HTTPS"

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "core_https_ipv4" {
  security_group_id = aws_security_group.brandhub_core.id

  description = "API BrandHub"

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}

# Kept because these rules already exist on brandhub-core-sg.
resource "aws_vpc_security_group_ingress_rule" "core_http_ipv6" {
  security_group_id = aws_security_group.brandhub_core.id

  cidr_ipv6   = "::/0"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "core_https_ipv6" {
  security_group_id = aws_security_group.brandhub_core.id

  cidr_ipv6   = "::/0"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "core_all_outbound" {
  security_group_id = aws_security_group.brandhub_core.id

  description = "Allow all outbound traffic"

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}


# =========================================================
# BrandHub Internal Services Security Group
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

  description = "Admin SSH"

  cidr_ipv4   = var.admin_ip
  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"
}

# API Gateway on the backend EC2 -> Business Service
resource "aws_vpc_security_group_ingress_rule" "business_from_gateway" {
  security_group_id = aws_security_group.brandhub_service.id

  description = "Allow API Gateway to access Business Service"

  referenced_security_group_id = aws_security_group.brandhub_core.id

  from_port   = 8081
  to_port     = 8081
  ip_protocol = "tcp"
}

# API Gateway on the backend EC2 -> Publisher Service
resource "aws_vpc_security_group_ingress_rule" "publisher_from_gateway" {
  security_group_id = aws_security_group.brandhub_service.id

  description = "Allow API Gateway to access Publisher Service"

  referenced_security_group_id = aws_security_group.brandhub_core.id

  from_port   = 8083
  to_port     = 8083
  ip_protocol = "tcp"
}

# API Gateway on the backend EC2 -> Redis on service EC2
resource "aws_vpc_security_group_ingress_rule" "redis_from_gateway" {
  security_group_id = aws_security_group.brandhub_service.id

  description = "Gateway access to Redis on service EC2"

  referenced_security_group_id = aws_security_group.brandhub_core.id

  from_port   = 6379
  to_port     = 6379
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "service_all_outbound" {
  security_group_id = aws_security_group.brandhub_service.id

  description = "Allow all outbound traffic"

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

# =========================================================
# BrandHub Crawl Security Group (browser crawler, no public ingress)
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

# AI on service EC2 -> crawler management API on crawl EC2.
resource "aws_vpc_security_group_ingress_rule" "crawl_api_from_ai" {
  security_group_id            = aws_security_group.brandhub_crawl.id
  description                  = "AI access to crawler API"
  referenced_security_group_id = aws_security_group.brandhub_service.id
  from_port                    = 8084
  to_port                      = 8084
  ip_protocol                  = "tcp"
}

# Crawl EC2 -> AI, RabbitMQ and Redis on service EC2.
resource "aws_vpc_security_group_ingress_rule" "ai_from_crawl" {
  security_group_id            = aws_security_group.brandhub_service.id
  description                  = "Crawler access to AI API"
  referenced_security_group_id = aws_security_group.brandhub_crawl.id
  from_port                    = 8082
  to_port                      = 8082
  ip_protocol                  = "tcp"
}

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
