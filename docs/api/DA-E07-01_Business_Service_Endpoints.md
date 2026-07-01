# DA-E07-01 — Business Service Endpoint Inventory

**Sprint:** 3 | **Owner:** Trung (Leader) | **Priority:** 🔴 Critical  
**Blocks:** DA-E07-04, DA-E07-05, DA-E11-04  
**Blocked by:** DA-E04-01, DA-E06-02, DA-E06-03, DA-E06-08

> **This is the index file.** Each endpoint group is documented in a separate file under [`endpoints/`](endpoints/).

---

## Quick Reference

| File | Group | Endpoints | PUBLIC |
|------|-------|-----------|--------|
| [00_conventions.md](endpoints/00_conventions.md) | Conventions + Summary Table + Gateway Allowlist | — | — |
| [01_auth.md](endpoints/01_auth.md) | Auth `/api/v1/auth` | 8 | 8 |
| [02_user.md](endpoints/02_user.md) | User `/api/v1/users` | 6 | 0 |
| [03_workspace.md](endpoints/03_workspace.md) | Workspace `/api/v1/workspaces` | 10 | 1 |
| [04_client.md](endpoints/04_client.md) | Client `/api/v1/clients` | 8 | 0 |
| [05_post.md](endpoints/05_post.md) | Post `/api/v1/posts` | 9 | 0 |
| [06_content_request.md](endpoints/06_content_request.md) | Content Request `/api/v1/content-requests` | 6 | 0 |
| [07_social_account.md](endpoints/07_social_account.md) | Social Account `/api/v1/social` | 5 | 1 |
| [08_analytics.md](endpoints/08_analytics.md) | Analytics `/api/v1/analytics` | 3 | 0 |
| [09_report.md](endpoints/09_report.md) | Report `/api/v1/reports` | 3 | 0 |
| [10_subscription.md](endpoints/10_subscription.md) | Subscription `/api/v1/subscriptions` | 6 | 2 |
| [11_admin.md](endpoints/11_admin.md) | Admin `/api/v1/admin` | 6 | 0 |
| **Total** | | **70** | **12** |

---

## Architecture Notes

**Base URL (internal):** `http://business-service:8081`  
**Gateway auth:** Access token RS256 JWT (15 min) + Refresh token HttpOnly cookie (30 day)  
**Gateway injects:** `X-User-Id`, `X-User-Role`, `X-Workspace-Id` — services trust these headers

**Storage split:**
- PostgreSQL: users, workspaces, members, clients, subscriptions, invoices, payments, auth tables
- MongoDB: posts, content_requests, social_accounts, notifications, publish_logs, ai_usage_logs, report_jobs, knowledge_documents

**Key flows:**
- Post lifecycle: DRAFT → PENDING_APPROVAL → APPROVED → SCHEDULED → PUBLISHING → PUBLISHED/FAILED
- Content request lifecycle: SUBMITTED → ASSIGNED → IN_PROGRESS → PENDING_REVIEW → SENT_TO_CLIENT → APPROVED/REJECTED
- Payment: subscribe → Stripe PaymentIntent → frontend confirms → webhook → activate subscription
- Social OAuth: GET /connect → platform consent → GET /callback (PUBLIC) → encrypt token → store in MongoDB

---

## Errata (corrections from original draft)

| # | Issue | Fix |
|---|-------|-----|
| 42 | `POST /content-requests` summary table listed `ACCOUNT_MANAGER+` — missing `BRAND_CLIENT` | Fixed in [00_conventions.md](endpoints/00_conventions.md) |
| 54 | `GET /analytics/clients/{id}` summary table missing `BRAND_CLIENT` | Fixed |
| 57 | `GET /reports/{jobId}` summary table missing `BRAND_CLIENT` | Fixed |
| 37 | `DELETE /posts/{id}` summary table `ACCOUNT_MANAGER+` implied CONTENT_CREATOR — incorrect | Fixed to `AGENCY_OWNER, ACCOUNT_MANAGER` |
| 23 | `GET /workspaces/.../permissions` — self-read not documented | Added `self` access in [03_workspace.md](endpoints/03_workspace.md) |
| 49 | `GET /social/connect/{platform}` — missing error for invalid platform | Added `400 UNSUPPORTED_PLATFORM` in [07_social_account.md](endpoints/07_social_account.md) |
