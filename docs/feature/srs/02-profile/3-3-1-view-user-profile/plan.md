> **Navigation:** [← Domain Index](../README.md) · [Spec](./spec.md) · **Plan** · [Task](./task.md) · [Test](./test.md)

# Plan — FR 3.3.1: View User Profile

> Implements [spec.md](./spec.md) — Principal-scoped personal profile retrieval (`GET /api/v1/users/me`) and profile completeness scoring (`GET /api/v1/users/me/completeness`).

## 1. Technical Component Map

| Layer | Repository / Package | Concrete Classes & Files |
| :--- | :--- | :--- |
| **API Gateway** | `brandhub-api-gateway` | `JwtAuthFilterGatewayFilterFactory.java` (validates JWT and forwards principal context to `/api/v1/users/**`) |
| **Controller** | `brandhub-business-service` | `controller/user/UserController.java` (`GET /api/v1/users/me`), `controller/collaborator/ProfileMatchingController.java` (`GET /api/v1/users/me/completeness`) |
| **Service** | `brandhub-business-service` | `service/impl/user/UserServiceImpl.java` (`getUserProfile`, `toResponse`), `service/matching/CompletenessService.java` |
| **DTOs & Errors** | `brandhub-business-service` | `UserProfileResponse`, `CompletenessService.Result`, `ErrorCode` (`UNAUTHORIZED`, `USER_NOT_FOUND`) |
| **Persistence** | `brandhub-business-service` | `model/user/User.java`, `UserRepository.java`, `UserSystemRoleRepository.java`, `WorkspaceMemberRepository.java` |
| **Web Frontend** | `brandhub-web` | `src/pages/profile/index.tsx`, `src/pages/profile/components/{ProfileViewDetails,ProfilePreviewCard}.tsx`, `src/components/shared/CompletenessCard.tsx`, `src/services/userService.ts` |
| **Mobile App** | `brandhub-mobile-app` | `src/screens/settings/AccountSettingsScreen.tsx`, `src/services/userService.ts` |

## 2. API Contract & Response Mapping

```http
GET /api/v1/users/me
Authorization: Bearer <accessToken>
-> 200 ApiResponse<UserProfileResponse>
```

- **Returned Fields (`UserProfileResponse`):** `userId`, `email`, `fullName`, `avatarUrl`, `bannerUrl`, `phone`, `role` (`SystemRole`, defaulting to `USER`), `workspaceId` (from token claim or fallback first active `WorkspaceMember`), `professionalTitle`, `bio`, `portfolioUrls` (`List<String>` safely deserialized from JSON string; empty list on null/blank), `skills`, `location`, `socialLinks`, `workingLanguage`, `timezone`, `notificationPreferences`, `createdAt`.
- **Principal Isolation:** Identity is derived strictly from `@AuthenticationPrincipal AuthenticatedUser`; no caller-supplied `userId` parameter exists on `/me`, guaranteeing zero horizontal privilege escalation.

## 3. PostgreSQL Data Model

- **`users` table:** `id` (`UUID` PK), `email` (`VARCHAR` unique), `full_name`, `phone` (`VARCHAR(20)` unique, nullable), `avatar_url`, `banner_url`, `professional_title`, `bio`, `portfolio_urls` (JSON array text), `working_language`, `preferences` (`JSONB` storing `timezone` and `notificationPreferences`), `created_at`.
- **`user_system_roles` & `workspace_members`:** Read-only joins/lookups to resolve global `SystemRole` and active `workspaceId` context.

## 4. End-to-End Execution Flow

1. Signed-in actor (`Owner, Manager, Creator, Client, Admin`) navigates to `/profile` (Web) or `AccountSettingsScreen` (Mobile).
2. Frontend calls `userService.getProfile()` (`GET /api/v1/users/me`) with TanStack Query caching keyed by authenticated `userId`.
3. `UserServiceImpl.getUserProfile()` loads `User` by `currentUser.getId()` (`404 USER_NOT_FOUND` if absent), resolves `SystemRole` and `workspaceId`, parses `preferences` JSONB (`timezone`, `notificationPreferences`) and `portfolioUrls`, and returns `UserProfileResponse`.
4. UI renders `ProfileBannerHeader` + `ProfileViewDetails` (falling back to deterministic initials avatar `UserAvatar` when `avatarUrl` is empty, without mock data).

## Endpoint, Authorization & Error Mapping Matrix

| Aspect | Specification |
| :--- | :--- |
| **FR / Feature** | `FR 3.3.1` — View User Profile |
| **HTTP / WS Endpoints** | `GET /api/v1/users/me · GET /api/v1/users/me/completeness` |
| **Authorized Canonical Roles** | `Owner, Manager, Creator, Client, Admin` |
| **Controller -> Service** | `UserController, ProfileMatchingController` -> `UserServiceImpl, CompletenessService` |
| **Persistence / Cache Targets** | PostgreSQL `users` (`preferences` JSONB), `user_system_roles`, `workspace_members` |
| **Business Rule Invariants** | `BR-11` |
| **Error Code Contract** | `401 UNAUTHORIZED`, `404 USER_NOT_FOUND` |

## Frontend Cache, i18n & Theme Architecture

- **Web State & Query Management (`brandhub-web`):**
  - Components & Hooks: `src/pages/profile/index.tsx`, `src/pages/profile/components/{ProfileViewDetails,ProfilePreviewCard}.tsx`, `src/components/shared/CompletenessCard.tsx`, `src/services/userService.ts`.
  - Query Keys & Cache Invalidation: Scoped by authenticated `userId`, `agencyId`, or `workspaceId` so switching tenants or logging out never leaks cached records across boundaries.
  - Conflict & Error Recovery: Preserves in-progress user form state on `400`/`409` responses, disables duplicate in-flight submissions, and never falls back to hardcoded mock data.
- **Mobile Parity (`brandhub-mobile-app`):**
  - Screens & Services: `src/screens/settings/AccountSettingsScreen.tsx`, `src/services/userService.ts`.
  - Uses shared REST/WS contract, `expo-secure-store` Bearer token injection, and mobile `workspaceStore` / `authStore` synchronization.
- **Localization & Theme Standards:**
  - Key-parallel Vietnamese (`vi`) and English (`en`) locale entries under `profile.*` with zero hardcoded strings.
  - Semantic CSS variables / Tailwind `dark:` variants on Web and `useTheme()` semantic tokens on Mobile verified across Light and Dark modes.
- **Observability & Audit Correlation:**
  - Propagates `X-Request-Id` from `brandhub-api-gateway` into `ApiResponse.requestId` and structured backend logs / `audit_logs` where security-sensitive mutations occur.
- **BA & Module Traceability:** [BA Domain Spec](../../../../ba/02-authentication-profile.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md).
