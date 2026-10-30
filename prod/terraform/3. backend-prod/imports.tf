# =========================================================
# Existing EC2 Instances
# =========================================================

import {
  to = aws_instance.brandhub["api_gateway"]
  id = "i-0761e3bd96ca5d4de"
}

import {
  to = aws_instance.brandhub["core_services"]
  id = "i-07283e8467a059e5a"
}

moved {
  from = aws_instance.brandhub["backend"]
  to   = aws_instance.brandhub["api_gateway"]
}

moved {
  from = aws_instance.brandhub["service"]
  to   = aws_instance.brandhub["core_services"]
}


# =========================================================
# Existing Security Groups
# =========================================================

import {
  to = aws_security_group.brandhub_core
  id = "sg-06d2b9232706a8347"
}

import {
  to = aws_security_group.brandhub_service
  id = "sg-042b2bafd616d436b"
}


# =========================================================
# Existing brandhub-core-sg Rules
# =========================================================

import {
  to = aws_vpc_security_group_ingress_rule.core_ssh
  id = "sgr-0016532125259803f"
}

import {
  to = aws_vpc_security_group_ingress_rule.core_http_ipv4
  id = "sgr-00778cf820e114f02"
}

import {
  to = aws_vpc_security_group_ingress_rule.core_https_ipv4
  id = "sgr-00b27a8ae416c096e"
}

import {
  to = aws_vpc_security_group_ingress_rule.core_http_ipv6
  id = "sgr-0627aeca4d1de1ae3"
}

import {
  to = aws_vpc_security_group_ingress_rule.core_https_ipv6
  id = "sgr-08ef003f1db385a5b"
}

import {
  to = aws_vpc_security_group_egress_rule.core_all_outbound
  id = "sgr-03be959efd7df5ff5"
}


# =========================================================
# Existing brandhub-service-sg Rules
# =========================================================

import {
  to = aws_vpc_security_group_ingress_rule.service_ssh
  id = "sgr-0de2a1cc79ef48093"
}

import {
  to = aws_vpc_security_group_ingress_rule.business_from_gateway
  id = "sgr-0e2b20b4e276691a8"
}

import {
  to = aws_vpc_security_group_ingress_rule.publisher_from_gateway
  id = "sgr-0fc1ed24d5c97a000"
}

import {
  to = aws_vpc_security_group_egress_rule.service_all_outbound
  id = "sgr-04954fab91976b475"
}
