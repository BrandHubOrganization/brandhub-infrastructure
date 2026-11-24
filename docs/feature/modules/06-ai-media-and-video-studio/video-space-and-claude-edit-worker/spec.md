> **Navigation:** [← Category Index](../README.md) · [← Modules Master Index](../../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# Video Space Nonlinear Editor, Conversational Auto-Edit Agent & Containerized Claude FFmpeg Worker

| Field | Value |
| :--- | :--- |
| **Module Slug** | `video-space-and-claude-edit-worker` |
| **Category** | `06-ai-media-and-video-studio` — AI Commercial Image, Product Video & Conversational Video Studio |
| **Canonical Actors / Roles** | `Owner, Manager, Creator` |
| **Consolidated Feature Scopes** | `video-space`, `video-space-conversational-edits`, `server-video-editor`, `edit-video-direct`, `video-auto-edit-agent`, `video-edit-claude-container`, `video-edit-guide-library` |
| **Aligned SRS Domains** | [FR 3.7.11 — Generate Video](../../../srs/06-ai-features/3-7-11-generate-video/spec.md) · [FR 3.7.12 — Export File](../../../srs/06-ai-features/3-7-12-export-file/spec.md) · [3.6 Content & Workflow](../../../srs/05-content-task-workflow/README.md) |
| **Status** | Implemented — Production Verified |

## 1. Objective & Architectural Motivation

Unify **Video Space** (`/workspaces/:workspaceId/video-space` — `VideoProjectController`), **Conversational AI Video Editing & Project Memory** (`VideoAutoEditController`, `VideoAutoEditMemoryController`), **Direct Server FFmpeg Runtime** (`server_video_edit.py` / `edit-video-direct`), **Sandboxed Containerized Claude Video-Edit Worker** (`video_edit_worker.py` + `InternalVideoEditController`), and **On-Demand Video Editing Guide Skills** (`video-edit-guide-library`).

## 2. User Stories

- As a `Creator`, `Manager`, or `Owner`, I want an integrated **Video Space** timeline workspace where I can upload multi-clip project assets to S3, instruct an AI Video Editing Agent in natural Vietnamese/English (e.g., *'cắt bỏ đoạn im lặng đầu clip, chèn phụ đề nhịp nhanh, xuất 9:16 cho TikTok'*), persist project style memory across edits, and export rendered MP4s back to Tasks or the Material Repository.

## 3. Consolidated Acceptance Criteria

1. **Video Space Project & Multipart Media Runtime (`video-space`, `2026-11-09-video-space-runtime-foundation.sql`):** `VideoProjectController` (`/api/v1/workspaces/{workspaceId}/video-projects`, `/{projectId}/edit-plans`, `/{projectId}/media/{assetId}/upload-session|upload-complete|upload-abort`) persists nonlinear project state in MongoDB (`video_projects`, `video_project_assets`, `video_project_upload_sessions`) with S3 quota reservations.
2. **Conversational Edits & Persistent Style Memory (`video-space-conversational-edits`, `video-auto-edit-agent`):** `VideoAutoEditController` (`POST/GET /video-projects/{projectId}/auto-edits`) and `VideoAutoEditMemoryController` (`GET/PUT .../auto-edit-memory`) translate conversational chat turns into structured edit plans (`video_edit_planner.py`) while remembering brand pacing, font, and aspect-ratio preferences.
3. **Server Video Editor & Containerized Claude Worker (`server-video-editor`, `edit-video-direct`, `video-edit-claude-container`):** `app/api/v1/endpoints/server_video_edit.py` and `app/video_edit_worker.py` run FFmpeg / Python editing tools (`tools/video-edit/edit.py`) inside an isolated container sandbox, fetching authorized source clips and uploading finished renders via `InternalVideoEditController` (`/api/v1/internal/video-edits/{jobId}/sources/{assetId}` & `/output-session|output-complete|output-abort`).
4. **On-Demand Video Editing Guide Library (`video-edit-guide-library`):** `tools/video-edit/package_guides.py` provides modular, token-efficient editing recipes (jump-cut pacing, burned-in captions, audio ducking, color Lut, aspect-ratio reframing) loaded on demand by the agent rather than bloating every prompt.
5. **Internationalization (`vi.json` + `en.json`):** Every user-facing string, tooltip, dialog prompt, status badge, and error banner uses key-parallel translations (`videoSpace.{timeline,chatAgent,memory,upload,export,guides}.*` in `src/i18n/locales/{vi,en}/videoSpace.json`) on `brandhub-web` and `tr()` (`en.json` + `vi/common.json`) on `brandhub-mobile-app` with zero hardcoded Vietnamese or English strings in JSX/TSX.
6. **Light & Dark Mode Compliance:** All surfaces, drawers, badges, charts, and interactive controls use semantic CSS variables / Tailwind `dark:` variants on Web and `useAppPreferences().palette` tokens on Mobile, achieving WCAG AA contrast in both Light and Dark themes.

## 4. UI / UX Surfaces & Lifecycle States

- **Web Surfaces (`brandhub-web`):** `pages/video-space/index.tsx`, `pages/video-space/components/VideoSpaceWorkspace.tsx`
- **Mobile Surfaces (`brandhub-mobile-app`):** `src/screens/more/QuickReelStudioScreen.tsx` (`POST /materials/reel-studio/auto-edit`), `src/services/videoSpaceService.ts`
- **UI States:**
  - **Loading / Streaming:** Deterministic skeleton placeholders, progress bars, and disabled submit buttons preventing duplicate requests.
  - **Empty / Onboarding:** Contextual empty state with localized call-to-action and zero fabricated mock fallback data.
  - **Active / Realtime Sync:** Scoped `TanStack Query` cache updates + WebSocket/SSE/polling synchronization where applicable.
  - **Error / Conflict Recovery:** Actionable localized error banners (`400/403/404/409/429/503`) preserving unsaved user input.

## 5. API, Messaging & Protocol Contract

| Route / Channel / Filter | Auth / Scope | Service & Handler |
| :--- | :--- | :--- |
| `GET/PUT/POST /api/v1/workspaces/{workspaceId}/video-projects/**` | Bearer (`Owner, Manager, Creator`) | `VideoProjectController` -> project state, edit plans & S3 asset upload sessions |
| `POST/GET /api/v1/workspaces/{workspaceId}/video-projects/{projectId}/auto-edits/**` | Bearer (`Owner, Manager, Creator`) | `VideoAutoEditController` -> conversational AI edit jobs & rendered MP4 stream |
| `GET/PUT /api/v1/workspaces/{workspaceId}/video-projects/{projectId}/auto-edit-memory` | Bearer (`Owner, Manager, Creator`) | `VideoAutoEditMemoryController` -> per-project editing style memory |
| `GET/POST /api/v1/internal/video-edits/{jobId}/**` | `X-Internal-Service-Key` | `InternalVideoEditController` <- containerized worker source fetch & S3 output commit |

## 6. Error Handling, Security & Edge Cases

- **Worker Crash or Invalid FFmpeg Filter Graph:** Isolated per-job staging directory (`scripts/stage_video_edit_context.py`) cleans up temporary disk artifacts and calls `/output-abort` so failed edits never leak S3 multipart parts or storage quota.
- **Path Traversal / Arbitrary Shell Escape Guard:** Worker mounts only job-scoped scratch directories and accesses media exclusively via signed `InternalVideoEditController` sessions.

## 7. Related Specifications & References

- **Aligned SRS Functional Requirements:** [FR 3.7.11 — Generate Video](../../../srs/06-ai-features/3-7-11-generate-video/spec.md) · [FR 3.7.12 — Export File](../../../srs/06-ai-features/3-7-12-export-file/spec.md) · [3.6 Content & Workflow](../../../srs/05-content-task-workflow/README.md)
- **BA & Architecture References:** [BA 06 AI Features](../../../../ba/06-ai-features.md) · [Roles & Permissions Matrix](../../../../ba/10-roles-permissions-matrix.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Production code verified across backend, AI/publisher workers, Web, and Mobile; `vi.json` + `en.json` parity verified; Light/Dark mode audited; all automated verification suites in [test.md](./test.md) passing.
- **Out of Scope:** De-scoped SRS items (livestream features, subscription plan downgrades, PayOS/VNPay/Stripe gateways, Zalo OA publishing, or copyright/plagiarism scanning).
