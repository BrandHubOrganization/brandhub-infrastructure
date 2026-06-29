# DA-E07-01 — Conventions, Summary & Gateway Allowlist

**Sprint:** 3 | **Owner:** Trung (Leader) | **Priority:** 🔴 Critical  
**Blocks:** DA-E07-04, DA-E07-05, DA-E11-04  
**Blocked by:** DA-E04-01, DA-E06-02, DA-E06-03, DA-E06-08

**Index file:** [DA-E07-01_Business_Service_Endpoints.md](../DA-E07-01_Business_Service_Endpoints.md)

---

## Conventions

**Base URL (internal):** `http://business-service:8081`  
**Path prefix:** `/api/v1/{resource}` — must match api-gateway routing rules  
**Auth header format:** Gateway injects headers after JWT validation:

| Header | Type | Description |
|--------|------|-------------|
| `X-User-Id` | UUID string | Extracted from JWT `sub` claim |
| `X-User-Role` | string | One of: `ADMIN`, `AGENCY_OWNER`, `ACCOUNT_MANAGER`, `CONTENT_CREATOR`, `BRAND_CLIENT`, `GUEST` |
| `X-Workspace-Id` | UUID string | Extracted from JWT `workspaceId` claim; absent for ADMIN |

**Notation:**
- `[PUBLIC]` — no JWT required; must be in gateway's no-auth allowlist
- `[JWT]` — JWT required; gateway validates + injects headers above
- `*` in role list = all authenticated roles allowed
- Request/response bodies use JSON unless stated otherwise

**Role hierarchy (high → low):**
```
ADMIN > AGENCY_OWNER > ACCOUNT_MANAGER > CONTENT_CREATOR > BRAND_CLIENT > GUEST
```
`ACCOUNT_MANAGER+` in summary table = AGENCY_OWNER + ACCOUNT_MANAGER  
`CONTENT_CREATOR+` = AGENCY_OWNER + ACCOUNT_MANAGER + CONTENT_CREATOR

**Standard error response:**
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable message",
    "details": {} 
  }
}
```

**Standard paginated response:**
```json
{
  "success": true,
  "data": {
    "items": [],
    "total": 100,
    "page": 1,
    "size": 20
  }
}
```

---

## Endpoint Summary Table

| # | Method | Path | Auth | Roles |
|---|--------|------|------|-------|
| 1 | POST | `/api/v1/auth/register` | PUBLIC | — |
| 2 | POST | `/api/v1/auth/login` | PUBLIC | — |
| 3 | POST | `/api/v1/auth/refresh` | PUBLIC | — |
| 4 | POST | `/api/v1/auth/logout` | PUBLIC | — |
| 5 | POST | `/api/v1/auth/forgot-password` | PUBLIC | — |
| 6 | POST | `/api/v1/auth/reset-password` | PUBLIC | — |
| 7 | GET | `/api/v1/auth/oauth/google` | PUBLIC | — |
| 8 | GET | `/api/v1/auth/oauth/google/callback` | PUBLIC | — |
| 9 | GET | `/api/v1/users/me` | JWT | * |
| 10 | PUT | `/api/v1/users/me` | JWT | * |
| 11 | POST | `/api/v1/users/me/avatar` | JWT | * |
| 12 | GET | `/api/v1/users/me/sessions` | JWT | * |
| 13 | DELETE | `/api/v1/users/me/sessions/{sessionId}` | JWT | * |
| 14 | PUT | `/api/v1/users/me/password` | JWT | * |
| 15 | POST | `/api/v1/workspaces` | JWT | AGENCY_OWNER |
| 16 | GET | `/api/v1/workspaces/mine` | JWT | AGENCY_OWNER, ACCOUNT_MANAGER, CONTENT_CREATOR |
| 17 | PUT | `/api/v1/workspaces/{id}` | JWT | AGENCY_OWNER |
| 18 | GET | `/api/v1/workspaces/{id}/members` | JWT | AGENCY_OWNER, ACCOUNT_MANAGER |
| 19 | POST | `/api/v1/workspaces/{id}/members/invite` | JWT | AGENCY_OWNER |
| 20 | POST | `/api/v1/workspaces/invitations/accept` | PUBLIC | — |
| 21 | DELETE | `/api/v1/workspaces/{id}/members/{userId}` | JWT | AGENCY_OWNER |
| 22 | PUT | `/api/v1/workspaces/{id}/members/{userId}/role` | JWT | AGENCY_OWNER |
| 23 | GET | `/api/v1/workspaces/{id}/members/{userId}/permissions` | JWT | AGENCY_OWNER, self |
| 24 | PUT | `/api/v1/workspaces/{id}/members/{userId}/permissions` | JWT | AGENCY_OWNER |
| 25 | POST | `/api/v1/clients` | JWT | AGENCY_OWNER |
| 26 | GET | `/api/v1/clients` | JWT | AGENCY_OWNER, ACCOUNT_MANAGER |
| 27 | GET | `/api/v1/clients/{id}` | JWT | AGENCY_OWNER, ACCOUNT_MANAGER, BRAND_CLIENT |
| 28 | PUT | `/api/v1/clients/{id}` | JWT | AGENCY_OWNER |
| 29 | DELETE | `/api/v1/clients/{id}` | JWT | AGENCY_OWNER |
| 30 | PUT | `/api/v1/clients/{id}/assign` | JWT | AGENCY_OWNER |
| 31 | PUT | `/api/v1/clients/{id}/service-package` | JWT | AGENCY_OWNER |
| 32 | PUT | `/api/v1/clients/{id}/portal-access` | JWT | AGENCY_OWNER |
| 33 | POST | `/api/v1/posts` | JWT | ACCOUNT_MANAGER, CONTENT_CREATOR |
| 34 | GET | `/api/v1/posts` | JWT | * |
| 35 | GET | `/api/v1/posts/{id}` | JWT | * |
| 36 | PUT | `/api/v1/posts/{id}` | JWT | CONTENT_CREATOR, ACCOUNT_MANAGER |
| 37 | DELETE | `/api/v1/posts/{id}` | JWT | AGENCY_OWNER, ACCOUNT_MANAGER |
| 38 | POST | `/api/v1/posts/{id}/submit` | JWT | CONTENT_CREATOR, ACCOUNT_MANAGER |
| 39 | POST | `/api/v1/posts/{id}/approve` | JWT | AGENCY_OWNER, ACCOUNT_MANAGER |
| 40 | POST | `/api/v1/posts/{id}/reject` | JWT | AGENCY_OWNER, ACCOUNT_MANAGER |
| 41 | POST | `/api/v1/posts/{id}/schedule` | JWT | AGENCY_OWNER, ACCOUNT_MANAGER |
| 42 | POST | `/api/v1/content-requests` | JWT | AGENCY_OWNER, ACCOUNT_MANAGER, BRAND_CLIENT |
| 43 | GET | `/api/v1/content-requests` | JWT | * |
| 44 | GET | `/api/v1/content-requests/{id}` | JWT | * |
| 45 | PUT | `/api/v1/content-requests/{id}/assign` | JWT | AGENCY_OWNER, ACCOUNT_MANAGER |
| 46 | PUT | `/api/v1/content-requests/{id}/status` | JWT | CONTENT_CREATOR, ACCOUNT_MANAGER, AGENCY_OWNER |
| 47 | POST | `/api/v1/content-requests/{id}/comments` | JWT | * |
| 48 | GET | `/api/v1/social/accounts` | JWT | AGENCY_OWNER, ACCOUNT_MANAGER |
| 49 | GET | `/api/v1/social/connect/{platform}` | JWT | AGENCY_OWNER, ACCOUNT_MANAGER |
| 50 | GET | `/api/v1/social/callback/{platform}` | PUBLIC | — |
| 51 | DELETE | `/api/v1/social/accounts/{id}` | JWT | AGENCY_OWNER, ACCOUNT_MANAGER |
| 52 | POST | `/api/v1/social/accounts/{id}/refresh` | JWT | AGENCY_OWNER, ACCOUNT_MANAGER |
| 53 | GET | `/api/v1/analytics/workspace` | JWT | AGENCY_OWNER, ACCOUNT_MANAGER |
| 54 | GET | `/api/v1/analytics/clients/{id}` | JWT | AGENCY_OWNER, ACCOUNT_MANAGER, BRAND_CLIENT |
| 55 | GET | `/api/v1/analytics/ai-usage` | JWT | AGENCY_OWNER |
| 56 | POST | `/api/v1/reports` | JWT | AGENCY_OWNER, ACCOUNT_MANAGER |
| 57 | GET | `/api/v1/reports/{jobId}` | JWT | AGENCY_OWNER, ACCOUNT_MANAGER, BRAND_CLIENT |
| 58 | GET | `/api/v1/reports` | JWT | AGENCY_OWNER, ACCOUNT_MANAGER |
| 59 | GET | `/api/v1/subscriptions/plans` | PUBLIC | — |
| 60 | GET | `/api/v1/subscriptions/current` | JWT | AGENCY_OWNER |
| 61 | POST | `/api/v1/subscriptions/subscribe` | JWT | AGENCY_OWNER |
| 62 | POST | `/api/v1/subscriptions/webhook` | PUBLIC | — |
| 63 | POST | `/api/v1/subscriptions/cancel` | JWT | AGENCY_OWNER |
| 64 | GET | `/api/v1/subscriptions/invoices` | JWT | AGENCY_OWNER |
| 65 | GET | `/api/v1/admin/users` | JWT | ADMIN |
| 66 | PUT | `/api/v1/admin/users/{id}/status` | JWT | ADMIN |
| 67 | GET | `/api/v1/admin/workspaces` | JWT | ADMIN |
| 68 | GET | `/api/v1/admin/stats` | JWT | ADMIN |
| 69 | POST | `/api/v1/admin/subscription-plans` | JWT | ADMIN |
| 70 | PUT | `/api/v1/admin/subscription-plans/{id}` | JWT | ADMIN |

**Total: 70 endpoints** — 12 PUBLIC, 58 JWT-protected

---

## Gateway Allowlist (no-JWT routes)

Cấu hình trong api-gateway — các path sau **bypass JWT validation:**

```
POST  /api/v1/auth/register
POST  /api/v1/auth/login
POST  /api/v1/auth/refresh
POST  /api/v1/auth/logout
POST  /api/v1/auth/forgot-password
POST  /api/v1/auth/reset-password
GET   /api/v1/auth/oauth/google
GET   /api/v1/auth/oauth/google/callback
POST  /api/v1/workspaces/invitations/accept
GET   /api/v1/social/callback/**
GET   /api/v1/subscriptions/plans
POST  /api/v1/subscriptions/webhook
```

> **Security note:** `POST /api/v1/auth/logout` is PUBLIC because the access token may already be expired when the user logs out. The service reads the `refreshToken` cookie directly to identify and revoke the session. Stripe webhook is PUBLIC but validated via `Stripe-Signature` header — never trust payload without signature check.
