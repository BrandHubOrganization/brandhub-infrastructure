locals {
  instance_security_groups = {
    api_gateway   = aws_security_group.brandhub_core.id
    core_services = aws_security_group.brandhub_service.id
  }
}

data "aws_iam_instance_profile" "ecr_pull" {
  name = "brandhub-ec2-ecr-pull"
}

resource "aws_instance" "brandhub" {
  for_each = var.instances

  ami                  = each.value.ami
  instance_type        = each.value.instance_type
  key_name             = each.value.key_name
  iam_instance_profile = data.aws_iam_instance_profile.ecr_pull.name

  subnet_id = data.aws_subnet.brandhub.id

  # Both existing instances currently have an auto-assigned public IPv4.
  # Keep this true while importing the current infrastructure.
  associate_public_ip_address = true

  vpc_security_group_ids = [
    local.instance_security_groups[each.key]
  ]

  root_block_device {
    volume_size           = each.value.root_volume_size
    volume_type           = each.value.root_volume_type
    delete_on_termination = true
    encrypted             = true

    tags = {
      Name        = "${each.value.name}-root-volume"
      Project     = "BrandHub"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name        = each.value.name
    Project     = "BrandHub"
    Environment = var.environment
    Service     = each.key
    ManagedBy   = "terraform"
  }

  lifecycle {
    prevent_destroy = true
  }
}
