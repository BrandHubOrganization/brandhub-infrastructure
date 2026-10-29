# Customer Drive with paid S3 overflow

## Objective
Owner or workspace Manager connects their Google Drive using a separate agency storage grant. BrandHub creates brandhub-[agency name]/[workspace name]. Existing mapped workspace folders are renamed in place to the current workspace name when next resolved. Folder IDs, not names, determine identity. Creators upload media through BrandHub; content records stay in the database. No Client may configure storage or access OAuth credentials.

## Acceptance criteria
- Prefer USER_GDRIVE for every new material, including paid agencies. If authoritative available Drive space cannot hold the upload (including staging/promotion), reserve SYSTEM_S3 only for an active unexpired paid plan with sufficient S3 quota.
- Never fall back on OAuth revocation, timeout, unknown capacity, or generic 403. Existing objects never migrate automatically and reads never depend on subscription status.
- No mirrored writes. Persist the selected provider on the upload reservation/material. Retry uses the original provider and idempotency key.
- Drive OAuth uses drive.file by default; opt-in workspace synchronization requests full Drive scope after explicit user consent (see ../../customer-drive-workspace-sync/spec.md). Both use offline access, PKCE and single-use actor/workspace bound state. Refresh tokens encrypted at rest; never returned to the browser or logged. Reconnection must not silently replace a different account that owns existing files.
- Root and workspace folders remain private. Owner/Manager grant Client audience through BrandHub. Creator cannot grant Client audience. Owner has repository operational access in their agency.
- Disconnect now requires a destructive confirmation and permanently deletes the agency BrandHub Drive resources across all workspaces, tombstones materials and releases quota before removing the old account binding. Another account may connect only after successful cleanup. S3 history remains readable. See ../../customer-drive-disconnect/spec.md (2026-10-27).
- Private Drive media is served through short-lived application capabilities, never public sharing or exposing access tokens. Range requests supported for video.
- S3 quota counts S3 objects/reservations only; customer Drive use is not deducted from purchased BrandHub storage. Concurrent reservations cannot oversubscribe capacity known at reservation time.

## UI
Storage panel in Repository for Owner/Manager: status, connect/reconnect/disconnect; Creator sees status/recovery guidance only; Client sees none. Preserve existing tokens, light/dark, keyboard support. New keys under library.drive in both vi/en locales: title, connected, disconnected, connect, disconnect, connecting, failed, folder, policy, reconnect, quotaFull.

## API
Workspace-scoped storage status, authorize, authenticated code completion, disconnect. Browser callback forwards code/state only; backend validates state and membership again. No arbitrary redirect URI. All normal endpoints return ApiResponse. Missing credentials/schema fail closed.

## Out of scope
Live OAuth consent, applying production migrations, migration of old SYSTEM_GDRIVE objects, native Google Docs editing and bidirectional external-folder synchronization. External owner edits/deletes may make a material unavailable.
