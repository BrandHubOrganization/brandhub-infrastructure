# Plan

1. Add a monotonic completed-layer boundary and connected-only option to HopGraphScan. Add bounded loadLayer to GraphScanController, leaving existing load(all) behavior compatible.
2. Create lazy scanner hook with session cache, selected-root reader, initial single-layer load, cancellation and per-action request budget. All-mode uses ranked root + paginated disconnected seeds. Use existing node search and expand/neighborhood APIs to resolve explicit links.
3. Add left Trend selector with debounced local input applied on search/submit, keyset-safe query pagination using existing node search offset/limit contract, loading/error/empty states and selection.
4. Wire explicit user zoom-out only to a new low-water threshold (~20% reduction); synchronous busy gating prevents duplicate requests. Preserve camera/positions and do not auto-fit newly loaded data. Manual Load more uses the same bounded layer action.
5. Refine inspector into overview/relations/raw disclosure without discarding returned public data. Update vi/admin.json and en/admin.json; preserve local filter/geometry work.
6. Offline scanner and zoom policy tests; browser tests with chain/disconnected/paginated fixtures; light/dark/keyboard/mobile; full Web CI. Keep QA in ignored keep-local-only, no new src test files.

## Follow-up
Use IntersectionObserver rooted in trend list, guarded by pending/error/hasMore. Reconnect on pagination changes and disconnect on unmount/search. Remove unused inspector expansion props and hiding state from Workspace; exclude redundant type property. Replace radial layout with deterministic occupied-cell neighbor packing (96px spacing), shelf disconnected components, incremental placement anchored to existing neighbors. Reuse existing admin loading/retry keys; no new locale keys.

## Pointer/label implementation
Track latest pointer in hover hook; measure preview and parent via ResizeObserver and position beside pointer. Add measured text wrapping/ellipsis utility for canvas labels, enlarge shared overview radius while keeping boundary/hit geometry consistent. Clip text to node shape; remove pinned-circle drawing. No data/API or locale keys change.
