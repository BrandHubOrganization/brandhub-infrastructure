> **Navigation:** [← Category Index](../README.md) · [← Modules Master Index](../../README.md) · [Spec](./spec.md) · **Plan** · [Task](./task.md) · [Test](./test.md)

# Technical Implementation Plan — Neo4j Trend Knowledge Graph Core, Workspace Trend Explorer & Brand-Fit Matching (`neo4j-trend-knowledge-graph`)

## 1. System Components & Touched Repositories

Consolidates the technical architecture for `trend-graph-core`, `trend-graph-ui`, `trend-viewer`, `workspace-trend-explorer`, `trend-fit` as specified in [spec.md](./spec.md):

| Layer / Repository | Key Classes, Services, Schemas & Components |
| :--- | :--- |
| **API Gateway (`brandhub-api-gateway`)** | `GatewayConfig.java` (`/api/v1/workspaces/*/trends/**`, `/api/v1/admin/ai/trend-graph/**`) |
| **Backend / Worker Services** | `WorkspaceTrendController.java`, `AdminTrendGraphController.java`, `AiCaptionController.java`; `brandhub-ai-service`: `trend_graph_service.py`, `workspace_trends.py`, `app/services/trend_fit/*` |
| **Persistence, Cache & Brokers** | Neo4j Knowledge Graph, ChromaDB (`brand_docs_{workspace_id}`), Redis (`trends:vn:*` snapshots) |
| **Web Frontend (`brandhub-web`)** | `pages/workspace-trends/index.tsx` (`TrendMatrix`, `TrendTable`, `TrendHistoryPanel`, `TrendSourcePosts`), `pages/admin/components/AdminTrendGraphPanel.tsx` (`TrendGraphCanvas`, `TrendGraphScene`, `TrendGraphInspector`) |
| **Mobile App (`brandhub-mobile-app`)** | `src/screens/more/SocialTrendsScreen.tsx`, `src/services/trendService.ts` |
| **i18n & Theme Assets** | `trends.{explorer,matrix,history,fit,graph}.*` in `src/i18n/locales/{vi,en}/trends.json`; Mobile `src/i18n/locales/en.json` + `src/i18n/locales/vi/common.json` & `src/theme/tokens.ts` |

## 2. Core Technical Design & Data Model Invariants

- **Hybrid Graph + Vector Context (`graph_context.py`):** Combines Neo4j 1-hop entity/hashtag neighborhood with ChromaDB brand guidelines to produce compact `< 500` token trend context blocks.
- **Vietnamese Cultural Calendar Awareness (`lunar.py`, `moments.py`):** Boosts culturally relevant seasonal campaigns (Tết, Trung Thu, Back-to-School, 11.11/12.12) accurately.

## 3. End-to-End Data & Control Flow

1. **Ingress & Identity Propagation:** Requests pass through `brandhub-api-gateway` (`InboundSecurityWebFilter` -> `JwtAuthFilterGatewayFilterFactory` -> `RateLimitGatewayFilterFactory`), stripping external header spoofing and injecting verified `X-User-Id`, `X-Request-Id`, and role claims.
2. **Authorization & Invariant Validation:** Downstream controllers and services re-verify canonical role permissions (`Owner, Manager, Creator, Admin`) and Agency/Workspace tenant membership against authoritative database state before mutating data or dispatching async jobs.
3. **Atomic Persistence & Event Fan-Out:** State transitions commit atomically across Neo4j Knowledge Graph, ChromaDB (`brand_docs_{workspace_id}`), Redis (`trends:vn:*` snapshots) using optimistic (`@Version` / `expectedRevision`) or pessimistic locks, emitting outbox/WebSocket/`pg_notify` events after commit.
4. **Client State Reconciliation:** `brandhub-web` and `brandhub-mobile-app` consume typed `ApiResponse<T>` envelopes, update user/tenant-scoped `TanStack Query` caches, and render localized UI states in Light and Dark themes.

## 4. Sequential Implementation & Rollout Order

1. **Phase 1 — Database / Storage / Config Baseline:** Apply additive migrations in `database/init/init-postgres-v2.sql` and `database/migrations/postgres/*.sql` (plus MongoDB/Neo4j/Redis indexes) with repeat-run idempotency.
2. **Phase 2 — Domain Services & Security Guards:** Implement core service logic, cryptographic/concurrency helpers, and internal service-to-service contracts.
3. **Phase 3 — Public REST / WebSocket / Worker Endpoints:** Wire controllers, consumers, and exception handlers returning standardized `ErrorCode` payloads.
4. **Phase 4 — Web & Mobile UI Surfaces:** Deliver responsive components, accessibility/keyboard navigation, and state transitions without mock data fallbacks.
5. **Phase 5 — Key-Parallel i18n (`vi`/`en`) & Light/Dark Theme Audit:** Synchronize translation namespaces and verify semantic color tokens across Light and Dark modes.
6. **Phase 6 — Multi-Layer Verification:** Execute unit, integration, contract, and browser/mobile E2E suites documented in [test.md](./test.md).

## 5. Localization (`vi.json` + `en.json`), Theme Tokens & Observability Plan

- **Key-Parallel Locale Synchronization:** Every new or updated label in `trends.{explorer,matrix,history,fit,graph}.*` in `src/i18n/locales/{vi,en}/trends.json` is committed simultaneously in `vi` and `en` bundles on `brandhub-web` and mirrored in `brandhub-mobile-app/src/i18n/locales/en.json` + `src/i18n/locales/vi/common.json` (verified by `mobileI18nParity.test.ts` and `i18nCoverage.test.ts`).
- **Light & Dark Theme Architecture:** Web components rely exclusively on semantic CSS custom properties (`bg-background`, `bg-card`, `text-foreground`, `text-muted-foreground`, `border-border`) and paired `dark:` utility classes; Mobile components consume `useAppPreferences().palette` (`src/theme/tokens.ts`) verified by `tokens.test.ts`.
- **Structured Telemetry & Rollback Safety:** Every boundary logs `X-Request-Id`, latency, and classified `ErrorCode` while redacting tokens/PII. Additive schema migrations preserve backward-compatible rollback without dropping historical audit or ledger data.

## 6. Engineering Risks & Mitigations

- **Dense Graph Rendering Lag in Browser:** Canvas caps initial render nodes (`<= 100`) and loads secondary hops on explicit node expansion (`/expand`).
