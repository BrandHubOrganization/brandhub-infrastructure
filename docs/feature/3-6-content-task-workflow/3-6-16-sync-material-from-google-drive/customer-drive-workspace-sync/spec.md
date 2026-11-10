# Workspace Drive sync and upload readiness
## Objective
Files uploaded directly into each mapped workspace Drive folder appear as private internal BrandHub materials; never import agency root files or another workspace. Google authorization must explicitly grant the configured broader scope; never silently broaden an existing grant.
## Acceptance
- Scheduled additive import traverses mapped workspace folders, follows pagination, skips shortcuts/native Google documents and unsupported MIME. No whole-Drive scan. Stable per-connection/file identity prevents duplicates and resurrection of trash/purged materials.
- Imported binaries can be read/downloaded through existing private capabilities. Default RAW/MATERIAL/INTERNAL; no automatic client visibility. Do not copy file bytes.
- Upload readiness: bind explicit writes flag; verify truly empty agencies before initializing zero inventory. Agencies with preexisting metadata/reservations require real inventory. Missing agency Drive returns actionable error, no fallback during outage.
- Imported originals participate in existing quota accounting and disconnect cleanup. Metadata import is recoverable across PG/Mongo failures; connection lease prevents disconnect races.
## UI / i18n
Use existing UI/themes. Add library.upload.driveNotConnected in vi/en. No new palette. Existing permission checks remain.
## Scope
Additive imports only; external rename/content/deletion reconciliation is not bidirectional editing. No automatic grant change; user performs Google consent. No auto-public sharing.

## Accepted Google permission
User explicitly chose full Drive scope for synchronization and existing deletion support. When sync is enabled, authorize requests https://www.googleapis.com/auth/drive; completion stores and verifies the exact granted scope. Existing per-file grants stay readable but cannot import until the user reconnects. Imported files moved outside their workspace are blocked on read; disconnect preserves moved-out external files.
