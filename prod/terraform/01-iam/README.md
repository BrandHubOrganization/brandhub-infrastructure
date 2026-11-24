# Terraform Stack `01-iam` — OIDC, CI/CD & EC2 Runtime Identity

- Back to [Terraform Overview](../README.md) · [Production Hub](../../README.md) · [Security Policy](../../../SECURITY.md)

Provisions account-wide IAM trust boundaries in AWS Account `134875421878` (`ap-southeast-1`) so GitHub Actions deploys without long-lived AWS keys and EC2 instances authenticate via short-lived IMDSv2 role credentials.

---

## 1. Source Files & Managed AWS Resources

| File | Terraform Resources | AWS Identity / Policy Details |
| :--- | :--- | :--- |
| [`providers.tf`](providers.tf) | `provider "aws"` | Terraform `>= 1.5.0`, `hashicorp/aws ~> 6.0`, locked to `allowed_account_ids = [var.aws_account_id]` |
| [`oidc.tf`](oidc.tf) | `aws_iam_openid_connect_provider.github_actions` | Federated OIDC provider `https://token.actions.githubusercontent.com` (`aud = sts.amazonaws.com`, `prevent_destroy = true`) |
| [`github-actions-role.tf`](github-actions-role.tf) | `aws_iam_role.github_actions`<br>`aws_iam_role_policy.github_actions_frontend`<br>`aws_iam_role_policy.github_actions_backend_cicd` | Role **`brandhub-github-actions`** (`1h` max session). Trust policy restricts `sub` to `repo:BrandHubOrganization/brandhub-*:ref:refs/heads/{main,develop}` and `environment:production` |
| [`ec2-role.tf`](ec2-role.tf) | `aws_iam_role.ec2_ecr_pull`<br>`aws_iam_role_policy.ec2_ecr_pull`<br>`aws_iam_role_policy_attachment.ec2_ssm_managed_instance_core`<br>`aws_iam_instance_profile.ec2_ecr_pull` | Role & Instance Profile **`brandhub-ec2-ecr-pull`** (`prevent_destroy = true`): attaches `AmazonSSMManagedInstanceCore` + read-only ECR pull (`BatchGetImage`, `GetDownloadUrlForLayer`) across all 7 BrandHub ECR repos |

> **Cross-Stack Policy Attachments**: Additional least-privilege inline policies attach to `brandhub-ec2-ecr-pull` from downstream stacks:
> - [`../03-backend/`](../03-backend/README.md): `brandhub-db-backup-put` (S3 backup & restore) and `brandhub-wake-instances` (`ec2:StartInstances` where `aws:ResourceTag/Wakeable == "true"`).
> - [`../04-storage/`](../04-storage/README.md): `brandhub-repository-s3-kms-prod` and `brandhub-app-buckets-prod`.

---

## 2. Least-Privilege Policy Matrix (`brandhub-github-actions`)

| Inline Policy | Allowed Actions | Resource / Condition Scope |
| :--- | :--- | :--- |
| **`brandhub-github-actions-policy`** | `s3:ListBucket`, `s3:GetObject`, `s3:PutObject`, `s3:DeleteObject`, `cloudfront:CreateInvalidation` | Scoped to `arn:aws:s3:::brandhub-web-prd-134875421878` (`/*`) + CloudFront invalidation |
| **`brandhub-github-actions-ecr-ssm`** | ECR push/pull (`PutImage`, `UploadLayerPart`, etc.), `ssm:SendCommand`, `ssm:GetCommandInvocation`, `ec2:StartInstances`, `ec2:DescribeInstances` | ECR limited to the 7 `var.ecr_repositories`; `ssm:SendCommand` limited to `AWS-RunShellScript` on EC2 instances tagged `Project = BrandHub`; `ec2:StartInstances` limited to `Wakeable = true` |

---

## 3. Input Variables (`variables.tf`) & Outputs (`outputs.tf`)

| Variable | Default | Purpose |
| :--- | :--- | :--- |
| `aws_region` | `"ap-southeast-1"` | Primary AWS region |
| `aws_account_id` | `"134875421878"` | Target AWS account guard |
| `github_org` | `"BrandHubOrganization"` | GitHub organization permitted to assume OIDC role |
| `github_oidc_thumbprints` | `["ab9d0263..."]` | GitHub Actions OIDC TLS thumbprint list |
| `frontend_s3_bucket_name` | `"brandhub-web-prd-134875421878"` | Target S3 bucket for `brandhub-web` CI/CD sync |
| `ecr_repositories` | 7 repos (`brandhub/*`) | `ai-service`, `api-gateway`, `business-service`, `crawl-service`, `db-backup`, `edit-video`, `publisher-service` |

**Outputs**: `github_oidc_provider_arn`, `github_actions_role_arn` (stored in GitHub repo/org secret `AWS_ROLE_ARN`), `github_actions_role_name`, `ec2_ecr_pull_role_arn`, `ec2_ecr_pull_instance_profile_name`, `ec2_ecr_pull_instance_profile_arn`.

---

## 4. Plan & Apply Commands

```powershell
cd prod/terraform/01-iam
Copy-Item terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
terraform apply
```
