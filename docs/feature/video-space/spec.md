# Video Space — approved editor integration

Created 2026-10-29. User approved the standalone editor and explicitly selected **editor + opening completed Video AI output first**. DemoVideo/AI editing is outside this phase.

## Objective and user story

A workspace content user can open Video Space from Video AI, edit a completed video or import a local video, save an editable project privately, reopen it and export MP4. Retain the reviewed editor: timeline/shortcuts, transitions, filters, speed, mask presets including None, 24 Vietnamese font families and the 85-item original resource catalog.

## Acceptance criteria

1. Latest accessible BrandHub repositories are updated before integration; existing local changes survive. Resolve conflicts locally. No commit/push. Preserve the working lab as a reference; no runtime dependency on it.
2. Protected route `/workspaces/:id/video-space` uses the same OWNER/MANAGER/CREATOR access as Video AI and existing admin rules. Each saved project remains private to its authenticated owner inside its workspace. Another member/admin-support session cannot overwrite or read the private project.
3. Video AI offers Open in Video Space for a completed job. The client passes its job ID only. The backend authorizes the job owner and reads its persisted S3 key; it never fetches a client-provided URL or creates another generation/credit charge.
4. The editor is a static isolated bundle inside brandhub-web, served at `/video-space/`; no additional Next/FastAPI service, lab SQLite or shared dummy workspace. The host owns JWT/refresh through its existing axios client. No token appears in URLs or iframe messages.
5. Bind the same-origin parent/iframe bridge to its source, origin, protocol version and random session. Permit only the selected workspace's project operations and selected source-job content. Reload the frame on user/workspace change. Scope IndexedDB, OPFS and content-related persisted state to user/workspace before editor imports initialize singletons.
6. Media uploads precede the first snapshot. Atomically claim a revision-0 private draft, stage immutable media and accept a snapshot plus its asset manifest with revision CAS. A stale save returns 409 and neither overwrites the accepted snapshot nor publishes staged media. Same asset ID/SHA is idempotent and preserves original metadata; different bytes conflict.
7. Preserve lab validation: project ID matches snapshot metadata ID; nonblank name <=200 chars; scenes array/settings object; finite JSON <=4 MiB; referenced media uploaded; optional unique mediaAssetIds <=1000; metadata <=512 KiB; media <=128 MiB with allowed MIME/signatures. Preserve current snapshot version data without imposing a new unsupported version gate.
8. Use provider-aware existing storage/quota accounting. Keep the existing 5MB/6MB multipart defaults. Logical editor uploads use JSON session -> direct provider PUT -> confirmation; do not publish workspace-visible MaterialDocuments. Recovery and usage reconciliation include private video assets. Keep individual upload-attempt checkpoints durable across abort/retry so old reservations/staged objects remain recoverable.
9. Save/reopen preserves original media IDs/hashes and all supported editable layers. Source video remains available when import/save fails. Export uses the real renderer, not CSS previews.
10. New host UI, navigation, errors and controls use parallel vi/en keys (`videoSpace`, `aiStudio.video`), shared UI components and existing theme tokens. Verify both host themes and pass theme/locale into the frame. Preserve reviewed third-party editor controls/layout rather than redesigning them during integration.
11. Keyboard focus/Undo/Redo/export work inside the frame; provide visible return to Video AI. On narrow screens keep a clear desktop-editor notice and return action.

## API contract

Authenticated base `/api/v1/workspaces/{workspaceId}/video-projects`:

- GET base: accepted private project summaries; bounded pagination, existing envelope/meta.
- GET `/{projectId}`: `{id,revision,updated_at,snapshot,assets}`.
- PUT `/{projectId}`: `{expected_revision,snapshot}` -> the exact newly accepted revision.
- GET `/{projectId}/media/{assetId}`: authorized original bytes.
- POST `/{projectId}/media/{assetId}/upload-session`: `{fileName,contentType,sizeBytes,sha256,metadata}` -> `{sessionId,uploadUrl,headers,expiresAt}`; provider upload uses PUT. For an already accepted immutable asset, uploadUrl is null and complete is idempotent without another upload or quota reservation.
- POST corresponding `/upload-complete` or `/upload-abort`: `{sessionId}`. Complete returns an immutable asset descriptor.
- GET `/api/v1/workspaces/{workspaceId}/ai/videos/{jobId}/content`: completion-only authorized MP4, private/no-store, nosniff.

Retain `expected_revision`, `updated_at`, `mime_type` at the lab compatibility boundary and BrandHub's ApiResponse envelope. Nested snapshot/metadata keys remain unchanged. Errors cover 401/403/404 access, 409 stale/content conflicts, 413 size, 415 format and 422 invalid/missing media; show a useful host error and retain local drafts.

## UI states and i18n

Host keys: `videoSpace.title`, `backToVideo`, `loading`, `loadError`, `retry`, `noWorkspace`, `frameTitle`, `unsupportedBrowser`, `sessionExpired`, `requestFailed`; Video AI keys `aiStudio.video.editInSpace`, `openVideoSpace`. Add both locale files/imports. Loading, missing workspace, invalid job, source failure, stale save, uploading and signed-out states must not show a false success. Light/dark uses existing tokens; the native canvas/background and user media remain their own content colors.

## Definition of done

Feature source and licensed assets reside in the main repos; no lab-only addresses/secrets/runtime required. Backend guard/CAS/upload/source tests, host bridge tests, portable build and real browser import/edit/save/reopen/export pass. Record any unrelated baseline failures separately. Do not call paid video generation for verification.

## Out of scope

DemoVideo, natural-language AI edit/planner, new video generation models, all-of-CapCut parity, publishing/deploying, commits/pushes, and migrating old lab/QA data into user workspaces.

## Reconnect and Claude editing - user authorization 2026-11-09
Restore missing Video Space/Product Video backend from retained safety stashes onto current develop without losing newer code. Connect workspace project CRUD/private media, completed AI source import and existing production renderer. Add editor natural-language editing using configured Claude and the commercially suitable DemoVideo editorial rules. Claude proposes structured actions; user applies them as one undoable edit and exports using native renderer. Supported actions: rename_project,set_aspect_ratio,add_text,set_text,set_volume,trim_clip,set_speed,set_transition. No arbitrary commands/URLs/code, no new video generation in edit requests, no automatic overwrite of manual edits. Use current text-generation pricing through existing accounting for edit planning; do not change price/catalog or bypass workspace credit rules. Do not promise every DemoVideo tool or automated visual analysis is supported.

Runtime setup ruling 2026-11-09: local PostgreSQL lacks storage foundation. Add a schema-only expansion for private editor quota (no plan/catalog/price update, no legacy DROP, no inventory verified backfill). Preserve billing catalog fingerprint. Apply existing additive Product Video and manager-sharing schemas only after backup and isolated restore preflight, because current Java entity validation needs sharing columns. Mongo additions are only new private video collections/indexes; existing task/chat validators stay untouched. Real S3 currently reports InvalidAccessKeyId; user is choosing local MinIO versus updating AWS, so don't change provider target until that reply.

Runtime acceptance: Video AI launch/history and Back must retain the route workspace. Existing global studio navigation clears workspace context; add a protected workspace-scoped alias and menu item using existing translations/access rules.

## BrandHub visual integration — 2026-11-11
Use the host sidebar only: remove the duplicated lab navigation and test-workspace label. Group Video AI, product video and Video Space in the existing workspace sidebar with unchanged role guards. Synchronize the embedded UI palette and font from the host in both themes; retain editable media styling, timeline controls, save/Undo and export. Library labels must react to Vietnamese/English changes. Keep the editor within the available viewport, including the mobile navigation. No backend, data or pricing changes.
