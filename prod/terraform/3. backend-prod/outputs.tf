output "instances" {
  description = "BrandHub EC2 instances"

  value = {
    for key, instance in aws_instance.brandhub : key => {
      instance_id = instance.id
      name        = var.instances[key].name
      public_ip   = instance.public_ip
      private_ip  = instance.private_ip
    }
  }
}

output "api_gateway_instance_id" {
  value = aws_instance.brandhub["api_gateway"].id
}

output "api_gateway_public_ip" {
  value = aws_instance.brandhub["api_gateway"].public_ip
}

output "api_gateway_private_ip" {
  value = aws_instance.brandhub["api_gateway"].private_ip
}

output "core_services_instance_id" {
  value = aws_instance.brandhub["core_services"].id
}

output "core_services_public_ip" {
  value = aws_instance.brandhub["core_services"].public_ip
}

output "core_services_private_ip" {
  value = aws_instance.brandhub["core_services"].private_ip
}

output "brandhub_core_sg_id" {
  value = aws_security_group.brandhub_core.id
}

output "brandhub_service_sg_id" {
  value = aws_security_group.brandhub_service.id
}
