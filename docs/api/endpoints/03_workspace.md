# DA-E07-01 — Workspace Endpoints

**Group:** Workspace | **Base path:** `/api/v1/workspaces`  
**Auth policy:** All endpoints `[JWT]` except `POST /invitations/accept` which is `[PUBLIC]`

**Index:** [00_conventions.md](00_conventions.md) | [← Back to main](../DA-E07-01_Business_Service_Endpoints.md)

---

## Endpoints in this group

| # | Method | Path | Roles |
|---|--------|------|-------|
| 15 | POST | `/api/v1/workspaces` | AGENCY_OWNER |
| 16 | GET | `/api/v1/workspaces/mine` | AGENCY_OWNER, ACCOUNT_MANAGER, CONTENT_CREATOR |
| 17 | PUT | `/api/v1/workspaces/{workspaceId}` | AGENCY_OWNER |
| 18 | GET | `/api/v1/workspaces/{workspaceId}/members` | AGENCY_OWNER, ACCOUNT_MANAGER |
| 19 | POST | `/api/v1/workspaces/{workspaceId}/members/invite` | AGENCY_OWNER |
| 20 | POST | `/api/v1/workspaces/invitations/accept` | PUBLIC |
| 21 | DELETE | `/api/v1/workspaces/{workspaceId}/members/{userId}` | AGENCY_OWNER |
| 22 | PUT | `/api/v1/workspaces/{workspaceId}/members/{userId}/role` | AGENCY_OWNER |
| 23 | GET | `/api/v1/workspaces/{workspaceId}/members/{userId}/permissions` | AGENCY_OWNER, self |
| 24 | PUT | `/api/v1/workspaces/{workspaceId}/members/{userId}/permissions` | AGENCY_OWNER |

> **Workspace isolation:** All JWT endpoints validate `X-Workspace-Id` matches the `workspaceId` path param. Cross-workspace access is rejected with `403 WORKSPACE_ACCESS_DENIED`.

---

## POST /api/v1/workspaces

**Auth:** `[JWT]` | **Roles:** `AGENCY_OWNER`  
**Goal:** Create a new workspace. Creator automatically becomes the owner with an `AGENCY_OWNER` `workspace_members` row.

**Request body:**
```json
{
  "name": "string (required, max 100 chars)",
  "slug": "string (required, unique globally, URL-safe: lowercase a-z 0-9 hyphen, max 50 chars)",
  "logoUrl": "string (optional, HTTPS URL)"
}
```

**Response 201:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "string",
    "slug": "string",
    "ownerId": "uuid",
    "logoUrl": "string | null",
    "isActive": true,
    "createdAt": "ISO8601"
  }
}
```

**Errors:**
- `409 SLUG_TAKEN` — slug already exists in `workspaces` table
- `400 VALIDATION_ERROR` — slug contains invalid characters or exceeds length

**Implementation notes:**
- Slug validation regex: `^[a-z0-9][a-z0-9-]{1,48}[a-z0-9]$`
- Insert `workspaces` row + insert `workspace_members` row (`role = AGENCY_OWNER`, `is_active = true`)
- Default `settings`: `{ approvalRequired: true, defaultLanguage: "vi", timezone: "Asia/Ho_Chi_Minh", reportFrequency: "monthly" }`

---

## GET /api/v1/workspaces/mine

**Auth:** `[JWT]` | **Roles:** `AGENCY_OWNER`, `ACCOUNT_MANAGER`, `CONTENT_CREATOR`  
**Goal:** Get the workspace the current user belongs to. Each user belongs to exactly one workspace.

**Request body:** none

**Response 200:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "string",
    "slug": "string",
    "ownerId": "uuid",
    "logoUrl": "string | null",
    "settings": {
      "brandColor": "string | null",
      "defaultLanguage": "en | vi",
      "approvalRequired": "boolean",
      "timezone": "string",
      "defaultPlatforms": ["FACEBOOK", "INSTAGRAM", "TIKTOK", "THREADS", "ZALO_OA"],
      "reportFrequency": "weekly | monthly"
    },
    "isActive": "boolean",
    "memberCount": "number",
    "createdAt": "ISO8601"
  }
}
```

**Errors:**
- `404 WORKSPACE_NOT_FOUND` — user has no active workspace membership (edge case: deactivated)

**Implementation notes:**
- Lookup by `X-Workspace-Id` from JWT (or join via `workspace_members.user_id = X-User-Id`)
- `memberCount` = count of active `workspace_members` rows

---

## PUT /api/v1/workspaces/{workspaceId}

**Auth:** `[JWT]` | **Roles:** `AGENCY_OWNER`  
**Goal:** Update workspace profile and settings. Partial update — only provided fields changed.

**Request body (all optional):**
```json
{
  "name": "string",
  "logoUrl": "string | null",
  "settings": {
    "brandColor": "string (hex color, e.g. #FF5733)",
    "defaultLanguage": "en | vi",
    "approvalRequired": "boolean",
    "timezone": "string (IANA)",
    "defaultPlatforms": ["FACEBOOK"],
    "reportFrequency": "weekly | monthly"
  }
}
```

**Response 200:**
```json
{
  "success": true,
  "data": { /* full updated workspace object */ }
}
```

**Errors:**
- `403 NOT_WORKSPACE_OWNER` — caller's `workspaceId` doesn't match path param
- `400 VALIDATION_ERROR` — invalid timezone or hex color format

---

## GET /api/v1/workspaces/{workspaceId}/members

**Auth:** `[JWT]` | **Roles:** `AGENCY_OWNER`, `ACCOUNT_MANAGER`  
**Goal:** List all active members of the workspace with their roles.

**Query params:**
- `page` (integer, default 1)
- `size` (integer, default 20, max 100)
- `role` (optional — filter by role: `ACCOUNT_MANAGER | CONTENT_CREATOR`)
- `search` (optional — name or email substring match)

**Response 200:**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "memberId": "uuid (workspace_members.id)",
        "userId": "uuid",
        "fullName": "string",
        "email": "string",
        "avatarUrl": "string | null",
        "role": "AGENCY_OWNER | ACCOUNT_MANAGER | CONTENT_CREATOR",
        "isActive": "boolean",
        "joinedAt": "ISO8601"
      }
    ],
    "total": "number",
    "page": "number",
    "size": "number"
  }
}
```

**Implementation notes:**
- Join `workspace_members` with `users` table
- Filter: `workspace_members.workspace_id = workspaceId` AND `is_active = true`
- ACCOUNT_MANAGER can see member list (needed to assign tasks) but cannot modify roles

---

## POST /api/v1/workspaces/{workspaceId}/members/invite

**Auth:** `[JWT]` | **Roles:** `AGENCY_OWNER`  
**Goal:** Invite a user to the workspace by email.

**Request body:**
```json
{
  "email": "string (required, valid email)",
  "role": "ACCOUNT_MANAGER | CONTENT_CREATOR (required)"
}
```

**Response 201:**
```json
{
  "success": true,
  "data": {
    "invitationId": "uuid",
    "invitedEmail": "string",
    "role": "string",
    "status": "PENDING",
    "expiresAt": "ISO8601 (7 days from now)"
  }
}
```

**Errors:**
- `409 ALREADY_MEMBER` — email already has active membership in this workspace
- `409 INVITATION_PENDING` — active (non-expired) invitation already exists for this email + workspace
- `400 VALIDATION_ERROR` — invalid email or invalid role value

**Implementation notes:**
- Two flows depending on whether the invited email already has a `users` account:
  - **Existing user:** Insert `workspace_members` row immediately (status: active) + send in-app notification
  - **New user:** Insert `workspace_invitations` row + send invite email with token link pointing to `/register?invitation={token}`
- Invitation token: UUID stored as `workspace_invitations.token`
- Invitation expires after 7 days (`expires_at`)

---

## POST /api/v1/workspaces/invitations/accept

**Auth:** `[PUBLIC]`  
**Goal:** Accept workspace invitation using token from email link. Activates membership.

**Request body:**
```json
{ "token": "string (required — UUID from invitation email)" }
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "workspaceId": "uuid",
    "role": "string",
    "message": "Welcome to the workspace"
  }
}
```

**Errors:**
- `400 INVITATION_INVALID` — token not found in `workspace_invitations`
- `400 INVITATION_EXPIRED` — current time past `expires_at`
- `400 INVITATION_ALREADY_USED` — `status = ACCEPTED`

**Implementation notes:**
- Lookup `workspace_invitations` by token
- Validate status = PENDING and `expires_at > now()`
- If invitee not yet registered → caller must register first (frontend handles this flow)
- On accept: set `status = ACCEPTED`, `accepted_by = userId`, `accepted_at = now()` → insert `workspace_members` row
- Return 200 even if user is already a member (idempotent)

---

## DELETE /api/v1/workspaces/{workspaceId}/members/{userId}

**Auth:** `[JWT]` | **Roles:** `AGENCY_OWNER`  
**Goal:** Remove a member from the workspace (soft delete).

**Response 200:**
```json
{ "success": true, "data": null }
```

**Errors:**
- `400 CANNOT_REMOVE_OWNER` — cannot remove the AGENCY_OWNER (workspace must always have one owner)
- `404 MEMBER_NOT_FOUND` — userId not an active member of this workspace

**Implementation notes:**
- Set `workspace_members.is_active = false` (soft delete — preserves history for audit)
- Does NOT revoke JWT immediately (access token still valid until 15-min expiry; refresh token becomes invalid on next use due to workspace check)
- Cascade consideration: unassign this user's `clients.assigned_manager_id` if applicable

---

## PUT /api/v1/workspaces/{workspaceId}/members/{userId}/role

**Auth:** `[JWT]` | **Roles:** `AGENCY_OWNER`  
**Goal:** Change a member's role within the workspace.

**Request body:**
```json
{
  "role": "ACCOUNT_MANAGER | CONTENT_CREATOR (required)"
}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "userId": "uuid",
    "previousRole": "string",
    "newRole": "string",
    "updatedAt": "ISO8601"
  }
}
```

**Errors:**
- `400 CANNOT_CHANGE_OWNER_ROLE` — cannot demote the AGENCY_OWNER
- `400 INVALID_ROLE` — role not one of allowed values
- `404 MEMBER_NOT_FOUND`

**Implementation notes:**
- Update `workspace_members.role` for the matching `(workspace_id, user_id)` row
- Note: JWT role is NOT updated immediately — takes effect on next login (new token issued)
- Log role change to audit system if available

---

## GET /api/v1/workspaces/{workspaceId}/members/{userId}/permissions

**Auth:** `[JWT]` | **Roles:** `AGENCY_OWNER` OR `self` (userId = X-User-Id)  
**Goal:** Get fine-grained permission overrides for a specific workspace member.

**Response 200:**
```json
{
  "success": true,
  "data": {
    "userId": "uuid",
    "role": "string",
    "permissions": [
      { "permission": "ai:image_gen", "granted": false },
      { "permission": "ai:video_gen", "granted": false },
      { "permission": "post:publish", "granted": true }
    ]
  }
}
```

**Errors:**
- `403 FORBIDDEN` — caller is not AGENCY_OWNER and `userId ≠ X-User-Id`
- `404 MEMBER_NOT_FOUND`

**Implementation notes:**
- Query `workspace_member_permissions` table filtered by `(workspace_id, user_id)`
- If no override rows exist → return empty `permissions` array (all permissions fall back to role defaults)
- Self-read use case: member can view their own restrictions before attempting an action

**Known permission keys:**
```
ai:content_gen    — generate AI text content
ai:image_gen      — generate AI images
ai:video_gen      — generate AI videos
ai:rag            — access knowledge base RAG
post:publish      — publish to social platforms directly
report:export     — export reports as PDF/CSV
```

---

## PUT /api/v1/workspaces/{workspaceId}/members/{userId}/permissions

**Auth:** `[JWT]` | **Roles:** `AGENCY_OWNER`  
**Goal:** Set or override fine-grained permissions for a specific workspace member.

**Request body:**
```json
{
  "permissions": [
    { "permission": "ai:image_gen", "granted": false },
    { "permission": "post:publish", "granted": true }
  ]
}
```

**Response 200:**
```json
{ "success": true, "data": null }
```

**Errors:**
- `400 INVALID_PERMISSION_KEY` — permission string not in known keys list
- `404 MEMBER_NOT_FOUND`

**Implementation notes:**
- Upsert rows in `workspace_member_permissions` for each `(workspace_id, user_id, permission)` triple
- To reset to role defaults: send `[]` (empty array) → delete all override rows for this member
- Cannot override AGENCY_OWNER's permissions (always full access)
