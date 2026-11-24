# Operational Database Manual (`database/`)

Operational bootstrap schemas, ordered incremental migrations, local snapshot restoration scripts, and administrative SQL utilities for **BrandHub**.

- Back to [Infrastructure Hub](../README.md)
- Conceptual ERDs, polyglot persistence strategy & schema dictionary: [`../docs/database/README.md`](../docs/database/README.md)
- Ordered incremental migrations (`25` PostgreSQL, `8` MongoDB, `1` Neo4j): [`migrations/README.md`](migrations/README.md)
- Local `.dump` / `.ejson` backup restoration: [`backups/README.md`](backups/README.md) · [`../docker/compose/seed-guide.md`](../docker/compose/seed-guide.md)

---

## Directory Layout

```text
database/
├── README.md                          # Operational database manual (this file)
├── init/                              # Fresh-volume bootstrap scripts (mounted read-only by Docker)
│   ├── init-postgres-v2.sql           # PostgreSQL 17 full DDL (97 tables, triggers, 6 seeded plans)
│   ├── init-mongo.js                  # MongoDB 7.0 full DDL (52 collections, $jsonSchema validators, indexes)
│   └── pgadmin-servers.json           # Pre-configured pgAdmin 4 v9 connection to postgres:5432
├── migrations/
│   ├── README.md                      # Master migration runbook, execution order & dry-run flags
│   ├── postgres/                      # 25 idempotent PostgreSQL 17 SQL migrations (YYYY-MM-DD-*.sql)
│   ├── mongodb/                       # 8 idempotent MongoDB 7.0 / Atlas mongosh migrations
│   └── neo4j/                         # 1 additive Neo4j 5.26 / Aura Cypher index migration
├── backups/
│   ├── README.md                      # Snapshot restore instructions (snapshots themselves are gitignored)
│   ├── restore-postgres.{bat,ps1}     # Drops & restores PostgreSQL custom-format .dump files
│   └── restore-mongodb.{bat,ps1,py}   # Restores MongoDB Extended JSON (.ejson) snapshots
└── scripts/
    ├── patch-update-running-db.sql    # In-place SQL catch-up patch for older local PostgreSQL volumes
    └── reduce-demo-users.sql          # Trims large demo datasets to 30 users preserving 5 core role accounts
```

---

## 1. Fresh Volume Bootstrap (`database/init/`)

When `docker/run_dev.bat` or `docker/run_dev_ai.bat` starts against **empty** named volumes (`brandhub-postgres-v2-data` and `brandhub-mongodb-data`), `docker/compose/shared/databases.yaml` bind-mounts the bootstrap scripts read-only into `/docker-entrypoint-initdb.d/`:

| File | Engine | Scope & Runtime Behavior |
| :--- | :--- | :--- |
| [`init/init-postgres-v2.sql`](init/init-postgres-v2.sql) | PostgreSQL 17 (`postgres:17-alpine`) | Creates all **97 unique tables**, enums, check constraints, foreign keys, immutability triggers (`billing_guard_plan_version`), real-time notification triggers (`NOTIFY user_notification`), `public.brandhub_schema_migrations`, and seeds the **6 active subscription plans** |
| [`init/init-mongo.js`](init/init-mongo.js) | MongoDB 7.0 (`mongo:7.0`) | Creates all **52 collections** in the `brandhub` database with strict/moderate `$jsonSchema` validators and compound/TTL/partial indexes |
| [`init/pgadmin-servers.json`](init/pgadmin-servers.json) | pgAdmin 4 v9 (`dpage/pgadmin4:9`) | Pre-configured server definition (`BrandHub PostgreSQL` → `postgres:5432`, database `brandhub`, user `brandhub_user`, `PassFile: /pgpass`) for `docker/compose/shared/pgadmin.yaml` |

> **Critical Rule**: Docker executes `/docker-entrypoint-initdb.d/*` **only** when the target data directory is completely empty. Never execute `init/init-mongo.js` against a populated staging or production **MongoDB Atlas** cluster — apply the incremental scripts in [`migrations/README.md`](migrations/README.md) instead.

---

## 2. PostgreSQL 17 Schema Groups (97 Tables)

`brandhub-business-service` owns PostgreSQL as the system of record for identity, multi-tenant RBAC (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`), contractual workflows, double-entry AI credit & storage ledgers, and SePay (VietQR) subscription billing:

| Domain Group | Count | Tables in `init/init-postgres-v2.sql` |
| :--- | :---: | :--- |
| **Identity, Auth & System Roles** | 6 | `users`, `user_oauth_providers`, `user_refresh_tokens`, `user_system_roles`, `account_activation_tokens`, `audit_logs` |
| **Agency, Personal Studio & Workspace** | 9 | `agencies` (`company_type`: `AGENCY` \| `PERSONAL`), `agency_members`, `agency_invitations`, `client_profiles`, `workspaces`, `workspace_members`, `workspace_invitations`, `workspace_templates`, `workspace_post_templates` *(via migration)* / `workspace_hashtags` |
| **Media Packages & Campaigns** | 9 | `media_packages`, `workspace_media_packages`, `package_negotiation_events`, `media_campaigns`, `campaign_versions`, `campaign_review_events`, `campaign_deployments`, `third_party_collaborators`, `campaign_collaborators` |
| **Task Spine & Content Operations** | 4 | `tasks`, `task_content_operations`, `task_content_snapshots`, `content_request_completion_jobs` |
| **Subscription Plans & SePay Billing** | 18 | `subscription_plans`, `subscription_plan_changes`, `user_subscriptions`, `transactions`, `billing_plan_versions`, `billing_plan_cycle_prices`, `billing_plan_change_log`, `agency_subscriptions`, `agency_subscription_periods`, `billing_orders`, `billing_payment_attempts`, `billing_payments`, `billing_payment_events`, `billing_order_fulfillments`, `billing_outbox_events`, `billing_audit_events`, `subscription_operational_issues`, `subscription_observation_jobs`, `subscription_provider_checks` *(see exact 97-table DDL)* |
| **AI Credits, Jobs & Product Video** | 16 | `agency_credit_wallets`, `credit_grants`, `workspace_credit_limits`, `credit_usage_periods`, `workspace_credit_usage`, `ai_credit_operation_prices`, `ai_credit_reservations`, `credit_reservation_allocations`, `credit_operations`, `credit_entries`, `ai_caption_generations`, `ai_video_jobs`, `product_video_productions`, `product_video_plans`, `product_video_quotes`, `product_video_attempts`, `product_video_requests` |
| **Material Storage, Drive & Client Vault** | 17 | `system_storage_pools`, `agency_storage_usage`, `agency_storage_reservations`, `storage_usage_entries`, `material_quota_releases`, `material_audit_receipts`, `storage_addon_plans`, `storage_addon_subscriptions`, `client_vault_storage_usage`, `client_vault_quota_releases`, `repository_vault_migration_receipts`, `agency_drive_connections`, `workspace_drive_folders`, `repository_drive_objects`, `repository_drive_states`, `repository_drive_generations`, `repository_drive_operations` |
| **Mail Delivery, Newsletter & Reminders** | 7 | `mail_attachments`, `mail_batches`, `mail_deliveries`, `mail_send_quota`, `mail_suppressions`, `newsletter_usage`, `engagement_reminders` |
| **Admin Governance, Moderation & Notifications** | 9 | `user_strikes`, `sanction_reviews`, `content_moderation_reviews`, `admin_account_operations`, `admin_email_outbox`, `admin_notifications`, `admin_report_exports`, `user_notifications` (`LISTEN/NOTIFY`), `brandhub_schema_migrations` |

### Seeded Subscription Catalog (6 Active Plans)

`init-postgres-v2.sql` and the `2026-11-18` / `2026-11-22` billing migrations maintain two immutable `billing_plan_versions` tracks paid exclusively via **SePay (VietQR)** (`SEEPAY`; plan downgrades are excluded by design — `Upgrade Plan` `3.9.1` only):

- **Personal Studio Track (`agencies.company_type = 'PERSONAL'`, capped at 1 `Owner` user)**: `STUDIO_FREE`, `STUDIO_PLUS`, `STUDIO_PRO`
- **Agency Track (`agencies.company_type = 'AGENCY'`)**: `BASIC` (Free), `PLUS` (`990,000 VND/month` via SePay with 3/6/12-month cycle discounts in `billing_plan_cycle_prices`), `ENTERPRISE` (`3,990,000 VND/month`, `500 GB` storage, sales-assisted activation)

---

## 3. MongoDB 7.0 Collection Groups (52 Collections)

MongoDB stores rich nested content documents, multi-step approval payloads, real-time workspace chat, S3/KMS material metadata, Video Space timelines, and system health telemetry:

| Collection Group | Count | Collections in `init/init-mongo.js` |
| :--- | :---: | :--- |
| **Workspace & Identity Mirrors** | 4 | `users`, `workspaces`, `workspace_members`, `clients` |
| **Content Requests, Tasks & Specialist Sections** | 11 | `content_requests`, `tasks`, `task_approvals`, `task_comments`, `task_comment_uploads`, `task_notification_outbox`, `task_sections`, `task_section_versions`, `task_section_events`, `event_plans`, `press_recommendations` |
| **Social Accounts, Posts & Publishing** | 4 | `social_accounts` *(strictly 4 platforms: `FACEBOOK`, `INSTAGRAM`, `TIKTOK`, `THREADS`)*, `posts`, `post_versions`, `publish_logs` |
| **Workspace Chat, Channels & Calls** | 7 | `chat_channels`, `chat_messages`, `chat_attachments`, `chat_read_states`, `chat_channel_reads`, `chat_notification_preferences`, `chat_calls`, `chat_scheduled_messages` *(8 chat collections total)* |
| **Material Repository, Versioning & Client Vault** | 7 | `materials`, `material_folders`, `material_versions`, `material_upload_sessions`, `material_references`, `material_audit_outbox`, `client_vault_shares` |
| **Video Space & Watermark Presets** | 5 | `video_projects`, `video_project_assets`, `video_project_upload_sessions`, `video_auto_edits`, `watermark_presets` |
| **Surveys, Outbound Mail & Brand Knowledge** | 5 | `surveys`, `survey_responses`, `mail_templates`, `mail_recipient_groups`, `knowledge_documents` |
| **Notifications, Reports, AI Logs & Monitoring** | 8 | `notifications` *(30-day TTL index)*, `report_jobs`, `ai_usage_logs`, `monitoring_servers`, `monitoring_collectors`, `monitoring_enrollments`, `monitoring_health_targets`, `seed_runs` |

---

## 4. pgAdmin 4 Configuration (`init/pgadmin-servers.json`)

When running pgAdmin locally via `docker/compose/shared/pgadmin.yaml` (`http://127.0.0.1:5050`), import [`init/pgadmin-servers.json`](init/pgadmin-servers.json) (**Tools → Import/Export Servers**) or bind-mount it to `/pgadmin4/servers.json` to pre-register the `BrandHub PostgreSQL` server (`postgres:5432`, maintenance DB `brandhub`).

---

## 5. Administrative Maintenance Scripts (`database/scripts/`)

Use the scripts in `database/scripts/` for local container catch-up or dataset trimming without destroying Docker volumes:

### A. In-Place Container Catch-Up (`scripts/patch-update-running-db.sql`)

Applies idempotent `ALTER TABLE ... ADD COLUMN IF NOT EXISTS` and `CREATE TABLE IF NOT EXISTS` statements to an older local `brandhub-postgres` volume (adds `owner_user_id` on `agency_storage_reservations` and `storage_usage_entries`, stamps `inventory_verified_at`, drops retired `public.seed_runs`, and creates the `product_video_*` durable coordinator tables):

```powershell
# PowerShell (from brandhub-infrastructure root)
Get-Content database\scripts\patch-update-running-db.sql | `
  docker exec -i brandhub-postgres psql -v ON_ERROR_STOP=1 -U brandhub -d brandhub
```

### B. Trim Large Demo Snapshots (`scripts/reduce-demo-users.sql`)

Reduces a large restored PostgreSQL dataset down to **30 users** while preserving **5 canonical demo accounts** (`admin@demo.brandhub.test` plus 4 agency/workspace accounts covering `Admin`, `Owner`, `Manager`, `Creator`, and `Client`) along with all linked agencies, workspaces, campaigns, and tasks. Uses `SET LOCAL session_replication_role = replica` and iterative FK cleanup, so it must run as the container superuser:

```bash
docker exec -i brandhub-postgres psql -v ON_ERROR_STOP=1 -U brandhub -d brandhub < database/scripts/reduce-demo-users.sql
```

---

## 6. Backups & Security Guardrails (`database/backups/`)

- One-command local snapshot restoration (`restore-postgres.bat` / `restore-mongodb.bat`) is documented in [`backups/README.md`](backups/README.md).
- **Never commit database dumps**: all `.dump`, `.sql`, `.ejson`, `.bson`, and `.archive*` files inside `database/backups/` are ignored by [`.gitignore`](../.gitignore) and blocked in pre-commit/CI by [`../scripts/security/check_sensitive_paths.py`](../scripts/security/check_sensitive_paths.py).
- Production automated backups (`pg_dump` + `mongodump` → AES-encrypted S3 archive via FastAPI `db-backup` service) are documented in [`../prod/hosts/core/db-backup/README.md`](../prod/hosts/core/db-backup/README.md).
