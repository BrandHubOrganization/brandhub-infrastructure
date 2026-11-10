# 3.2.8 Sign Out

| | |
|---|---|
| FR Code | 3.2.8 |
| Feature | Sign Out (Logout) |
| Domain | Authentication (FR 3.2) |
| Role | Any signed-in USER |
| Version | 4.0 — 2026-09-25 — FE now calls the logout endpoint — token blacklisting is real, not just local state clear |
| Document status | Implemented |

## Function Trigger

Begins when a signed-in user clicks "Log out" in the account/navbar menu (or the dashboard's logout button).

## Function Description

-  **Actors / Roles:** Any authenticated USER.
-  **Purpose:** End the current session. Blacklists the current access and refresh token `jti` values server-side and records a LOGOUT audit event, then clears local client state and redirects to `/login`.
-  **Interface:** A "Log out" menu item / icon button in the Navbar and in the Dashboard page header (not a full-page confirmation screen).
-  **Data Processing:** `Navbar.handleLogout` fires `authService.logout()` (`POST /api/v1/auth/logout`, fire-and-forget, best-effort — the call is not awaited before proceeding) and, independent of that call's outcome, immediately clears `user`, `accessToken`, `refreshToken`, `isAuthenticated`, `systemRole` via `clearAuth()` and navigates to `/login`. On the backend, `AuthController.logout` reads the `Authorization: Bearer <accessToken>` header, the `refreshToken` cookie, `X-Forwarded-For` (ipAddress) and `User-Agent` headers, blacklists the access token's `jti` (best-effort) and the refresh token's `jti` (best-effort), writes an audit log when the access token yielded a user id, clears the `refreshToken` cookie, and returns 200 with no data.

## Screen Layout

Figure — Sign Out entry points (no dedicated Sign Out screen exists):
-  Navbar: a "Log out" icon button (`LogOut` icon, `Navbar.tsx`) inside the account area, calling `handleLogout()`.
-  Dashboard page header: a "Log out" button (`dashboard.page.logout` — `pages/dashboard/index.tsx`, via `useDashboardData().handleLogout`), calling `clearAuth()` directly (does not go through `Navbar.handleLogout`, so it does not call the logout endpoint — see Business Rules).
-  After either action, `isAuthenticated` becomes `false`; `AuthGuard` (`components/layout/AuthGuard.tsx`) then redirects any protected route to `/login`.
-  `lib/axios.ts` also calls `useAuthStore.getState().logout()` automatically on a 401 response interceptor (session-expired forced logout), toast MSG22 in that case — this path also does not call the logout endpoint (the session is already invalid).
-  The landing-page navbar (`components/landing/Navbar.tsx`) has no logout handler — it is shown only to unauthenticated visitors.

⚠ **BA conflict (needs team decision):** the Dashboard page header's own "Log out" button (`useDashboardData().handleLogout`) still calls `clearAuth()` directly and does **not** go through `authService.logout()`, unlike `Navbar.handleLogout`. A user signing out from the dashboard header therefore still leaves their access/refresh token unblacklisted server-side, the same gap this revision closes for the Navbar path. Needs a team decision: either route the dashboard header's logout through the same `authService.logout()` call, or confirm this entry point is being deprecated in favor of the Navbar's.

## Function Details

### Data Specifications

-  **Input required (backend):** `Authorization: Bearer <accessToken>` header. `refreshToken` cookie is optional (its absence does not fail the request).
-  **Input optional (backend):** `X-Forwarded-For` (ipAddress), `User-Agent` (userAgent), `X-Request-Id` (requestId, generated server-side if absent).
-  **Input (frontend):** none — `authService.logout()` sends no body; the browser attaches the `Authorization` header via the axios instance's interceptor and the `refreshToken` cookie automatically.
-  **System data:** userId resolved from the access token's JWT subject (only if the token parses); the token's `jti` for blacklisting; the caller's ipAddress/userAgent for the audit record.
-  **Output:** `ApiResponse<Void>` — `data` is `null` on success. The `refreshToken` cookie is cleared (`MaxAge=0`, same `Path=/api/v1/auth`, `HttpOnly`, `Secure`, `SameSite=Strict` as when login sets it).

### Business Rules

-  **BR-14:** "Sign-out blacklists both access and refresh token `jti` values and clears the refresh cookie."
   -  Access token blacklisting and refresh token blacklisting are each wrapped independently in their own try/catch for `JwtException` — either one failing (expired, malformed, wrong signature) is swallowed silently and does **not** fail the request. `AuthServiceImpl.logout` never throws.
   -  The refresh cookie is cleared by the controller unconditionally, on every successful (200) response — regardless of whether blacklisting succeeded.
   -  The frontend call is itself best-effort: `authService.logout().catch(() => {})` in `Navbar.handleLogout` swallows any error (network failure, already-expired token, 401) and proceeds to clear local state regardless — see Abnormal Cases.
-  **BR-16:** Security events (LOGIN, LOGOUT, PASSWORD_RESET) are always persisted to the audit log with IP + user agent. For logout, the `AuditLog` (action=`LOGOUT`, resourceType=`USER`, resourceId=userId, ipAddress, userAgent) is written **only if** the access token successfully parsed to a userId; if the access token could not be parsed, no audit row is written for that logout call — success is still reported.
-  Only the tokens for the current device/session are invalidated; refresh tokens held by other devices/sessions are unaffected (unlike a password change, which invalidates every refresh token — see FR 3.2.x Change Password).
-  Missing or malformed `Authorization` header is the **one** case that is not idempotent/best-effort on the backend: it is rejected before `authService.logout(...)` (Java service) is ever called (see Abnormal Cases). This never surfaces to the FE user because `Navbar.handleLogout` clears local state and navigates away regardless of the API outcome.

### Validation

-  `Authorization` header missing, or present but not starting with `"Bearer "` → 401 `INVALID_CREDENTIALS`. Note: unlike every other authenticated endpoint in `AuthController` (which throw `BusinessException(INVALID_CREDENTIALS)` via the shared `requireUserId` helper, handled by the global exception handler), `logout` checks this inline in the controller method itself and calls `response.setStatus(401)` + returns `ApiResponse.error(...)` directly — a different code path from the rest of the controller. This is a code-quality inconsistency worth a cleanup ticket, but it produces the same 401/`INVALID_CREDENTIALS` result, so it is not a behavioral BA conflict. The FE never shows this as an error — see Abnormal Cases.
-  Expired or otherwise unparsable access token (header well-formed) → not an error; sign-out still returns 200.
-  Missing, expired, or unparsable refresh token → not an error; sign-out still returns 200.

## Functionalities

### Normal Flow

1. User clicks "Log out" in the Navbar.
2. `Navbar.handleLogout` calls `authService.logout()` (`POST /api/v1/auth/logout` with `Authorization: Bearer <accessToken>` header and `refreshToken` cookie sent automatically) without awaiting it, and swallows any rejection with `.catch(() => {})`.
3. In parallel/independent of step 2's outcome, `Navbar.handleLogout` calls `clearAuth()` (clears `user`, `accessToken`, `refreshToken`, `isAuthenticated`, `systemRole` from the auth store and resets the workspace store) and navigates to `/login`. The client does not wait for the API response before proceeding.
4. On the backend, the controller validates the `Authorization` header format; on success it strips the `Bearer ` prefix and calls `authService.logout(accessToken, refreshToken, ipAddress, userAgent)`.
5. The service parses the access token; on success it extracts the userId and blacklists the access token's `jti` (BR-14).
6. If a refresh token is present, the service blacklists its `jti` too (BR-14), independent of step 5's outcome.
7. If a userId was resolved in step 5, the service writes a LOGOUT `AuditLog` with ipAddress and userAgent (BR-16).
8. The controller clears the `refreshToken` cookie (`MaxAge=0`) and returns 200 `ApiResponse.ok(null)`.
9. By the time the response arrives (if it arrives before the browser navigates away), the user is typically already on `/login`; no toast is shown for the success case since the UI has already moved on.

### Abnormal Cases

4.a1: `Authorization` header missing or not starting with `"Bearer "` → the controller itself sets HTTP 401 and returns `ApiResponse.error(INVALID_CREDENTIALS, ...)` inline, without calling `authService.logout`. 4.a2: `authService.logout()`'s promise rejects; `Navbar.handleLogout`'s `.catch(() => {})` swallows it — the frontend still clears its local state and navigates to `/login` with no user-facing error, per BR-14's best-effort FE contract.

5.a1: Access token is present with a valid `Bearer ` prefix but is expired or fails to parse (`JwtException`) → caught and ignored; `userId` stays `null`; sign-out proceeds as idempotent success (no audit row written). 5.a2: Refresh token blacklisting (step 6) still runs if a refresh token is present.

6.a1: Refresh token is absent, expired, or fails to parse → caught and ignored; sign-out still returns 200. 6.a2: The access token's blacklisting result (step 5) is unaffected.

N.a1 (network failure / API unreachable): the `POST /api/v1/auth/logout` call throws a network error (offline, timeout, server down) → the promise rejects and `.catch(() => {})` swallows it. The frontend proceeds exactly as in the success case: local state cleared, redirect to `/login`, no error toast. The server-side token is not blacklisted in this case and remains valid until natural expiry.

N.a2 (forced logout, session already expired): `lib/axios.ts`'s response interceptor calls `useAuthStore.getState().logout()` on a 401 from any API call (expired/invalid session), which triggers the same local-only clear-and-redirect, with toast MSG22 ("session expired") instead of the normal flow. This path does not call `authService.logout()` — the session is already considered invalid, so no additional server round trip is made.

## Post-Conditions

-  The access token's and refresh token's `jti` values are blacklisted server-side (best-effort — see BR-14), the `refreshToken` cookie is cleared, and — when the access token was resolvable and the request reached the backend — a LOGOUT audit log row exists with ipAddress and userAgent.
-  Regardless of the API call's outcome, the frontend's local auth/workspace state is cleared and the user is redirected to `/login`.
-  Sessions on other devices are unaffected.
-  If the API call failed (network error, already-expired token) the server-side token may remain valid until natural expiry, but the user is signed out of the current browser session either way (see Abnormal Cases N.a1).

## Out of Scope

-  Remembering/highlighting the last-used sign-in method (e.g. "used last time" on `/login`) — no such field or local-storage key exists in the current frontend code (`authStore.ts`, `Navbar.tsx`, login page); any earlier spec mentioning it does not match the codebase and has been removed from this revision.
-  Server-side "logout all devices" — out of scope for this FR; see Change Password, which does invalidate every refresh token.
-  Wiring the Dashboard page header's separate logout button through `authService.logout()` — see BA conflict above.

## References

Section5_Requirement_Appendix.md (BR-14, BR-16; MSG22) — read-only, not modified by this revision.
