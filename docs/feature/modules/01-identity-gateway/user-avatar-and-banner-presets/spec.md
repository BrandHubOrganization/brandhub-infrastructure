> **Navigation:** [← Category Index](../README.md) · [← Modules Master Index](../../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# Unified People Avatars, Banner Presets & S3 Image Upload Pipeline

| Field | Value |
| :--- | :--- |
| **Module Slug** | `user-avatar-and-banner-presets` |
| **Category** | `01-identity-gateway` — Identity, API Gateway & Edge Security |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client, Admin` |
| **Consolidated Feature Scopes** | `people-avatars` |
| **Aligned SRS Domains** | [3.3 User & Client Profile](../../../srs/02-profile/README.md) (`3.3.1–3.3.4`) |
| **Status** | Implemented — Production Verified |

## 1. Objective & Architectural Motivation

Deliver consistent, zero-broken-image identity rendering (custom S3 avatars, curated illustrated avatar/banner presets, and deterministic initials fallback) across every user-facing surface in BrandHub: Sidebar, Agency/Workspace participant tables, Task assignees & comments, Workspace Chat, Approval trails, and Admin Account tables.

## 2. User Stories

- As an `Owner`, `Manager`, `Creator`, `Client`, or `Admin`, I want my custom uploaded avatar/banner or selected preset to appear consistently across every Workspace, Task, Chat message, and Profile card without broken image icons or layout shifts.

## 3. Consolidated Acceptance Criteria

1. **Three-Tier Avatar Resolution (`people-avatars`):** Resolves `avatarUrl` (S3/CDN `/api/v1/public/images/**` or OAuth picture) -> curated BrandHub preset identifier -> deterministic WCAG-contrasted initials badge derived from `fullName` / `email`.
2. **Custom S3 Crop & Upload (`UserController`):** `POST /api/v1/users/me/avatar` and `POST /api/v1/users/me/banner` validate MIME magic bytes (`JPEG`, `PNG`, `WebP`, `<= 5 MB`), crop/normalize via `ImageCropperModal.tsx`, upload to S3, and update `users.avatar_url` / `banner_url`.
3. **Universal Surface Rollout:** Shared `UserAvatar` primitive renders identically across Agency member rosters, Workspace rosters, Task Kanban/Table/Detail/Comments, Chat channels/threads/calls, Collaborator/Client cards, and Admin User Directory.
4. **Graceful Broken-URL Fallback:** Image `onError` transitions smoothly to deterministic initials without retry loops or layout jitter.
5. **Internationalization (`vi.json` + `en.json`):** Every user-facing string, tooltip, dialog prompt, status badge, and error banner uses key-parallel translations (`profile.avatar.{upload,choosePreset,cropTitle,remove,sizeLimitError}` in `src/i18n/locales/{vi,en}/profile.json`) on `brandhub-web` and `tr()` (`en.json` + `vi/common.json`) on `brandhub-mobile-app` with zero hardcoded Vietnamese or English strings in JSX/TSX.
6. **Light & Dark Mode Compliance:** All surfaces, drawers, badges, charts, and interactive controls use semantic CSS variables / Tailwind `dark:` variants on Web and `useAppPreferences().palette` tokens on Mobile, achieving WCAG AA contrast in both Light and Dark themes.

## 4. UI / UX Surfaces & Lifecycle States

- **Web Surfaces (`brandhub-web`):** `components/shared/image-editor/ImageCropperModal.tsx`, shared `UserAvatar` component across `pages/{agency,workspace,tasks,chat,admin}/*`
- **Mobile Surfaces (`brandhub-mobile-app`):** `src/screens/settings/AccountSettingsScreen.tsx` (`expo-image-picker` + `expo-image-manipulator` + `expo-image`)
- **UI States:**
  - **Loading / Streaming:** Deterministic skeleton placeholders, progress bars, and disabled submit buttons preventing duplicate requests.
  - **Empty / Onboarding:** Contextual empty state with localized call-to-action and zero fabricated mock fallback data.
  - **Active / Realtime Sync:** Scoped `TanStack Query` cache updates + WebSocket/SSE/polling synchronization where applicable.
  - **Error / Conflict Recovery:** Actionable localized error banners (`400/403/404/409/429/503`) preserving unsaved user input.

## 5. API, Messaging & Protocol Contract

| Route / Channel / Filter | Auth / Scope | Service & Handler |
| :--- | :--- | :--- |
| `POST /api/v1/users/me/avatar` | Bearer (`Owner, Manager, Creator, Client, Admin`) | `UserController.uploadAvatar()` -> S3 upload + `users.avatar_url` update |
| `POST /api/v1/users/me/banner` | Bearer (`Owner, Manager, Creator, Client, Admin`) | `UserController.uploadBanner()` -> S3 upload + `users.banner_url` update |
| `PUT /api/v1/users/me` | Bearer (`Owner, Manager, Creator, Client, Admin`) | `UserController.updateMe()` -> persists preset key or profile metadata |
| `GET /api/v1/public/images/**` | Public Read (Cached) | `PublicImageController` -> serves public avatar/banner/logo assets with cache headers |

## 6. Error Handling, Security & Edge Cases

- **Oversize / Disguised SVG or Executable:** Rejected `400/413` by server-side magic-byte inspection (SVG disallowed for user avatars to prevent stored XSS).
- **Deactivated User Historical Attribution:** Historical Task comments and Chat messages retain non-clickable display name and fallback avatar.

## 7. Related Specifications & References

- **Aligned SRS Functional Requirements:** [3.3 User & Client Profile](../../../srs/02-profile/README.md) (`3.3.1–3.3.4`)
- **BA & Architecture References:** [BA 02 Authentication & Profile](../../../../ba/02-authentication-profile.md) · [Roles & Permissions Matrix](../../../../ba/10-roles-permissions-matrix.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Production code verified across backend, AI/publisher workers, Web, and Mobile; `vi.json` + `en.json` parity verified; Light/Dark mode audited; all automated verification suites in [test.md](./test.md) passing.
- **Out of Scope:** De-scoped SRS items (livestream features, subscription plan downgrades, PayOS/VNPay/Stripe gateways, Zalo OA publishing, or copyright/plagiarism scanning).
