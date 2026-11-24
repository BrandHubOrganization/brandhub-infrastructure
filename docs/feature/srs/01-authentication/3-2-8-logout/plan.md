> **Navigation:** [← Domain Index](../README.md) · [Spec](./spec.md) · **Plan** · [Task](./task.md) · [Test](./test.md)

# Plan — FR 3.2.8: Logout

> Implements [spec.md](./spec.md) — Current-device session termination (`POST /api/v1/auth/logout`), Redis JWT access/refresh token blacklisting (`BR-05`), `HttpOnly` cookie clearing, IP/User-Agent audit logging, and client-side `lastUsedLoginMethod` persistence.

## 1. Technical Component Map

| Layer | Repository / Package | Concrete Classes & Files |
| :--- | :--- | :--- |
| **API Gateway** | `brandhub-api-gateway` | `JwtAuthFilterGatewayFilterFactory.java` (checks Redis `jwt:blacklist:{jti}` on every subsequent request) |
| **Controller** | `brandhub-business-service` | `controller/auth/AuthController.java` (`logout` extracting `Authorization` header, `refreshToken` cookie, `X-Forwarded-For`, and `User-Agent`) |
| **Service** | `brandhub-business-service` | `service/impl/auth/AuthServiceImpl.java` (`logout`), `util/JwtUtil.java` (`blacklistToken`) |
| **Persistence** | `brandhub-business-service` | `AuditLogRepository.java` (`AuditLog` with `ip_address` & `user_agent`), `UserRefreshTokenRepository.java`, Redis `jwt:blacklist:{jti}` |
| **Web Frontend** | `brandhub-web` | `src/components/layout/{Navbar,Sidebar}.tsx`, `src/services/authService.ts`, `src/stores/authStore.ts`, `src/pages/auth/LoginPage.tsx` |
| **Mobile App** | `brandhub-mobile-app` | `src/screens/settings/SettingsScreen.tsx`, `src/utils/confirmSignOut.ts`, `src/services/authService.ts`, `src/store/authStore.ts` |

## 2. Database, Redis & LocalStorage Design

- **Redis Token Blacklist:** `jwt:blacklist:{jti}` set with TTL equal to the remaining lifetime of the presented `accessToken` and `refreshToken` so neither token can be replayed at `brandhub-api-gateway` or `/api/v1/auth/refresh`.
- **PostgreSQL `user_refresh_tokens` & `audit_logs`:**
  - Marks only the current device's refresh token revoked (leaving other signed-in devices active).
  - Inserts `AuditLog(userId, action=LOGOUT, resourceType="USER", ipAddress, userAgent)` (`2026-09-23-audit-log-ip-user-agent.sql`: `ip_address VARCHAR(45)`, `user_agent VARCHAR(512)`).
- **Client Storage (`lastUsedLoginMethod`):**
  - Stored in browser `localStorage` / mobile preferences (`"email"` | `"google_oauth"`) during login and preserved across `clearAuth()` so `/login` highlights the user's last-used sign-in option without extra backend state.

## 3. End-to-End Execution Flow

1. **Client Sign-Out Trigger:** User clicks Logout in `Navbar` / `Sidebar` (Web) or confirms sign-out via `confirmSignOut.ts` (Mobile).
2. **Backend Revocation (`POST /api/v1/auth/logout`):**
   - Validates `Authorization: Bearer <token>` header presence (`401 INVALID_CREDENTIALS` if missing/malformed).
   - Parses `userId` and `jti` (gracefully handling already-expired tokens idempotently -> still returns `200 OK`).
   - Blacklists `accessToken` and `refreshToken` `jti`s in Redis (`jwt:blacklist:{jti}`) for their remaining TTL, revokes matching `UserRefreshToken`, writes `AuditLog(LOGOUT, ipAddress, userAgent)`, and sets `Set-Cookie: refreshToken=; Max-Age=0; HttpOnly`.
3. **Client State Cleanup:** Clears `authStore` access token/user profile, clears TanStack Query user-scoped caches (preventing cross-account data flash), retains `lastUsedLoginMethod`, and redirects to `/login`.

## 4. Security & Multi-Device Isolation

- **Per-Device Scope:** Only the refresh token presented by the current browser/device is revoked; active sessions on other devices remain valid unless explicitly revoked via `POST /api/v1/auth/sessions/revoke-others`.
- **Idempotent Expiry Resilience:** Calling `/logout` with an already-expired JWT still clears cookies and returns `200 OK` so client sign-out never gets stuck in an error loop.

## Endpoint, Authorization & Error Mapping Matrix

| Aspect | Specification |
| :--- | :--- |
| **FR / Feature** | `FR 3.2.8` — Logout |
| **HTTP / WS Endpoints** | `POST /api/v1/auth/logout` |
| **Authorized Canonical Roles** | `Owner, Manager, Creator, Client, Admin` |
| **Controller -> Service** | `AuthController` -> `AuthServiceImpl, JwtUtil` |
| **Persistence / Cache Targets** | Redis `jwt:blacklist:{jti}`; PostgreSQL `user_refresh_tokens`, `audit_logs` (`ip_address`, `user_agent`) |
| **Business Rule Invariants** | `BR-05` |
| **Error Code Contract** | `401 INVALID_CREDENTIALS` (missing header); idempotent `200 OK` on expired token |

## Frontend Cache, i18n & Theme Architecture

- **Web State & Query Management (`brandhub-web`):**
  - Components & Hooks: `src/components/layout/Navbar.tsx`, `src/components/layout/Sidebar.tsx`, `src/services/authService.ts`, `src/stores/authStore.ts`.
  - Query Keys & Cache Invalidation: Scoped by authenticated `userId`, `agencyId`, or `workspaceId` so switching tenants or logging out never leaks cached records across boundaries.
  - Conflict & Error Recovery: Preserves in-progress user form state on `400`/`409` responses, disables duplicate in-flight submissions, and never falls back to hardcoded mock data.
- **Mobile Parity (`brandhub-mobile-app`):**
  - Screens & Services: `src/screens/settings/SettingsScreen.tsx`, `src/utils/confirmSignOut.ts`, `src/store/authStore.ts`.
  - Uses shared REST/WS contract, `expo-secure-store` Bearer token injection, and mobile `workspaceStore` / `authStore` synchronization.
- **Localization & Theme Standards:**
  - Key-parallel Vietnamese (`vi`) and English (`en`) locale entries under `auth.logout.* / common.logout` with zero hardcoded strings.
  - Semantic CSS variables / Tailwind `dark:` variants on Web and `useTheme()` semantic tokens on Mobile verified across Light and Dark modes.
- **Observability & Audit Correlation:**
  - Propagates `X-Request-Id` from `brandhub-api-gateway` into `ApiResponse.requestId` and structured backend logs / `audit_logs` where security-sensitive mutations occur.
- **BA & Module Traceability:** [BA Domain Spec](../../../../ba/02-authentication-profile.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md).
