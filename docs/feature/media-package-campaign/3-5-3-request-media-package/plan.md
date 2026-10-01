# Plan - FR 3.5.3

## Scope

Implement E50-04 negotiation requests/counter-offers without replacing the selected package.

## Plan

1. Add `terms_version` plus append-only negotiation-event migration and V2 init update.
2. Implement request-change, counter-offer, and history read endpoints with role/state checks.
3. In the same transaction, update current terms, increment version, and invalidate both approvals.
4. Test multi-round immutable history and approval invalidation.
