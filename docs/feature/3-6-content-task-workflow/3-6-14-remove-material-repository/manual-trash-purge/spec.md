# Manual permanent deletion
Users may request permanent deletion of one trashed file or all accessible trash files in the current workspace without waiting 30 days. Active files and client vault files are excluded. Existing ownership/audience checks remain authoritative. Active references block deletion. Confirmation uses BrandHub modal, names the single file, and explicitly states that bulk affects all accessible trash regardless of filters/pages. Requests are irreversible once queued; storage cleanup, history removal, audit and quota release reuse the purge worker. No actual customer deletion is performed during development.

## Acceptance criteria
- POST individual purge returns updated material; POST trash/purge returns requested/skipped counts.
- Version conflict and permission checks apply; blocked/dependency failures never delete storage or release quota.
- Existing 30-day automatic retention remains unchanged.
- VI/EN keys under library.trash are parallel: purge, emptyTrash, purgeTitle, emptyTrashTitle, purgeDescription, emptyTrashDescription, purgeQueued, purgeUnavailable, referenced, bulkPurgeQueued.
- Light/dark: use existing semantic tokens and shared Dialog/Button components. Keyboard focus begins on Cancel; pending prevents duplicate requests and dismissal.

## Readiness correction
Explicit user deletion is independent of automatic 30-day purge feature flags. When automatic flags are false, the worker may claim only explicit requests bearing both request timestamp and actor. Permission, references, provider identity, verified quota inventory, lease, storage confirmation and audit checks remain mandatory. Unverified accounting must fail before deleting any storage object. Automatic expiry remains gated.

## Trash visibility and folders
Accepted permanent deletions are excluded from trash rows AND counts while storage cleanup runs. Folder permanent deletion requires a trashed root and all contained folders/files to be authorized and in trash; referenced files block the entire folder request. Queue file requests and remove folder tree atomically under the existing tree lock. No active folder or client vault is included. Folder deletion uses BrandHub confirmation modal with recursive warning and VI/EN keys folderPurgeTitle, folderPurgeDescription, folderPurgeBlocked, folderPurged.
