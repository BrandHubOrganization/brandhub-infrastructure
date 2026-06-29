# DA-E07-01 — User Endpoints

**Group:** User | **Base path:** `/api/v1/users`  
**Auth policy:** All endpoints `[JWT]` | Roles: `*` (all authenticated users, own data only)

**Index:** [00_conventions.md](00_conventions.md) | [← Back to main](../DA-E07-01_Business_Service_Endpoints.md)

---

## Endpoints in this group

| # | Method | Path | Goal |
|---|--------|------|------|
| 9 | GET | `/api/v1/users/me` | Get own profile |
| 10 | PUT | `/api/v1/users/me` | Update own profile |
| 11 | POST | `/api/v1/users/me/avatar` | Upload avatar to S3 |
| 12 | GET | `/api/v1/users/me/sessions` | List active sessions |
| 13 | DELETE | `/api/v1/users/me/sessions/{sessionId}` | Revoke a session |
| 14 | PUT | `/api/v1/users/me/password` | Change password |

> **Data isolation:** All `/users/me` endpoints operate on `X-User-Id` injected by gateway. Users cannot access other users' data through these endpoints.

---

## GET /api/v1/users/me

**Auth:** `[JWT]` | **Roles:** `*`  
**Goal:** Get current authenticated user's full profile.

**Request body:** none

**Response 200:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "email": "string",
    "fullName": "string",
    "avatarUrl": "string | null",
    "status": "ACTIVE | SUSPENDED",
    "role": "string",
    "preferences": {
      "language": "en | vi",
      "timezone": "Asia/Ho_Chi_Minh",
      "notifications": {
        "email": true,
        "inApp": true
      }
    },
    "lastLoginAt": "ISO8601 | null",
    "createdAt": "ISO8601"
  }
}
```

**Implementation notes:**
- Read from `users` table by `X-User-Id`
- `role` comes from `X-User-Role` header (source of truth: JWT) — no need to re-query DB for role

---

## PUT /api/v1/users/me

**Auth:** `[JWT]` | **Roles:** `*`  
**Goal:** Update own profile. Only whitelisted fields are patchable.

**Request body (all fields optional):**
```json
{
  "fullName": "string (min 1 char, max 100 chars)",
  "preferences": {
    "language": "en | vi",
    "timezone": "string (IANA timezone, e.g. Asia/Ho_Chi_Minh)",
    "notifications": {
      "email": "boolean",
      "inApp": "boolean"
    }
  }
}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "email": "string",
    "fullName": "string",
    "avatarUrl": "string | null",
    "preferences": { /* updated preferences */ },
    "updatedAt": "ISO8601"
  }
}
```

**Errors:**
- `400 VALIDATION_ERROR` — invalid timezone string or fullName empty

**Implementation notes:**
- `email` is NOT patchable via this endpoint (separate flow if needed)
- `role` is NOT patchable here — only Admin can change roles
- Merge `preferences` object (PATCH semantics for nested object — only provided keys updated)

---

## POST /api/v1/users/me/avatar

**Auth:** `[JWT]` | **Roles:** `*`  
**Goal:** Upload profile avatar image. Stores in S3, updates `users.avatar_url`.

**Request:** `multipart/form-data`  
**Field:** `file` — image file (JPEG / PNG / WebP, max 5 MB)

**Response 200:**
```json
{
  "success": true,
  "data": {
    "avatarUrl": "string (HTTPS URL — S3 object or CloudFront CDN)"
  }
}
```

**Errors:**
- `400 FILE_TOO_LARGE` — file exceeds 5 MB
- `400 INVALID_FILE_TYPE` — MIME type not `image/jpeg`, `image/png`, or `image/webp` (validated from file header magic bytes, NOT extension)
- `400 NO_FILE_PROVIDED` — multipart field `file` missing

**Implementation notes:**
- S3 key: `avatars/{userId}/{timestamp}.{ext}` — overwrites on re-upload not guaranteed (timestamp ensures unique key)
- Old avatar NOT automatically deleted from S3 (keep for audit; cleanup via S3 lifecycle rule)
- Validate content type from file header (first 12 bytes) — reject mismatched extension
- Return permanent URL (CloudFront) not presigned S3 URL for avatar (public-read object)

---

## GET /api/v1/users/me/sessions

**Auth:** `[JWT]` | **Roles:** `*`  
**Goal:** List all active refresh token sessions (across devices) for the current user.

**Request body:** none

**Response 200:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "ipAddress": "string",
      "userAgent": "string",
      "deviceInfo": {
        "deviceType": "desktop | mobile | tablet",
        "osName": "string",
        "browserName": "string"
      },
      "isCurrent": "boolean",
      "createdAt": "ISO8601",
      "expiresAt": "ISO8601"
    }
  ]
}
```

**Implementation notes:**
- Query `user_refresh_tokens` where `user_id = X-User-Id` AND `expires_at > now()` AND `revoked_at IS NULL`
- `isCurrent = true` for the session whose `jti` matches current access token's `jti` claim
- Ordered by `created_at DESC`

---

## DELETE /api/v1/users/me/sessions/{sessionId}

**Auth:** `[JWT]` | **Roles:** `*`  
**Goal:** Revoke a specific session (log out a device). Useful for "log out all other devices".

**Path param:** `sessionId` (UUID — from sessions list)

**Response 200:**
```json
{ "success": true, "data": null }
```

**Errors:**
- `404 SESSION_NOT_FOUND` — session doesn't exist OR doesn't belong to `X-User-Id` (same error — prevents enumeration)

**Implementation notes:**
- Set `user_refresh_tokens.revoked_at = now()` for the matching row
- If the session being revoked is the current session (same `jti`) → also blacklist current access token in Redis
- Ownership check: `user_id = X-User-Id` mandatory — user cannot revoke others' sessions

---

## PUT /api/v1/users/me/password

**Auth:** `[JWT]` | **Roles:** `*`  
**Goal:** Change password while logged in (requires current password verification).

**Request body:**
```json
{
  "currentPassword": "string (required)",
  "newPassword": "string (required, min 8 chars)"
}
```

**Response 200:**
```json
{ "success": true, "data": null }
```

**Errors:**
- `400 WRONG_CURRENT_PASSWORD` — bcrypt compare failed for `currentPassword`
- `400 OAUTH_ONLY_ACCOUNT` — `users.password_hash = null` (user registered via OAuth only, no password set — direct them to forgot-password flow to set one)
- `400 VALIDATION_ERROR` — newPassword < 8 chars or same as current password

**Implementation notes:**
- Verify `currentPassword` via bcrypt compare against `users.password_hash`
- Hash `newPassword` with bcrypt cost=12 → update `users.password_hash`
- Optionally invalidate all OTHER refresh token sessions (force re-login on other devices) — recommended for security
- Do NOT invalidate the current session (user should stay logged in on current device)
