# Verification plan

| Case | Expected |
| --- | --- |
| Exact trend with evidence | Parameterized read query; grouped names/types with source URLs. |
| Another client or trend | Excluded by query predicates; no name-based or arbitrary-depth traversal. |
| Missing graph, mock, malformed URLs | No invented context; existing captions continue. |
| Long/duplicate rows | At most 3 posts, 12 mentions and 3,000 prompt characters; JSON stays valid. |
| Graph connection/query failure | Empty context and a redacted diagnostic. |
| Deadline | Cancels optional lookup and falls back after the configured bound. |
| Selected pipeline event | Resolve Redis card, fetch graph, pass context to existing generator. |
| Plain/moment/format caption | No graph lookup. |
| Unknown trend | Existing 404; no graph lookup or generation. |
| Model prompt | Includes graph evidence and source interpretation rules, retains Humanizer/brand/trend and one generation call. |
| Numeric fact check | A number appearing only in graph evidence does not authorize a fabricated product claim. |

UI locale/theme: not applicable. Provider calls are mocked. Optional live verification must be read-only and must not call a paid model.

## Results

Verified on 2026-11-03:

- Before implementation, the prompt integration test failed because `generate_caption_variants` did not accept graph context.
- Initial focused suite: **93 passed in 121.18s**:

  ```powershell
  .\.venv\Scripts\python.exe -m pytest tests/unit/services/test_caption_service.py tests/unit/services/test_caption_graph_context.py tests/unit/api/test_trend_fit_api.py tests/integration/api/test_content_endpoint.py tests/unit/services/test_trend_fit.py -q --disable-warnings --maxfail=3
  ```

- After adding the character-budget edge case, graph and caption tests: **39 passed in 8.59s**. Runtime code did not change after the initial suite.
- Tests cover exact parameterized read, client predicates, source URLs, deduplication, record/character limits, unavailable graph, timeout/cancellation, event-only wiring, existing schemas, Humanizer and numeric-claim checks. Providers are mocked.
- Live read-only probe: `EXPLAIN` accepted the actual Cypher; a public graph trend returned **3 sources, 5 entity mentions, 692 context characters** through the new loader. No database write or paid LLM call.
- Compilation and tracked diff whitespace checks passed. Tests ran outside the Windows sandbox because its event-loop socket setup previously stalled.

Limit: no paid end-to-end caption request was made, and no production process was restarted by this change. Existing graph records must contain evidenced source-post links; bare/inferred entity associations are intentionally insufficient.
