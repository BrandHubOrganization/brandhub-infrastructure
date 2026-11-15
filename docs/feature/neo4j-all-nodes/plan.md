# Plan
1. New AI overview selection/page model, parameterized keyset node query and bounded induced-edge query. Preserve any label in all-scope node mapping; public mapping unchanged. Reuse read-only/timeouts/real-driver guard.
2. Add scope public/all to expand, apply unrestricted node/relationship read only for explicit all; preserve caps. New overview API internal key.
3. Business admin-only overview proxy with bounded validation; explicit scoped expand overload preserves existing Java callers. No access-rule changes to public endpoints.
4. Web overview response schema/API method and All nodes mode with search/page-size/keyset previous stack/refetch; reuse workspace with scope=all, no default-hidden posts, disconnected nodes visible. Error/empty have no invented graph.
5. Existing test files cover keyset continuation, unknown/disconnected/brand nodes, edge caps/projection, scoped expand, auth/validation; run AI, Business tests and Web CI. Use isolated local Neo4j fixture for actual queries if available; never shared DB writes.

## Large graph plan
1. Add read-only keyset edge pages with identical all-node search predicate at both endpoints; admin proxy/auth and request limits remain bounded.
2. Separate bounded wire graph schema from uncapped in-memory scene merging. Progressive loader scans node batches then relationship batches with AbortController, operation identity and resumable cursors; completion requires both streams.
3. Build linear-time component layout plus stable incremental placement with spatial occupancy; explicit rearrange re-groups after links load. No global all-pairs force algorithm in overview.
4. Canvas overview renders the accumulated graph with viewport culling, level-of-detail/collision-aware labels, focus, pan/zoom/full-screen and accessible paginated node selector. Reuse workspace inspector, safe projection and real scoped expansion; public trend SVG unchanged.
5. Verify >200 nodes and cross-batch relationships on isolated Neo4j, loader abort/failure/resume and layout separation/stability, frontend CI/Business/AI tests and local-only visual QA.

## Overview interaction parity plan
Extend OverviewGraphCanvas pointer hit testing to distinguish node drag from background pan; capture pointer identity, retain world coordinates and manual positions. Add release/move controls and double-click expansion guard. Wire workspace highlight/edge labels and hidden types into Canvas; legend uses unfiltered categories so hidden types can be restored. Draw highlights/labels/manual-position markers with bounded screen detail. Update vi/en admin keys. No API/schema changes.

## Rank-one scan plan
AI adds protected read-only GET overview/root and POST overview/neighbors. Neighbors accepts at most 50 frontier elementIds and 200 relationship rows, paginates by (center elementId, relationship elementId), returns safe projected endpoint nodes and edges. No fanout LIMIT loss; cycle-safe BFS visited sets in Web. Business validates bounded payload and requires admin before forwarding. Web HopGraphScan uses rank root -> paged frontier chunks per depth -> next unseen component from keyset pages. GraphScanController consumes a common scan-driver interface; existing GraphScan/public SVG kept. Auto-load all on mount, pause/resume existing buttons. Keep first root as graph rootId; initialize all-mode selection for seeded graph, Canvas starts centered on singleton root. Update vi/en admin phase/progress keys.

## Post visibility/right pan plan
Reuse workspace hiddenLabels/onToggleLabel from OverviewGraphCanvas; add shared Switch with unique labelled id. Pointer drag state tracks canPan/selectOnRelease, right-button starts pan with no node target, left background drags cannot pan and right clicks never change focus. Keep capture/cancel handling, node drag, wheel and keyboard. Update admin vi/en hidePostNodes and overviewCanvasHint. No backend/data changes.

## Relationship context plan
Remove selection-based edge omission from Canvas rendering and hit testing. Use existing Trend visual accent for related edges, stronger opacity/width and consistent arrow color; keep unrelated edges visible. Simplify hitOverviewEdge arguments after removing selection filter. Update vi/en focusLinks label. No API/data changes.
