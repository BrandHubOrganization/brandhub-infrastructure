# Terraform Stack `04-storage` — Media S3, KMS Envelope Key & GPU Worker IAM

- Back to [Terraform Overview](../README.md) · [Production Hub](../../README.md) · [Repository Pre-S3 Encryption](../../../scripts/repository-encryption/README.md) · [Security Policy](../../../SECURITY.md)

Provisions BrandHub's unified media & encrypted Workspace Repository / `Client` Vault S3 bucket, Customer-Managed KMS key (`CMK`), social crawler object storage, and prefix-restricted IAM credentials for external Vast.ai GPU workers.

---

## 1. Source Files & Managed AWS Resources

| File | Terraform Resources | Cryptographic & Access Controls |
| :--- | :--- | :--- |
| [`s3.tf`](s3.tf) | `aws_s3_bucket.repository` + ownership, public access block, `AES256` SSE, CORS, lifecycle, bucket policy | Unified bucket **`brandhub-media-134875421878`** (`BucketOwnerEnforced`, `bucket_key_enabled = true`, `prevent_destroy = true`) |
| [`kms.tf`](kms.tf) | `aws_kms_key.repository_media`<br>`aws_kms_alias.repository_media` | CMK **`alias/brandhub-repository-media-prod`** (`enable_key_rotation = true`, `deletion_window_in_days = 30`, `prevent_destroy = true`), restricted to root admin + `local.allowed_runtime_role_arns` |
| [`iam-service-policy.tf`](iam-service-policy.tf) | `aws_iam_role_policy.runtime_repository_s3_kms` | Attaches `brandhub-repository-s3-kms-prod` to `brandhub-ec2-ecr-pull` (`s3:GetObject`, `PutObject`, `DeleteObject`, `ListBucket`, `GetBucketVersioning` + KMS `Encrypt`/`Decrypt`/`ReEncrypt*`/`GenerateDataKey*`/`DescribeKey`) |
| [`app-buckets.tf`](app-buckets.tf) | `aws_s3_bucket.app["crawler"]`<br>`aws_iam_role_policy.runtime_app_buckets`<br>`aws_iam_user.image_worker` + `aws_iam_user_policy.image_worker` | Private `AES256` bucket **`crawler-social-134875421878`** (all public access blocked, TLS-only) + external IAM user **`brandhub-image-worker-prod`** |

---

## 2. Prefix Security Model on `brandhub-media-134875421878`

| S3 Key Prefix(es) | Visibility | Encryption & Principal Enforcement |
| :--- | :--- | :--- |
| `image/*` | Public Read (`s3:GetObject`) | Bucket SSE (`AES256`). Serves non-sensitive user avatars, agency logos, and workspace banners directly over HTTPS (`DenyInsecureHttpTransport` blocks HTTP). |
| `repository/*`, `repository-staging/*`, `staging/*`, `client-vault/*` | **Strictly Private** | Accessible only to `allowed_runtime_role_arns` (`brandhub-ec2-ecr-pull`). Payloads are pre-encrypted before S3 upload by `RepositoryEnvelopeCrypto` (`ALG_AES_256_GCM_HKDF_SHA512_COMMIT_KEY`) — see [`../../../scripts/repository-encryption/README.md`](../../../scripts/repository-encryption/README.md). Unconfirmed `staging/` and `repository-staging/` objects expire automatically after **2 days**; incomplete multipart uploads abort after **1 day**. Physical S3 versioning is kept disabled so permanent `Client` Vault / Repository purges immediately free quota bytes. |
| `ai/*`, `qwen-ambassador/*` | Private (EC2 Runtime + Vast.ai Worker) | `brandhub-image-worker-prod` (`app-buckets.tf`) can `ListBucket`, `GetObject`, `PutObject`, and `DeleteObject` **exclusively** within `ai/*` and `qwen-ambassador/*` — zero access to `repository/*` or `client-vault/*`. |

**CORS Configuration (`s3.tf`)**: Allows browser `GET`, `HEAD`, `PUT` (`expose_headers = ["ETag", "x-amz-version-id"]`, `max_age_seconds = 3000`) solely from `https://brandhub.id.vn`, `https://www.brandhub.id.vn`, and `http://localhost:3000`.

---

## 3. Input Variables (`variables.tf`) & Outputs (`outputs.tf`)

| Variable | Default | Purpose |
| :--- | :--- | :--- |
| `aws_account_id` | `"134875421878"` | 12-digit AWS account guard |
| `aws_region` | `"ap-southeast-1"` | Target AWS region |
| `environment` | `"prod"` | Allowed: `dev`, `staging`, `prod` |
| `repository_s3_bucket_name` | `"brandhub-media-134875421878"` | Unified media & encrypted repository bucket |
| `service_iam_role_name` | `"brandhub-ec2-ecr-pull"` | EC2 runtime IAM role from `01-iam` |
| `additional_allowed_service_role_arns` | `[]` | Optional extra service role ARNs (never human dev IAM users) |
| `allowed_cors_origins` | `brandhub.id.vn`, `www.brandhub.id.vn`, `localhost:3000` | Allowed browser origins |

**Outputs**: `repository_s3_bucket_name`, `repository_s3_bucket_arn`, `repository_kms_key_id` (`REPOSITORY_SYSTEM_S3_KMS_KEY_ID`), `repository_kms_key_arn`, `repository_kms_alias`, `app_bucket_names`, `image_worker_iam_user`.

---

## 4. Validation & Apply Commands

```powershell
cd prod/terraform/04-storage
Copy-Item terraform.tfvars.example terraform.tfvars
terraform init
terraform fmt -check
terraform validate
terraform plan
terraform apply
```
