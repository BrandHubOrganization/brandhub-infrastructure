# Persistent CLI authentication

Objective: keep Codex-managed OAuth and agy login usable across AI-service restarts and container replacement. Requested by the operator; no UI, role, database or public API changes.

Acceptance: Codex CLI owns refresh (no custom OAuth endpoint); managed mode ignores static access-token env overrides; one serialized refresh stream per persistent home; bounded subprocess timeout and sanitized failures. All Codex image, suggestion and critique calls use managed credentials and retry authentication once before streaming. Missing/revoked credentials require explicit bootstrap, never fabricated success. agy profile and Linux keyring persist with stable volume names and runtime ownership. Deployment must not overwrite existing auth.

Verification distinguishes filesystem persistence from authenticated upstream success. Live login checks must pass before and after restart/recreate to claim session survival. Initial interactive login remains necessary if no valid session exists. Existing image HTTP/SSE contract is preserved; CLI manages authentication, not image transport. This does not convert the existing backend endpoint into a supported public API.
