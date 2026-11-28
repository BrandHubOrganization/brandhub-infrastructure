# Tasks

- [x] Fix endpoint inheritance, isolate cheap review model, consolidate batches and verify exact call counts.
- [x] Run bounded live review and document fresh-S3 access outcome (fresh S3 remains blocked by InvalidAccessKeyId).

- [x] Extend label review and add regression tests.
- [x] Implement validated/cached T7 display naming and tests.
- [x] Connect display-name persistence and Business presentation without changing identity.
- [x] Make training-row export idempotent and add monthly VM runner/timer/runbook.
- [x] Run focused tests, inspect diff and document operational prerequisites/results.

Direct Anthropic authentication and two Haiku review calls succeeded after pinning the
endpoint. Earlier HTTP 401 checks inherited a DeepSeek endpoint and cannot be attributed
to Anthropic. Current S3 credentials return InvalidAccessKeyId. The user will identify
the VM later; no timer is activated.
