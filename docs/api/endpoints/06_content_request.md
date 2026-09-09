# DA-E07-01 — Content Request Endpoints

**Group:** Content Request | **Base path:** `/api/v1/content-requests`  
**Auth policy:** All endpoints `[JWT]`

**Index:** [00_conventions.md](00_conventions.md) | [← Back to main](../DA-E07-01_Business_Service_Endpoints.md)

---

## Endpoints in this group

| # | Method | Path | Roles |
|---|--------|------|-------|
| 42 | POST | `/api/v1/content-requests` | ACCOUNT, CLIENT |
| 43 | GET | `/api/v1/content-requests` | * |
| 44 | GET | `/api/v1/content-requests/{requestId}` | * |
| 45 | PUT | `/api/v1/content-requests/{requestId}/assign` | ACCOUNT |
| 46 | PUT | `/api/v1/content-requests/{requestId}/status` | CREATOR, ACCOUNT |
| 47 | POST | `/api/v1/content-requests/{requestId}/comments` | * |

> **Storage:** Content requests stored in MongoDB `content_requests` collection. `requestId` is a MongoDB ObjectId string.

**Request status workflow:**
```
SUBMITTED → ASSIGNED → IN_PROGRESS → PENDING_REVIEW → SENT_TO_CLIENT → APPROVED
                                                                      ↘ REJECTED → (re-open)
         ↘ CANCELLED (any state, by ACCOUNT)
```

**Role transition rights:**
| Role | Allowed transitions |
|------|---------------------|
| `CREATOR` | ASSIGNED → IN_PROGRESS, IN_PROGRESS → PENDING_REVIEW |
| `ACCOUNT` | SUBMITTED → ASSIGNED (via /assign), PENDING_REVIEW → SENT_TO_CLIENT, SENT_TO_CLIENT → APPROVED/REJECTED |
| `CLIENT` | read-only; cannot change status |

**Data isolation:**
- `CREATOR`: sees only requests where `assignedTo = X-User-Id`
- `ACCOUNT`: sees requests for their assigned clients
- `CLIENT`: sees only requests where `clientId = their linked clientId`
- `ACCOUNT`: sees all requests for their assigned clients (no separate workspace-wide role — `OWNER` does not access content screens)

---

## POST /api/v1/content-requests

**Auth:** `[JWT]` | **Roles:** `ACCOUNT`, `CLIENT`  
**Goal:** Create a new content request. Starts as `SUBMITTED`.

**Request body:**
```json
{
  "clientId": "uuid (required)",
  "title": "string (required, max 200 chars)",
  "description": "string (optional, max 5000 chars)",
  "tone": "professional | casual | humorous | inspirational (optional)",
  "platforms": ["FACEBOOK", "INSTAGRAM", "TIKTOK", "THREADS", "ZALO_OA"],
  "deadline": "ISO8601 (optional — must be future time)",
  "attachments": ["string (S3 URL — reference materials, max 10 files)"]
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
    "requestedBy": "uuid",
    "title": "string",
    "status": "SUBMITTED",
    "deadline": "ISO8601 | null",
    "createdAt": "ISO8601"
  }
}
```

**Errors:**
- `403 CLIENT_ACCESS_DENIED` — CLIENT trying to create request for a different client
- `400 DEADLINE_IN_PAST` — `deadline` is in the past
- `400 VALIDATION_ERROR`

**Implementation notes:**
- `requestedBy` = `X-User-Id`; `workspaceId` = `X-Workspace-Id`
- `CLIENT` creating a request: `clientId` must match their linked client (`clients.portal_user_id = X-User-Id`)
- Notify ACCOUNT (assigned manager, if any) of new request

---

## GET /api/v1/content-requests

**Auth:** `[JWT]` | **Roles:** `*`  
**Goal:** List content requests with filtering. Role-based isolation applied server-side.

**Query params:**
- `clientId` (uuid, optional)
- `status` (optional)
- `assignedTo` (uuid, optional — only ACCOUNT can use this filter)
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
        "title": "string",
        "tone": "string | null",
        "platforms": ["string"],
        "status": "string",
        "deadline": "ISO8601 | null",
        "assignedTo": "uuid | null",
        "assignedToName": "string | null",
        "requestedBy": "uuid",
        "createdAt": "ISO8601"
      }
    ],
    "total": "number",
    "page": "number",
    "size": "number"
  }
}
```

---

## GET /api/v1/content-requests/{requestId}

**Auth:** `[JWT]` | **Roles:** `*`  
**Goal:** Get single content request with full detail including comments thread.

**Response 200:**
```json
{
  "success": true,
  "data": {
    "id": "string",
    "workspaceId": "uuid",
    "clientId": "uuid",
    "requestedBy": "uuid",
    "title": "string",
    "description": "string | null",
    "tone": "string | null",
    "platforms": ["string"],
    "status": "string",
    "deadline": "ISO8601 | null",
    "assignedTo": "uuid | null",
    "linkedPostId": "string | null",
    "attachments": ["string"],
    "comments": [
      {
        "id": "string",
        "userId": "uuid",
        "userName": "string",
        "text": "string",
        "at": "ISO8601"
      }
    ],
    "createdAt": "ISO8601",
    "updatedAt": "ISO8601"
  }
}
```

**Errors:**
- `403 FORBIDDEN` — role isolation denies access
- `404 REQUEST_NOT_FOUND`

---

## PUT /api/v1/content-requests/{requestId}/assign

**Auth:** `[JWT]` | **Roles:** `ACCOUNT`  
**Goal:** Assign a CREATOR to the request. Transitions `SUBMITTED → ASSIGNED`.

**Request body:**
```json
{
  "assignedTo": "uuid (required — must be active workspace member with CREATOR role)"
}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "requestId": "string",
    "status": "ASSIGNED",
    "assignedTo": "uuid",
    "assignedToName": "string"
  }
}
```

**Errors:**
- `400 REQUEST_NOT_SUBMITTED` — can only assign requests in `SUBMITTED` status
- `400 INVALID_ASSIGNEE` — `assignedTo` not a workspace member, not active, or not CREATOR role
- `404 REQUEST_NOT_FOUND`

**Implementation notes:**
- Notify the assigned CREATOR
- ACCOUNT can only assign requests for their own clients

---

## PUT /api/v1/content-requests/{requestId}/status

**Auth:** `[JWT]` | **Roles:** `CREATOR`, `ACCOUNT`  
**Goal:** Advance request through workflow. Each role may only perform allowed transitions.

**Request body:**
```json
{
  "status": "IN_PROGRESS | PENDING_REVIEW | SENT_TO_CLIENT | APPROVED | REJECTED | CANCELLED (required)",
  "comment": "string (optional — recommended for REJECTED and CANCELLED)",
  "linkedPostId": "string (optional — MongoDB ObjectId — link a completed post when transitioning to SENT_TO_CLIENT)"
}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "requestId": "string",
    "previousStatus": "string",
    "status": "string",
    "updatedAt": "ISO8601"
  }
}
```

**Errors:**
- `400 INVALID_TRANSITION` — transition not allowed for caller's role (see transition table above)
- `400 COMMENT_REQUIRED` — comment required for REJECTED transitions
- `404 REQUEST_NOT_FOUND`

**Implementation notes:**
- Server enforces transition validity per role — client cannot skip states
- On `SENT_TO_CLIENT`: optionally link a completed post via `linkedPostId`
- On `APPROVED` / `REJECTED`: notify `requestedBy` (the client or account manager who submitted)
- On `CANCELLED`: notify all parties (requestedBy, assignedTo)

---

## POST /api/v1/content-requests/{requestId}/comments

**Auth:** `[JWT]` | **Roles:** `*`  
**Goal:** Add a comment to the request's discussion thread.

**Request body:**
```json
{
  "text": "string (required, min 1 char, max 2000 chars)"
}
```

**Response 201:**
```json
{
  "success": true,
  "data": {
    "commentId": "string (sub-document ID)",
    "userId": "uuid",
    "userName": "string",
    "text": "string",
    "at": "ISO8601"
  }
}
```

**Errors:**
- `403 FORBIDDEN` — role isolation denies access to this request
- `404 REQUEST_NOT_FOUND`
- `400 VALIDATION_ERROR` — empty text

**Implementation notes:**
- Append to `content_requests.comments[]` array (embedded sub-document in MongoDB)
- `CLIENT` can comment only on their own client's requests
- Notify other parties in the request thread (CREATOR + ACCOUNT) when new comment added
