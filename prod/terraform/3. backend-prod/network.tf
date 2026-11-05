data "aws_vpc" "brandhub" {
  id = var.vpc_id
}

data "aws_subnet" "brandhub" {
  id = var.subnet_id
}
