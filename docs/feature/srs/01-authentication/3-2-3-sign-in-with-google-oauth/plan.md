> **Navigation:** [← Domain Index](../README.md) · [Spec](./spec.md) · **Plan** · [Task](./task.md) · [Test](./test.md)

# Plan — FR 3.2.3: Sign In with Google OAuth

> Implements [spec.md](./spec.md) — Backend-driven Google OAuth 2.0 authorization-code flow, CSRF state verification, case-insensitive account linking (`BR-01`), lifecycle checks (`BR-05`), and 2FA challenge support.

## 1. Technical Component Map

| Layer | Repository / Package | Concrete Classes & Files |
| :--- | :--- | :--- |
| **API Gateway** | `brandhub-api-gateway` | `GatewayConfig.java` (public routes `/api/v1/auth/oauth/google/**` and callback alias `/login/oauth2/code/google`) |
| **Controller** | `brandhub-business-service` | `controller/auth/GoogleOAuthController.java` (`redirect`, `callback`, plus authenticated `link`) |
| **Service** | `brandhub-business-service` | `service/impl/auth/GoogleOAuthService.java` (`fetchProfile` via `APPLICATION_FORM_URLENCODED`), `OAuthService.java`, `AuthServiceImpl.java` |
| **Persistence** | `brandhub-business-service` | `model/auth/UserOAuthProvider.java`, `UserOAuthProviderRepository.java`, `UserRepository.java`, Redis `oauth:state:{state}` |
| **Web Frontend** | `brandhub-web` | `src/pages/auth/OAuthCallbackPage.tsx`, `src/pages/auth/hooks/useOAuthCallback.ts`, `src/pages/auth/LoginPage.tsx` |
| **Mobile App** | `brandhub-mobile-app` | `app/(auth)/login.tsx`, `src/services/authService.ts` |

## 2. Resolved Engineering Defect & Form-Encoded Token Exchange

- **Root Cause Fixed:** `GoogleOAuthService.fetchProfile()` previously posted a JSON `Map.of(...)` body to `https://oauth2.googleapis.com/token`, which Google OAuth rejects because RFC 6749 requires `application/x-www-form-urlencoded`.
- **Implementation Fix:** Switched token exchange payload to `LinkedMultiValueMap<String, String>` with explicit `.contentType(MediaType.APPLICATION_FORM_URLENCODED)`, followed by `GET https://www.googleapis.com/oauth2/v2/userinfo` validating `verified_email == true`.

## 3. Database & Redis Schema

- **PostgreSQL `user_oauth_providers`:** `id` (`UUID`), `user_id` (`UUID` FK -> `users.id`), `provider` (`OAuthProvider.GOOGLE`), `provider_user_id` (`VARCHAR`, Google `sub`/`id`), `email`, `created_at` — `UNIQUE(provider, provider_user_id)`.
- **PostgreSQL `users`:** Auto-provisioned OAuth users have `email_verified_at = now`, `password_hash = null`, `full_name` and `avatar_url` populated from Google profile, and default `SystemRole.USER`.
- **Redis CSRF State:** `oauth:state:{state}` (cryptographically random token, single-use atomic read-and-delete, 5-minute TTL).

## 4. End-to-End Execution Flow

1. **Consent Redirect (`GET /api/v1/auth/oauth/google`):** Generates random `state`, stores `oauth:state:{state}` in Redis, and returns `302 Found` to Google's OAuth 2.0 consent endpoint.
2. **Callback Verification (`GET /api/v1/auth/oauth/google/callback` or `/login/oauth2/code/google`):**
   - Atomically consumes `oauth:state:{state}` from Redis; missing/expired state or provider `error` parameter redirects safely to `/login?error=oauth_failed`.
   - Exchanges authorization `code` via `APPLICATION_FORM_URLENCODED` POST and fetches verified Google user profile (`email`, `name`, `picture`).
3. **Case-Insensitive Account Merge or Auto-Provision (`BR-01`, `BR-05`):**
   - Normalizes email (`lowercase + trim`). If `User` exists, links `UserOAuthProvider(GOOGLE)` if not yet linked; otherwise creates `User` (`ACTIVE`, `emailVerifiedAt = now`, `passwordHash = null`) + `UserSystemRole(USER)` + `UserOAuthProvider`.
   - Enforces `checkStatus(user)` (`DEACTIVATED` / `SUSPENDED` redirect with error code).
4. **2FA Handoff vs Token Fragment Redirect:**
   - If `user.isTwoFactorEnabled()` is `true`: generates 5-minute `twoFactorToken` and redirects `302` to `/2fa-verify?twoFactorToken=...` (reusing `POST /api/v1/auth/2fa/verify`).
   - Otherwise: sets `HttpOnly` `refreshToken` cookie, writes `AuditLog(LOGIN)`, and redirects `302` to `/oauth/callback#token=<accessToken>`, where `useOAuthCallback.ts` extracts the fragment, clears URL history, loads `/users/me`, and routes into the app.

## Endpoint, Authorization & Error Mapping Matrix

| Aspect | Specification |
| :--- | :--- |
| **FR / Feature** | `FR 3.2.3` — Sign In with Google OAuth |
| **HTTP / WS Endpoints** | `GET /api/v1/auth/oauth/google · GET /api/v1/auth/oauth/google/callback · GET /login/oauth2/code/google` |
| **Authorized Canonical Roles** | `Guest, Owner, Manager, Creator, Client, Admin` |
| **Controller -> Service** | `GoogleOAuthController` -> `GoogleOAuthService, OAuthService, AuthServiceImpl` |
| **Persistence / Cache Targets** | PostgreSQL `users`, `user_oauth_providers`, `audit_logs`; Redis `oauth:state:{state}` |
| **Business Rule Invariants** | `BR-01, BR-05` |
| **Error Code Contract** | `302 ?error=oauth_failed` / `ACCOUNT_DEACTIVATED` / `ACCOUNT_SUSPENDED` |

## Frontend Cache, i18n & Theme Architecture

- **Web State & Query Management (`brandhub-web`):**
  - Components & Hooks: `src/pages/auth/LoginPage.tsx`, `src/pages/auth/OAuthCallbackPage.tsx`, `src/pages/auth/hooks/useOAuthCallback.ts`.
  - Query Keys & Cache Invalidation: Scoped by authenticated `userId`, `agencyId`, or `workspaceId` so switching tenants or logging out never leaks cached records across boundaries.
  - Conflict & Error Recovery: Preserves in-progress user form state on `400`/`409` responses, disables duplicate in-flight submissions, and never falls back to hardcoded mock data.
- **Mobile Parity (`brandhub-mobile-app`):**
  - Screens & Services: `app/(auth)/login.tsx`, `src/services/authService.ts`.
  - Uses shared REST/WS contract, `expo-secure-store` Bearer token injection, and mobile `workspaceStore` / `authStore` synchronization.
- **Localization & Theme Standards:**
  - Key-parallel Vietnamese (`vi`) and English (`en`) locale entries under `auth.oauth.* / auth.login.*` with zero hardcoded strings.
  - Semantic CSS variables / Tailwind `dark:` variants on Web and `useTheme()` semantic tokens on Mobile verified across Light and Dark modes.
- **Observability & Audit Correlation:**
  - Propagates `X-Request-Id` from `brandhub-api-gateway` into `ApiResponse.requestId` and structured backend logs / `audit_logs` where security-sensitive mutations occur.
- **BA & Module Traceability:** [BA Domain Spec](../../../../ba/02-authentication-profile.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md).
