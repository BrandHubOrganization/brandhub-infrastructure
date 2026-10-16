# Plan - FR 3.5.4

## Scope

Implement E50-05 two-party approval for one negotiated terms version.

## Plan

1. Increment the terms version and invalidate both approvals whenever terms change.
2. Persist/derive approvals tied to the current terms version.
3. Add the approve API behaviour.
4. Transition to `APPROVED` only when both approvals match the same version.
5. Test first approval, second approval, changed terms, and duplicate calls.

Phase 5: validated ApproveMediaPackageRequest, required expectedTermsVersion;
check while holding PESSIMISTIC_WRITE selection lock, before approved fast path.
Preserve a side's non-null timestamp on repeated same-version approval. Web always
sends displayed termsVersion; 409 is not retried against a newer version.

