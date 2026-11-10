# Test scenarios

- Query defaults: all dates, page 20, depth 2, maxNodes 100. Submit search/date
  resets page; paging doesn't unexpectedly clear selected Trend. Malformed URL
  stays safe and offers reset. Deep link selects without searching first.
- Correct search/query forwarding and no prior graph visible during new selection;
  network cancellation / delayed results cannot show a mismatched graph.
- Root-only and connected graph, parallel/directed edges, valid properties,
  rejected dangling edges/oversized malformed payloads. Truncation warning with
  exact server reason. Unsafe URLs remain text and HTML content remains escaped.
- Node/edge selection via canvas and lists; zoom, fit, pan buttons, pointer pan;
  reset view and state on new graph, no viewport state leakage between roots.
- Empty search, 404 missing root, 503, retry, pending/loading and successful reload;
  list failure doesn't hide a deep-linked graph. No production fallback fixtures.
- Keyboard focus and labels, language switch, light/dark screenshots, narrow
  screen no horizontal overflow, reduced motion and no animation dependency.
- Build and changed-file lint; local artifacts only in ignored keep-local-only.

## Results (2026-10-25)

- Production build PASS; new graph view is lazy loaded. Existing application
  large-chunk and mixed static/dynamic library import warnings remain unchanged.
- Targeted ESLint PASS with no new warnings; Admin index remains 140 lines and all
  new source files are below 300 lines. 52 graph locale keys match in vi/en.
- Playwright CLI on a separate Vite 3107 instance, actual AdminPage rendered under
  BrowserRouter with API fixtures: PASS, 18 intercepted graph/search requests and
  zero application pageerror events. No DB writes or paid model calls.
- PASS: default all dates, literal Vietnamese/ampersand/plus/percent query, search
  submit/re-submit, pagination, selected root and depth changes, no previous root
  while pending, history Back/Forward, viewport reset on root change, deep link
  still works when search fails or does not contain the selected root.
- PASS: zoom, fit-to-content, directional and pointer pan, keyboard node selection,
  relationship list filtering/selection and property projection. 4 fixture nodes /
  5 distinct curved paths; invalid dangling/duplicate topology rejected by schema.
- PASS: isolated root, 404, 503, malformed graph, retry, truncation reason, empty
  search, independent search error, invalid URL/reset. React escapes hostile text;
  javascript source URL is not rendered as a link.
- PASS: 375/768/1440 x light/dark = 6 layouts with no horizontal page overflow.
  SVG text measured approximately 14 CSS px in every case; vi/en and reduced motion
  checked. Light/dark screenshots visually reviewed under output/playwright.
- Local-only QA script is in ignored keep-local-only; screenshots and CLI logs
  are ignored. No tests added under src, no package/dependency changes or commits.

Live authenticated Gateway -> Business -> AI -> Neo4j has not been exercised in
this UI phase. Backend direct read checks are documented in trend-graph-core.
The synthetic browser fixture can produce Vite HMR local-network WebSocket errors;
these concern development hot reload in that test context, not application graph
requests. Application error cases intentionally produce HTTP 404/503 in QA.

## Commit preflight (2026-10-26)

The UI has since gained force/radial layouts, node expansion, drag/pin and label
controls. The results above describe the original foundation, not a full browser
regression of these later additions. The exact staged tree passed production
build and changed-file ESLint in an isolated local checkout without replay-only
files. No new dependency, test code, image, environment file or local tool is
included in the commit. Some later UI components exceed the suggested 300-line
size; component decomposition is deferred rather than mixed into this commit.
