# =========================================================
# Import Existing IAM & OIDC Resources
# =========================================================

import {
  to = aws_iam_openid_connect_provider.github_actions
  id = "arn:aws:iam::821014378805:oidc-provider/token.actions.githubusercontent.com"
}

import {
  to = aws_iam_role.github_actions
  id = "brandhub-github-actions"
}

import {
  to = aws_iam_role_policy.github_actions_frontend
  id = "brandhub-github-actions:brandhub-github-actions-policy"
}

import {
  to = aws_iam_role_policy.github_actions_backend_cicd
  id = "brandhub-github-actions:brandhub-github-actions-ecr-ssm"
}

import {
  to = aws_iam_role.ec2_ecr_pull
  id = "brandhub-ec2-ecr-pull"
}

import {
  to = aws_iam_role_policy.ec2_ecr_pull
  id = "brandhub-ec2-ecr-pull:brandhub-images-read"
}

import {
  to = aws_iam_role_policy_attachment.ec2_ssm_managed_instance_core
  id = "brandhub-ec2-ecr-pull/arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

import {
  to = aws_iam_instance_profile.ec2_ecr_pull
  id = "brandhub-ec2-ecr-pull"
}
