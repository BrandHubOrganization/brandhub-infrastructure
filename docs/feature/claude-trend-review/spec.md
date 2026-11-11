# Claude trend review

## Objective
Use Claude API to review new post emotion labels and name T7 trends without altering NER, scoring, membership or stable IDs. Collect corrections for monthly PhoBERT refresh on an existing VM.

## Acceptance
- Reuse current label-check stage; review all new post emotions once per crawl run, in bounded batches. Preserve existing topic selection/seed constraints.
- Preserve original PhoBERT softmax when Claude changes a label; do not invent a 100% probability. Persist correction provenance and training rows.
- T7 receives an optional display_name, naming status and quoted source evidence. keyword/post_ids/scores/IDs remain unchanged. Mixed/insufficient/invalid output keeps the old display fallback.
- Call configured Claude directly, never silently switch providers. Errors/missing key keep the original pipeline output. Reuse valid naming decisions when source content and model are unchanged.
- Persist/display the new name through Neo4j, trend-fit context, chunks and Business-service display mapping; IDs continue to use keyword.
- Provide a calendar-month VM retraining entry point using real corrections plus old replay data, a held-out quality comparison, versioned outputs and no automatic replacement of production adapters. Monthly job installation depends on identifying the existing VM.
- No UI redesign, NER retraining, speculative entity changes, new GPU purchase or deployment.

## API
Cost/auth follow-up: pin the Anthropic endpoint explicitly, use a separate economical review model, merge emotion batches across platforms, and disable automatic retry/provider fallback for review calls. Naming remains batched and content-cached. S3 testing must use current configured credentials; do not substitute old local data for fresh S3 results.

CandidateTrend adds optional display_name and name_status. Existing keyword remains the stable source key. All existing fields remain backward-compatible. Emotion probabilities retain their model meaning even if the reviewed label differs.

## Failure behavior
Invalid JSON/labels/IDs/citations, missing credentials, model errors or incomplete response cannot overwrite validated values. Uncached failures remain retryable. Training cannot publish a regressing or unvalidated adapter.
