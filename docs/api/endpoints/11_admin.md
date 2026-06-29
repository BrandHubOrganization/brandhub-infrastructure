# DA-E07-01 — Admin Endpoints

**Group:** Admin | **Base path:** `/api/v1/admin`  
**Auth policy:** All endpoints `[JWT]` | **Roles:** `ADMIN` only

**Index:** [00_conventions.md](00_conventions.md) | [← Back to main](../DA-E07-01_Business_Service_Endpoints.md)

---

## Endpoints in this group

| # | Method | Path | Goal |
|---|--------|------|------|
| 65 | GET | `/api/v1/admin/users` | List all users system-wide |
| 66 | PUT | `/api/v1/admin/users/{userId}/status` | Suspend/activate a user |
| 67 | GET | `/api/v1/admin/workspaces` | List all workspaces system-wide |
| 68 | GET | `/api/v1/admin/stats` | System-wide aggregate dashboard |
| 69 | POST | `/api/v1/admin/subscription-plans` | Create subscription plan |
| 70 | PUT | `/api/v1/admin/subscription-plans/{planId}` | Update subscription plan |

> **ADMIN role characteristics:**
> - `X-Workspace-Id` header is **absent** for ADMIN (not scoped to any workspace)
> - ADMIN users are created manually — no self-registration path for ADMIN
> - Gateway enforces: any request to `/api/v1/admin/**` must have `X-User-Role = ADMIN`

---

## GET /api/v1/admin/users

**Auth:** `[JWT]` | **Roles:** `ADMIN`  
**Goal:** List all users in the system with filters.

**Query params:**
- `page` (default 1)
- `size` (default 20, max 100)
- `status` (optional — `ACTIVE | SUSPENDED`)
- `search` (optional — substring match on `email` OR `full_name`)
- `role` (optional — filter by `system_roles.role_name`)

**Response 200:**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "uuid",
        "email": "string",
        "fullName": "string",
        "status": "ACTIVE | SUSPENDED",
        "role": "string",
        "workspaceId": "uuid | null",
        "workspaceName": "string | null",
        "createdAt": "ISO8601",
        "lastLoginAt": "ISO8601 | null"
      }
    ],
    "total": "number",
    "page": "number",
    "size": "number"
  }
}
```

**Implementation notes:**
- Join `users` with `workspace_members` (to get workspaceId) and `workspaces`
- No workspace scoping — ADMIN sees all users across all workspaces
- `search` uses `ILIKE '%term%'` on both `email` and `full_name` (PG)

---

## PUT /api/v1/admin/users/{userId}/status

**Auth:** `[JWT]` | **Roles:** `ADMIN`  
**Goal:** Suspend or reactivate a user account system-wide.

**Request body:**
```json
{
  "status": "ACTIVE | SUSPENDED (required)",
  "reason": "string (optional — reason for audit log)"
}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "userId": "uuid",
    "status": "string",
    "updatedAt": "ISO8601"
  }
}
```

**Errors:**
- `404 USER_NOT_FOUND`
- `400 CANNOT_SUSPEND_ADMIN` — cannot suspend another ADMIN account
- `400 STATUS_UNCHANGED` — user already has the requested status

**Implementation notes:**
- Update `users.status` field
- On SUSPEND:
  1. Revoke all active refresh tokens for the user (set `revoked_at = now()` in `user_refresh_tokens`)
  2. Add access tokens to Redis blacklist (best-effort for currently active tokens)
  3. Suspended users get `403 ACCOUNT_SUSPENDED` on next login attempt
- Log action to audit system: `{ adminId, userId, action: "STATUS_CHANGE", oldStatus, newStatus, reason, at }`

---

## GET /api/v1/admin/workspaces

**Auth:** `[JWT]` | **Roles:** `ADMIN`  
**Goal:** List all workspaces system-wide.

**Query params:**
- `page` (default 1)
- `size` (default 20, max 100)
- `isActive` (optional boolean)
- `plan` (optional — `FREE | BASIC | PRO | ENTERPRISE`)
- `search` (optional — substring match on workspace `name` or `slug`)

**Response 200:**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "uuid",
        "name": "string",
        "slug": "string",
        "ownerId": "uuid",
        "ownerEmail": "string",
        "memberCount": "number",
        "clientCount": "number",
        "subscriptionPlan": "FREE | BASIC | PRO | ENTERPRISE",
        "subscriptionStatus": "ACTIVE | TRIALING | EXPIRED | CANCELLED",
        "isActive": "boolean",
        "createdAt": "ISO8601"
      }
    ],
    "total": "number",
    "page": "number",
    "size": "number"
  }
}
```

**Implementation notes:**
- Join `workspaces`, `users` (owner), `workspace_subscriptions`, `subscription_plans`
- `memberCount`: count of active `workspace_members` rows
- `clientCount`: count of active `clients` rows

---

## GET /api/v1/admin/stats

**Auth:** `[JWT]` | **Roles:** `ADMIN`  
**Goal:** System-wide aggregate statistics for the admin dashboard.

**Response 200:**
```json
{
  "success": true,
  "data": {
    "users": {
      "total": "number",
      "active": "number",
      "suspended": "number",
      "newThisMonth": "number"
    },
    "workspaces": {
      "total": "number",
      "active": "number"
    },
    "subscriptions": {
      "total": "number",
      "byPlan": {
        "FREE": "number",
        "BASIC": "number",
        "PRO": "number",
        "ENTERPRISE": "number"
      },
      "activeTrials": "number"
    },
    "revenue": {
      "thisMonth": "number (VND — sum of PAID invoices in current calendar month)",
      "lastMonth": "number (VND)"
    },
    "posts": {
      "publishedThisMonth": "number",
      "totalAllTime": "number"
    }
  }
}
```

**Implementation notes:**
- Aggregate queries across `users`, `workspaces`, `workspace_subscriptions`, `invoices` (all PG)
- `posts.publishedThisMonth`: MongoDB aggregation (cross-DB call from business-service)
- Cache in Redis (TTL 5 min) — stats don't need to be real-time for admin dashboard
- `revenue.thisMonth`: SUM of `invoices.amount` WHERE `status = PAID` AND `paid_at` in current month

---

## POST /api/v1/admin/subscription-plans

**Auth:** `[JWT]` | **Roles:** `ADMIN`  
**Goal:** Create a new subscription plan available for workspaces to subscribe to.

**Request body:**
```json
{
  "name": "FREE | BASIC | PRO | ENTERPRISE (required — must be unique)",
  "displayName": "string (required)",
  "priceMonthly": "number (required, 0 for FREE, in VND)",
  "priceYearly": "number (required, 0 for FREE, in VND)",
  "maxMembers": "number (required, -1 = unlimited)",
  "maxClients": "number (required, -1 = unlimited)",
  "maxPostsMonth": "number (required, -1 = unlimited)",
  "aiCreditsMonth": "number (required)",
  "features": ["string (feature description strings for pricing page display)"],
  "isActive": "boolean (optional, default true)",
  "stripeProductId": "string (optional — Stripe product ID for billing)"
}
```

**Response 201:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "string",
    "displayName": "string",
    "priceMonthly": "number",
    "priceYearly": "number",
    "isActive": "boolean",
    "createdAt": "ISO8601"
  }
}
```

**Errors:**
- `409 PLAN_NAME_EXISTS` — a plan with this `name` already exists
- `400 VALIDATION_ERROR` — negative price, or priceYearly > priceMonthly × 12

**Implementation notes:**
- Insert into `subscription_plans` PG table
- Invalidate the Redis cache for `GET /api/v1/subscriptions/plans`

---

## PUT /api/v1/admin/subscription-plans/{planId}

**Auth:** `[JWT]` | **Roles:** `ADMIN`  
**Goal:** Update subscription plan details. Partial update — only provided fields changed.

**Request body (all optional):**
```json
{
  "displayName": "string",
  "priceMonthly": "number",
  "priceYearly": "number",
  "maxMembers": "number",
  "maxClients": "number",
  "maxPostsMonth": "number",
  "aiCreditsMonth": "number",
  "features": ["string"],
  "isActive": "boolean",
  "stripeProductId": "string"
}
```

**Response 200:**
```json
{
  "success": true,
  "data": { /* full updated plan object */ }
}
```

**Errors:**
- `404 PLAN_NOT_FOUND`
- `400 VALIDATION_ERROR`
- `400 CANNOT_CHANGE_PLAN_NAME` — `name` (FREE/BASIC/PRO/ENTERPRISE) is immutable after creation

**Implementation notes:**
- Changing limits on an active plan does NOT retroactively enforce limits on existing subscriptions — enforcement takes effect at next billing cycle or on next workspace action
- Invalidate Redis cache for plans list
- Setting `isActive = false` hides the plan from `GET /subscriptions/plans` but does NOT cancel existing subscriptions on that plan
