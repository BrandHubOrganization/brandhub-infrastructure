# Plan
1. Add manual purge service: resolve existing access, reuse mutable material check, require trash state and verified accounting inventory, check references, atomically enqueue through audited/versioned store.
2. Extend store with REQUEST_PURGE precondition and worker claim with explicit manual request timestamp; preserve original deletion date. Bulk streams a snapshot cursor of authorized non-vault trash and reports skips.
3. Add canPurge capability and two controller endpoints.
4. Wire materialService/useMaterialTrash to individual/bulk mutations, refresh list/usage and show honest queued feedback. Add buttons and shared confirmation dialog to MediaTab/cards.
5. Update src/i18n/locales/vi/library.json and en/library.json. Verify backend focused tests/build, frontend CI, whitespace. Do not deploy feature unless authorized.

Readiness fix: replace the manual endpoint global flag dependency with read-only MaterialPurgeAccounting.requireVerified; always poll explicit requests while including expired trash/drafts only when both automatic flags are enabled. Preflight accounting before binary/history deletion. No environment flags are enabled and no customer deletions are executed as verification.

Visibility: only DELETED records are eligible for user-facing trash queries; worker status queries remain unchanged. Folder API POST folders/{id}/purge calls MaterialFolderService transaction, checks ownership/references/inventory, reuses a session-bound MaterialTrashStore mutation helper for audit/version/ancestor fencing, then removes trashed folder documents. Add frontend folder action and parallel translations.
