locals {
  instance_security_groups = {
    api_gateway   = aws_security_group.brandhub_core.id
    core_services = aws_security_group.brandhub_service.id
    crawl         = aws_security_group.brandhub_crawl.id
    ai            = aws_security_group.brandhub_ai.id
    edit_video    = aws_security_group.brandhub_edit_video.id
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

  subnet_id  = data.aws_subnet.brandhub.id
  private_ip = each.value.private_ip

  # Instances need outbound internet (ECR, crawl targets) and there is no NAT.
  associate_public_ip_address = true

  # Wakeable hosts stop themselves when idle (hosts/_shared/idle-sleep/idle-sleep.sh): `shutdown` must stop, never terminate.
  instance_initiated_shutdown_behavior = "stop"

  vpc_security_group_ids = [
    local.instance_security_groups[each.key]
  ]

  root_block_device {
    volume_size           = each.value.root_volume_size
    volume_type           = each.value.root_volume_type
    delete_on_termination = true
    encrypted             = each.value.root_volume_encrypted

    tags = {
      Name        = "${each.value.name}-root-volume"
      Project     = "BrandHub"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }

  lifecycle {
    # The AI host was created by hand with its own user_data; changing it would stop the
    # instance. No Terraform-managed host sets user_data.
    ignore_changes = [user_data]
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
    # 2 hops: containers (the waker) reach IMDSv2 for the instance role credentials.
    http_put_response_hop_limit = 2
  }

  tags = {
    Name        = each.value.name
    Project     = "BrandHub"
    Environment = var.environment
    Service     = each.key
    ManagedBy   = "terraform"
    # IAM lets the wakers start only instances with Wakeable = true.
    Wakeable = tostring(each.value.wake_on_request)
  }
}
