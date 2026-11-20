# Terraform (account 134875421878)

Local state per stack (`terraform.tfstate`, gitignored). Old-account (821014378805) state backups were moved to
`keep-local-only/archive-20261121/terraform-state/`.

| Stack | Manages |
| --- | --- |
| `1-iam` | GitHub OIDC, CI/CD roles, EC2 role + instance profile `brandhub-ec2-ecr-pull` |
| `2-frontend` | S3 `brandhub-web-prd-134875421878`, CloudFront + function, ACM (us-east-1), Route 53 zone `brandhub.id.vn` |
| `3-backend` | EC2 gateway / core / crawl / edit-video, security groups (incl. `brandhub-ai-sg`), ECR, `api.brandhub.id.vn`, DB backup bucket, wake scheduler |
| `4-storage` | Media/repository buckets, KMS key, service IAM policy (see its README) |

Apply order for a fresh account: `1-iam` → `2-frontend` (Route 53 zone, targeted) → `4-storage` → `3-backend` → `2-frontend` (rest).

Not in state: `brandhub-ai` (`i-0f7857edf71b6bb3f`) and `brandhub-ci-runner` (`i-017dbae8f6110e50c`).

Update the admin IP allowed by the security groups: `3-backend/update-admin-ip.ps1`.
