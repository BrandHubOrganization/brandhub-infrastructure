# Plan - FR 3.5.4

## Scope

Implement E50-05 two-party approval for one negotiated terms version.

## Plan

1. Increment the terms version and invalidate both approvals whenever terms change.
2. Persist/derive approvals tied to the current terms version.
3. Add the approve API behaviour.
4. Transition to `APPROVED` only when both approvals match the same version.
5. Test first approval, second approval, changed terms, and duplicate calls.

