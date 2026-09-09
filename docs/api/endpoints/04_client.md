# DA-E07-01 — Client Endpoints

**Group:** Client | **Base path:** `/api/v1/clients`  
**Auth policy:** All endpoints `[JWT]`

**Index:** [00_conventions.md](00_conventions.md) | [← Back to main](../DA-E07-01_Business_Service_Endpoints.md)

---

## Endpoints in this group

| # | Method | Path | Roles |
|---|--------|------|-------|
| 25 | POST | `/api/v1/clients` | OWNER, MANAGER |
| 26 | GET | `/api/v1/clients` | OWNER, MANAGER, ACCOUNT |
| 27 | GET | `/api/v1/clients/{clientId}` | OWNER, MANAGER, ACCOUNT, CLIENT |
| 28 | PUT | `/api/v1/clients/{clientId}` | OWNER, MANAGER |
| 29 | DELETE | `/api/v1/clients/{clientId}` | OWNER |
| 30 | PUT | `/api/v1/clients/{clientId}/assign` | OWNER, MANAGER |
| 31 | PUT | `/api/v1/clients/{clientId}/service-package` | OWNER |
| 32 | PUT | `/api/v1/clients/{clientId}/portal-access` | OWNER, MANAGER |

> **Data isolation:**
> - `ACCOUNT`: sees only clients where `assigned_manager_id = X-User-Id`
> - `CLIENT`: can only access their own `clientId` (linked via `users.id → clients.portal_user_id`)
> - All queries implicitly scoped to `X-Workspace-Id`

---

## POST /api/v1/clients

**Auth:** `[JWT]` | **Roles:** `OWNER`, `MANAGER`  
**Goal:** Create a new brand client under the current workspace.

**Request body:**
```json
{
  "name": "string (required, max 100 chars)",
  "brandName": "string (optional — public-facing brand name if different from company name)",
  "industry": "string (optional — e.g. F&B, Fashion, Tech)",
  "logoUrl": "string (optional, HTTPS URL)",
  "contactEmail": "string (optional, valid email)",
  "contactPhone": "string (optional)"
}
```

**Response 201:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "workspaceId": "uuid",
    "name": "string",
    "brandName": "string | null",
    "industry": "string | null",
    "logoUrl": "string | null",
    "contactEmail": "string | null",
    "contactPhone": "string | null",
    "assignedManagerId": null,
    "portalAccessEnabled": false,
    "portalUserId": null,
    "isActive": true,
    "createdAt": "ISO8601"
  }
}
```

**Errors:**
- `400 VALIDATION_ERROR` — invalid contact email format
- `409 CLIENT_NAME_EXISTS` — a client with the same `name` already exists in this workspace

**Implementation notes:**
- `workspaceId` taken from `X-Workspace-Id` — not from request body
- Service package defaults to plan-level quota until explicitly set via `/service-package`

---

## GET /api/v1/clients

**Auth:** `[JWT]` | **Roles:** `OWNER`, `MANAGER`, `ACCOUNT`  
**Goal:** List clients. Role-based filter applied automatically.

**Query params:**
- `page` (integer, default 1)
- `size` (integer, default 20, max 100)
- `search` (optional — name substring match, case-insensitive)
- `isActive` (optional boolean, default true)

**Response 200:**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "uuid",
        "name": "string",
        "brandName": "string | null",
        "industry": "string | null",
        "logoUrl": "string | null",
        "assignedManagerId": "uuid | null",
        "assignedManagerName": "string | null",
        "portalAccessEnabled": "boolean",
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
- `OWNER`: sees all clients in workspace (`workspace_id = X-Workspace-Id`)
- `ACCOUNT`: filter `assigned_manager_id = X-User-Id`
- Join with `users` to populate `assignedManagerName`

---

## GET /api/v1/clients/{clientId}

**Auth:** `[JWT]` | **Roles:** `OWNER`, `MANAGER`, `ACCOUNT`, `CLIENT`  
**Goal:** Get full details of a single client including service package.

**Response 200:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "workspaceId": "uuid",
    "name": "string",
    "brandName": "string | null",
    "industry": "string | null",
    "logoUrl": "string | null",
    "contactEmail": "string | null",
    "contactPhone": "string | null",
    "assignedManagerId": "uuid | null",
    "assignedManagerName": "string | null",
    "portalAccessEnabled": "boolean",
    "portalUserId": "uuid | null",
    "servicePackage": {
      "postsPerMonth": "number (-1 = unlimited)",
      "platforms": ["FACEBOOK", "INSTAGRAM", "TIKTOK", "THREADS", "ZALO_OA"],
      "aiCreditsPerMonth": "number"
    },
    "metadata": "object | null",
    "isActive": "boolean",
    "createdAt": "ISO8601",
    "updatedAt": "ISO8601"
  }
}
```

**Errors:**
- `403 FORBIDDEN` — ACCOUNT accessing unassigned client, or CLIENT accessing another client
- `404 CLIENT_NOT_FOUND`

**Implementation notes:**
- `CLIENT` access check: `clients.portal_user_id = X-User-Id`
- `ACCOUNT` access check: `clients.assigned_manager_id = X-User-Id`

---

## PUT /api/v1/clients/{clientId}

**Auth:** `[JWT]` | **Roles:** `OWNER`, `MANAGER`  
**Goal:** Update client profile fields. Partial update — only provided fields changed.

**Request body (all optional):**
```json
{
  "name": "string",
  "brandName": "string | null",
  "industry": "string | null",
  "logoUrl": "string | null",
  "contactEmail": "string | null",
  "contactPhone": "string | null",
  "metadata": "object | null"
}
```

**Response 200:**
```json
{
  "success": true,
  "data": { /* full updated client object */ }
}
```

**Errors:**
- `404 CLIENT_NOT_FOUND`
- `400 VALIDATION_ERROR`

---

## DELETE /api/v1/clients/{clientId}

**Auth:** `[JWT]` | **Roles:** `OWNER`  
**Goal:** Soft-delete client — sets `is_active = false`. Data preserved.

**Response 200:**
```json
{ "success": true, "data": null }
```

**Errors:**
- `404 CLIENT_NOT_FOUND`
- `400 CLIENT_HAS_ACTIVE_POSTS` — client still has posts in `SCHEDULED` or `PUBLISHING` status (must cancel/complete those first)

**Implementation notes:**
- Soft delete only: `is_active = false`, `updated_at = now()`
- Does NOT cascade-delete posts, content requests, or social accounts (preserved for history)
- Portal user account (`portal_user_id`) is NOT deleted — must be handled separately if needed

---

## PUT /api/v1/clients/{clientId}/assign

**Auth:** `[JWT]` | **Roles:** `OWNER`, `MANAGER`  
**Goal:** Assign an ACCOUNT to a client. Replaces any existing assignment.

**Request body:**
```json
{
  "managerId": "uuid (required — must be active workspace member with ACCOUNT role)"
}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "clientId": "uuid",
    "assignedManagerId": "uuid",
    "assignedManagerName": "string"
  }
}
```

**Errors:**
- `400 INVALID_MANAGER` — `managerId` not found in workspace, not active, or not ACCOUNT role
- `404 CLIENT_NOT_FOUND`

**Implementation notes:**
- Validate manager exists in `workspace_members` with matching `workspace_id`, `is_active = true`, `role = ACCOUNT`
- Send notification to newly assigned manager

---

## PUT /api/v1/clients/{clientId}/service-package

**Auth:** `[JWT]` | **Roles:** `OWNER`  
**Goal:** Set client-level content quota (overrides workspace plan defaults for this client).

**Request body:**
```json
{
  "postsPerMonth": "number (required, -1 = unlimited)",
  "platforms": ["FACEBOOK", "INSTAGRAM", "TIKTOK", "THREADS", "ZALO_OA"],
  "aiCreditsPerMonth": "number (required, -1 = unlimited)"
}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "clientId": "uuid",
    "servicePackage": {
      "postsPerMonth": "number",
      "platforms": ["string"],
      "aiCreditsPerMonth": "number"
    }
  }
}
```

**Errors:**
- `400 EXCEEDS_PLAN_LIMIT` — client quota exceeds what the workspace subscription plan allows
- `400 INVALID_PLATFORM` — platform not in supported list

**Implementation notes:**
- Stored as JSONB in `clients.service_package`
- If `postsPerMonth = -1`, no monthly cap enforced for this client
- Platform list controls which social platforms the client's posts can target

---

## PUT /api/v1/clients/{clientId}/portal-access

**Auth:** `[JWT]` | **Roles:** `OWNER`, `MANAGER`  
**Goal:** Enable or disable CLIENT portal access for a client.

**Request body:**
```json
{
  "enabled": "boolean (required)",
  "portalEmail": "string (required when enabled=true — email for portal login account)"
}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "portalAccessEnabled": "boolean",
    "portalUserId": "uuid | null"
  }
}
```

**Errors:**
- `400 PORTAL_EMAIL_REQUIRED` — `enabled = true` but `portalEmail` not provided
- `409 EMAIL_ALREADY_USED` — `portalEmail` already exists as a non-CLIENT user
- `404 CLIENT_NOT_FOUND`

**Implementation notes:**
- When `enabled = true`:
  1. Check if user with `portalEmail` exists in `users`
  2. If not → create user row with `role = CLIENT`, `password_hash = null` (no password — invite-only access)
  3. Set `clients.portal_user_id = userId`, `portal_access_enabled = true`
  4. Send portal invitation email to `portalEmail` with a one-time login link
- When `enabled = false`:
  - Set `portal_access_enabled = false`
  - Set `portal_user_id = null` (unlink, but do NOT delete the `users` row)
  - Revoke all active sessions for the portal user
