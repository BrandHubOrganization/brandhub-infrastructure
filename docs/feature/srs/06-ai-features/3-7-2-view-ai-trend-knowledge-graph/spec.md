> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.7.2 — View AI Trend Knowledge Graph

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.7.2` |
| **Use Case ID** | `UC-089` |
| **Feature** | View AI Trend Knowledge Graph |
| **Domain** | AI Features (`3.7`) |
| **Canonical Actors / Roles** | `Owner`, `Manager`, `Creator`, `Admin` |
| **Business Rules** | `BR-20`, `BR-45` |
| **Message Codes** | `MSG01`, `MSG02`, `MSG03`, `MSG07` |
| **Status** | Implemented — Production Verified |

## 1. Objective & Business Value

Provide an interactive Neo4j-backed Trend Knowledge Graph explorer (`/workspaces/:workspaceId/trends` & `/admin?view=trend-graph`) that visualizes multi-platform trend topology across `Trend`, `Topic`, `Keyword`, `Hashtag`, `Entity`, and `PlatformSource` nodes along with `CO_OCCURS_WITH`, `BELONGS_TO_CATEGORY`, and `MENTIONED_IN` relationships (`BR-45`). Content teams (`Owner`, `Manager`, `Creator`) inspect semantic clusters, momentum scores, and brand-fit context before drafting content, while `Admin` audits global ingestion graph health.

## 2. User Story

As an `Owner`, `Manager`, `Creator`, or `Admin`, I want to explore the AI Trend Knowledge Graph with bounded neighborhood expansion, node inspection, and category/platform filtering so that I can trace how viral keywords, hashtags, and named entities connect in real time without exposing cross-tenant workspace brand context.

## 3. Acceptance Criteria

1. **Role & Scope Enforcement:** Authenticated `Owner`, `Manager`, and `Creator` members of a Workspace can inspect the Workspace Trend Explorer (`/api/v1/workspaces/{workspaceId}/trends`, `/matrix`, `/history`), while `Admin` can also query global graph inspection endpoints (`/api/v1/admin/ai/trend-graph/overview`, `/neighborhood`, `/nodes`, `/expand`). Unauthorized callers receive `403 FORBIDDEN` (`MSG07`).
2. **Bounded Graph Traversal (`BR-45`):** Neighborhood expansion strictly clamps hop depth (`depth ∈ [1, 2]`) and neighbor fan-out (`limit <= 100` nodes, `<= 250` edges) to prevent Neo4j Cypher supernode explosions.
3. **Node Inspector & Source Provenance:** Selecting any node displays its normalized label, node type (`Trend`, `Topic`, `Hashtag`, `Entity`), virality/momentum score, first-seen/last-seen timestamps, and anonymized source post evidence across supported trend sources.
4. **Action Bridge to Caption Generation:** Clicking "Use Trend in Caption" from the Inspector pre-populates `trendId` and Neo4j graph context into FR 3.7.6 (`Generate Caption`).
5. **Internationalization (`vi.json` + `en.json`):** All graph controls, node type badges, filter pills, empty states, and inspector labels use key-parallel entries in `src/i18n/locales/{vi,en}/trends.json` and `admin.json` (and `tr('trends.*')` on Mobile) with zero hardcoded UI strings.
6. **Light & Dark Mode Compliance:** Force-directed canvas (`TrendGraphCanvas.tsx`, `TrendGraphScene.tsx`), node category colors, edge opacity, and inspector sidebars adapt seamlessly between Light and Dark themes via semantic CSS variables and `dark:` variants.

## 4. UI / UX & Screen States

- **Web Surfaces:** `pages/workspace-trends/index.tsx` (`TrendViews.tsx`, `TrendHistoryCharts.tsx`) and `pages/admin/components/AdminTrendGraphPanel.tsx` (`TrendGraphWorkspace.tsx`, `TrendGraphCanvas.tsx`, `TrendGraphInspector.tsx`, `TrendGraphSearch.tsx`).
- **Mobile Surface:** `src/screens/more/SocialTrendsScreen.tsx` using `useAppPreferences().palette`.
- **UI States:**
  - **Loading:** Shimmer graph skeleton (`TrendSkeleton.tsx`) while fetching initial overview root and top-weighted edges.
  - **Interactive Ready:** Zoom/pan canvas, search autocomplete, node click -> side inspector + incremental `GET /expand` fetch.
  - **Empty:** Localized empty state when no graph nodes match the selected date window or category filter.
  - **Degraded / Neo4j Unavailable:** Non-blocking error banner (`MSG03`) with retry button; cached summary list remains readable.

## 5. API Contract

| Method & Endpoint | Caller Role | Upstream Handler | Response |
| :--- | :--- | :--- | :--- |
| `GET /api/v1/workspaces/{workspaceId}/trends` | `Owner, Manager, Creator` | `WorkspaceTrendController` -> `ai-service` `/api/v1/ai/trends/explore` | `ApiResponse<WorkspaceTrendListResponse>` |
| `GET /api/v1/workspaces/{workspaceId}/trends/matrix` | `Owner, Manager, Creator` | `WorkspaceTrendController.matrix()` -> `workspace_trends.py` | `ApiResponse<TrendMatrixResponse>` |
| `GET /api/v1/admin/ai/trend-graph/overview` | `Admin` | `AdminTrendGraphController` -> `trend_graph.py` `GET /ai/graph/explorer/overview` | `ApiResponse<TrendGraphOverviewResponse>` |
| `GET /api/v1/admin/ai/trend-graph/neighborhood` | `Admin` | `AdminTrendGraphController` -> `trend_graph.py` `GET /ai/graph/explorer/neighborhood` | `ApiResponse<TrendGraphNeighborhoodResponse>` |
| `GET /api/v1/admin/ai/trend-graph/expand` | `Admin` | `AdminTrendGraphController` -> `trend_graph.py` `GET /ai/graph/explorer/expand` | `ApiResponse<TrendGraphExpandResponse>` |

## 6. Error Handling & Edge Cases

- `NODE_NOT_FOUND` (`404`, `MSG01`): Seed `nodeId` or `trendId` was evicted or never ingested into Neo4j.
- `INVALID_GRAPH_QUERY` (`400`, `MSG02`): Caller passes `limit > 100` or unsupported node type filter.
- `GRAPH_STORE_UNAVAILABLE` (`503`, `MSG03`): Neo4j Bolt driver timeout or circuit breaker open (`app/utils/circuit_breaker.py`); returns structured fallback error without crashing worker pool.
- **Supernode Protection:** High-degree hub nodes (e.g., `#vietnam`, `#trending`) sort neighbors by `co_occurrence_weight DESC, updated_at DESC` before applying `LIMIT`.

## 7. Related Specifications & References

- **Sibling SRS FRs:** [FR 3.7.1 — View Trending Topics Suggestions](../3-7-1-view-trending-topics-suggestions/spec.md) · [FR 3.7.6 — Generate Caption](../3-7-6-generate-caption/spec.md) · [FR 3.7.13 — Crawl Schedule Config](../3-7-13-crawl-schedule-config/spec.md)
- **Consolidated Extension Module:** [`neo4j-trend-knowledge-graph`](../../../modules/05-ai-rag-and-crawler/neo4j-trend-knowledge-graph/spec.md)
- **BA Domain Baseline:** [BA 3.7 AI Features](../../../../ba/06-ai-features.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Parameterized Cypher queries verified in `trend_graph_service.py`, Business proxy authorization verified, Web & Mobile graph/explorer views localized in `vi` + `en` and verified in Light/Dark themes, all test cases in [test.md](./test.md) passing.
- **Out of Scope:** Manual editing of Neo4j nodes from the UI; social publishing outside the 4 canonical platforms (Facebook, Instagram, TikTok, Threads).
