# Verification

## Isolated verification

Reject empty/broad/escaped prefixes, invalid IDs, future/reversed dates, more than
31 days, more than 500 objects, oversized files and malformed JSON. Discovery must
paginate, group by an unambiguous key date and pin reads to the previewed ETag.

Use fake S3/model/graph/vector services and a disposable Redis instance. Verify
oldest-day-first processing, all file batches before daily aggregation, previous
days only in the history window, duplicate handling and original source dates.
Failures block later days; explicit resume skips completed checkpoints. Missing
checkpoints and changed source objects must block instead of silently rebuilding.

Verify preflight checks Neo4j/APOC, Chroma and finite nonzero 384d vectors before
file/model work; failures leave extraction checkpoints untouched. Verify replay
tracking keys and history roots are isolated and normal live defaults remain intact.

Check Admin authorization, internal-key protection, date validation and start/resume
auditing. On Web, check preview invalidation, duplicate Start prevention, polling,
errors/results, vi/en, keyboard interaction and light/dark responsive layouts.

All executable QA files and generated artifacts stay in ignored keep-local-only
folders. This document is a shared verification plan, not executable test code.
Never flush shared Redis or call paid models as part of isolated QA.

## Verification result — 2026-10-26

93 checks passed: 89 existing regression checks and four local behavior repros.
Coverage includes replay, normal-pipeline compatibility, runtime readiness,
caption generation, RAG ingestion, Ambassador API/client, Commercial image API,
video parameters/styles, scheduling/event-loop behavior and trend persistence.
Worker/model and graph/vector calls were mocked; Redis was disposable. These
checks do not establish real worker availability or performance under load.

The four passing repros confirm unresolved behavior, not fixes:

1. A stale same-day replay can update graph data while Redis keeps a newer snapshot.
2. Global resolution can cluster same-label/name entities across Brand namespaces.
3. An archived replay can populate the live cache when no newer snapshot exists.
4. An in-flight blocking vector write can finish after async task cancellation.

See the known limitations in spec.md and remaining work in task.md. Require an
explicitly authorized runtime test for real S3 reads, paid AI or shared persistence;
inspect daily publication and resolution status rather than treating HTTP 202 as
successful completion.
