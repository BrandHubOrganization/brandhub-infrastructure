# BrandHub AWS Terraform Architecture (`prod/terraform/`)

Layered Terraform (`>= 1.5.0`, `hashicorp/aws ~> 6.0`) Infrastructure-as-Code stacks provisioning AWS Account **`134875421878`** (`ap-southeast-1`, plus `us-east-1` for CloudFront ACM).

- Back to [Production Hub](../README.md) · [Infrastructure Hub](../../README.md)
- EC2 Runtime Manifests: [`../hosts/README.md`](../hosts/README.md)
- Production Runbooks: [`../../docs/operations/deployment-acct134.md`](../../docs/operations/deployment-acct134.md)

---

## 1. Stack Architecture & Blast-Radius Isolation

Instead of a monolithic Terraform root module, BrandHub partitions AWS infrastructure into **4 independent state boundaries** (`terraform.tfstate` gitignored per stack) with `allowed_account_ids = [var.aws_account_id]` (`134875421878`) and `prevent_destroy = true` on stateful resources:

| Stack | Directory | Blast Radius | Primary AWS Resources Managed |
| :---: | :--- | :--- | :--- |
| **01** | [`01-iam/`](01-iam/README.md) | Account-wide IAM | GitHub OIDC provider (`token.actions.githubusercontent.com`), `brandhub-github-actions` CI/CD role (S3/CloudFront/ECR/SSM/Wake), `brandhub-ec2-ecr-pull` EC2 role & instance profile |
| **02** | [`02-frontend/`](02-frontend/README.md) | Public DNS & Edge CDN | Route 53 hosted zone `brandhub.id.vn`, `us-east-1` ACM certificate, private S3 bucket `brandhub-web-prd-134875421878`, CloudFront OAC distribution + `brandhub-public-routes` viewer function |
| **03** | [`03-backend/`](03-backend/README.md) | Compute, Network & ECR | 5 EC2 hosts (`api_gateway`, `core_services`, `ai`, `crawl`, `edit_video`), 5 Security Groups, 7 immutable ECR repos, `api.brandhub.id.vn` DNS `A` record, `brandhub-db-backup-prd-134875421878` S3 bucket, EventBridge crawl wake/kick schedules |
| **04** | [`04-storage/`](04-storage/README.md) | Media, Vault & KMS | Unified `brandhub-media-134875421878` S3 bucket, KMS CMK `alias/brandhub-repository-media-prod`, `crawler-social-134875421878` bucket, runtime S3/KMS inline policies, `brandhub-image-worker-prod` IAM user for Vast.ai |

---

## 2. Fresh-Account Bootstrap Order

Cross-stack coupling is minimized via deterministic resource names (`brandhub-ec2-ecr-pull`, `brandhub.id.vn.`) and AWS resource tags (`Project=BrandHub`, `Wakeable=true`). On a clean AWS account, apply in this 5-step sequence:

1. **[`01-iam/`](01-iam/README.md)** — `terraform apply`: Creates the OIDC provider, GitHub Actions role, and `brandhub-ec2-ecr-pull` instance profile referenced by `03-backend` and `04-storage`.
2. **[`02-frontend/`](02-frontend/README.md)** — `terraform apply -target=aws_route53_zone.brandhub_public`: Creates the Route 53 hosted zone and outputs NS records for domain registrar delegation (required before ACM DNS validation and `03-backend` `api.brandhub.id.vn` lookup).
3. **[`04-storage/`](04-storage/README.md)** — `terraform apply`: Provisions `brandhub-media-134875421878`, `crawler-social-134875421878`, KMS CMK, and attaches S3/KMS inline policies to `brandhub-ec2-ecr-pull`.
4. **[`03-backend/`](03-backend/README.md)** — `terraform apply`: Provisions the 7 ECR repositories, 5 Security Groups, 5 EC2 instances, `api.brandhub.id.vn` Route 53 record, `db-backup` S3 bucket, and EventBridge crawl schedules.
5. **[`02-frontend/`](02-frontend/README.md)** — `terraform apply`: Completes ACM DNS validation in `us-east-1`, private S3 origin policy, CloudFront distribution, and `A`/`AAAA` alias records.

---

## 3. Standard Validation & Operator Workflow

Run inside any stack directory (`01-iam`, `02-frontend`, `03-backend`, or `04-storage`):

```powershell
Copy-Item terraform.tfvars.example terraform.tfvars   # First time only (gitignored)
terraform init
terraform fmt -check
terraform validate
terraform plan
```

- **Refresh Admin SSH CIDR (`03-backend`)**: Run [`03-backend/update-admin-ip.ps1`](03-backend/update-admin-ip.ps1) to detect your current public IPv4 `/32`, update `admin_ip` in `03-backend/terraform.tfvars`, and run `terraform plan`.
- **State Discipline**: Never delete `.terraform.lock.hcl` without review; never commit `terraform.tfstate*` or `terraform.tfvars` (enforced by [`../.gitignore`](../.gitignore)).
