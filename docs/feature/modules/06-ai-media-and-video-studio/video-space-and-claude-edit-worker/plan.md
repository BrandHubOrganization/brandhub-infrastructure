> **Navigation:** [← Category Index](../README.md) · [← Modules Master Index](../../README.md) · [Spec](./spec.md) · **Plan** · [Task](./task.md) · [Test](./test.md)

# Technical Implementation Plan — Video Space Nonlinear Editor, Conversational Auto-Edit Agent & Containerized Claude FFmpeg Worker (`video-space-and-claude-edit-worker`)

## 1. System Components & Touched Repositories

Consolidates the technical architecture for `video-space`, `video-space-conversational-edits`, `server-video-editor`, `edit-video-direct`, `video-auto-edit-agent`, `video-edit-claude-container`, `video-edit-guide-library` as specified in [spec.md](./spec.md):

| Layer / Repository | Key Classes, Services, Schemas & Components |
| :--- | :--- |
| **API Gateway (`brandhub-api-gateway`)** | `GatewayConfig.java` (`/api/v1/workspaces/*/video-projects/**`) |
| **Backend / Worker Services** | `VideoProjectController.java`, `VideoAutoEditController.java`, `VideoAutoEditMemoryController.java`, `InternalVideoEditController.java`; `brandhub-ai-service`: `server_video_edit.py`, `video_edit_worker.py`, `video_edit_planner.py`, `app/services/server_video_edit/tools.py`, `tools/video-edit/{edit,package_guides}.py` |
| **Persistence, Cache & Brokers** | MongoDB `video_projects`, `video_project_assets`, `video_project_upload_sessions`, `video_auto_edits`; PostgreSQL `agency_storage_reservations`; AWS S3 project & output media |
| **Web Frontend (`brandhub-web`)** | `pages/video-space/index.tsx`, `pages/video-space/components/VideoSpaceWorkspace.tsx` |
| **Mobile App (`brandhub-mobile-app`)** | `src/screens/more/QuickReelStudioScreen.tsx` (`POST /materials/reel-studio/auto-edit`), `src/services/videoSpaceService.ts` |
| **i18n & Theme Assets** | `videoSpace.{timeline,chatAgent,memory,upload,export,guides}.*` in `src/i18n/locales/{vi,en}/videoSpace.json`; Mobile `src/i18n/locales/en.json` + `src/i18n/locales/vi/common.json` & `src/theme/tokens.ts` |

## 2. Core Technical Design & Data Model Invariants

- **Zero-Credential Worker Sandbox:** Containerized Claude/FFmpeg worker never holds AWS S3 root keys or PostgreSQL credentials; all asset reads/writes broker through `InternalVideoEditController`.
- **On-Demand Skill Injection:** Agent loads only the relevant guide markdown (`package_guides.py`) for the requested edit operation, cutting token usage and improving FFmpeg command accuracy.

## 3. End-to-End Data & Control Flow

1. **Ingress & Identity Propagation:** Requests pass through `brandhub-api-gateway` (`InboundSecurityWebFilter` -> `JwtAuthFilterGatewayFilterFactory` -> `RateLimitGatewayFilterFactory`), stripping external header spoofing and injecting verified `X-User-Id`, `X-Request-Id`, and role claims.
2. **Authorization & Invariant Validation:** Downstream controllers and services re-verify canonical role permissions (`Owner, Manager, Creator`) and Agency/Workspace tenant membership against authoritative database state before mutating data or dispatching async jobs.
3. **Atomic Persistence & Event Fan-Out:** State transitions commit atomically across MongoDB `video_projects`, `video_project_assets`, `video_project_upload_sessions`, `video_auto_edits`; PostgreSQL `agency_storage_reservations`; AWS S3 project & output media using optimistic (`@Version` / `expectedRevision`) or pessimistic locks, emitting outbox/WebSocket/`pg_notify` events after commit.
4. **Client State Reconciliation:** `brandhub-web` and `brandhub-mobile-app` consume typed `ApiResponse<T>` envelopes, update user/tenant-scoped `TanStack Query` caches, and render localized UI states in Light and Dark themes.

## 4. Sequential Implementation & Rollout Order

1. **Phase 1 — Database / Storage / Config Baseline:** Apply additive migrations in `database/init/init-postgres-v2.sql` and `database/migrations/postgres/*.sql` (plus MongoDB/Neo4j/Redis indexes) with repeat-run idempotency.
2. **Phase 2 — Domain Services & Security Guards:** Implement core service logic, cryptographic/concurrency helpers, and internal service-to-service contracts.
3. **Phase 3 — Public REST / WebSocket / Worker Endpoints:** Wire controllers, consumers, and exception handlers returning standardized `ErrorCode` payloads.
4. **Phase 4 — Web & Mobile UI Surfaces:** Deliver responsive components, accessibility/keyboard navigation, and state transitions without mock data fallbacks.
5. **Phase 5 — Key-Parallel i18n (`vi`/`en`) & Light/Dark Theme Audit:** Synchronize translation namespaces and verify semantic color tokens across Light and Dark modes.
6. **Phase 6 — Multi-Layer Verification:** Execute unit, integration, contract, and browser/mobile E2E suites documented in [test.md](./test.md).

## 5. Localization (`vi.json` + `en.json`), Theme Tokens & Observability Plan

- **Key-Parallel Locale Synchronization:** Every new or updated label in `videoSpace.{timeline,chatAgent,memory,upload,export,guides}.*` in `src/i18n/locales/{vi,en}/videoSpace.json` is committed simultaneously in `vi` and `en` bundles on `brandhub-web` and mirrored in `brandhub-mobile-app/src/i18n/locales/en.json` + `src/i18n/locales/vi/common.json` (verified by `mobileI18nParity.test.ts` and `i18nCoverage.test.ts`).
- **Light & Dark Theme Architecture:** Web components rely exclusively on semantic CSS custom properties (`bg-background`, `bg-card`, `text-foreground`, `text-muted-foreground`, `border-border`) and paired `dark:` utility classes; Mobile components consume `useAppPreferences().palette` (`src/theme/tokens.ts`) verified by `tokens.test.ts`.
- **Structured Telemetry & Rollback Safety:** Every boundary logs `X-Request-Id`, latency, and classified `ErrorCode` while redacting tokens/PII. Additive schema migrations preserve backward-compatible rollback without dropping historical audit or ledger data.

## 6. Engineering Risks & Mitigations

- **Disk Exhaustion on Large Raw 4K Clips:** `prepare_ai_volume.py` + per-job scratch quota and immediate post-upload cleanup bound worker disk usage.
