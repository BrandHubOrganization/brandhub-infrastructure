# Workspace Trend Explorer — plan
Depends on spec.md; supersedes previous materialized-topic design.
1. Dedicated AI read service/routes. Bounded Redis lookup of live snapshot; distinguish published-empty from absent snapshot. Cache page filter operates on at most100 entries. Neo4j fallback latest UTC day, explicit source/reason.
2. Daily graph list seeks date/id (limit+1). Query length100, cursor cap/binding, date validation, timeout8s/overall10s. Public predicate and scalar projection, no global GROUP BY, deep SKIP or exact total.
3. Selected keyword history max90 UTC days, bounded2001 rows, latest per day, null gaps and unknown count. Bounded public source URLs fetched only with detail. No relationship count presented as post count.
4. Keep Trend IDs/nodes. Add normalized keyword and observed count/metric metadata to future writes; existing schema bootstrap gains date/id indexes. Optional rerunnable index-only migration, no automatic APPLY/backfill. Legacy metrics remain null. Locate graph bootstrap rather than editing Mongo init for graph indexes.
5. Business workspace controller/service: WorkspaceAccessService.requireActiveMember then validate and proxy; old routes untouched.
6. Web feature src/pages/workspace-trends with components/hooks/services/types, /workspaces/:id/trends and Workspace nav. Reuse shared Query/Skeleton/Button/Input/Recharts; page QueryClient per existing architecture. Debounced search/cancellation and lazy detail. vi/en aiStudio.json, both themes and responsive. Use UI/UX Pro Max + React guidance, preserve design.
7. Tests with fakes/disposable data; keep new QA in ignored keep-local-only. No full-text/alias admin/projection or multi-day list aggregation now. PROFILE on offline representative graph before asserting production-scale capacity; record missing live validation.

Ranking refinement: use shared semantic-token rank badges; compact the existing Trend cards to rows while retaining detail dialog and source hover. Add score/id cursor to cache and graph reads; composite (date,score,id) index definition in bootstrap/optional migration. Preserve published rank values.

Weekly fix: Business AiTrendController shared score selector prefers numeric weekly_final_score when present, including topic totals; frontend orders by authoritative rank with score tie-break. Do not change the weekly weighting formula or stored Redis data.
