# DA-D12-03 — [R3 §3.1.3] ERD Entity Descriptions

> **Task:** Entity Descriptions table for ERD. Embed ERD figure.
> **Owner:** Trung | **Priority:** 🟡 Medium
> **Depends on:** DA-D02-02 (ERD diagram)
> **Source ERD:** [`brandhub_erd.puml`](./brandhub_erd.puml) · [`brandhub_dbml.dbml`](./brandhub_dbml.dbml) · [`brandhub_schema_diagram.html`](./brandhub_schema_diagram.html)

---

## 1. ERD Figure

> Figure DA-D02-02. Render `brandhub_erd.puml` (PlantUML) or open `brandhub_schema_diagram.html` for the interactive schema diagram.

---

## 2. Entity Descriptions

BrandHub's ERD contains **23 entities**: **15 PostgreSQL** tables (financial, identity, workspace data requiring ACID/FK integrity) and **8 MongoDB** collections (content, operational, high-write data). See [`Database_Strategy.md`](./Database_Strategy.md) for the storage-split rationale.

### 2.1 PostgreSQL — Identity Group (5 tables)

| # | Entity | Description |
|---|---|---|
| 1 | `users` | Core user account: credentials, profile, status, preferences. Anchor for all identity FKs. |
| 2 | `user_oauth_providers` | Links a user to external OAuth identities (Google, Facebook, etc.), one row per provider. |
| 3 | `user_refresh_tokens` | Active refresh tokens per device/session, used to rotate JWT access tokens. |
| 4 | `user_system_roles` | System-level role (`ADMIN`/`USER`) per user, separate from workspace-level roles. |
| 5 | `password_reset_tokens` | Single-use tokens for the forgot-password flow; permanent audit trail (Redis holds runtime TTL). |

### 2.2 PostgreSQL — Workspace Group (5 tables)

| # | Entity | Description |
|---|---|---|
| 6 | `workspaces` | Tenant root entity — every workspace-scoped resource traces back to this table via FK or soft ref. |
| 7 | `workspace_members` | Join table between `users` and `workspaces` with a role (`OWNER`/`MANAGER`/`MEMBER`, etc.). |
| 8 | `workspace_invitations` | Pending/accepted/expired invitations to join a workspace by email. |
| 9 | `workspace_member_permissions` | Per-member permission overrides (explicit allow/deny) on top of the base role. |
| 10 | `clients` | Brand/client managed by an agency workspace; carries service package and portal access flag. |

### 2.3 PostgreSQL — Billing Group (5 tables)

| # | Entity | Description |
|---|---|---|
| 11 | `subscription_plans` | Catalog of pricing plans (FREE/PRO/ENTERPRISE) with quota limits and feature flags. |
| 12 | `workspace_subscriptions` | Active subscription per workspace — current plan, billing period, status. |
| 13 | `invoices` | Billing invoice per period; immutable once issued. |
| 14 | `payments` | Payment transactions against an invoice; unique `transaction_id` prevents double-charge. |
| 15 | `audit_logs` | Append-only log of sensitive actions across the system, for compliance. |

### 2.4 MongoDB Collections (8 collections)

| # | Entity | Description |
|---|---|---|
| 16 | `social_accounts` | Connected social platform accounts per workspace/client, with AES-256-GCM encrypted tokens. |
| 17 | `posts` | Social media post content, scheduling, publish status, and inline approval history. |
| 18 | `content_requests` | Client/agency content briefs — title, tone, deadline, status — linked to a resulting post. |
| 19 | `knowledge_documents` | Raw text documents used to build the RAG knowledge base (ai-service); chunk IDs point into ChromaDB. |
| 20 | `notifications` | In-app notifications per user, TTL-expired after 30 days. |
| 21 | `publish_logs` | Append-only publish attempt log per post/platform, with retry tracking (publisher-service). |
| 22 | `ai_usage_logs` | Per-request AI usage/cost/latency log by feature and model (ai-service). |
| 23 | `report_jobs` | Async analytics report generation jobs — date range, status, output file URL. |

---

## 3. Relationship Notes

Full FK relationship diagram lives in [`brandhub_erd.puml`](./brandhub_erd.puml). Summary:

- **Identity chain**: `users` radiates FKs to `user_oauth_providers`, `user_refresh_tokens`, `user_system_roles`, `password_reset_tokens`.
- **Workspace hub**: `workspaces` is the anchor for `workspace_members`, `workspace_invitations`, `clients`, `workspace_subscriptions`, `invoices`, `payments` — all via real FK.
- **Billing chain**: `workspace_subscriptions → subscription_plans`, `invoices → workspace_subscriptions`, `payments → invoices`.
- **MongoDB collections** use **soft references** (string IDs, no DB-enforced FK) back to PostgreSQL `workspaceId`/`clientId`/`userId` — consistent with the multi-database strategy where cross-database referential integrity is enforced at the application layer, not the database layer.

::: warning Note on Jira task description
DA-D12-03's original description states "~17 entities (12 MongoDB + 5 PostgreSQL)". The current ERD (`brandhub_erd.puml`) contains **23 entities (15 PostgreSQL + 8 MongoDB)** — this document reflects the up-to-date schema, not the original estimate.
:::
