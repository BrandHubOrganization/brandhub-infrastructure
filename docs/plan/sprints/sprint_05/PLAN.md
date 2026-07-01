# Sprint 5 — Authentication & RBAC

**Timeline:** Weeks 9–10 (Jul 15–28, 2026)
**Jira:** DA Sprint 5
**Phase:** Phase 3 — Backend Core
**Goal:** Implement the complete authentication system (register, login, OAuth, token refresh, logout) and role-based access control enforcement in business-service.

> **AI Parallel:** AI Iteration 1 runs concurrently this sprint.

---

## Overview

| Epic | Title | Owner |
|---|---|---|
| E12 | Authentication | Trung |
| E13 | User & Profile Management | Trung, Ân |
| E14 | Role-Based Access Control (RBAC) | Trung, Phước |

**Deliverables by end of Sprint 5:**
- Register / Login / Logout / Refresh Token APIs working
- Google OAuth login working (callback + user creation)
- Forgot Password / Reset Password flow working
- Avatar upload to S3 working
- Admin user management APIs (list, ban/suspend)
- RBAC annotation enforced on all endpoints
- Workspace isolation filter active (workspaceId required on all queries)
- Permission matrix document

---

## EPIC E12 — Authentication

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E12-01 | Implement Register API (validate email uniqueness, hash password with bcrypt cost=12) | Trung (Leader) | 🔴 Critical |
| DA-E12-02 | Implement Login API (verify password, issue JWT access token 15 min + refresh token 30 days) | Trung (Leader) | 🔴 Critical |
| DA-E12-03 | Implement Refresh Token API (verify refresh token, issue new access token) | Trung (Leader) | 🔴 Critical |
| DA-E12-04 | Implement Logout API (add JWT jti to Redis blacklist, clear cookie) | Trung (Leader) | 🔴 Critical |
| DA-E12-05 | Implement Forgot Password & Reset Password flow (email link with time-limited token) | Trung (Leader) | 🔴 Critical |
| DA-E12-06 | Implement Google OAuth login (callback handler, create user if not exists) | Trung (Leader) | 🟡 High |

**JWT specification:**
- Access token: 15 min TTL, signed with RS256, payload: `{sub: userId, role, workspaceId, jti}`
- Refresh token: 30 days TTL, stored in HttpOnly cookie + MongoDB `users.refreshTokens[]`
- Blacklist: Redis `jwt:blacklist:{jti}` with TTL = access token TTL (15 minutes)

**Reset password token:** random UUID, stored in Redis `pwd:reset:{token}` with TTL = 1 hour.

**Notes:**
- DA-E12-05: use AWS SES or a transactional email service (SendGrid free tier) for password reset emails.
- DA-E12-06: Google OAuth scope = `openid email profile`. On callback, check if email exists → login; else create new user with role=AGENCY_OWNER (default for self-registration).
- Never store plain-text passwords. bcrypt cost=12 is the minimum — do not lower for "performance".

---

## EPIC E13 — User & Profile Management

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E13-01 | Implement GET/PUT /api/v1/users/me (get and update own profile) | Trung (Leader) | 🔴 Critical |
| DA-E13-02 | Implement avatar upload (receive file → upload to S3 → save URL to MongoDB) | Trung (Leader) | 🟡 High |
| DA-E13-03 | Implement Admin: GET /api/v1/admin/users (list all users with filters) | Ân (AI) | 🟡 High |
| DA-E13-04 | Implement Admin: Ban/Suspend user (set isActive=false, send notification) | Ân (AI) | 🟡 High |

**Avatar upload (DA-E13-02):**
- Accept: JPEG, PNG, WebP. Max size: 5MB.
- S3 key: `avatars/{userId}/{timestamp}.{ext}`
- Return presigned URL with 7-day TTL.
- Validate content-type from file header, not just extension.

---

## EPIC E14 — Role-Based Access Control (RBAC)

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E14-01 | Write RBAC annotation/middleware for business-service (@RequireRole) | Trung (Leader) | 🔴 Critical |
| DA-E14-02 | Implement workspace isolation filter (every MongoDB query must include workspaceId filter) | Trung (Leader) | 🔴 Critical |
| DA-E14-03 | Implement client isolation for BRAND_CLIENT (can only view data belonging to their clientId) | Trung (Leader) | 🔴 Critical |
| DA-E14-04 | Write permission matrix document (6 roles x all endpoints = allowed/denied) | Phước (Publisher) | 🟢 Medium |

**RBAC implementation:**
- Extract `X-User-Role` from gateway-injected header (set by JWT filter in Sprint 4)
- `@RequireRole({AGENCY_OWNER, ADMIN})` annotation on controller methods
- Return 403 Forbidden if role not in allowed list

**Workspace isolation:**
- Spring `@Bean` request-scoped `WorkspaceContext` holding `workspaceId` from JWT
- Custom MongoDB repository base class injects `{workspaceId: ctx.workspaceId}` into every query
- BRAND_CLIENT: additionally inject `{clientId: ctx.clientId}` filter

---

## Sprint 5 Checklist

- [ ] POST /api/v1/auth/register creates user, returns JWT
- [ ] POST /api/v1/auth/login returns access + refresh tokens
- [ ] POST /api/v1/auth/refresh issues new access token
- [ ] POST /api/v1/auth/logout blacklists JWT in Redis
- [ ] Forgot password email sent, reset link works within 1h
- [ ] Google OAuth redirect → callback → user created/logged in
- [ ] GET/PUT /api/v1/users/me working with auth
- [ ] Avatar upload: file → S3 → URL saved to user profile
- [ ] Admin can list users with pagination and role filter
- [ ] Admin can ban a user (isActive=false enforced on login)
- [ ] @RequireRole enforced: wrong role returns 403
- [ ] workspaceId filter active: cannot access other workspace's data
- [ ] BRAND_CLIENT clientId isolation: cannot see other clients' data
- [ ] Permission matrix document committed
