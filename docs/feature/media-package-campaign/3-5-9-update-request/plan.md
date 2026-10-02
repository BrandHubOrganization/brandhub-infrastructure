# Plan - FR 3.5.9

## Scope

Implement Client editing of a pending content request.

## Plan

1. Load by workspace and request ID, enforcing request creator ownership.
2. Perform conditional update only where status is `PENDING`.
3. Return `409 REQUEST_NOT_EDITABLE` if a Manager changed status first.
4. Test partial updates, ownership, and concurrent status transition.
