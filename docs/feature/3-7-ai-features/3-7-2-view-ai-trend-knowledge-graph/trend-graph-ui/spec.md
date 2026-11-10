# Trend graph UI foundation

## Objective and scope

Admin can inspect existing public Neo4j trend graphs through the completed core
APIs. Add `/admin?view=trendGraph` with navigation from published Trends. Preserve
BrandHub design; no DB/schema, model, pipeline, Chroma, editor or permission changes.

## Acceptance criteria and states

- Search persisted Trends by literal name and optional date, explicit submit,
  page 20 rows with previous/next and visible current range. No current-date filter
  by default, since historical Neo4j records can outlive Redis snapshots.
- Selecting a Trend immediately loads its graph. URL persists trendId, depth,
  search/date/page; Back/refresh restores selection without requiring the search
  result to contain the selected Trend. Depth 1/2 and node bounds 50/100/200.
- Graph displays only returned real nodes/edges, their direction and parallel
  relationships. Supports radial and bounded force layout, node drag/pin, zoom,
  fit, pointer pan and equivalent directional buttons. No new graph dependency.
- Select nodes/edges to inspect public properties and IDs. Provide keyboard-usable
  node/edge lists alongside graph so information never depends on color/dragging.
  Node placement is visual only, not a metric or confidence measure.
- Independent list and graph loading/error/retry; empty search, missing Trend,
  isolated root, invalid URL and truncated response have explicit feedback.
  Never substitute mock data or keep a previous Trend graph after selection change.
- Display returned graph counts and truncation reasons; no claim of full DB view.
  Cap rendering at backend contract bounds. Safely render text and only link http(s).
- Search can include eligible public nodes, and expansion can merge their returned
  neighborhoods into the displayed graph. Support label visibility, edge labels,
  neighbor highlighting and collapsing the search panel.
- All graph labels use `admin.trendGraph.*` and `admin.navigation.trendGraph` in both
  src/i18n/locales/vi/admin.json and en/admin.json. Existing tokens/shared controls;
  light/dark, keyboard and responsive 375/768/1440, reduced motion/static layout.

## API contract / definition of done

GET Business `/api/v1/admin/ai/trend-graph/trends`, `/neighborhood`, `/nodes` and `/expand` using shared
authenticated Axios, cancellation and TanStack Query; Zod validates response bounds
and edge endpoints. Catalog is a backend vocabulary contract, not a health probe;
the UI needs only graph/search responses. Done after build/lint and isolated browser
checks. Live authenticated HTTP validation depends on running Business/AI services.
No commits/push, no new tests in src; local verification remains keep-local-only.
