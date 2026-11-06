# Verification

- Generate/refine/adapt must supply `X-AI-Workspace-Id` from their endpoint and a UUID `Idempotency-Key`; separate calls have distinct keys.
- Preserve caller payload and unwrap the existing `data.data` envelope.
- Refresh the authenticated user's credit queries after success and after failure; propagate the failure unchanged.
- Local tests mock transport only and do not call a model or charge credits.
- Live UI: select the Viettel event trend, supply factual BrandHub context, generate once and inspect three results or report the exact blocking error. Do not publish.

## Results — 2026-11-05

- Regression proof before change: 4 request-contract tests failed because generate/refine/adapt omitted credit headers and did not refresh balances.
- After reusing `postAiWithCredit`: 4/4 tests passed. TypeScript app/node checks passed.
- Caption/Humanizer/Neo4j regression suite: 39 passed in 3.85s; providers mocked.
- Live UI used the Viettel VGC event trend and factual BrandHub topic. The submitted request returned HTTP 503; no successful caption result was produced.
- Read-only PostgreSQL inspection: `agency_credit_wallets`, `credit_grants`, `workspace_credit_limits`, and `ai_credit_operation_prices` are absent; caption `credits` is integer and Video `reservation_id` is absent. Schema updates are a prerequisite to live generation. No database schema, balance or payment data was changed.
- Normal-config Neo4j read earlier in this task found the selected event with 3 source posts and 3 entity mentions. This proves graph evidence exists; it does not prove that the blocked UI request reached the model.

The baseline now marks CAPTION_VARIANTS as non-billable (`CreditOperation.isBillable()`); it still requires valid accounting schema and a reviewed/initialized Agency wallet. No prices or test funds were invented.

## Subsequent authorized API-only acceptance

- Normal authenticated Business API on the main-code preview (8091 -> AI 8092) returned HTTP 200, 3 variants, generation `2cd8512d-3e6a-4ac1-a190-55e1b2445b60`.
- Real selected event: `trend:2026-11-04:all:hang-cay`. Redis supplied the card; independent Neo4j lookup returned 2 sources/2 mentions. Humanizer is embedded in the generator prompt.
- First generation: 231.59 seconds. Gemini logged two HTTP 503 responses then Claude fallback; PhoBERT loaded on first use. Per-stage timings were not measured.
- Response context: brand=true, trend=true, examples=0, knowledgeChunks=0, task=false. Do not claim Chroma contributed retrieved documents.
- Same key/body retry returned the identical generation and captions. PostgreSQL contains one matching generation with 3 options, reservation SETTLED/SUCCEEDED and charged_amount=0. Balance stayed 5,000.
- All variants reported compliance PASSED, unverifiedClaims=[] and issues=[]. These automated checks do not establish semantic retrieval quality.
- Found warnings: mixed source posts in one excluded Viettel candidate, irrelevant Neo4j entities for the selected event, and a literal-keyword trendUsed=false signal despite the muon_format technique. No application/data-quality fix or manual caption editing was performed as part of this API test.
- User explicitly prohibited UI interaction for this acceptance run; none was performed.
