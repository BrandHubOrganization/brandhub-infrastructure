# Plan - FR 3.5.10

## Scope

Implement cancellation of a pending request as terminal `CANCELLED` state.

## Plan

1. Enforce request creator and `PENDING` state.
2. Atomically set `CANCELLED` and retain audit/history visibility.
3. Test invalid states, ownership, and no generated-task side effect.
