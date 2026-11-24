> **Navigation:** [← Category Index](../README.md) · [← Modules Master Index](../../README.md) · [Spec](./spec.md) · **Plan** · [Task](./task.md) · [Test](./test.md)

# Technical Implementation Plan — Brand-Grounded RAG Captions, Editor AI Popover, Content Humanizer & Text Safety Moderation (`rag-caption-moderation-and-humanizer`)

## 1. System Components & Touched Repositories

Consolidates the technical architecture for `brand-trend-caption-quality`, `caption-credit-request`, `caption-neo4j-context`, `caption-text-moderation`, `caption-trend-retrieval`, `content-humanizer`, `editor-ai-content-popover` as specified in [spec.md](./spec.md):

| Layer / Repository | Key Classes, Services, Schemas & Components |
| :--- | :--- |
| **API Gateway (`brandhub-api-gateway`)** | `GatewayConfig.java` (`/api/v1/workspaces/*/ai/**`) |
| **Backend / Worker Services** | `AiCaptionController.java`, `InternalModerationController.java`, `AiCreditGenerationService.java`; `brandhub-ai-service`: `content.py`, `llm_service.py`, `prompt_builder.py`, `humanizer.py`, `text_moderation_service.py` |
| **Persistence, Cache & Brokers** | PostgreSQL `ai_caption_generations`, `ai_credit_reservations`, `content_moderation_reviews`, `task_content_snapshots`; ChromaDB `brand_docs_{workspace_id}`; Neo4j Trend Graph |
| **Web Frontend (`brandhub-web`)** | `components/ai/AiCaptionDialog.tsx`, `pages/editor/components/{AIGeneratePanel,ContentCreatorAiPanel,CaptionModeration,EditorModerationStatus}.tsx` |
| **Mobile App (`brandhub-mobile-app`)** | `src/screens/more/{AiCaptionScreen,AiPostStudioScreen}.tsx`, `src/utils/editorModeration.ts` (`editorModeration.test.ts`) |
| **i18n & Theme Assets** | `editor.aiPopover.*`, `editor.aiCaption.*`, `editor.humanizer.*`, `editor.moderation.*` in `src/i18n/locales/{vi,en}/editor.json`; Mobile `src/i18n/locales/en.json` + `src/i18n/locales/vi/common.json` & `src/theme/tokens.ts` |

## 2. Core Technical Design & Data Model Invariants

- **Single-Pass Grounding + Humanization + Safety Check:** Reduces round-trip latency while guaranteeing every returned caption variant carries moderation metadata.
- **Fallback LLM Resilience:** `llm_factory.py` + `circuit_breaker.py` fail over seamlessly between Groq and Gemini models on `429/503`.

## 3. End-to-End Data & Control Flow

1. **Ingress & Identity Propagation:** Requests pass through `brandhub-api-gateway` (`InboundSecurityWebFilter` -> `JwtAuthFilterGatewayFilterFactory` -> `RateLimitGatewayFilterFactory`), stripping external header spoofing and injecting verified `X-User-Id`, `X-Request-Id`, and role claims.
2. **Authorization & Invariant Validation:** Downstream controllers and services re-verify canonical role permissions (`Owner, Manager, Creator, Admin`) and Agency/Workspace tenant membership against authoritative database state before mutating data or dispatching async jobs.
3. **Atomic Persistence & Event Fan-Out:** State transitions commit atomically across PostgreSQL `ai_caption_generations`, `ai_credit_reservations`, `content_moderation_reviews`, `task_content_snapshots`; ChromaDB `brand_docs_{workspace_id}`; Neo4j Trend Graph using optimistic (`@Version` / `expectedRevision`) or pessimistic locks, emitting outbox/WebSocket/`pg_notify` events after commit.
4. **Client State Reconciliation:** `brandhub-web` and `brandhub-mobile-app` consume typed `ApiResponse<T>` envelopes, update user/tenant-scoped `TanStack Query` caches, and render localized UI states in Light and Dark themes.

## 4. Sequential Implementation & Rollout Order

1. **Phase 1 — Database / Storage / Config Baseline:** Apply additive migrations in `database/init/init-postgres-v2.sql` and `database/migrations/postgres/*.sql` (plus MongoDB/Neo4j/Redis indexes) with repeat-run idempotency.
2. **Phase 2 — Domain Services & Security Guards:** Implement core service logic, cryptographic/concurrency helpers, and internal service-to-service contracts.
3. **Phase 3 — Public REST / WebSocket / Worker Endpoints:** Wire controllers, consumers, and exception handlers returning standardized `ErrorCode` payloads.
4. **Phase 4 — Web & Mobile UI Surfaces:** Deliver responsive components, accessibility/keyboard navigation, and state transitions without mock data fallbacks.
5. **Phase 5 — Key-Parallel i18n (`vi`/`en`) & Light/Dark Theme Audit:** Synchronize translation namespaces and verify semantic color tokens across Light and Dark modes.
6. **Phase 6 — Multi-Layer Verification:** Execute unit, integration, contract, and browser/mobile E2E suites documented in [test.md](./test.md).

## 5. Localization (`vi.json` + `en.json`), Theme Tokens & Observability Plan

- **Key-Parallel Locale Synchronization:** Every new or updated label in `editor.aiPopover.*`, `editor.aiCaption.*`, `editor.humanizer.*`, `editor.moderation.*` in `src/i18n/locales/{vi,en}/editor.json` is committed simultaneously in `vi` and `en` bundles on `brandhub-web` and mirrored in `brandhub-mobile-app/src/i18n/locales/en.json` + `src/i18n/locales/vi/common.json` (verified by `mobileI18nParity.test.ts` and `i18nCoverage.test.ts`).
- **Light & Dark Theme Architecture:** Web components rely exclusively on semantic CSS custom properties (`bg-background`, `bg-card`, `text-foreground`, `text-muted-foreground`, `border-border`) and paired `dark:` utility classes; Mobile components consume `useAppPreferences().palette` (`src/theme/tokens.ts`) verified by `tokens.test.ts`.
- **Structured Telemetry & Rollback Safety:** Every boundary logs `X-Request-Id`, latency, and classified `ErrorCode` while redacting tokens/PII. Additive schema migrations preserve backward-compatible rollback without dropping historical audit or ledger data.

## 6. Engineering Risks & Mitigations

- **False-Positive Safety Flag on Medical/Beauty Terms:** Moderation response includes granular category + confidence reason so `Admin` can approve benign industry copy in FR 3.10.4.
