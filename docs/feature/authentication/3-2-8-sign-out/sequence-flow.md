# Sequence Flow — Sign Out

> Companion to `spec.md` (3.2.8). Lists each actor -> action -> system step in enough detail to draw the sequence diagram directly; the business description lives in `spec.md`.

## Actors

- **User / Browser** — the signed-in user's client.
- **Navbar (FE)** — `Navbar.handleLogout`, `brandhub-web-dashboard/src/components/layout/Navbar.tsx`.
- **authService (FE)** — `authService.logout()`, `brandhub-web-dashboard/src/services/authService.ts`.
- **AuthController** — `POST /api/v1/auth/logout`.
- **AuthServiceImpl** — `logout(accessToken, refreshToken, ipAddress, userAgent)`.
- **JwtUtil / Redis blacklist** — parses JWTs and stores blacklisted `jti` values.
- **AuditLogRepository** — persists the LOGOUT audit row.

> The frontend's "Log out" click in the Navbar now reaches `AuthController` for real: `Navbar.handleLogout` fires `authService.logout()` fire-and-forget (not awaited) and, independent of its outcome, clears local Zustand state and navigates to `/login` immediately. The Dashboard page header's separate logout button still calls `clearAuth()` directly and does not call the endpoint — see the BA conflict note in `spec.md`.

---

## Flow A — Normal logout (valid access token, refresh token present)

1. User/Browser -> Navbar (FE): clicks "Log out".
2. Navbar (FE) -> authService (FE): `logout()` — call started, **not awaited**.
3. Navbar (FE): in parallel, immediately calls `clearAuth()` (clears `user`, `accessToken`, `refreshToken`, `isAuthenticated`, `systemRole`, resets workspace store) and navigates to `/login`. This does not wait for step 2's result.
4. authService (FE) -> AuthController: `POST /api/v1/auth/logout`, header `Authorization: Bearer <accessToken>`, cookie `refreshToken=<token>`, headers `X-Forwarded-For`, `User-Agent`.
5. AuthController: `authHeader` starts with `"Bearer "` -> strips prefix to get `accessToken`; continues (no 401).
6. AuthController -> AuthServiceImpl: `logout(accessToken, refreshToken, ipAddress, userAgent)`.
7. AuthServiceImpl -> JwtUtil: `parseToken(accessToken)` — succeeds, returns `Claims` with subject `userId`.
8. AuthServiceImpl -> JwtUtil/Redis: `blacklistToken(accessToken)` — access token `jti` blacklisted.
9. AuthServiceImpl: `refreshToken` is non-blank -> AuthServiceImpl -> JwtUtil/Redis: `blacklistToken(refreshToken)` — refresh token `jti` blacklisted.
10. AuthServiceImpl -> AuditLogRepository: `save(AuditLog{action=LOGOUT, resourceType=USER, resourceId=userId, ipAddress, userAgent})` — userId was resolved, so the row is written (BR-16).
11. AuthServiceImpl --> AuthController: returns (void).
12. AuthController: clears `refreshToken` cookie (`MaxAge=0`, same `Path=/api/v1/auth`, `HttpOnly`, `Secure`, `SameSite=Strict` attributes as login sets it).
13. AuthController --> authService (FE): 200 `ApiResponse.ok(null)`.
14. authService (FE) --> Navbar (FE): promise resolves. By this point the user has typically already navigated to `/login` (step 3 ran without waiting); the resolved value is discarded (no `.then` handler beyond the implicit fire-and-forget).

## Flow B — API call fails / rejects (opt: best-effort catch, swallowed)

1–3. Same as Flow A — `clearAuth()` and navigation to `/login` proceed immediately regardless of what happens next.
4. authService (FE) -> AuthController: `POST /api/v1/auth/logout` — fails before or after reaching the server (network error, timeout, server down, or a non-2xx response e.g. 401 from Flow C below).
5. **opt** [request rejects]: authService (FE) --> Navbar (FE): promise rejects.
6. Navbar (FE): `.catch(() => {})` swallows the rejection — no error surfaces to the user, no retry, no toast. The user is already on `/login` from step 3. **opt end**
7. Server-side effect (if the request reached the backend but the response was an error): the access/refresh token is not guaranteed to be blacklisted — depends on which sub-step failed. If it never reached the backend at all (pure network failure), no blacklisting happens; the token remains valid until natural expiry.

## Flow C — Access token already expired/invalid, but backend logout still succeeds (idempotent)

1–6. Same as Flow A steps 4–6 (request reaches the controller with a well-formed `Bearer` prefix).
7. AuthServiceImpl -> JwtUtil: `parseToken(accessToken)` — throws `JwtException` (expired or malformed).
8. AuthServiceImpl: catches the exception silently; `userId` stays `null`; the access token is **not** blacklisted (nothing to blacklist against — it never parsed) and no error propagates.
9. AuthServiceImpl: `refreshToken` is non-blank -> AuthServiceImpl -> JwtUtil/Redis: `blacklistToken(refreshToken)` — still attempted and, if it parses, succeeds regardless of step 7's failure. If it also throws `JwtException`, that is caught and ignored too.
10. AuthServiceImpl: `userId` is `null` -> AuditLogRepository is **not** called; no audit row is written for this call.
11–13. Same as Flow A — AuthController still clears the cookie and returns 200 `ApiResponse.ok(null)`.

## Flow D — Missing or malformed `Authorization` header (the one non-idempotent backend branch)

1. authService (FE) -> AuthController: `POST /api/v1/auth/logout` with `Authorization` header absent, or not starting with `"Bearer "` (e.g. the access token was never set — edge case).
2. AuthController: guard `authHeader == null || !authHeader.startsWith("Bearer ")` is true. This check is inline in the controller method itself — unlike every other authenticated endpoint on this controller (which throw `BusinessException(INVALID_CREDENTIALS)` through the shared `requireUserId` helper and the global exception handler), `logout` sets the response status directly.
3. AuthController: `response.setStatus(401)`; builds `ApiResponse.error(INVALID_CREDENTIALS.name(), INVALID_CREDENTIALS.getDefaultMessage(), requestId)` and returns it immediately. `AuthServiceImpl.logout` is **never called** — no blacklisting, no audit log, cookie is **not** touched.
4. AuthController --> authService (FE): 401, `INVALID_CREDENTIALS`.
5. authService (FE) --> Navbar (FE): promise rejects -> falls into Flow B's `.catch(() => {})` — swallowed, no user-facing effect since local state was already cleared in step 3 of Flow A.

---

## Error paths summary (for "alt"/"opt" fragments)

| Step | Failure condition | HTTP | Error code | FE-visible effect |
|---|---|---|---|---|
| Sign out | `Authorization` header missing or malformed (no `Bearer ` prefix) | 401 | `INVALID_CREDENTIALS` | None — swallowed by `.catch(() => {})`, local state already cleared |
| Sign out | Access token present but expired/unparsable | 200 | — (idempotent, no error; no audit row) | None |
| Sign out | Refresh token absent, expired, or unparsable | 200 | — (idempotent, no error) | None |
| Sign out | Network error / request never reaches backend | — | — (promise rejection) | None — swallowed; local state already cleared |

## Notes

- `Navbar.handleLogout` never awaits `authService.logout()` — `clearAuth()` and the `/login` navigation happen unconditionally and immediately, in parallel with (not after) the API call. This is the FE's best-effort contract described in `spec.md`'s BR-14 notes.
- `AuthServiceImpl.logout` never throws once past the controller's header check — it is fully best-effort/idempotent for both token-blacklisting steps.
- The audit log row is written only when the access token parsed to a userId; an all-expired-tokens logout call succeeds with 200 but leaves no audit trail.
- Only the current device's access/refresh token `jti` values are blacklisted; other devices' sessions are unaffected.
- The Dashboard page header's logout button (`useDashboardData().handleLogout`) does not go through `authService.logout()` at all — it only calls `clearAuth()`. See the BA conflict flagged in `spec.md`.
