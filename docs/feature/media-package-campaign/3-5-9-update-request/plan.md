# Plan - FR 3.5.9

## Scope

Implement Client editing of a pending content request.

## Plan

1. Load by workspace and request ID, enforcing request creator ownership.
2. Perform conditional update only where status is `PENDING` and expectedVersion matches; whitelist title/description/type/dueDate and validate the resulting values like creation.
3. Return `409 REQUEST_NOT_EDITABLE` if a Manager changed status first.
4. Test partial updates, ownership, and concurrent status transition.

Reuse create form fields with parallel vi/en `requests.json` keys, keep conflict input and semantic light/dark tokens. Existing PENDING requests may still be edited after Campaign completion. Follow the [shared plan](../remaining-work/plan.md) for API scoping, unsupported-field errors and migration; do not change Task/editor DTOs.
