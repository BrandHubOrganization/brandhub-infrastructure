locals {
  application_images = toset(["api-gateway", "business-service", "publisher-service", "ai-service"])
}

resource "aws_ecr_repository" "applications" {
  for_each             = local.application_images
  name                 = "brandhub/${each.key}"
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Project = "BrandHub"
  }
}

resource "aws_ecr_lifecycle_policy" "applications" {
  for_each   = aws_ecr_repository.applications
  repository = each.value.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep baseline deploy-20261029 tag"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["deploy-"]
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Keep last 15 CI/CD images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 15
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
