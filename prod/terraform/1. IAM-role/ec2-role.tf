# =========================================================
# EC2 Runtime & Deployment IAM Role (ECR Pull + SSM Agent)
# =========================================================

resource "aws_iam_role" "ec2_ecr_pull" {
  name                 = "brandhub-ec2-ecr-pull"
  path                 = "/"
  max_session_duration = 3600

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_iam_role_policy" "ec2_ecr_pull" {
  name = "brandhub-images-read"
  role = aws_iam_role.ec2_ecr_pull.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ecr:GetAuthorizationToken"]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
        ]
        Resource = [
          for repo in var.ecr_repositories :
          "arn:aws:ecr:${var.aws_region}:${var.aws_account_id}:repository/${repo}"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_ssm_managed_instance_core" {
  role       = aws_iam_role.ec2_ecr_pull.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_ecr_pull" {
  name = "brandhub-ec2-ecr-pull"
  path = "/"
  role = aws_iam_role.ec2_ecr_pull.name

  lifecycle {
    prevent_destroy = true
  }
}
