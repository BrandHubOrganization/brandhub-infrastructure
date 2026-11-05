# =========================================================
# GitHub Actions Deployment IAM Role (Frontend & Backend CD)
# =========================================================

resource "aws_iam_role" "github_actions" {
  name                 = "brandhub-github-actions"
  path                 = "/"
  description          = "Allows GitHub Actions workflows in the BrandHub organization to securely deploy application builds to authorized AWS resources using OIDC, including uploading frontend files to S3 and creating CloudFront cache invalidations."
  max_session_duration = 3600

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_actions.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/*"
          }
        }
      }
    ]
  })

  lifecycle {
    prevent_destroy = true
  }
}

# Inline Policy 1: Frontend Deployment (S3 + CloudFront Invalidation)
resource "aws_iam_role_policy" "github_actions_frontend" {
  name = "brandhub-github-actions-policy"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ListBrandHubBucket"
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = "arn:aws:s3:::${var.frontend_s3_bucket_name}"
      },
      {
        Sid    = "DeployBrandHubFrontend"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
        ]
        Resource = "arn:aws:s3:::${var.frontend_s3_bucket_name}/*"
      },
      {
        Sid      = "InvalidateBrandHubCloudFront"
        Effect   = "Allow"
        Action   = ["cloudfront:CreateInvalidation"]
        Resource = "*"
      }
    ]
  })
}

# Inline Policy 2: Backend CI/CD Deployment (ECR Push + SSM Rolling Update)
resource "aws_iam_role_policy" "github_actions_backend_cicd" {
  name = "brandhub-github-actions-ecr-ssm"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ECRAuthorizationToken"
        Effect   = "Allow"
        Action   = ["ecr:GetAuthorizationToken"]
        Resource = "*"
      },
      {
        Sid    = "ECRPushPullBrandHubImages"
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeImages",
        ]
        Resource = [
          for repo in var.ecr_repositories :
          "arn:aws:ecr:${var.aws_region}:${var.aws_account_id}:repository/${repo}"
        ]
      },
      {
        Sid    = "SSMSendCommandToBrandHubEC2"
        Effect = "Allow"
        Action = ["ssm:SendCommand"]
        Resource = concat(
          ["arn:aws:ssm:${var.aws_region}::document/AWS-RunShellScript"],
          [
            for instance_id in var.ec2_instance_ids :
            "arn:aws:ec2:${var.aws_region}:${var.aws_account_id}:instance/${instance_id}"
          ]
        )
      },
      {
        Sid    = "SSMGetCommandStatus"
        Effect = "Allow"
        Action = [
          "ssm:GetCommandInvocation",
          "ssm:ListCommandInvocations",
        ]
        Resource = "*"
      }
    ]
  })
}
