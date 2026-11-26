# Lazy trend graph explorer

Implement the approved 2026-11-23 sketch and lazy loading clarification. Left: searchable, paginated persisted Trend nodes with All graph option. Center: start at root plus one complete hop; user zoom-out to a new threshold requests one more layer. All graph starts at ranked root, then explores disconnected components after exhausting the current component. A selected trend explores only its connected component. Keep cached data, stable existing positions, local filters, read-only APIs and bounded requests. Zoom-in, fitting, resize, focus or rendering must never start a scan. Provide a keyboard/manual Load more alternative, errors/retry and cancellation; do not silently load the full DB.

Right: selected-element header, Overview/Relationships tabs, existing description/aliases when present, readable public properties, related nodes and collapsible technical IDs/raw properties. Never invent descriptions, metrics or source facts. Selection and related-node navigation update the inspector. Preserve original scalar public property contract and safe URL handling.

Existing BrandHub theme/shared controls; parallel vi/en `admin.trendGraph.explorer.*` keys. Responsive side panels overlay on small screens, preserve fixed viewport. No schema, backend authorization, graph data or production mutation. No commits/push requested.

## Follow-up 2026-11-23
Trend list loads automatically near scroll end, including underfilled viewport. No More button; pending/error/retry remain accessible. Remove Hide node and Expand links actions from detail; show type only once. Place graph neighbors compactly without pushing each hop onto increasingly large rings, preserving existing positions as lazy data arrives. No API/database changes; reuse existing loading/error i18n keys in vi/en and theme tokens.

## Pointer and node labels follow-up
Keep hover preview beside latest pointer with measured edge flipping/clamping. Admin canvas displays node names inside opaque shapes; omit type initials and external labels. Remove pinned-node dashed circles while retaining drag position and unpin functionality. Full name remains accessible via hover/detail. Reuse theme and existing vi/en strings.
