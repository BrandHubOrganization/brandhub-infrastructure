# Plan

## Follow-up implementation

1. Route AdminTrendGraphPanel exclusively to TrendGraphOverview; preserve URL node/trend selection as initial focus.
2. Keep useGraphScan('', 200) auto-load semantics; batch size remains an internal request limit. Move local filter state into the workspace; remove obsolete status/count and mode controls.
3. Add typed graph filter utility and a compact GraphFilterBar with custom-condition popover. Dynamic types and incident degree come from the unfiltered merged graph. Filter results never replace the fetched source graph.
4. Open existing inspector on selection; remove visible hints/legend and category switches from the unified canvas while retaining accessible instructions and node list.
5. Update vi/en admin.json, verify filters, partial loading, >200-node/disconnected fixture, deep links, properties, accessibility and full Web CI. Preserve existing local changes and keep QA fixtures ignored.

1. Simplify AdminTrendGraphPanel selection without changing deep-link behavior.
2. Bound AdminPage, overview, workspace and both canvases with flex/min-height:0. Show detail actions inside an overlay drawer. Bound filter and keyboard list scrolling separately.
3. Share Canvas shape-boundary geometry with shape tracing; calculate radii consistently, trim directed lines and loops, paint opaque node bases, and reduce unrelated label clutter. Correct SVG dynamic-radius endpoints as well.
4. Verify with offline geometry assertions and browser fixture using actual components, mocked data APIs, responsive layouts, selection/drag/zoom, light/dark and vi/en. Run Web CI.

Files: admin index/components, overviewShapes/overviewCanvas/graphLayout. Existing locale files are reviewed for key reuse; add the compact interaction hint to both vi/admin.json and en/admin.json. Preserve pre-existing working-tree changes.

## Compact toolbar implementation
Move refresh/loading controls into GraphFilterBar trailing slot. Float compact canvas controls at bottom left; remove two named buttons. Extend typed local filters with optional quick options; add grouped filter panel using existing Popover/Input/Button controls. Reuse Campaign styling, add vi/en labels, preserve custom rules and selected properties. Follow Neo4j Bloom scene-first/overlay layout (official overview and scene interactions docs consulted 2026-11-22).
