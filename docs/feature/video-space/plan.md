# Video Space implementation plan

> For agentic workers: implement task-by-task using executing-plans. Independent backend, static engine and host tasks may run concurrently against the interfaces below. No commits/pushes; root owns integration and verification.

**Goal:** Transfer the reviewed manual editor and open completed AI videos through BrandHub auth, storage and workspace ownership.

**Architecture:** A static Vite bundle in an isolated iframe preserves the editor's aliases/CSS and Rust/WASM renderer. The protected host route owns axios/refresh and serves a session-bound API bridge. Business service owns private Mongo snapshots/media state and provider-aware storage/quota. No new backend/frontend server process is introduced.

**Tech stack:** Existing React/Vite/TypeScript and Java/Spring/Mongo/storage; packaged Rust WASM and original licensed resources.

**Spec:** [spec.md](spec.md).

## Global constraints

- Preserve uncommitted work and the lab; no git commit/push or live-data migration as a side effect.
- No new test files under web src; verification belongs in tests/ or local .tmp artifacts.
- Keep multipart defaults; editor originals <=128 MiB, snapshots <=4 MiB, metadata <=512 KiB.
- Authenticated owner/workspace scope on every project/media operation; no JWT in frame messages or URLs.
- New host text has parallel vi/en keys and theme-token styling. Keep existing native editor behavior and licenses.

## Review focus

1. Another workspace/user, stale frame or forged message must not access/change a project, its media or an AI source.
2. Failed/stale saves and partially finished uploads must preserve accepted snapshots, immutable original metadata and quota consistency.
3. Eager WASM/storage initialization must occur only after the immutable user/workspace context; migrations must not touch another user's databases/directories.
4. Static build, workers, shaders, fonts, resource URLs and original MP4 export must work without Next, FastAPI, lab paths or root CSS/alias leakage.
5. Source import must be completion-only and owner-checked, not a provider refresh/regeneration or arbitrary URL proxy; unsupported browser/failure needs a safe return path.

## 1. Business API and durable media

Files: new `controller/VideoProjectController.java`, document classes under `document/`, records under `dto/`, `repository/VideoProjectStore.java`, and focused `service/video/` classes for access, snapshot validation, media sessions/recovery and project CAS. Patch `AiVideoController`/`AiVideoService` for completion-only content; use `FileStorageService.downloadObject` only for the persisted legacy AI output key. New uploads use `MaterialAccessPolicy.resolve`, provider-aware storage methods and `StorageQuotaService` choreography, not legacy uploadObject.

Use `video_projects` for draft ownership/revision/accepted serialized snapshot+asset manifest; `video_project_assets` for immutable logical originals/provider/key/hash/original metadata; `video_project_upload_sessions` for per-attempt reservation/staging/copy/recovery checkpoints. Separating attempts prevents abort/retry from losing the old reservation or staged object. Scope Mongo queries and CAS; serialize arbitrary JSON to bounded strings to avoid Mongo map-key/Jackson node mapping problems. Preserve initial asset metadata on idempotent upload. List accepted projects only. Add supporting Mongo index documentation.

Implement upload-session JSON and direct PUT confirmation/abort from spec. Match existing material reservation/claim/copy/commit/published recovery behavior while retaining private video ownership and video/audio/image MIME policy. Route recovery by reservation namespace; include committed private originals in usage reconciliation without double counting materials.

Produces the HTTP contract in spec.md. Tests: access/owner denial, draft claiming, CAS conflict, staged visibility, immutable re-upload, provider/quota success and recovery, allowed signatures/size limits, completed-source owner check and zero provider-refresh/credit calls.

## 2. Static editor package

Files under `brandhub-web/vendor/video-space/`: approved reachable editor/library source, scoped storage adapters, platform/host integration, Vite/TypeScript/package config, generated wasm glue/binary/types, source/provenance and resource inputs. Omit server/auth/marketing routes, env/data/artifacts/build folders, Git metadata and source test files. Preserve MIT/OFL/CC0 notices.

Initialize same-origin host context, then packaged WASM with its generated glue namespace, then dynamically import the editor app. Alias opencut-wasm to that exact initialized glue module. Use MemoryRouter `/projects` and `/editor/:project_id`; small next/navigation/link/image adapters only. Keep React next-themes, tooltip/toaster providers. Prefix assets with `/video-space/`; generate public library schema from 85-item manifest and local URLs for all 24 fonts.

Central IndexedDB open/delete and OPFS constructor prefixing must cover migrations as well as active storage. Scope persisted content/editor keys. Adapt `brandhub/api.ts` and sync media fetch to hostFetch; retain logical GET/PUT operations and lab-shaped JSON. Remove AI-edit/planner branch from studio controls in this manual-only phase. Reuse library File import for context.sourceJobId; get original bytes through the authorized content endpoint and never use a supplied URL.

Produces a static build in host `public/video-space/`, to be copied by the normal main Vite production build. Root owns root package/workspaces/lock/Docker scripts and shared protocol; engine worker owns only vendor/video-space.

## 3. Host route, bridge and launch buttons

Files: `brandhub-web/shared/video-space-protocol.ts`; `src/pages/video-space/{index.tsx,components/,hooks/,services/,types/}`; existing AppRoutes/access/sidebar files; `src/pages/ai-studio/video.tsx`; vi/en videoSpace and aiStudio locale modules plus i18n index; root package/Vite/TS alias/Docker/ignore config.

Protocol v1 message types: `brandhub-video-space:ready`, `:context`, `:request`, `:response`, `:command`, `:command-result`. Every message carries version 1. Context fields `{sessionId,workspaceId,userId,locale,theme,sourceJobId?}` contain no token. Request `{sessionId,requestId,method:GET|PUT,path,responseType:json|blob,body?}`; response `{sessionId,requestId,status,body}`. Multipart logical body is `{file:File,metadata:string}`. Host command `{sessionId,requestId,command:flush}` asks the child to flush a pending local draft before return navigation; result `{sessionId,requestId,success,error?}` keeps the page open on failure. Validate sender origin/source/session and exact route patterns for the current workspace/job. Cancel pending work on unmount; remount iframe for each user/workspace/source job. Same-session theme/locale updates must not recreate storage or editor state.

Feature service delegates to existing api client. For logical media PUT: create session using file hash/metadata, PUT to server-issued provider URL without bearer credentials, confirm; abort known upload failures. Other operations use the authenticated project endpoints. The iframe receives only data/status, never auth credentials. Honor body/time limits and useful ApiResponse errors.

Add `/workspaces/:id/video-space` under current AuthGuard/Layout and access map roles matching Video AI. Add open-library action on Video AI and edit action on completed current/history videos. Host provides return to `/ai-studio/video`, loading/error/retry states and full available editor width/height. Shared wire types prevent host/engine drift.

## 4. Build and verification

Install workspace dependencies once after both manifests exist. Root scripts build the static editor before host dev/build; update Docker's manifest COPY/install and Node version to support the verified toolchain. Exclude generated public/editor output from commits. No dependence on lab node_modules or machine-specific paths.

Run backend targeted tests, host unit/bridge tests outside src, engine/host TypeScript/build and actual Edge/WebGPU flow through host with API/storage fixtures. Test completed source -> native timeline -> Ctrl+B/mask/font -> save -> fresh restore -> MP4. Inspect decoded pixels. Test vi/en, light/dark, narrow desktop/mobile notice, foreign sender/path rejection and another user/workspace's local storage isolation. Keep paid providers and live DB writes out of verification.

## Reconnection plan 2026-11-09
Recover Business files from stash pre-pull-develop-20261102-180740 (video source/new tests plus narrow shared integrations), and AI product-video module/resources from its matching stash. Use isolated worktrees seeded with current local edits, then copy only changed files back after checks. Work is split through subagent-driven-development: Business owns persistence/accounting/proxy, AI owns product renderer recovery and typed Claude planner, Web owns protocol/action execution/UI. No commits/pushes.
Public POST /api/v1/workspaces/{ws}/video-projects/{project}/edit-plans accepts expected_revision and instruction <=4000, requires Idempotency-Key and owner check. Business supplies canonical saved snapshot to internal POST /api/v1/ai/video/edit-plan authenticated X-Internal-Key. Internal body {snapshot,instruction}; response {summary,actions}; Business returns base_revision. Action fields snake_case: kind,text?,element_id?,aspect_ratio?,start_seconds default0,duration_seconds default3,volume?,speed?,transition_id?. Bounds: <=10 actions, text<=500, rename<=200, ratio16:9/9:16/1:1, volume0..2,speed0.25..4, trim positions finite/nonnegative and existing active-scene video/audio IDs. Transition IDs only existing renderer-supported registry, no invented URL/assets. Main controller coordinates any schema/index setup after read-only preflight and backup; no destructive or catalog migration.

Runtime setup: prepare2026-11-09-video-space-runtime-foundation.sql from existing foundation DDL while omitting its immutable catalog UPDATE. Include empty add-on schemas required by current quota reader, owner_user_id columns, unverified usage rows and ledger receipt. Restore PostgreSQL dump into a dedicated verification DB, run schema expansions and verify unchanged catalog checksum before local APPLY. Snapshot Mongo target collection metadata before additive private indexes. Never disable encrypted reads to work around key readiness.

Runtime routing repair: add /workspaces/:id/ai-studio/video reusing VideoStudioPage; prefer useParams id over store in that page; workspace menu entry and editor Back use scoped URL. Retain legacy global route. No broader dashboard/navigation redesign.

## Visual integration plan — 2026-11-11
Read the host root semantic tokens inside the existing same-origin iframe and apply only a fixed UI token mapping in HostAppearance; reuse context theme/locale subscriptions. Remove the library-only sidebar/theme switch, retain its connection state and project operations, and supply parallel native library labels. Move video links into one workspace sidebar section, preserving canAccess filtering. Add the video route to the bounded Layout viewport. Update host videoSpace subtitle and nav section in both locale files.
