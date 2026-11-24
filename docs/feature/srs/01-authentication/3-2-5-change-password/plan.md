> **Navigation:** [← Domain Index](../README.md) · [Spec](./spec.md) · **Plan** · [Task](./task.md) · [Test](./test.md)

# Plan — FR 3.2.5: Change Password

> Implements [spec.md](./spec.md) — Authenticated password change (`POST /api/v1/auth/change-password`, plus OTP-verified change/set-password support), current password verification, password reuse guard (`BR-08`), and other-device refresh token invalidation.

## 1. Technical Component Map

| Layer | Repository / Package | Concrete Classes & Files |
| :--- | :--- | :--- |
| **API Gateway** | `brandhub-api-gateway` | `JwtAuthFilterGatewayFilterFactory.java` (enforces valid `Bearer` JWT on `/api/v1/auth/change-password*` and `/set-password`) |
| **Controller** | `brandhub-business-service` | `controller/auth/AuthController.java` (`changePassword`, `sendPasswordChangeOtp`, `changePasswordWithOtp`, `setPassword`, `revokeOtherSessions`) |
| **Service** | `brandhub-business-service` | `service/impl/auth/AuthServiceImpl.java` (`changePassword`, `setPassword`, `revokeOtherSessions`) |
| **DTOs & Errors** | `brandhub-business-service` | `ChangePasswordRequest(currentPassword, newPassword)`, `ErrorCode` (`WRONG_CURRENT_PASSWORD`, `SAME_AS_CURRENT_PASSWORD`, `VALIDATION_ERROR`) |
| **Persistence** | `brandhub-business-service` | `UserRepository.java`, `UserRefreshTokenRepository.java`, `AuditLogRepository.java` |
| **Web Frontend** | `brandhub-web` | `src/pages/security/index.tsx`, `src/pages/security/components/{ChangePasswordCard,ActiveSessionsCard}.tsx`, `src/services/authService.ts` |
| **Mobile App** | `brandhub-mobile-app` | `src/screens/settings/SecuritySettingsScreen.tsx`, `src/services/authService.ts` |

## 2. Database Schema & Session Impact

- **PostgreSQL `users`:** Updates `password_hash` (BCrypt cost 12) and `last_password_change` (`TIMESTAMPTZ`).
- **PostgreSQL `user_refresh_tokens`:** Stamping `last_password_change = Instant.now()` invalidates refresh tokens issued prior to the change on other devices at their next refresh attempt while keeping the caller's active in-memory `accessToken` usable (no forced logout of the active browser tab).
- **PostgreSQL `audit_logs`:** Appends `AuditAction.PASSWORD_RESET` / security audit entry with `userId`, `ipAddress`, and `userAgent`.

## 3. End-to-End Execution Flow

1. **Authenticated Request (`POST /api/v1/auth/change-password`):**
   - Extracts `userId` strictly from `@AuthenticationPrincipal AuthenticatedUser` (`401 UNAUTHORIZED` if token missing/expired/blacklisted).
   - Bean Validation enforces `currentPassword` (`@NotBlank`) and `newPassword` (`BR-02`: min 8 chars, >= 1 digit).
2. **Credential & Distinctness Verification (`BR-02`, `BR-08`):**
   - Loads `User` (`404 USER_NOT_FOUND` if missing).
   - Verifies `passwordEncoder.matches(currentPassword, user.getPasswordHash())`; if mismatch -> `400 WRONG_CURRENT_PASSWORD`.
   - Checks `passwordEncoder.matches(newPassword, user.getPasswordHash())`; if identical -> `400 SAME_AS_CURRENT_PASSWORD` (checked strictly *after* verifying `currentPassword` so attackers with a stolen session cannot probe password equality without knowing the current password).
3. **Persistence & Audit:**
   - Hashes `newPassword` with BCrypt cost 12, sets `lastPasswordChange = Instant.now()`, persists `User`, writes `AuditLog`, and returns `200 ApiResponse<Void>`.
   - Note: OAuth-only users (`passwordHash == null`) are routed to `POST /api/v1/auth/set-password` on the same Security screen to establish an initial password.

## 4. Security & UX Considerations

- **Validation Ordering:** Always verify `currentPassword` before checking `SAME_AS_CURRENT_PASSWORD` or mutating state.
- **Client Form Hygiene:** Clear all three password inputs (`currentPassword`, `newPassword`, `confirmPassword`) immediately after `200 OK` and toast localized confirmation.

## Endpoint, Authorization & Error Mapping Matrix

| Aspect | Specification |
| :--- | :--- |
| **FR / Feature** | `FR 3.2.5` — Change Password |
| **HTTP / WS Endpoints** | `POST /api/v1/auth/change-password · POST /api/v1/auth/set-password` |
| **Authorized Canonical Roles** | `Owner, Manager, Creator, Client, Admin` |
| **Controller -> Service** | `AuthController` -> `AuthServiceImpl` |
| **Persistence / Cache Targets** | PostgreSQL `users` (`password_hash`, `last_password_change`), `user_refresh_tokens`, `audit_logs` |
| **Business Rule Invariants** | `BR-02, BR-08` |
| **Error Code Contract** | `400 WRONG_CURRENT_PASSWORD` / `SAME_AS_CURRENT_PASSWORD` / `VALIDATION_ERROR`, `401 UNAUTHORIZED` |

## Frontend Cache, i18n & Theme Architecture

- **Web State & Query Management (`brandhub-web`):**
  - Components & Hooks: `src/pages/security/index.tsx`, `src/pages/security/components/ChangePasswordCard.tsx`, `src/services/authService.ts`.
  - Query Keys & Cache Invalidation: Scoped by authenticated `userId`, `agencyId`, or `workspaceId` so switching tenants or logging out never leaks cached records across boundaries.
  - Conflict & Error Recovery: Preserves in-progress user form state on `400`/`409` responses, disables duplicate in-flight submissions, and never falls back to hardcoded mock data.
- **Mobile Parity (`brandhub-mobile-app`):**
  - Screens & Services: `src/screens/settings/SecuritySettingsScreen.tsx`, `src/services/authService.ts`.
  - Uses shared REST/WS contract, `expo-secure-store` Bearer token injection, and mobile `workspaceStore` / `authStore` synchronization.
- **Localization & Theme Standards:**
  - Key-parallel Vietnamese (`vi`) and English (`en`) locale entries under `security.changePassword.*` with zero hardcoded strings.
  - Semantic CSS variables / Tailwind `dark:` variants on Web and `useTheme()` semantic tokens on Mobile verified across Light and Dark modes.
- **Observability & Audit Correlation:**
  - Propagates `X-Request-Id` from `brandhub-api-gateway` into `ApiResponse.requestId` and structured backend logs / `audit_logs` where security-sensitive mutations occur.
- **BA & Module Traceability:** [BA Domain Spec](../../../../ba/02-authentication-profile.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md).
