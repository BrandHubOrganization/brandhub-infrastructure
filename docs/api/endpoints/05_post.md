# DA-E07-01 — Post Endpoints

**Group:** Post | **Base path:** `/api/v1/posts`  
**Auth policy:** All endpoints `[JWT]`

**Index:** [00_conventions.md](00_conventions.md) | [← Back to main](../DA-E07-01_Business_Service_Endpoints.md)

---

## Endpoints in this group

| # | Method | Path | Roles |
|---|--------|------|-------|
| 33 | POST | `/api/v1/posts` | ACCOUNT, CREATOR |
| 34 | GET | `/api/v1/posts` | * |
| 35 | GET | `/api/v1/posts/{postId}` | * |
| 36 | PUT | `/api/v1/posts/{postId}` | CREATOR, ACCOUNT |
| 37 | DELETE | `/api/v1/posts/{postId}` | ACCOUNT |
| 38 | POST | `/api/v1/posts/{postId}/submit` | CREATOR, ACCOUNT |
| 39 | POST | `/api/v1/posts/{postId}/approve` | ACCOUNT |
| 40 | POST | `/api/v1/posts/{postId}/reject` | ACCOUNT |
| 41 | POST | `/api/v1/posts/{postId}/schedule` | ACCOUNT |

> **Storage:** Posts stored in MongoDB `posts` collection. `postId` is a MongoDB ObjectId string.

**Post status workflow:**
```
DRAFT → PENDING_APPROVAL → APPROVED → SCHEDULED → PUBLISHING → PUBLISHED
                        ↘ REJECTED → (edit) → DRAFT
                                              ↘ CANCELLED (any state)
                                              ↘ FAILED (from PUBLISHING)
```

**Role-based data isolation:**
- `CLIENT`: read-only, sees only posts where `clientId` = their linked client
- `CREATOR`: sees only posts where `createdBy = X-User-Id`
- `ACCOUNT`: sees posts for assigned clients only
- `ACCOUNT`: sees all posts for assigned clients (no separate workspace-wide role — `OWNER` does not access content screens)

---

## POST /api/v1/posts

**Auth:** `[JWT]` | **Roles:** `ACCOUNT`, `CREATOR`  
**Goal:** Create a new post draft.

**Request body:**
```json
{
  "clientId": "uuid (required — must be accessible to caller)",
  "title": "string (optional, max 200 chars)",
  "contentText": "string (required, max 10000 chars)",
  "mediaUrls": ["string (S3 URLs, max 10 items)"],
  "platform": "FACEBOOK | INSTAGRAM | TIKTOK | THREADS | ZALO_OA (required)",
  "socialAccountId": "string (optional — MongoDB ObjectId of social_accounts doc)",
  "scheduledAt": "ISO8601 (optional — pre-set schedule, must be future time)",
  "aiGenerated": "boolean (optional, default false)"
}
```

**Response 201:**
```json
{
  "success": true,
  "data": {
    "id": "string (MongoDB ObjectId)",
    "workspaceId": "uuid",
    "clientId": "uuid",
    "createdBy": "uuid",
    "title": "string | null",
    "contentText": "string",
    "platform": "string",
    "status": "DRAFT",
    "aiGenerated": "boolean",
    "createdAt": "ISO8601"
  }
}
```

**Errors:**
- `403 CLIENT_ACCESS_DENIED` — caller cannot access the specified `clientId`
- `400 PLATFORM_NOT_ALLOWED` — platform not in client's `servicePackage.platforms`
- `400 SCHEDULE_IN_PAST` — `scheduledAt` is in the past
- `400 VALIDATION_ERROR`

**Implementation notes:**
- `workspaceId` taken from `X-Workspace-Id`; `createdBy` from `X-User-Id`
- If `scheduledAt` provided, post is created as DRAFT — scheduling is applied separately after approval
- If workspace `settings.approvalRequired = false` and role is ACCOUNT → can auto-approve on submit

---

## GET /api/v1/posts

**Auth:** `[JWT]` | **Roles:** `*`  
**Goal:** List posts with filtering. Role-based data isolation applied server-side.

**Query params:**
- `clientId` (uuid, optional)
- `status` (optional — one of post status values)
- `platform` (optional)
- `from` (ISO date string, optional — filter by `createdAt >=`)
- `to` (ISO date string, optional — filter by `createdAt <=`)
- `page` (default 1)
- `size` (default 20, max 100)

**Response 200:**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "string",
        "clientId": "uuid",
        "clientName": "string",
        "title": "string | null",
        "contentText": "string (truncated to 200 chars in list)",
        "platform": "string",
        "status": "string",
        "scheduledAt": "ISO8601 | null",
        "publishedAt": "ISO8601 | null",
        "aiGenerated": "boolean",
        "createdBy": "uuid",
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
- All queries scoped to `workspaceId = X-Workspace-Id`
- Role filters applied before user-supplied filters:
  - `CREATOR`: `createdBy = X-User-Id`
  - `ACCOUNT`: `clientId IN (clients assigned to user)`
  - `CLIENT`: `clientId = (client linked to portal user)`
- MongoDB index used: `{ workspaceId: 1, status: 1, createdAt: -1 }`

---

## GET /api/v1/posts/{postId}

**Auth:** `[JWT]` | **Roles:** `*`  
**Goal:** Get single post with full content and approval history.

**Response 200:**
```json
{
  "success": true,
  "data": {
    "id": "string",
    "workspaceId": "uuid",
    "clientId": "uuid",
    "createdBy": "uuid",
    "title": "string | null",
    "contentText": "string",
    "mediaUrls": ["string"],
    "platform": "string",
    "socialAccountId": "string | null",
    "status": "string",
    "scheduledAt": "ISO8601 | null",
    "publishedAt": "ISO8601 | null",
    "platformPostId": "string | null",
    "aiGenerated": "boolean",
    "approvalHistory": [
      {
        "userId": "uuid",
        "userName": "string",
        "action": "APPROVED | REJECTED",
        "comment": "string | null",
        "at": "ISO8601"
      }
    ],
    "publishLogs": [
      {
        "attemptedAt": "ISO8601",
        "result": "SUCCESS | FAILED",
        "errorMessage": "string | null"
      }
    ],
    "createdAt": "ISO8601",
    "updatedAt": "ISO8601"
  }
}
```

**Errors:**
- `403 FORBIDDEN` — caller's role isolation rules deny access to this post
- `404 POST_NOT_FOUND`

**Implementation notes:**
- `publishLogs` fetched from separate `publish_logs` MongoDB collection by `postId`
- Same role-based isolation applies as GET list

---

## PUT /api/v1/posts/{postId}

**Auth:** `[JWT]` | **Roles:** `CREATOR`, `ACCOUNT`  
**Goal:** Update post content. Only editable when status is `DRAFT` or `REJECTED`.

**Request body (all optional):**
```json
{
  "title": "string | null",
  "contentText": "string",
  "mediaUrls": ["string"],
  "platform": "FACEBOOK | INSTAGRAM | TIKTOK | THREADS | ZALO_OA",
  "socialAccountId": "string | null",
  "scheduledAt": "ISO8601 | null"
}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "id": "string",
    "status": "string",
    "updatedAt": "ISO8601"
  }
}
```

**Errors:**
- `400 POST_NOT_EDITABLE` — status is not `DRAFT` or `REJECTED`
- `403 FORBIDDEN` — CREATOR editing a post they didn't create
- `404 POST_NOT_FOUND`

**Implementation notes:**
- CREATOR can only edit own posts (`createdBy = X-User-Id`)
- If post was `REJECTED` and now edited → status stays `REJECTED` until `submit` is called again
- `updatedAt` set to now on every edit

---

## DELETE /api/v1/posts/{postId}

**Auth:** `[JWT]` | **Roles:** `ACCOUNT`  
**Goal:** Cancel/archive a post. Sets status to `CANCELLED`.

**Response 200:**
```json
{ "success": true, "data": null }
```

**Errors:**
- `400 POST_ALREADY_PUBLISHED` — cannot cancel a `PUBLISHED` post
- `400 POST_PUBLISHING` — cannot cancel while `PUBLISHING` (in-flight to platform)
- `404 POST_NOT_FOUND`

**Implementation notes:**
- Sets `status = CANCELLED`, `updated_at = now()`
- ACCOUNT can only cancel posts for their assigned clients
- ACCOUNT can cancel any post for their assigned clients

---

## POST /api/v1/posts/{postId}/submit

**Auth:** `[JWT]` | **Roles:** `CREATOR`, `ACCOUNT`  
**Goal:** Submit post for approval. Transitions `DRAFT → PENDING_APPROVAL`.

**Request body:** none

**Response 200:**
```json
{ "success": true, "data": { "postId": "string", "status": "PENDING_APPROVAL" } }
```

**Errors:**
- `400 POST_NOT_DRAFT` — can only submit posts in `DRAFT` status
- `403 FORBIDDEN` — CREATOR submitting a post they didn't create

**Implementation notes:**
- If `workspace.settings.approvalRequired = false` → auto-transition to `APPROVED` instead of `PENDING_APPROVAL`
- Notify ACCOUNT of pending review (in-app notification via `notifications` collection)

---

## POST /api/v1/posts/{postId}/approve

**Auth:** `[JWT]` | **Roles:** `ACCOUNT`  
**Goal:** Approve post. Transitions `PENDING_APPROVAL → APPROVED`.

**Request body:**
```json
{ "comment": "string (optional)" }
```

**Response 200:**
```json
{ "success": true, "data": { "postId": "string", "status": "APPROVED" } }
```

**Errors:**
- `400 POST_NOT_PENDING` — post not in `PENDING_APPROVAL` status

**Implementation notes:**
- Append entry to `approvalHistory[]`: `{ userId, action: "APPROVED", comment, at: now() }`
- Notify post creator of approval
- ACCOUNT can only approve posts for their assigned clients

---

## POST /api/v1/posts/{postId}/reject

**Auth:** `[JWT]` | **Roles:** `ACCOUNT`  
**Goal:** Reject post. Transitions `PENDING_APPROVAL → REJECTED`.

**Request body:**
```json
{ "comment": "string (required — rejection reason must be provided)" }
```

**Response 200:**
```json
{ "success": true, "data": { "postId": "string", "status": "REJECTED" } }
```

**Errors:**
- `400 POST_NOT_PENDING` — post not in `PENDING_APPROVAL` status
- `400 COMMENT_REQUIRED` — rejection comment is mandatory

**Implementation notes:**
- Append entry to `approvalHistory[]`: `{ userId, action: "REJECTED", comment, at: now() }`
- Notify post creator with rejection reason
- Post can be edited and re-submitted after rejection

---

## POST /api/v1/posts/{postId}/schedule

**Auth:** `[JWT]` | **Roles:** `ACCOUNT`  
**Goal:** Schedule an approved post for publishing. Transitions `APPROVED → SCHEDULED`.

**Request body:**
```json
{
  "scheduledAt": "ISO8601 (required — must be at least 5 minutes in the future)",
  "socialAccountId": "string (required — MongoDB ObjectId of social_accounts doc)"
}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "postId": "string",
    "status": "SCHEDULED",
    "scheduledAt": "ISO8601",
    "socialAccountId": "string"
  }
}
```

**Errors:**
- `400 POST_NOT_APPROVED` — can only schedule `APPROVED` posts
- `400 SCHEDULE_IN_PAST` — `scheduledAt` is in the past
- `400 SCHEDULE_TOO_SOON` — `scheduledAt` less than 5 minutes from now (publisher needs lead time)
- `400 SOCIAL_ACCOUNT_NOT_FOUND` — `socialAccountId` not found in workspace's `social_accounts`
- `400 SOCIAL_ACCOUNT_EXPIRED` — social account token status is `EXPIRED` or `REVOKED`
- `400 PLATFORM_MISMATCH` — social account platform doesn't match post's `platform` field

**Implementation notes:**
- Validate `social_accounts` doc: `workspaceId` match + `tokenStatus = ACTIVE | EXPIRING_SOON` + `platform` match
- Scheduler (publisher-service) picks up posts where `status = SCHEDULED` AND `scheduledAt <= now()`
- Publisher transitions post: `SCHEDULED → PUBLISHING → PUBLISHED | FAILED`
- On EXPIRING_SOON token: proceed but add warning in response: `"warning": "Token expires soon, reconnect recommended"`
