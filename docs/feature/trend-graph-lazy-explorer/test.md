# Verification

- Chain A-B-C-D: initial load includes A/B only, first new zoom-out threshold adds C, next adds D. Zoom-in/out to the same extent does not reload cached layers. Fit/resize/hover must cause zero API expansion calls.
- Page a single hop over multiple pages and 50-ID frontier slices before crossing its boundary; bound one interaction to at most eight requests. Retry retains cursor and accumulated data; repeated cursors fail safely.
- All-mode: after connected component exhaustion, advance to disconnected seeds through pagination. Trend mode never invokes seed enumeration. Empty/null ranked root and isolated nodes work.
- Busy requests cannot overlap/queue uncontrolled work. Unmount/switch aborts previous work; revisiting a cached view does not re-fetch initial graph. Cached views bounded to ten.
- Trend search has loading/empty/error/retry, paginates and accepts real unknown names safely; selecting All returns to cached All view. Explicit trend/node links resolve correct root.
- Inspector presents actual public data, missing fields without fabricated text, overview/relations/raw disclosure, safe links, keyboard and related selection.
- Theme/locale/390/768/1440 viewport checks; local filters still apply to newly received data. Full Web CI and final diff check.

## Local verification — 2026-11-23

- Offline scanner/controller/zoom tests: 16 passed across two ignored QA files, including eight legacy compatibility cases.
- Browser QA with the real Admin page and isolated API adapter: 22 checks passed; native mouse-wheel expansion and keyboard Trend search also passed. No production/database requests or writes.
- Checked initial 1-hop, monotonic zoom threshold, no idle/fit/resize loads, disconnected components, connected-only Trend traversal, cached return, pagination, error retention/retry, direct links, mobile viewport, Vietnamese/English and settled dark-mode contrast.
- Targeted ESLint: no errors/warnings; locale parity: matching explorer keys. Full `npm run ci` passed: lint (0 errors, 227 repository warnings), type-check and production build/prerender. Generated SEO outputs restored after verification.
- QA fixtures, scripts and images remain ignored under Web keep-local-only; no new tracked test files.

## Follow-up cases
- Scroll near end fetches next page once; underfilled list fills automatically; pending does not overlap. Error stops automatic retries, explicit retry works; query change resets list.
- Detail has one type label, no Hide node or Expand links button, relationships still navigable.
- 200-neighbor hub uses area packing instead of circumference radius; incremental nearby node lands near its linked neighbor; old coordinates stable and no duplicate positions; disconnected components remain separate.
- Keyboard, vi/en, light/dark, responsive viewport, existing scanner tests, Web CI and diff check.

Follow-up local results: 20 offline tests passed (4 compact-layout cases plus 16 scanner/zoom/compatibility cases). Includes 200-neighbor packing, 2,000-neighbor performance, coordinate stability, disconnected/self-edge handling. Browser QA: 14 checks passed with isolated API fixture; automatic underfilled/scroll pagination, no duplicate requests, failure stops retry loop, explicit retry, search resets scroll, removed actions/redundant type, fixed viewport, mobile dark/English, no page errors. Targeted lint passed. Full npm run ci passed (exit 0): lint 0 errors/227 repository warnings, type-check, production build and 105 prerendered routes. Generated SEO files restored. QA artifacts remain ignored.

## Pointer/label checks
Latest pointer updates before/after hover delay. Tooltip within graph, beside pointer unless flipped at boundaries. Canvas records actual name text inside node only, no type code, no pinned arc/dash; long names ellipsized without overflow. Updated radius used for boundary and hit testing. Drag still persists; tooltip hides during drag and full name remains available; light/dark/mobile and CI.

Pointer/label verification: 23 offline tests passed (including measured Unicode wrapping, clipped canvas text without type initials/pin strokes, shared radius/boundary checks). Browser QA passed 12 checks with isolated API adapter: latest pointer before delay, visible pointer following at 12px, flip/clamp at bottom-right, drag hides tooltip and retains position, no dashed circles, English full-name tooltip, mobile bounds and no page errors. Light/dark screenshots inspected. Targeted lint passed; full npm run ci passed (exit 0), including lint (0 errors/227 repository warnings), type-check, production build and prerender. Restored generated SEO outputs. All verification artifacts remain ignored.
