# Persistent CLI authentication implementation plan

Goal: persistent CLI-managed credentials without changing Studio responses.
Architecture: a Python auth manager serializes bounded Codex CLI probes using an OS file lock in CODEX_HOME. A shared async HTTP context refreshes/reloads once on 401. Production enables managed auth; local legacy mode remains compatible. Existing agy volumes are retained, initialized and checked.
Stack: Python, Codex CLI, Linux Secret Service, Docker Compose.
Spec: [spec.md](spec.md). Execute inline using executing-plans; user already selected the approach and requested implementation.

1. Add failing tests for managed token priority, CLI rotation, missing refresh credentials, timeout, concurrent refresh and one-shot HTTP retry. Implement app/services/image/codex_auth.py and integrate codex_provider.py/prompt_suggester.py/config.py.
2. Install pinned Codex CLI in Dockerfile; add auth volume preparation and session verification scripts. Retain the three named auth volumes in production compose and enable managed mode; update deploy preparation so old hosts acquire mounts without losing existing volumes.
3. Run targeted tests, lint, broader tests, Docker build/config checks. Run an isolated restart/recreate probe with actual persisted sessions when available. Record blocked live checks explicitly; never substitute file existence for successful login.

Review focus: stale env override, concurrent rotation, absent CLI/expired session, keyring bus visibility, recreate with unchanged volume names. No commits/pushes requested. No credential contents in output.
