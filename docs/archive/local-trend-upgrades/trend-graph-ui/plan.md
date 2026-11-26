# Plan

1. Admin feature types/trendGraph.ts for strict bounded DTO parsing and selection;
   services/trendGraphService.ts and hooks/useTrendGraph.ts for query/URL lifecycle.
2. Lazy-load AdminTrendGraphPanel only for new Admin view; reuse sidebar and
   PageWrapper. Compact left search panel, main graph, and lower inspector with
   node/edge lists; stack on mobile. Link from existing published Trend screen.
3. Pure utils/graphLayout helper computes hop rings, edge curves and parallel offsets.
   SVG renderer uses existing semantic colors and labels, native titles, and a
   bounded force-layout option. useGraphViewport manages zoom/pan in viewBox coordinates, pointer
   capture/cleanup, keyboard/button alternatives; instance-local marker IDs. Fit
   uses real node/curve bounds; ResizeObserver preserves readable SVG label sizes.
4. Dedicated search/canvas/inspector/status components keep file sizes bounded.
   Parent selection keyed by returned graph identity prevents stale inspector or
   viewport state. Error views show friendly i18n messages, no raw stack/DB detail.
   Current UI additionally supports public-node search/expansion, visibility
   filters, neighbor highlighting, label toggles and node drag/pin controls.
5. Update src/i18n/locales/vi/admin.json and en/admin.json key-parallel. Build,
   targeted ESLint, local-only pure/schema checks and Playwright CLI browser QA:
   fixture-only API responses, both languages/themes, 3 sizes, keyboard, retries,
   no mock fixture bundled in application. Screenshots under output/playwright.

## Graph-first revision — 2026-11-22
Reuse HopGraphScan. Update AdminTrendGraphPanel default and collapsed detail search; TrendGraphOverview owns filter visibility and passes into Workspace/OverviewGraphCanvas. Workspace preserves ranked root through visibility filters, hides posts and inspector by default, opens inspector on explicit selection. Add delayed hover hook + reusable property preview, canvas node shapes and edge arrows/labels. Keep bounded readable labels for dense graphs. Update vi/admin.json and en/admin.json. Browser fixture QA in ignored keep-local-only, full npm run ci.
