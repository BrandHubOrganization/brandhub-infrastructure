> **Navigation:** [← Category Index](../README.md) · [← Modules Master Index](../../README.md) · [Spec](./spec.md) · **Plan** · [Task](./task.md) · [Test](./test.md)

# Technical Implementation Plan — Mobile Media Package Review, Campaign Tracking & Client Content Request Workflows (`mobile-package-campaign`)

## 1. System Components & Touched Repositories

Consolidates the technical architecture for `mobile-package-campaign`, `mobile-nav-role-parity (Content Requests & Campaign Partners)` as specified in [spec.md](./spec.md):

| Layer / Repository | Key Classes, Services, Schemas & Components |
| :--- | :--- |
| **API Gateway (`brandhub-api-gateway`)** | `GatewayConfig.java` (`/api/v1/workspaces/*/media-package/**`, `/campaigns/**`, `/content-requests/**`) |
| **Backend / Worker Services** | `MediaPackageController.java`, `WorkspaceCampaignController.java`, `CampaignCollaboratorController.java`, `ContentRequestController.java`, `ContentRequestReviewController.java` |
| **Persistence, Cache & Brokers** | PostgreSQL `media_packages`, `workspace_media_packages`, `package_negotiation_events`, `media_campaigns`, `campaign_collaborators`; MongoDB `content_requests` |
| **Web Frontend (`brandhub-web`)** | Parity with `pages/campaign/*`, `pages/client/components/{ServicePackageModal,ClientContentRequests}.tsx` |
| **Mobile App (`brandhub-mobile-app`)** | `src/screens/more/{MediaPackageScreen,CampaignsScreen,CampaignDetailScreen,ContentRequestsScreen,ContentRequestDetailScreen,ContentRequestFormScreen}.tsx`, `src/components/campaign/CampaignPartnersSection.tsx` |
| **i18n & Theme Assets** | `mediaPackage.*`, `campaign.*`, `contentRequests.*` in `src/i18n/locales/en.json` & `src/i18n/locales/vi/common.json` (`tr()`); Mobile `src/i18n/locales/en.json` + `src/i18n/locales/vi/common.json` & `src/theme/tokens.ts` |

## 2. Core Technical Design & Data Model Invariants

- **Capability-Flag Driven Actions (`canEdit`, `canDelete`, `canReceive`, `canAccept`, `canDeny`):** Mobile UI renders mutation buttons strictly from server-computed flags rather than duplicating state-machine branching.

## 3. End-to-End Data & Control Flow

1. **Ingress & Identity Propagation:** Requests pass through `brandhub-api-gateway` (`InboundSecurityWebFilter` -> `JwtAuthFilterGatewayFilterFactory` -> `RateLimitGatewayFilterFactory`), stripping external header spoofing and injecting verified `X-User-Id`, `X-Request-Id`, and role claims.
2. **Authorization & Invariant Validation:** Downstream controllers and services re-verify canonical role permissions (`Owner, Manager, Client`) and Agency/Workspace tenant membership against authoritative database state before mutating data or dispatching async jobs.
3. **Atomic Persistence & Event Fan-Out:** State transitions commit atomically across PostgreSQL `media_packages`, `workspace_media_packages`, `package_negotiation_events`, `media_campaigns`, `campaign_collaborators`; MongoDB `content_requests` using optimistic (`@Version` / `expectedRevision`) or pessimistic locks, emitting outbox/WebSocket/`pg_notify` events after commit.
4. **Client State Reconciliation:** `brandhub-web` and `brandhub-mobile-app` consume typed `ApiResponse<T>` envelopes, update user/tenant-scoped `TanStack Query` caches, and render localized UI states in Light and Dark themes.

## 4. Sequential Implementation & Rollout Order

1. **Phase 1 — Database / Storage / Config Baseline:** Apply additive migrations in `database/init/init-postgres-v2.sql` and `database/migrations/postgres/*.sql` (plus MongoDB/Neo4j/Redis indexes) with repeat-run idempotency.
2. **Phase 2 — Domain Services & Security Guards:** Implement core service logic, cryptographic/concurrency helpers, and internal service-to-service contracts.
3. **Phase 3 — Public REST / WebSocket / Worker Endpoints:** Wire controllers, consumers, and exception handlers returning standardized `ErrorCode` payloads.
4. **Phase 4 — Web & Mobile UI Surfaces:** Deliver responsive components, accessibility/keyboard navigation, and state transitions without mock data fallbacks.
5. **Phase 5 — Key-Parallel i18n (`vi`/`en`) & Light/Dark Theme Audit:** Synchronize translation namespaces and verify semantic color tokens across Light and Dark modes.
6. **Phase 6 — Multi-Layer Verification:** Execute unit, integration, contract, and browser/mobile E2E suites documented in [test.md](./test.md).

## 5. Localization (`vi.json` + `en.json`), Theme Tokens & Observability Plan

- **Key-Parallel Locale Synchronization:** Every new or updated label in `mediaPackage.*`, `campaign.*`, `contentRequests.*` in `src/i18n/locales/en.json` & `src/i18n/locales/vi/common.json` (`tr()`) is committed simultaneously in `vi` and `en` bundles on `brandhub-web` and mirrored in `brandhub-mobile-app/src/i18n/locales/en.json` + `src/i18n/locales/vi/common.json` (verified by `mobileI18nParity.test.ts` and `i18nCoverage.test.ts`).
- **Light & Dark Theme Architecture:** Web components rely exclusively on semantic CSS custom properties (`bg-background`, `bg-card`, `text-foreground`, `text-muted-foreground`, `border-border`) and paired `dark:` utility classes; Mobile components consume `useAppPreferences().palette` (`src/theme/tokens.ts`) verified by `tokens.test.ts`.
- **Structured Telemetry & Rollback Safety:** Every boundary logs `X-Request-Id`, latency, and classified `ErrorCode` while redacting tokens/PII. Additive schema migrations preserve backward-compatible rollback without dropping historical audit or ledger data.

## 6. Engineering Risks & Mitigations

- **Accidental Tap on Package/Campaign Approval:** Protected by explicit confirmation modal summarizing deliverable scope + haptic confirmation (`haptics.ts`).
