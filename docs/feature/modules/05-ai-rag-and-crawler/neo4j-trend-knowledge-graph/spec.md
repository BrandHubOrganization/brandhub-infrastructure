> **Navigation:** [← Category Index](../README.md) · [← Modules Master Index](../../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# Neo4j Trend Knowledge Graph Core, Workspace Trend Explorer & Brand-Fit Matching

| Field | Value |
| :--- | :--- |
| **Module Slug** | `neo4j-trend-knowledge-graph` |
| **Category** | `05-ai-rag-and-crawler` — AI Trend Crawler, Neo4j Knowledge Graph & Brand RAG |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Admin` |
| **Consolidated Feature Scopes** | `trend-graph-core`, `trend-graph-ui`, `trend-viewer`, `workspace-trend-explorer`, `trend-fit` |
| **Aligned SRS Domains** | [FR 3.7.1 — View Trending Topics](../../../srs/06-ai-features/3-7-1-view-trending-topics-suggestions/spec.md) · [FR 3.7.2 — View AI Trend Knowledge Graph](../../../srs/06-ai-features/3-7-2-view-ai-trend-knowledge-graph/spec.md) |
| **Status** | Implemented — Production Verified |

## 1. Objective & Architectural Motivation

Combine the **Neo4j Trend Knowledge Graph** schema & traversal engine (`trend-graph-core`), interactive Admin & Workspace graph/table explorers (`trend-graph-ui`, `trend-viewer`, `workspace-trend-explorer`), and **Brand-Fit Trend Scoring** (`trend-fit` — matching live trends + Vietnamese lunar/seasonal moments against a Workspace's Brand Profile & safety rules to launch 1-click trend-grounded captions).

## 2. User Stories

- As an `Owner`, `Manager`, or `Creator`, I want to explore live trends ranked by Brand-Fit (`GET /api/v1/workspaces/{workspaceId}/ai/trend-fit` and `/workspaces/{workspaceId}/trends`), inspect historical momentum charts and source posts, and launch 'Write Post with Trend' directly into the Editor.
- As an `Admin`, I want an interactive force-directed Neo4j graph canvas (`TrendGraphCanvas.tsx`) to inspect `Trend`, `Topic`, `Hashtag`, and `Entity` co-occurrence clusters.

## 3. Consolidated Acceptance Criteria

1. **Neo4j Graph Core (`trend-graph-core`):** `trend_graph_mapping.py` and `trend_graph_service.py` maintain idempotent `MERGE` constraints on `Trend`, `Topic`, `Keyword`, `Hashtag`, `Entity`, and `PlatformSource` nodes with weighted `CO_OCCURS_WITH` and `MENTIONED_IN` edges, supporting bounded `/overview`, `/neighborhood`, `/nodes`, and `/expand` queries.
2. **Interactive Graph UI & Workspace Trend Explorer (`trend-graph-ui`, `trend-viewer`, `workspace-trend-explorer`):** `TrendGraphWorkspace.tsx` renders zoomable graph topologies + `TrendGraphInspector.tsx` side panels; `pages/workspace-trends/index.tsx` (`WorkspaceTrendController` `/trends`, `/matrix`, `/history`) renders matrix heatmaps, sparkline history charts (`TrendHistoryCharts.tsx`), and verified source post drawers (`TrendSourcePosts.tsx`).
3. **Brand-Fit Trend Selection (`trend-fit`):** `app/services/trend_fit/` (`profile.py`, `lunar.py`, `moments.py`, `matching.py`, `safety.py`, `graph_context.py`) evaluates active trends against Workspace industry, Brand Knowledge RAG profile, Vietnamese lunar/holiday calendar moments, and brand-safety filters (`GET /api/v1/workspaces/{workspaceId}/ai/trend-fit`), feeding selected trend context directly into FR 3.7.6 (`Generate Caption`).
4. **Internationalization (`vi.json` + `en.json`):** Every user-facing string, tooltip, dialog prompt, status badge, and error banner uses key-parallel translations (`trends.{explorer,matrix,history,fit,graph}.*` in `src/i18n/locales/{vi,en}/trends.json`) on `brandhub-web` and `tr()` (`en.json` + `vi/common.json`) on `brandhub-mobile-app` with zero hardcoded Vietnamese or English strings in JSX/TSX.
5. **Light & Dark Mode Compliance:** All surfaces, drawers, badges, charts, and interactive controls use semantic CSS variables / Tailwind `dark:` variants on Web and `useAppPreferences().palette` tokens on Mobile, achieving WCAG AA contrast in both Light and Dark themes.

## 4. UI / UX Surfaces & Lifecycle States

- **Web Surfaces (`brandhub-web`):** `pages/workspace-trends/index.tsx` (`TrendMatrix`, `TrendTable`, `TrendHistoryPanel`, `TrendSourcePosts`), `pages/admin/components/AdminTrendGraphPanel.tsx` (`TrendGraphCanvas`, `TrendGraphScene`, `TrendGraphInspector`)
- **Mobile Surfaces (`brandhub-mobile-app`):** `src/screens/more/SocialTrendsScreen.tsx`, `src/services/trendService.ts`
- **UI States:**
  - **Loading / Streaming:** Deterministic skeleton placeholders, progress bars, and disabled submit buttons preventing duplicate requests.
  - **Empty / Onboarding:** Contextual empty state with localized call-to-action and zero fabricated mock fallback data.
  - **Active / Realtime Sync:** Scoped `TanStack Query` cache updates + WebSocket/SSE/polling synchronization where applicable.
  - **Error / Conflict Recovery:** Actionable localized error banners (`400/403/404/409/429/503`) preserving unsaved user input.

## 5. API, Messaging & Protocol Contract

| Route / Channel / Filter | Auth / Scope | Service & Handler |
| :--- | :--- | :--- |
| `GET /api/v1/workspaces/{workspaceId}/trends[/matrix|/history]` | Bearer (`Owner, Manager, Creator`) | `WorkspaceTrendController` -> `workspace_trends.py` (`/ai/trends/explore/*`) |
| `GET /api/v1/workspaces/{workspaceId}/ai/trend-fit` | Bearer (`Owner, Manager, Creator`) | `AiCaptionController.trendFit()` -> `trends.py` `POST /ai/trends/for-brand` |
| `GET/POST /api/v1/admin/ai/trend-graph/**` | Bearer (`Admin`) | `AdminTrendGraphController` -> `trend_graph.py` (`/ai/graph/explorer/*`) |

## 6. Error Handling, Security & Edge Cases

- **Workspace Without Brand Docs:** `trend-fit` gracefully falls back to Workspace industry/description metadata + seasonal moments (`lunar.py`) without failing.
- **Sensitive / Controversial Viral Trend:** `trend_fit/safety.py` filters political/tragedy/unsafe viral spikes from commercial brand recommendations.

## 7. Related Specifications & References

- **Aligned SRS Functional Requirements:** [FR 3.7.1 — View Trending Topics](../../../srs/06-ai-features/3-7-1-view-trending-topics-suggestions/spec.md) · [FR 3.7.2 — View AI Trend Knowledge Graph](../../../srs/06-ai-features/3-7-2-view-ai-trend-knowledge-graph/spec.md)
- **BA & Architecture References:** [BA 06 AI Features](../../../../ba/06-ai-features.md) · [Roles & Permissions Matrix](../../../../ba/10-roles-permissions-matrix.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Production code verified across backend, AI/publisher workers, Web, and Mobile; `vi.json` + `en.json` parity verified; Light/Dark mode audited; all automated verification suites in [test.md](./test.md) passing.
- **Out of Scope:** De-scoped SRS items (livestream features, subscription plan downgrades, PayOS/VNPay/Stripe gateways, Zalo OA publishing, or copyright/plagiarism scanning).
