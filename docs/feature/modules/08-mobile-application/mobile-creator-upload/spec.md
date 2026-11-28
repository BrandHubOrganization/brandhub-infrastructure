> **Navigation:** [← Category Index](../README.md) · [← Modules Master Index](../../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# Mobile Pro VisionCamera Capture, Offline-Resilient S3 Multipart Sync & Task Take Promotion

| Field | Value |
| :--- | :--- |
| **Module Slug** | `mobile-creator-upload` |
| **Category** | `08-mobile-application` — BrandHub Mobile Application (Expo SDK 58 / React Native 0.88) |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Consolidated Feature Scopes** | `mobile-creator-upload`, `mobile-video-task-sync`, `mobile-native-enhancements (OfflineBanner & Haptics)` |
| **Aligned SRS Domains** | [3.6 Content & Workflow — Material Repository & Task Content](../../../srs/05-content-task-workflow/README.md) (`3.6.11–3.6.16`, `3.6.4`) |
| **Status** | Implemented — Production Verified |

## 1. Objective & Architectural Motivation

Deliver BrandHub Mobile's flagship on-site production capability: **Cinema-Style Native Camera Capture** (`react-native-vision-camera` 5.2.4 with real hardware FPS, Shutter, ISO, WB, EV, Torch, Stabilization & Teleprompter script overlay), **Automatic Offline-Resilient S3 Multipart Task Upload Queue** (`mediaSyncService.ts` + Wi-Fi-only toggle + HEIC->JPEG conversion), and **Creator Take-to-Draft Promotion** synced directly to Web Task Detail.

## 2. User Stories

- As an on-site `Creator`, I want to shoot vertical/horizontal takes using real hardware camera controls (`CameraRecordScreen.tsx`) or pick gallery clips, have takes auto-upload in the background/foreground queue (resuming automatically after offline drops), and promote the best take into the Task draft for `Manager` review.

## 3. Consolidated Acceptance Criteria

1. **Pro Hardware Camera Deck (`CameraRecordScreen.tsx`, `mobile-video-task-sync` AC-12..13):** Built on `react-native-vision-camera` 5.2.4 (`CameraBottomDeck.tsx`, `CameraDrawerAndRail.tsx`, `CameraOverlays.tsx`, `nativeCameraGuard.ts`). Exposes real hardware-verified FPS, resolution, stabilization, EV exposure bias, torch, zoom, and capability-gated manual Shutter & White Balance Kelvin sliders (gracefully falling back to `CameraUnavailableScreen.tsx` on simulators/unsupported devices; zero fake ND/zebra/audio meters).
2. **Offline-Resilient Auto-Upload Queue (`mediaSyncService.ts`, `uploadService.ts`):** Captured or gallery-picked files (`.mp4` `isom`/`mp42`, `.mov` `video/quicktime`, `JPEG/PNG/WebP`, plus automatic on-device `HEIC -> JPEG` via `expo-image-manipulator`) enqueue immediately, persist across app restarts, pause cleanly with `OfflineBanner.tsx` (`@react-native-community/netinfo`) or optional 'Wi-Fi Only' toggle, auto-renew expired S3 upload sessions (`POST /materials/upload-session[/multipart]`), and never auto-submit the Task for approval.
3. **Task Sync & Client Pre-Review Privacy (`mobile-video-task-sync` AC-10..11):** Uploaded takes link directly to `taskId` (`RAW` material) and appear live in Web Task Detail ('Files from Mobile') for `Owner`, `Manager`, and `Creator`. Before the Task enters `CLIENT_REVIEW`, `Client` never sees raw unpromoted takes (`url: null` / `POST_NOT_FOUND`); once the assigned `Creator` promotes the chosen take into the post draft and submits for review, `Manager` and `Client` review the exact selected clip.
4. **Internationalization (`vi.json` + `en.json`):** Every user-facing string, tooltip, dialog prompt, status badge, and error banner uses key-parallel translations (`camera.*`, `upload.*`, `offlineBanner.*` in `src/i18n/locales/en.json` & `src/i18n/locales/vi/common.json` (`tr()`)) on `brandhub-web` and `tr()` (`en.json` + `vi/common.json`) on `brandhub-mobile-app` with zero hardcoded Vietnamese or English strings in JSX/TSX.
5. **Light & Dark Mode Compliance:** All surfaces, drawers, badges, charts, and interactive controls use semantic CSS variables / Tailwind `dark:` variants on Web and `useAppPreferences().palette` tokens on Mobile, achieving WCAG AA contrast in both Light and Dark themes.

## 4. UI / UX Surfaces & Lifecycle States

- **Web Surfaces (`brandhub-web`):** `pages/tasks/detail.tsx` ('Mobile Uploads' preview & take promotion section)
- **Mobile Surfaces (`brandhub-mobile-app`):** `src/screens/content/{CameraRecordScreen,CameraUnavailableScreen,TaskUploadScreen,UploadScreen}.tsx`, `src/components/camera/*`, `src/components/common/OfflineBanner.tsx`, `src/services/{mediaSyncService,uploadService}.ts`
- **UI States:**
  - **Loading / Streaming:** Deterministic skeleton placeholders, progress bars, and disabled submit buttons preventing duplicate requests.
  - **Empty / Onboarding:** Contextual empty state with localized call-to-action and zero fabricated mock fallback data.
  - **Active / Realtime Sync:** Scoped `TanStack Query` cache updates + WebSocket/SSE/polling synchronization where applicable.
  - **Error / Conflict Recovery:** Actionable localized error banners (`400/403/404/409/429/503`) preserving unsaved user input.

## 5. API, Messaging & Protocol Contract

| Route / Channel / Filter | Auth / Scope | Service & Handler |
| :--- | :--- | :--- |
| `POST /api/v1/workspaces/{workspaceId}/materials/upload-session[/multipart|/{id}/parts|/confirm]` | Bearer (`Owner, Manager, Creator`) | `MaterialController` -> presigned/multipart S3 upload + Task `RAW` material binding |
| `GET/POST /api/v1/workspaces/{workspaceId}/tasks/{taskId}/post` | Bearer (`Owner, Manager, Creator`; `Client` gated until review) | `TaskPostController` -> promotes selected mobile take into Task post draft |

## 6. Error Handling, Security & Edge Cases

- **Upload Session Expired While Underground / Offline:** `mediaSyncService.ts` detects `404/410` session expiry on resume, requests a fresh upload session, and completes transfer without user re-selection.
- **Permanent Validation Failure (`403` / unsupported file):** Marks queue item `FAILED` with exact backend localized error (`serverText.ts`) without infinite retry loops.

## 7. Related Specifications & References

- **Aligned SRS Functional Requirements:** [3.6 Content & Workflow — Material Repository & Task Content](../../../srs/05-content-task-workflow/README.md) (`3.6.11–3.6.16`, `3.6.4`)
- **BA & Architecture References:** [BA 05 Content & Task Workflow](../../../../ba/05-content-task-workflow.md) · [Roles & Permissions Matrix](../../../../ba/10-roles-permissions-matrix.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Production code verified across backend, AI/publisher workers, Web, and Mobile; `vi.json` + `en.json` parity verified; Light/Dark mode audited; all automated verification suites in [test.md](./test.md) passing.
- **Out of Scope:** De-scoped SRS items (livestream features, subscription plan downgrades, PayOS/VNPay/Stripe gateways, Zalo OA publishing, or copyright/plagiarism scanning).
