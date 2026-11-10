# Verification scenarios

- Internal key missing/wrong: 401 before DB. Non-Admin: denied before AI client.
- Search by literal punctuation/injection-like text, exact date, page lookahead;
  malformed date and out-of-bound fields rejected without queries.
- Real root with no edges returns one node; absent root is 404. DB failure and
  timeout are 503 without generated nodes or successful empty fallback.
- Depth 1 vs 2; direction, parallel edges, cyclic/shared nodes, duplicate rows,
  no dangling edges; stable opaque IDs and separate businessId.
- High-degree roots hit fanout/node/edge bounds and disclose truncation reasons;
  leaf graph below limits reports no truncation. Excluded relation/brand node
  cannot enter results. Properties are allowlisted with bounded text.
- Business forwards only validated parameters, requires Admin for every endpoint,
  rejects malformed AI shapes, maps graph 404 without changing existing client calls.
- Local HTTP stub receives correctly encoded colon, Unicode, percent, ampersand,
  plus and slash characters (no percent double encoding).
- Python syntax/unit checks and Maven compile. If reachable, search and traverse
  live Neo4j read-only and verify edge endpoints/counts; do not seed/clean/replay.

## Results (2026-10-25)

- 25 isolated Python graph checks PASS. Covers API key, validation, HTTP graph
  serialization/errors, breadth-first traversal, parallel/directed/cyclic links,
  all caps, search binding/lookahead, mapping, timeout/config/driver failure, and
  legacy zero-length path/error handling. Fixtures live in ignored keep-local-only.
- Existing Python graph service suite: 6 tests PASS as part of a 28-test run
  before the last two new isolated cases; no existing test source was changed.
- 17 isolated Java service assertions PASS: Admin first on every method, validated
  forwarding/limits, response shapes, graph 404 and upstream 503.
- 6 MockMvc HTTP/controller cases PASS: registered path, ApiResponse/requestId,
  missing/invalid Trend ID, depth, date and numeric conversion. Principal supplied
  by the test fixture; this is not an end-to-end JWT/Gateway check.
- Local real HTTP stub PASS: encoded colon, Vietnamese Unicode, ampersand, plus,
  percent and slash preserved. Foreign-host, scheme-relative and fragment URIs
  rejected by the new client method; existing String GET behavior unchanged.
- Direct read-only Aura smoke PASS: search 2 rows with hasMore=true; existing
  disconnected Trend returns one real node. Connected sample: depth 1 = 6 nodes /
  5 edges; depth 2 = 8 nodes / 13 edges. Unique identities and every edge endpoint
  checked; maxNodes=1 returns one node/zero edges with NODE_LIMIT; absent root 404.
- Python syntax checks and git diff --check PASS. Maven compile PASS.
- Existing AiServiceClientTest initially blocked at testCompile by a cached
  AiCaptionService$Request.class (undeclared type variable E). A verified local
  Maven target clean resolved this: `mvn -o clean -Dtest=AiServiceClientTest test`
  BUILD SUCCESS, 729 main / 215 test source files compiled, 2 tests PASS. No Caption
  source/test modifications and no POM changes.

No schema/data changes, seed, replay/model calls, dependency installs, service
restart or UI changes in this phase. Aura reports the compatible subquery syntax
deprecation warning described in plan.md. Live authenticated Admin HTTP remains
to be checked after Business/AI startup; no claim of deployed endpoints.

## Commit preflight (2026-10-26)

The committed scope includes the newer `/nodes` and `/expand` APIs. The 25 local
foundation checks passed again. An independent checkout of the staged Business
tree compiled offline successfully, with replay-only sources omitted. Python
syntax was checked on the staged graph files. Expanded-node paths are included
in the API contract; these checks do not claim a new end-to-end live graph test.
