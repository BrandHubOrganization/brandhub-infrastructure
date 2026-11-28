# 3.3 User & Client Profile (4 FRs)

> **Navigation:** [← Feature Master Index](../../README.md) · [← SRS 141 FRs Index](../README.md) · [BA Domain Spec](../../../ba/02-authentication-profile.md) · [Use Cases](../../../ba/use-cases/01-authentication-profile.md) · [Module Specs Index](../../modules/README.md) · [Workflow Rule](../../../rule/feature-workflow.md)

Canonical specification, technical implementation plan, task breakdown, and unit/acceptance test verification suite for **3.3 User & Client Profile** (`3.3.1 – 3.3.4`, **4 Atomic CRUD Functional Requirements**).

---

## 1. Domain Architecture Overview

Domain `3.3` separates **personal identity (`User`)** from **reusable brand representation (`ClientProfile`)** so a single user account can collaborate across multiple Agencies and Workspaces without duplicating accounts:

- **Personal User Profile (`3.3.1`, `3.3.2`):**
  - **Backend (`brandhub-business-service`):** `UserController` (`GET /api/v1/users/me`, `PUT /api/v1/users/me`, `POST /api/v1/users/me/avatar`, `POST /api/v1/users/me/banner`, `GET /api/v1/users/lookup`) → `UserServiceImpl` + `ProfileMatchingController` (`GET /api/v1/users/me/completeness`).
  - **Storage & Schema:** PostgreSQL `users` (`full_name`, `phone`, `avatar_url`, `banner_url`, `professional_title`, `bio`, `portfolio_urls`, `working_language`, `preferences` JSONB storing `timezone` and `notificationPreferences`), `user_system_roles`, and AWS S3 (`S3FileStorageServiceImpl`) for validated image uploads (max 5 MB, `image/*` magic-byte & MIME validation via `ImageValidator`).
- **User-Owned Client Profiles (Multi-Brand Representation) (`3.3.3`, `3.3.4`):**
  - **Backend (`brandhub-business-service`):** `ClientProfileController` (`GET /api/v1/client-profile/mine`, `POST /api/v1/client-profile`, `POST /api/v1/client-profile/logo`, `GET /api/v1/client-profile/{profileId}`, `PUT /api/v1/client-profile/{profileId}`, `POST /api/v1/client-profile/{profileId}/logo`, `DELETE /api/v1/client-profile/{profileId}`) → `ClientProfileServiceImpl` + `ClientProfileRepository`.
  - **Decoupled Ownership Model (V2 Architecture):** `client_profiles` belongs strictly to `user_id` (no `agency_id` column). One `Client` user can maintain multiple brand profiles (e.g., distinct brands or subsidiaries) and attach any profile to any Workspace via `workspace_members.client_profile_id`. Deletion is guarded by `409 CLIENT_PROFILE_IN_USE` while linked to an active Workspace membership.
- **Client Surfaces (`brandhub-web` & `brandhub-mobile-app`):**
  - **Web (`brandhub-web`):** `src/pages/profile/index.tsx` (`ProfileViewDetails`, `ProfileEditForm`, `AvatarUploadModal`, `LinkPhoneModal`, `CompletenessCard`), `src/pages/workspace/client-profile.tsx`, `src/pages/workspace/clients.tsx`, `src/services/{userService,clientProfileService}.ts`.
  - **Mobile (`brandhub-mobile-app`):** `src/screens/settings/AccountSettingsScreen.tsx`, `src/screens/more/{ClientsScreen,ClientProfileScreen}.tsx`, `src/services/{userService,clientProfileService}.ts`.

---

## 2. Functional Requirements Matrix

| FR ID | UC ID | Function Name | Canonical Roles | Status | Feature Artefacts (`spec → plan → task → test`) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `3.3.1` | `UC-010` | **View User Profile** | `Owner, Manager, Creator, Client, Admin` | Implemented | [Spec](./3-3-1-view-user-profile/spec.md) · [Plan](./3-3-1-view-user-profile/plan.md) · [Task](./3-3-1-view-user-profile/task.md) · [Test](./3-3-1-view-user-profile/test.md) |
| `3.3.2` | `UC-011` | **Update User Profile** | `Owner, Manager, Creator, Client, Admin` | Implemented | [Spec](./3-3-2-update-user-profile/spec.md) · [Plan](./3-3-2-update-user-profile/plan.md) · [Task](./3-3-2-update-user-profile/task.md) · [Test](./3-3-2-update-user-profile/test.md) |
| `3.3.3` | `UC-012` | **View Client Profile** | `Owner, Manager, Client` | Implemented | [Spec](./3-3-3-view-client-profile/spec.md) · [Plan](./3-3-3-view-client-profile/plan.md) · [Task](./3-3-3-view-client-profile/task.md) · [Test](./3-3-3-view-client-profile/test.md) |
| `3.3.4` | `UC-013` | **Update Client Profile** | `Owner, Manager, Client` | Implemented | [Spec](./3-3-4-update-client-profile/spec.md) · [Plan](./3-3-4-update-client-profile/plan.md) · [Task](./3-3-4-update-client-profile/task.md) · [Test](./3-3-4-update-client-profile/test.md) |

---

## 3. Core Business Rules & Ownership Invariants

- **`BR-11` (Immutable Principal Email & Validated Media):** Personal profile updates derive identity strictly from `@AuthenticationPrincipal` (`/api/v1/users/me`), prohibit email mutation, and enforce `image/*` MIME + 5 MB size limits on avatar/banner uploads.
- **`BR-13` (User-Owned Reusable Client Profiles):** Each `ClientProfile` is owned by one `User` (`user_id`) and reusable across multiple Workspaces and Agencies via `workspace_members.client_profile_id`.
- **`BR-14` (Ownership & Active-Link Deletion Guard):** Only the owning user may update or delete a `ClientProfile` (`403 CLIENT_PROFILE_NOT_OWNED`), and deletion is rejected (`409 CLIENT_PROFILE_IN_USE`) while any active `workspace_members` record references that profile.

## 4. Cross-References

- **BA Domain Specification:** [02-authentication-profile.md](../../../ba/02-authentication-profile.md)
- **BA System Overview:** [BA Overview](../../../ba/README.md)
- **Consolidated Feature Modules:** [Module Specs Index](../../modules/README.md)

---

## 5. Endpoint & Persistence Reference

| FR ID | Primary HTTP Endpoints | Backend Controller & Service | Primary Storage | Web & Mobile Surfaces |
| :--- | :--- | :--- | :--- | :--- |
| `3.3.1` | `GET /api/v1/users/me`<br>`GET /api/v1/users/me/completeness` | `UserController` -> `UserServiceImpl`<br>`ProfileMatchingController` -> `CompletenessService` | PostgreSQL `users`, `user_system_roles`, `workspace_members` | Web: `/profile` (`ProfileViewDetails`)<br>Mobile: `AccountSettingsScreen` |
| `3.3.2` | `PUT /api/v1/users/me`<br>`POST /api/v1/users/me/avatar`<br>`POST /api/v1/users/me/banner` | `UserController` -> `UserServiceImpl`, `S3FileStorageServiceImpl`, `ImageValidator` | PostgreSQL `users` (`preferences` JSONB) + AWS S3 (`avatars/`, `banners/`) | Web: `/profile` (`ProfileEditForm`, `AvatarUploadModal`)<br>Mobile: `AccountSettingsScreen` |
| `3.3.3` | `GET /api/v1/client-profile/mine`<br>`GET /api/v1/client-profile/{profileId}`<br>`GET /api/v1/workspaces/{workspaceId}/members` | `ClientProfileController` -> `ClientProfileServiceImpl`<br>`WorkspaceController` -> `WorkspaceServiceImpl` | PostgreSQL `client_profiles` (`user_id` FK), `workspace_members` (`client_profile_id`) | Web: `/client-profiles`, `/workspaces/:id/clients`<br>Mobile: `ClientsScreen`, `ClientProfileScreen` |
| `3.3.4` | `POST /api/v1/client-profile`<br>`PUT /api/v1/client-profile/{profileId}`<br>`POST /api/v1/client-profile/{profileId}/logo`<br>`DELETE /api/v1/client-profile/{profileId}` | `ClientProfileController` -> `ClientProfileServiceImpl`, `S3FileStorageServiceImpl` | PostgreSQL `client_profiles`, `workspace_members` + AWS S3 (`client-logos/`) | Web: `/client-profiles`<br>Mobile: `ClientProfileScreen` |
