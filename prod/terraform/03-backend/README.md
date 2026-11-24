# Terraform Stack `03-backend` — EC2 Fleet, Security Groups, ECR, Backups & Wake

- Back to [Terraform Overview](../README.md) · [Production Hub](../../README.md) · [EC2 Host Manifests](../../hosts/README.md)

Manages BrandHub's 5 production EC2 instances in `ap-southeast-1`, strict VPC Security Group segmentation, 7 immutable ECR repositories, `api.brandhub.id.vn` DNS, S3 daily database backup storage, and EventBridge wake-on-schedule automation.

---

## 1. Source Files & Managed AWS Resources

| File | Managed Resources | Key Design Details |
| :--- | :--- | :--- |
| [`network.tf`](network.tf) | `data.aws_vpc.brandhub`, `data.aws_subnet.brandhub` | Binds compute and security groups to the production VPC and subnet |
| [`ec2.tf`](ec2.tf) | `aws_instance.brandhub` (`for_each = var.instances`) | Provisions `api_gateway` (`172.31.27.199`), `core_services` (`172.31.24.149`), `ai` (`172.31.20.60`), `crawl` (`172.31.20.50`), and `edit_video` (`172.31.20.80`). Enforces IMDSv2 (`http_tokens = "required"`, `http_put_response_hop_limit = 2`), encrypted EBS root volumes, `instance_initiated_shutdown_behavior = "stop"`, `ignore_changes = [user_data]`, and `Wakeable` tag |
| [`security.tf`](security.tf) | 5 Security Groups + explicit `aws_vpc_security_group_*_rule` resources | Least-privilege SG-to-SG east-west port matrix (see Section 2) |
| [`ecr.tf`](ecr.tf) | `aws_ecr_repository.applications` + lifecycle policies | 7 `IMMUTABLE` repositories (`scan_on_push = true`): `brandhub/{api-gateway,business-service,publisher-service,ai-service,crawl-service,edit-video,db-backup}`; retains last 10 `deploy-*` tags and last 15 CI images |
| [`api-dns.tf`](api-dns.tf) | `aws_route53_record.api` | Maps `api.brandhub.id.vn` (`A`, `TTL 60`) to `aws_instance.brandhub["api_gateway"].public_ip` |
| [`backup.tf`](backup.tf) | `aws_s3_bucket.db_backup` + `aws_iam_role_policy.ec2_db_backup_put` | Private `AES256` bucket **`brandhub-db-backup-prd-134875421878`** (TLS-only policy, 30-day expiry on objects tagged `retention=daily`, untagged baselines kept forever); grants `ListBucket`, `PutObject`, `PutObjectTagging`, `GetObject` under `{postgres,redis,chroma,mongo,neo4j}/*` (no `DeleteObject`) |
| [`wake.tf`](wake.tf) | `aws_iam_role_policy.ec2_wake_instances`, `aws_iam_role.scheduler_crawl`, `aws_scheduler_schedule.{crawl_wake,crawl_kick}` | Allows wakers on `brandhub-ec2-ecr-pull` to call `ec2:StartInstances` strictly on `Wakeable=true` hosts; creates paired EventBridge schedules (`Asia/Ho_Chi_Minh`) pre-waking `crawl` `crawl_wake_lead_minutes` early and invoking `/usr/local/bin/brandhub-crawl-kick.sh` via SSM |
| [`update-admin-ip.ps1`](update-admin-ip.ps1) | Operator PowerShell helper | Fetches current public IPv4 `/32`, updates `admin_ip` in `terraform.tfvars`, and runs `terraform plan` |

---

## 2. VPC Security Group Segmentation (`security.tf`)

> Historical AWS Security Group names (`brandhub-core-sg` on `api_gateway`, `brandhub-service-sg` on `core_services`) are preserved with `prevent_destroy = true` to avoid disruptive SG replacements.

| Terraform Resource & AWS SG Name | Attached EC2 Host | Allowed Inbound Rules (Source → TCP Port) |
| :--- | :--- | :--- |
| `brandhub_core` (`brandhub-core-sg`) | `api_gateway` (`172.31.27.199`) | `0.0.0.0/0` & `::/0` → `80`, `443`; `var.admin_ip` → `22` |
| `brandhub_service` (`brandhub-service-sg`) | `core_services` (`172.31.24.149`) | `brandhub-core-sg` → `8081` (business), `8083` (publisher), `6379` (redis); `brandhub-ai-sg` → `6379` (redis), `5672` (rabbitmq), `8000` (chromadb), `8084` (`crawl-gate`); `brandhub-crawl-sg` → `5672`, `6379`; `var.admin_ip` → `22` |
| `brandhub_ai` (`brandhub-ai-sg`) | `ai` (`172.31.20.60`) | `brandhub-service-sg`, `brandhub-core-sg`, `brandhub-crawl-sg` → `8082`; `var.admin_ip` → `22` |
| `brandhub_crawl` (`brandhub-crawl-sg`) | `crawl` (`172.31.20.50`) | `brandhub-service-sg` (`crawl-gate`) & `brandhub-ai-sg` → `8084`; `var.admin_ip` → `22` |
| `brandhub_edit_video` (`brandhub-edit-video-sg`) | `edit_video` (`172.31.20.80`) | `brandhub-core-sg` (gateway Nginx) → `8095`; `var.admin_ip` → `22` |

---

## 3. Key Variables & Outputs

- **Inputs (`variables.tf`)**: `aws_account_id` (`134875421878`), `aws_region` (`ap-southeast-1`), `vpc_id`, `subnet_id`, `admin_ip` (`/32` CIDR), `instances` map (AMI, instance type, private IP, EBS size/encryption, `wake_on_request`), `db_backup_bucket_name` (`brandhub-db-backup-prd-134875421878`), `db_backup_retention_days` (`30`), `crawl_schedule_times` (`HH:MM` list in `Asia/Ho_Chi_Minh`), `crawl_wake_lead_minutes`.
- **Outputs (`outputs.tf`, `backup.tf`, `wake.tf`)**: `instances` map, per-host `*_instance_id` / `*_public_ip` / `*_private_ip`, all 5 `*_sg_id`s, `db_backup_bucket`, and `wakeable_instances` (used to populate `WAKE_TARGETS` on `gateway` and `core`).

---

## 4. Plan, Apply & Admin IP Update

```powershell
cd prod/terraform/03-backend
Copy-Item terraform.tfvars.example terraform.tfvars
terraform init
.\update-admin-ip.ps1        # Refreshes admin_ip to your current /32 and runs terraform plan
terraform apply
```
