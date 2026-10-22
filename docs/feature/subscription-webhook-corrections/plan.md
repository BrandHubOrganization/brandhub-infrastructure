# Plan

1. Add in-repo Spring transaction-proxy integration tests with a disposable Testcontainers PostgreSQL and synthetic fixtures. Reuse existing minimal service DDL for regression tests; full-schema API/SQL QA remains the constraint/ledger validation layer.
2. Reserve the event unique key before parsing order content. On duplicate compare canonical business fingerprint (or exact legacy DTO hash), record last_error plus immutable audit hashes for the original order agency when available; do not overwrite the original hash/status/financial effect.
3. Attach a newly received event to the resolved order, then keep existing validations and locks. Unmatched events get durable review status.
4. Allow valid expired orders through the same fulfillment checks as pending orders; preserve plan/future-period conflict review and add explicit reason.
5. Run regression tests, full Maven unit suite and isolated QA gates; retain initial red evidence. No live database mutation or schema migration is needed.

Risk: canonical hashes cannot reconstruct semantically equivalent historical payloads when only their old raw hash was stored. Exact legacy retries remain accepted; otherwise fail closed to review. Do not retry a callback automatically after an uncertain commit; provider replay is idempotent.

AB-10 follow-up: add a red regression for a second event ID on a fulfilled order; constrain the review-path attempt update to preserve SUCCEEDED. Re-run transaction and mutation cases on the corrected build.

