# Database Migrations Manual (`database/migrations/`)

Authoritative runbook and complete chronological inventory for incremental **PostgreSQL 17**, **MongoDB 7.0 / Atlas**, and **Neo4j 5.26 / Aura** migrations in BrandHub.

- Back to [Operational Database Manual](../README.md) · [Infrastructure Hub](../../README.md)
- Conceptual schema design & entity dictionary: [`../../docs/database/README.md`](../../docs/database/README.md)
- MongoDB container & Atlas `mongosh` CLI reference: [`../../docker/README.md`](../../docker/README.md)
- Fresh empty volumes execute [`../init/init-postgres-v2.sql`](../init/init-postgres-v2.sql) and [`../init/init-mongo.js`](../init/init-mongo.js) automatically instead of incremental migrations.

---

## 1. Migration Naming, Idempotency & Safety Contract

All migration files follow the date-prefixed convention `YYYY-MM-DD-<slug>.<ext>`:

| Directory | Engine | Count | File Extensions | Safety & Idempotency Mechanism |
| :--- | :--- | :---: | :--- | :--- |
| `postgres/` | PostgreSQL 17 | **25** | `.sql` | Transactional `BEGIN ... COMMIT`, `lock_timeout = '5s'`, `IF NOT EXISTS`, `ON CONFLICT DO NOTHING`, immutable plan version cloning (`billing_guard_plan_version`), and tracking in `public.brandhub_schema_migrations` |
| `mongodb/` | MongoDB 7.0 / Atlas | **8** | `.js`, `.mongosh.js` | Additive `$jsonSchema` `collMod` merges and idempotent `createIndex()` calls; **7 of 8 scripts default to dry-run (`false`)** unless an explicit `globalThis.*_APPLY = true` flag is set |
| `neo4j/` | Neo4j 5.26 / Aura | **1** | `.cypher` | `CREATE INDEX ... IF NOT EXISTS` (also enforced at startup by `Neo4jTrendService.ensure_schema()` in `brandhub-ai-service`) |

---

## 2. CLI Execution Commands

### PostgreSQL (`psql`)

Execute scripts in chronological order (observing the **two same-day dependency overrides** in Section 3):

```bash
# Local Docker container
docker exec -i brandhub-postgres psql -X -v ON_ERROR_STOP=1 -U brandhub -d brandhub \
  < database/migrations/postgres/<YYYY-MM-DD-slug>.sql

# Remote / Production PostgreSQL
psql "$POSTGRES_URL" -X -v ON_ERROR_STOP=1 -f database/migrations/postgres/<YYYY-MM-DD-slug>.sql
```

### MongoDB (`mongosh`)

Most MongoDB migration scripts default to **read-only dry-run mode** so you can inspect validator diffs before mutating a live cluster. Pass `--eval "globalThis.<FLAG> = true;"` before `--file` when applying:

```bash
# Dry-run preview (default)
mongosh "$MONGODB_URI" --file database/migrations/mongodb/2026-11-23-task-finished-at.js

# Apply mode
mongosh "$MONGODB_URI" \
  --eval "use('brandhub'); globalThis.TASK_FINISHED_AT_APPLY = true;" \
  --file database/migrations/mongodb/2026-11-23-task-finished-at.js
```

### Neo4j (`cypher-shell`)

```bash
cypher-shell -u neo4j -p "$NEO4J_PASSWORD" \
  -f database/migrations/neo4j/2026-11-01-workspace-trend-indexes.cypher
```

---

## 3. PostgreSQL Same-Day Dependency Order Overrides

Alphabetical filename sorting is **unsafe** on `2026-11-18` and `2026-11-22` because sibling migrations depend on newly inserted immutable `billing_plan_versions` rows or newly added `agencies.company_type` constraints. Always apply those dates in the exact order below:

### `2026-11-18` Agency Billing & Prepaid Cycles Order

1. [`postgres/2026-11-18-agency-subscription-entitlements.sql`](postgres/2026-11-18-agency-subscription-entitlements.sql) — Synchronizes `BASIC`, `PLUS`, and `ENTERPRISE` quotas, retention windows, and feature flags.
2. [`postgres/2026-11-18-agency-plan-prices.sql`](postgres/2026-11-18-agency-plan-prices.sql) — Publishes immutable `PLUS` (`990,000 VND/mo` via SePay) and `ENTERPRISE` (`3,990,000 VND/mo`) plan versions.
3. [`postgres/2026-11-18-agency-billing-cycles.sql`](postgres/2026-11-18-agency-billing-cycles.sql) — Creates `billing_plan_cycle_prices` and binds 3-, 6-, and 12-month prepaid discounts to the latest plan versions from step 2.

### `2026-11-22` Personal Studio & Admin Plan Editor Order

1. [`postgres/2026-11-22-agency-company-type.sql`](postgres/2026-11-22-agency-company-type.sql) — Adds `agencies.company_type` (`'AGENCY' | 'PERSONAL'`) with check constraint and personal studio backfill.
2. [`postgres/2026-11-22-personal-remove-extra-members.sql`](postgres/2026-11-22-personal-remove-extra-members.sql) — Archives non-`Owner` rows into `personal_extra_members_backup_20261122` and enforces the 1-user cap on `PERSONAL` companies (*requires step 1*).
3. [`postgres/2026-11-22-studio-plans.sql`](postgres/2026-11-22-studio-plans.sql) — Seeds `STUDIO_FREE`, `STUDIO_PLUS`, `STUDIO_PRO`, migrates free `PERSONAL` companies to `STUDIO_FREE`, and upgrades `ENTERPRISE` storage to `500 GB` (*requires step 1*).
4. [`postgres/2026-11-22-studio-single-user.sql`](postgres/2026-11-22-studio-single-user.sql) — Publishes a new immutable `STUDIO_PRO` version capping internal members from `3` to `1` (*requires step 3*).
5. [`postgres/2026-11-22-plus-display-name.sql`](postgres/2026-11-22-plus-display-name.sql) — Publishes a new Agency `PLUS` version renaming `"Plus / Pro"` to `"Plus"` (*requires step 3*).
6. [`postgres/2026-11-22-admin-plan-editor.sql`](postgres/2026-11-22-admin-plan-editor.sql) — Creates `billing_plan_change_log` for `Admin` plan catalog edits.

---

## 4. Complete PostgreSQL Migration Inventory (25 Scripts)

| # | Date | Script | Schema Changes & Business Purpose |
| :---: | :---: | :--- | :--- |
| 1 | `2026-10-29` | [`postgres/2026-10-29-client-report-email.sql`](postgres/2026-10-29-client-report-email.sql) | Scheduled `Client` PDF report email outbox reference (`CLIENT_REPORT:<ws>:<from>:<to>`) and workspace schedule columns |
| 2 | `2026-10-30` | [`postgres/2026-10-30-drop-legacy-monitoring-billing-storage.sql`](postgres/2026-10-30-drop-legacy-monitoring-billing-storage.sql) | Drops retired PostgreSQL monitoring tables (migrated to MongoDB `monitoring_*`) and legacy billing/storage columns |
| 3 | `2026-10-30` | [`postgres/2026-10-30-drop-seed-runs.sql`](postgres/2026-10-30-drop-seed-runs.sql) | Drops retired `public.seed_runs` demo marker table |
| 4 | `2026-10-30` | [`postgres/2026-10-30-product-video-pipeline.sql`](postgres/2026-10-30-product-video-pipeline.sql) | Creates `product_video_productions`, `product_video_plans`, `product_video_quotes`, `product_video_attempts`, `product_video_requests` |
| 5 | `2026-11-04` | [`postgres/2026-11-04-media-package-workspace-scope.sql`](postgres/2026-11-04-media-package-workspace-scope.sql) | Adds `media_packages.custom_workspace_id` FK (`ON DELETE RESTRICT`) for workspace-scoped packages |
| 6 | `2026-11-04` | [`postgres/2026-11-04-repository-storage-addons-client-vault.sql`](postgres/2026-11-04-repository-storage-addons-client-vault.sql) | Creates `storage_addon_plans`, `storage_addon_subscriptions`, `client_vault_storage_usage`, `client_vault_quota_releases`, `repository_vault_migration_receipts` |
| 7 | `2026-11-06` | [`postgres/2026-11-06-manager-led-package-sharing.sql`](postgres/2026-11-06-manager-led-package-sharing.sql) | Adds `Manager`-led workspace media package preparation and controlled `Guest` share token columns |
| 8 | `2026-11-09` | [`postgres/2026-11-09-video-space-runtime-foundation.sql`](postgres/2026-11-09-video-space-runtime-foundation.sql) | Expands storage reservation & repository metadata prerequisites for Video Space assets and auto-edits |
| 9 | `2026-11-10` | [`postgres/2026-11-10-newsletter.sql`](postgres/2026-11-10-newsletter.sql) | Creates `newsletter_usage` and outbound mail dispatch linkages for Newsletter tasks |
| 10 | `2026-11-11` | [`postgres/2026-11-11-mobile-google-oauth-link.sql`](postgres/2026-11-11-mobile-google-oauth-link.sql) | Enforces unique `(user_id, provider)` index on `user_oauth_providers` for mobile Google OAuth linking |
| 11 | `2026-11-12` | [`postgres/2026-11-12-campaign-brief-and-partners.sql`](postgres/2026-11-12-campaign-brief-and-partners.sql) | Adds `strategy_detail` brief columns on `media_campaigns` and partner/collaborator linkage fields |
| 12 | `2026-11-16` | [`postgres/2026-11-16-collaborator-kol-type.sql`](postgres/2026-11-16-collaborator-kol-type.sql) | Appends `'KOL'` to `collaborator_type` enum (`FR 3.7.19` Recommend Collaborator) |
| 13 | `2026-11-18` | [`postgres/2026-11-18-agency-subscription-entitlements.sql`](postgres/2026-11-18-agency-subscription-entitlements.sql) | *(1/3)* Synchronizes `BASIC`, `PLUS`, `ENTERPRISE` quotas, AI credit allowances, and feature flags |
| 14 | `2026-11-18` | [`postgres/2026-11-18-agency-plan-prices.sql`](postgres/2026-11-18-agency-plan-prices.sql) | *(2/3)* Publishes immutable SePay pricing for `PLUS` (`990,000 VND/mo`) and `ENTERPRISE` (`3,990,000 VND/mo`) |
| 15 | `2026-11-18` | [`postgres/2026-11-18-agency-billing-cycles.sql`](postgres/2026-11-18-agency-billing-cycles.sql) | *(3/3)* Creates `billing_plan_cycle_prices` for 3-, 6-, and 12-month prepaid Agency cycles |
| 16 | `2026-11-19` | [`postgres/2026-11-19-workspace-post-templates.sql`](postgres/2026-11-19-workspace-post-templates.sql) | Creates `workspace_post_templates` (`PostTemplate` entity) and seeds workspace template catalog |
| 17 | `2026-11-21` | [`postgres/2026-11-21-engagement-reminders.sql`](postgres/2026-11-21-engagement-reminders.sql) | Creates `engagement_reminders` (`kind`, `recipient`, `subject`, `sent_count` CAS) for hourly `EngagementReminderJob` |
| 18 | `2026-11-21` | [`postgres/2026-11-21-user-notification-realtime.sql`](postgres/2026-11-21-user-notification-realtime.sql) | Adds PostgreSQL `AFTER INSERT` trigger emitting `NOTIFY user_notification` for STOMP `/user/queue/notifications` |
| 19 | `2026-11-22` | [`postgres/2026-11-22-agency-company-type.sql`](postgres/2026-11-22-agency-company-type.sql) | *(1/6)* Adds `agencies.company_type` (`AGENCY` \| `PERSONAL`) |
| 20 | `2026-11-22` | [`postgres/2026-11-22-personal-remove-extra-members.sql`](postgres/2026-11-22-personal-remove-extra-members.sql) | *(2/6)* Backs up and removes non-`Owner` members from `PERSONAL` studios |
| 21 | `2026-11-22` | [`postgres/2026-11-22-studio-plans.sql`](postgres/2026-11-22-studio-plans.sql) | *(3/6)* Seeds `STUDIO_FREE`, `STUDIO_PLUS`, `STUDIO_PRO` and sets `ENTERPRISE` storage to `500 GB` |
| 22 | `2026-11-22` | [`postgres/2026-11-22-studio-single-user.sql`](postgres/2026-11-22-studio-single-user.sql) | *(4/6)* Caps `STUDIO_PRO` internal members to `1` |
| 23 | `2026-11-22` | [`postgres/2026-11-22-plus-display-name.sql`](postgres/2026-11-22-plus-display-name.sql) | *(5/6)* Updates Agency `PLUS` display name from `"Plus / Pro"` to `"Plus"` |
| 24 | `2026-11-22` | [`postgres/2026-11-22-admin-plan-editor.sql`](postgres/2026-11-22-admin-plan-editor.sql) | *(6/6)* Creates `billing_plan_change_log` audit table for `Admin` plan catalog edits |
| 25 | `2026-11-23` | [`postgres/2026-11-23-studio-default-name.sql`](postgres/2026-11-23-studio-default-name.sql) | Normalizes untouched auto-generated `"Personal Studio — <name>"` labels to `"Studio — <name>"` |

---

## 5. Complete MongoDB Migration Inventory (8 Scripts)

| # | Date | Script | Apply Guard Flag (`globalThis.*`) | Collections & Validator / Index Changes |
| :---: | :---: | :--- | :--- | :--- |
| 1 | `2026-10-29` | [`mongodb/2026-10-29-video-projects-indexes.js`](mongodb/2026-10-29-video-projects-indexes.js) | `VIDEO_PROJECT_INDEXES_APPLY` | Creates lookup & lease indexes on `video_projects`, `video_project_assets`, `video_project_upload_sessions`, `video_auto_edits` |
| 2 | `2026-11-04` | [`mongodb/2026-11-04-repository-folder-version-vault-indexes.mongosh.js`](mongodb/2026-11-04-repository-folder-version-vault-indexes.mongosh.js) | *(Direct idempotent `createIndex`)* | Adds unique & ancestor indexes on `material_upload_sessions`, `material_folders`, `material_versions`, `client_vault_shares`, `materials` |
| 3 | `2026-11-07` | [`mongodb/2026-11-07-campaign-timeline.js`](mongodb/2026-11-07-campaign-timeline.js) | `TASK_TIMELINE_APPLY` | Extends `tasks` `$jsonSchema` validator with optional campaign timeline planned start/due dates |
| 4 | `2026-11-08` | [`mongodb/2026-11-08-chat-attachments.js`](mongodb/2026-11-08-chat-attachments.js) | `CHAT_ATTACHMENTS_APPLY` | Creates `chat_attachments` with `$jsonSchema`, extends `chat_messages` / `chat_scheduled_messages` for `attachmentIds`, and indexes `material_references` |
| 5 | `2026-11-10` | [`mongodb/2026-11-10-subtask-role-sections.js`](mongodb/2026-11-10-subtask-role-sections.js) | `SUBTASK_SECTIONS_APPLY` | Extends `tasks` validator with specialist task types & `subtasks[].subtaskRole` (`Manager`, `Creator`, `Client`); creates `task_sections`, `task_section_versions`, `task_section_events` |
| 6 | `2026-11-12` | [`mongodb/2026-11-12-task-partner-contacts.js`](mongodb/2026-11-12-task-partner-contacts.js) | `TASK_PARTNERS_APPLY` | Adds `partnerIds[]` and subtask acceptance criteria to `tasks` validator + `idx_tasks_partner_ids` partial index |
| 7 | `2026-11-21` | [`mongodb/2026-11-21-engagement-mail-templates.mongosh.js`](mongodb/2026-11-21-engagement-mail-templates.mongosh.js) | `ENGAGEMENT_TEMPLATES_APPLY` | Seeds `Admin`-editable M1–M5 engagement reminder templates into `mail_templates` |
| 8 | `2026-11-23` | [`mongodb/2026-11-23-task-finished-at.js`](mongodb/2026-11-23-task-finished-at.js) | `TASK_FINISHED_AT_APPLY` | Backfills `tasks.finishedAt` on completed tasks and builds `idx_tasks_workspace_finished_at` for role-based dashboards |

---

## 6. Complete Neo4j Migration Inventory (1 Script)

| # | Date | Script | Graph Node & Index Definitions |
| :---: | :---: | :--- | :--- |
| 1 | `2026-11-01` | [`neo4j/2026-11-01-workspace-trend-indexes.cypher`](neo4j/2026-11-01-workspace-trend-indexes.cypher) | Creates `IF NOT EXISTS` composite indexes `trend_date_id_idx`, `trend_date_score_id_idx`, and `trend_normalized_date_idx` on `:Trend` nodes for workspace trend history & Graph Virality Score queries |
