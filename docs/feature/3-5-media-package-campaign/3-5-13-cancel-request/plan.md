# Plan - FR 3.5.10

## Scope

Implement cancellation of a pending request as terminal `CANCELLED` state.

## Plan

1. Enforce request creator and `PENDING` state.
2. Atomically set `CANCELLED` with workspace/creator/status/version predicates and audit/history visibility; Manager receipt races with cancellation, one succeeds.
3. Test invalid states, ownership, and no generated-task side effect.

Existing PENDING requests remain cancellable after Campaign completion. Add parallel vi/en `requests.cancelDialog.*` keys, keyboard focus and light/dark/mobile verification. No hard delete, no Task mutation. API/version conventions and cutover follow the [shared plan](../remaining-work/plan.md).
