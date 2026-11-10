# Destructive agency Drive disconnect
## Objective / user story
Agency managers can deliberately delete the agency's BrandHub Drive resources and connect another Google account.
## Acceptance criteria
- Owner/manager confirms a destructive warning covering every agency workspace, including trash and uploads. Never delete unrelated Drive files or system storage.
- Disconnect fences Drive grants and OAuth callbacks before deletion. Durable disconnecting state survives failure/restart; retry resumes cleanup. Do not permit another connection until cleanup succeeds.
- Delete tracked Drive objects (including moved objects), workspace folders and the agency root; tolerate 404. Retain credentials until cleanup is complete.
- Tombstone USER_GDRIVE materials, fail upload sessions, release reserved and committed quota once, remove mappings and connection. Other providers/agencies remain unchanged. Existing external references may become unavailable; warn explicitly.
- Repeated disconnect is harmless. New authorization after successful cleanup can choose another account.
## UI / i18n
Use existing danger ConfirmDialog. Update workspace.agencyStorage.disconnectDescription, disconnectSuccess; add disconnectConfirm, disconnectPending, disconnectFailed to both vi/en workspace.json. Theme tokens and existing keyboard/mobile behavior remain.
## API / errors / states
DELETE existing workspace storage/drive route; status adds disconnecting boolean. Pending cleanup blocks authorize/complete; errors retain retry action. Missing connection returns success.
## Out of scope / done
No migration of old files, no deletion of personal Drive outside BrandHub folders, no live destructive execution. Done when targeted backend/frontend checks pass or environment limitations are recorded.

## Readiness diagnostics
When storage is unavailable, backend logs must identify disabled/missing environment variable names, invalid encryption key format/length, missing tables or disconnecting column. Never log configuration values, credentials or tokens. Public API stays unchanged.

## Callback diagnostics
Callback validation failures must log only reason, origin and boolean presence flags; never OAuth values or identity IDs. API failures log status and correlation identifiers only. UI remains unchanged; no cross-origin fallback or weakening actor validation.
