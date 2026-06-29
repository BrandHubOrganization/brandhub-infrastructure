# DA-E07-01 — Social Account Endpoints

**Group:** Social Account | **Base path:** `/api/v1/social`  
**Auth policy:** Mixed — see per-endpoint

**Index:** [00_conventions.md](00_conventions.md) | [← Back to main](../DA-E07-01_Business_Service_Endpoints.md)

---

## Endpoints in this group

| # | Method | Path | Auth | Roles |
|---|--------|------|------|-------|
| 48 | GET | `/api/v1/social/accounts` | JWT | AGENCY_OWNER, ACCOUNT_MANAGER |
| 49 | GET | `/api/v1/social/connect/{platform}` | JWT | AGENCY_OWNER, ACCOUNT_MANAGER |
| 50 | GET | `/api/v1/social/callback/{platform}` | PUBLIC | — |
| 51 | DELETE | `/api/v1/social/accounts/{accountId}` | JWT | AGENCY_OWNER, ACCOUNT_MANAGER |
| 52 | POST | `/api/v1/social/accounts/{accountId}/refresh` | JWT | AGENCY_OWNER, ACCOUNT_MANAGER |

> **Storage:** Social accounts stored in MongoDB `social_accounts` collection. `accountId` is a MongoDB ObjectId string.  
> **Token security:** Access tokens and refresh tokens are encrypted at rest using AES-256-GCM before storing in MongoDB. Key from env `SOCIAL_TOKEN_ENCRYPTION_KEY`.

**Supported platforms:** `FACEBOOK`, `INSTAGRAM`, `TIKTOK`, `THREADS`, `ZALO_OA`  
Path param `{platform}` uses lowercase: `facebook`, `instagram`, `tiktok`, `threads`, `zalo`

**Token status values:**
- `ACTIVE` — token valid, can publish
- `EXPIRING_SOON` — token expires within 7 days; warn user but still functional
- `EXPIRED` — token past expiry; cannot publish; must reconnect
- `REVOKED` — user revoked access at platform level; must reconnect

---

## GET /api/v1/social/accounts

**Auth:** `[JWT]` | **Roles:** `AGENCY_OWNER`, `ACCOUNT_MANAGER`  
**Goal:** List all connected social accounts in the workspace with current token status.

**Response 200:**
```json
{
  "success": true,
  "data": [
    {
      "id": "string (ObjectId)",
      "platform": "FACEBOOK | INSTAGRAM | TIKTOK | THREADS | ZALO_OA",
      "accountName": "string",
      "accountId": "string (platform-side user/page ID)",
      "profilePictureUrl": "string | null",
      "tokenStatus": "ACTIVE | EXPIRING_SOON | EXPIRED | REVOKED",
      "tokenExpiresAt": "ISO8601 | null",
      "isActive": "boolean",
      "connectedAt": "ISO8601",
      "connectedBy": "uuid"
    }
  ]
}
```

**Implementation notes:**
- Scoped to `workspaceId = X-Workspace-Id`
- Do NOT return raw tokens in response — return only status metadata
- `connectedBy` = userId who initiated the OAuth flow

---

## GET /api/v1/social/connect/{platform}

**Auth:** `[JWT]` | **Roles:** `AGENCY_OWNER`, `ACCOUNT_MANAGER`  
**Goal:** Initiate OAuth flow for a social platform. Returns redirect to platform consent screen.

**Path param:** `platform` — one of `facebook`, `instagram`, `tiktok`, `threads`, `zalo`

**Query params:** none

**Response 302:** Redirect to platform OAuth authorization URL

**Errors:**
- `400 UNSUPPORTED_PLATFORM` — `platform` not in supported list
- `400 ACCOUNT_ALREADY_CONNECTED` — this platform already has an active connected account in the workspace (must disconnect first)

**Implementation notes:**
- Generate CSRF state token (UUID) → encode `{ state, workspaceId, userId, platform }` as base64 → store in Redis `oauth:state:{state}` TTL 10 min
- Platform-specific OAuth URLs:
  - Facebook/Instagram: `https://www.facebook.com/v19.0/dialog/oauth`
  - TikTok: `https://www.tiktok.com/v2/auth/authorize`
  - Zalo: `https://oauth.zaloapp.com/v4/oa/permission`
- Scope per platform:
  - Facebook: `pages_manage_posts, pages_read_engagement, instagram_basic, instagram_content_publish`
  - TikTok: `user.info.basic, video.publish`
  - Zalo: `manage_official_account, send_message`

---

## GET /api/v1/social/callback/{platform}

**Auth:** `[PUBLIC]` — OAuth redirect from platform cannot include JWT  
**Goal:** Handle OAuth callback, exchange code for token, encrypt and store.

**Path param:** `platform` — one of `facebook`, `instagram`, `tiktok`, `threads`, `zalo`

**Query params:** `code` (required), `state` (required)

**Response 302:**
- Success: redirect to `{frontendUrl}/workspace/social-accounts?connected=true&platform={platform}`
- Error: redirect to `{frontendUrl}/workspace/social-accounts?error={code}`

**Errors (via redirect query param):**
- `OAUTH_STATE_INVALID` — state not found in Redis (expired or CSRF)
- `OAUTH_CODE_INVALID` — platform token exchange failed
- `PLATFORM_AUTH_DENIED` — user denied access at platform consent screen

**Implementation notes:**
1. Validate `state` in Redis → extract `{ workspaceId, userId, platform }` → delete state key (one-time use)
2. Exchange `code` for access token + refresh token via platform API
3. Fetch platform account info (name, profilePicture, accountId)
4. Encrypt tokens: AES-256-GCM with `SOCIAL_TOKEN_ENCRYPTION_KEY` → store `{ encryptedToken, iv, tag }` in MongoDB
5. Upsert `social_accounts` doc (match on `workspaceId + platform + accountId`)
6. Set `tokenStatus = ACTIVE`, compute `tokenExpiresAt` from platform response
7. Redirect to frontend success URL
- **Note for Instagram:** Instagram tokens are obtained via Facebook Graph API (same flow). The `platform` value stored is `INSTAGRAM` even though the OAuth app is Facebook.

---

## DELETE /api/v1/social/accounts/{accountId}

**Auth:** `[JWT]` | **Roles:** `AGENCY_OWNER`, `ACCOUNT_MANAGER`  
**Goal:** Disconnect a social account — attempt token revocation at platform, then delete from DB.

**Response 200:**
```json
{ "success": true, "data": null }
```

**Errors:**
- `404 SOCIAL_ACCOUNT_NOT_FOUND` — accountId not found in workspace
- `400 ACCOUNT_IN_USE` — account has posts in `SCHEDULED` status (would break scheduled publishing)

**Implementation notes:**
- Decrypt stored token → call platform revoke API (best-effort — proceed even if revoke call fails)
- Delete `social_accounts` document from MongoDB
- Do NOT delete published posts that used this account (post history preserved)
- ACCOUNT_MANAGER can disconnect any workspace social account (not restricted to own accounts)

---

## POST /api/v1/social/accounts/{accountId}/refresh

**Auth:** `[JWT]` | **Roles:** `AGENCY_OWNER`, `ACCOUNT_MANAGER`  
**Goal:** Manually trigger token refresh for a social account using stored refresh token.

**Request body:** none

**Response 200:**
```json
{
  "success": true,
  "data": {
    "accountId": "string",
    "tokenStatus": "ACTIVE",
    "tokenExpiresAt": "ISO8601"
  }
}
```

**Errors:**
- `404 SOCIAL_ACCOUNT_NOT_FOUND`
- `400 CANNOT_REFRESH` — platform does not support token refresh (e.g. TikTok short-lived tokens require re-authorization)
- `400 REFRESH_TOKEN_EXPIRED` — stored refresh token has expired; full reconnect required
- `400 REFRESH_TOKEN_MISSING` — account was connected without a refresh token (some platforms)

**Implementation notes:**
- Decrypt stored refresh token → call platform token refresh endpoint
- On success: encrypt new access token → update `social_accounts` doc → set `tokenStatus = ACTIVE`, new `tokenExpiresAt`
- On failure: update `tokenStatus = EXPIRED` in DB; return appropriate error
- Platform refresh support:
  - Facebook/Instagram: supported (long-lived tokens, 60-day refresh)
  - TikTok: limited — access tokens are short-lived (24h); refresh token valid 365 days
  - Zalo: supported
  - Threads: same as Instagram (Meta)
