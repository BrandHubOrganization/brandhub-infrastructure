> **Navigation:** [← Domain Index](../README.md) · [Spec](./spec.md) · [Plan](./plan.md) · **Task** · [Test](./test.md)

# Task — FR 3.4.24: Add Workspace Member

> Comprehensive implementation & verification checklist mapped 1-to-1 from [spec.md](./spec.md) and [plan.md](./plan.md).

## 1. Backend API, DTOs & Domain Service (`brandhub-business-service` & `brandhub-api-gateway`)

- [x] Verify API Gateway routing, rate limiting, and JWT filter configuration for `POST /api/v1/workspaces/{workspaceId}/members/assign · POST /api/v1/workspaces/{workspaceId}/members/invite · POST /api/v1/workspaces/{workspaceId}/clients · GET /api/v1/workspaces/{workspaceId}/assignee-suggestions`.
- [x] Implement controller handler(s) in `WorkspaceController.assignMembers() / inviteMember() / addClient(), ProfileMatchingController.assigneeSuggestions()` with `@Valid` request payload validation and `X-Request-Id` correlation header propagation.
- [x] Enforce canonical role and tenant access control (`Owner, Manager`) at both controller (`@RequireRole`) and service (`WorkspaceAccessService` / ownership) layers.
- [x] Implement core domain logic in `WorkspaceServiceImpl.assignMembers() / inviteMember() / addClient(), SuggestionService` enforcing business rules `BR-20` without silent no-ops or unvalidated state transitions.
- [x] Define typed request/response DTO records wrapped in `ApiResponse<T>` without leaking internal entity fields, password hashes, or raw storage keys.
- [x] Map all validation, authorization, missing-resource, and concurrency failures deterministically to `ErrorCode` (`400 VALIDATION_ERROR`, `403 FORBIDDEN`, `404 USER_NOT_IN_AGENCY`, `409 ALREADY_WORKSPACE_MEMBER` / `MANAGER_ALREADY_ASSIGNED`) via `GlobalExceptionHandler`.

## 2. Database Schema, Indexes & Ephemeral State

- [x] Verify persistence mappings, constraints, and `@Transactional` / CAS atomicity across PostgreSQL `workspace_members`, `agency_members`, `workspace_invitations`, `client_profiles`.
- [x] Verify tenant-prefixed lookup and uniqueness indexes so queries scale cleanly without full-table or unbounded collection scans.
- [x] Verify soft-delete filtering, Redis TTL/cooldown keys, outbox event durability, and S3 object lifecycle cleanup where applicable to `FR 3.4.24`.

## 3. Web Application UI, i18n & Theme (`brandhub-web`)

- [x] Wire typed API client methods and TanStack Query queries/mutations in `src/pages/workspace/members.tsx`, `src/pages/workspace/clients.tsx`, `src/pages/workspace/components/{AssignMemberPicker,InviteMemberDialog,AddClientDialog,ClientInvitePicker}.tsx` against live `/api/v1/**` endpoints (zero mock fallback).
- [x] Implement distinct **Loading** (skeleton/spinner + disabled submit), **Empty**, **Success** (scoped cache invalidation + localized toast), **Conflict (`409`)**, and **Error/Retry** states.
- [x] Enforce role-gated UI visibility matching `Owner, Manager` using server capabilities / verified membership context.
- [x] Add and verify key-parallel translations in `src/i18n/locales/vi/*.json` and `src/i18n/locales/en/*.json` (`workspace.members.add.* / workspace.clients.add.*`) with zero hardcoded Vietnamese or English text.
- [x] Verify semantic Light and Dark theme contrast (`dark:` variants / CSS custom properties), keyboard navigation (`Tab`, `Enter`, `Escape`), and responsive layout (`375px`, `768px`, `1440px`).

## 4. Mobile Application Parity (`brandhub-mobile-app`)

- [x] Wire mobile service client and screen state in `src/screens/workspace/{WorkspaceMembersScreen,WorkspaceInviteMemberScreen}.tsx`, `src/services/workspaceService.ts` aligned with `POST /api/v1/workspaces/{workspaceId}/members/assign · POST /api/v1/workspaces/{workspaceId}/members/invite · POST /api/v1/workspaces/{workspaceId}/clients · GET /api/v1/workspaces/{workspaceId}/assignee-suggestions`.
- [x] Synchronize `authStore` / `workspaceStore` state transitions, error banners, and pull-to-refresh / retry interactions on mobile.
- [x] Verify mobile `vi` / `en` localization keys and `useTheme()` semantic Light/Dark tokens.

## 5. Automated Testing & Quality Gates

- [x] Execute JUnit 5 unit and service test cases verifying every normal (`N`), boundary (`B`), and abnormal (`A`) `UTCID` scenario in [test.md](./test.md).
- [x] Verify negative security boundaries: unauthenticated (`401`), unauthorized role / cross-tenant access (`403`), and stale revision / duplicate submission (`409`).
- [x] Run `mvn test` in `brandhub-business-service` and `tsc --noEmit` + Vite production bundle check in `brandhub-web`.
- [x] Cross-check traceability links across [spec.md](./spec.md), [plan.md](./plan.md), [test.md](./test.md), and [BA Domain Spec](../../../../ba/03-agency-workspace.md).

## 6. Phase-to-Plan & Verification Traceability Matrix

| Implementation Phase | Primary Plan Reference | Verification Gate | Status |
| :--- | :--- | :--- | :---: |
| **1. Backend API & Domain Service** | [plan.md §1 & §3](./plan.md) | JUnit 5 service & ErrorCode suite ([test.md](./test.md)) | Completed |
| **2. Database, Index & Cache/S3** | [plan.md §2](./plan.md) | Schema constraint, index & @Transactional/CAS check | Completed |
| **3. Web UI, i18n (i/en) & Theme** | [plan.md Frontend Architecture](./plan.md) | 	sc --noEmit, Vite build, VI/EN & Light/Dark parity | Completed |
| **4. Mobile App Parity** | [plan.md Frontend Architecture](./plan.md) | Mobile service contract & useTheme() token check | Completed |
| **5. End-to-End & Tenant Security** | [spec.md](./spec.md) · [BA Spec](../../../../ba/03-agency-workspace.md) | 401 / 403 / 409 boundary & regression check for FR 3.4.24 | Completed |
