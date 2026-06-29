# DA-E07-01 — Auth Endpoints

**Group:** Auth | **Base path:** `/api/v1/auth`  
**Auth policy:** All endpoints `[PUBLIC]` — Gateway allowlist: `/api/v1/auth/**`

**Index:** [00_conventions.md](00_conventions.md) | [← Back to main](../DA-E07-01_Business_Service_Endpoints.md)

---

## Endpoints in this group

| # | Method | Path | Goal |
|---|--------|------|------|
| 1 | POST | `/api/v1/auth/register` | Create user account |
| 2 | POST | `/api/v1/auth/login` | Issue JWT pair |
| 3 | POST | `/api/v1/auth/refresh` | Refresh access token |
| 4 | POST | `/api/v1/auth/logout` | Revoke session |
| 5 | POST | `/api/v1/auth/forgot-password` | Trigger reset email |
| 6 | POST | `/api/v1/auth/reset-password` | Set new password via token |
| 7 | GET | `/api/v1/auth/oauth/google` | Initiate Google OAuth |
| 8 | GET | `/api/v1/auth/oauth/google/callback` | Handle Google OAuth callback |

---

## POST /api/v1/auth/register

**Auth:** `[PUBLIC]`  
**Goal:** Create new user account. Self-registered users get `AGENCY_OWNER` role by default.

**Request body:**
```json
{
  "email": "string (required, valid email format)",
  "password": "string (required, min 8 chars)",
  "fullName": "string (required)"
}
```

**Response 201:**
```json
{
  "success": true,
  "data": {
    "accessToken": "string (JWT RS256, 15 min TTL)",
    "user": {
      "id": "uuid",
      "email": "string",
      "fullName": "string",
      "role": "AGENCY_OWNER"
    }
  }
}
```
Cookie: `Set-Cookie: refreshToken=<token>; HttpOnly; Secure; SameSite=Strict; Path=/api/v1/auth`

**Errors:**
- `409 EMAIL_ALREADY_EXISTS` — email already registered
- `400 VALIDATION_ERROR` — invalid email format or password < 8 chars

**Implementation notes:**
- Password hashed with bcrypt cost=12 before storage
- Refresh token (30-day TTL) stored in `user_refresh_tokens` table with device info
- Access token payload: `{ sub: userId, role, workspaceId?, jti, iat, exp }`

---

## POST /api/v1/auth/login

**Auth:** `[PUBLIC]`  
**Goal:** Authenticate with email + password, issue JWT pair.

**Request body:**
```json
{
  "email": "string (required)",
  "password": "string (required)"
}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "accessToken": "string (JWT RS256, 15 min TTL)",
    "user": {
      "id": "uuid",
      "email": "string",
      "fullName": "string",
      "avatarUrl": "string | null",
      "role": "string",
      "workspaceId": "uuid | null"
    }
  }
}
```
Cookie: `Set-Cookie: refreshToken=<token>; HttpOnly; Secure; SameSite=Strict`

**Errors:**
- `401 INVALID_CREDENTIALS` — wrong email or password (intentionally vague — do not distinguish which field failed)
- `403 ACCOUNT_SUSPENDED` — user `status = SUSPENDED`

**Implementation notes:**
- Device fingerprint (`ip_address`, `user_agent`, `device_info`) saved to `user_refresh_tokens`
- `users.last_login_at` updated on successful login
- Do NOT reveal whether email exists in 401 response (prevents user enumeration)

---

## POST /api/v1/auth/refresh

**Auth:** `[PUBLIC]` (reads HttpOnly cookie — no Bearer header)  
**Goal:** Issue new access token using refresh token cookie.

**Request body:** none  
**Cookie required:** `refreshToken` (HttpOnly)

**Response 200:**
```json
{
  "success": true,
  "data": {
    "accessToken": "string (new JWT RS256, 15 min TTL)"
  }
}
```

**Errors:**
- `401 REFRESH_TOKEN_INVALID` — token not in `user_refresh_tokens`, already revoked, or expired
- `401 REFRESH_TOKEN_BLACKLISTED` — `jti` found in Redis `jwt:blacklist:{jti}`

**Implementation notes:**
- Validate token exists in `user_refresh_tokens` AND not past `expires_at`
- Check Redis blacklist second (faster than DB for hot-path)
- Does NOT rotate the refresh token (rotation is optional; if enabled, update row + reissue cookie)

---

## POST /api/v1/auth/logout

**Auth:** `[PUBLIC]` (reads cookie to identify session — access token may already be expired)  
**Goal:** Invalidate current session: blacklist access token jti, delete refresh token row.

**Request body:** none  
**Cookie required:** `refreshToken`

**Response 200:**
```json
{ "success": true, "data": null }
```

**Implementation notes:**
- Add access token `jti` to Redis `jwt:blacklist:{jti}` with TTL = remaining access token lifetime
- Delete matching row from `user_refresh_tokens`
- Clear cookie: `Set-Cookie: refreshToken=; Max-Age=0; HttpOnly; Secure; SameSite=Strict`
- If cookie missing or token already expired — still return 200 (idempotent)

---

## POST /api/v1/auth/forgot-password

**Auth:** `[PUBLIC]`  
**Goal:** Trigger password reset email with time-limited token link.

**Request body:**
```json
{ "email": "string (required)" }
```

**Response 200:**
```json
{
  "success": true,
  "data": null,
  "message": "If an account with that email exists, a reset link has been sent."
}
```

**Errors:**
- `400 VALIDATION_ERROR` — invalid email format

**Implementation notes:**
- **Always return 200** regardless of whether email exists — prevents user enumeration
- Flow: generate UUID token → store in Redis `pwd:reset:{token}` (TTL 1h) AND insert row in `password_reset_tokens` table (for audit trail)
- Send email via configured email provider (AWS SES / SendGrid) with link: `{frontendUrl}/reset-password?token={token}`
- Rate limit: max 3 requests per email per hour (Redis counter)

---

## POST /api/v1/auth/reset-password

**Auth:** `[PUBLIC]`  
**Goal:** Set new password using reset token from email link.

**Request body:**
```json
{
  "token": "string (required — UUID from reset email link)",
  "newPassword": "string (required, min 8 chars)"
}
```

**Response 200:**
```json
{ "success": true, "data": null }
```

**Errors:**
- `400 RESET_TOKEN_INVALID` — token not found in Redis (expired or never existed)
- `400 RESET_TOKEN_USED` — token already consumed (`used_at` not null in `password_reset_tokens`)
- `400 VALIDATION_ERROR` — newPassword < 8 chars

**Implementation notes:**
1. Look up token in Redis `pwd:reset:{token}` (fast path — if missing, return RESET_TOKEN_INVALID)
2. Cross-check `password_reset_tokens` table — if `used_at` is set, return RESET_TOKEN_USED
3. On success: bcrypt hash new password → update `users.password_hash` → set `password_reset_tokens.used_at = now()` → delete Redis key
4. Invalidate all existing refresh tokens for this user (security: force re-login on all devices)

---

## GET /api/v1/auth/oauth/google

**Auth:** `[PUBLIC]`  
**Goal:** Initiate Google OAuth flow. Returns redirect to Google consent screen.

**Query params:** `redirectUri` (optional — override default frontend redirect URI)

**Response 302:** Redirect to `https://accounts.google.com/o/oauth2/v2/auth?client_id=...&scope=openid+email+profile&state=...`

**Errors:**
- `400 INVALID_REDIRECT_URI` — provided `redirectUri` not in configured allowlist

**Implementation notes:**
- Generate CSRF state token (UUID) → store in Redis `oauth:state:{state}` TTL 10 min
- State payload (base64): `{ state, redirectUri, createdAt }`
- Scope: `openid email profile`
- Response type: `code`

---

## GET /api/v1/auth/oauth/google/callback

**Auth:** `[PUBLIC]` (called by Google redirect — cannot include JWT)  
**Goal:** Handle Google OAuth callback. Create user if not exists; issue JWT pair.

**Query params:** `code` (required), `state` (required)

**Response 302:** Redirect to frontend with access token:
- Success: `{redirectUri}?accessToken={token}` — frontend extracts and stores in memory
- Error: `{redirectUri}?error={code}`

**Errors:**
- `400 OAUTH_STATE_INVALID` — state not found in Redis (expired or CSRF attack)
- `400 OAUTH_CODE_INVALID` — Google token exchange failed (code expired or reused)

**Implementation notes:**
- Validate state in Redis first → delete state key immediately (one-time use)
- Exchange `code` for Google ID token → extract `email`, `name`, `picture` from ID token payload
- If `email` already in `users` table → login flow (update `last_login_at`)
- If not → create `users` row with `role = AGENCY_OWNER`, `password_hash = null`, `oauth_provider = google`
- Issue JWT pair → refresh token in HttpOnly cookie → redirect
- If existing user has `password_hash` set (registered via email), still allow OAuth login to same account (link by email)
