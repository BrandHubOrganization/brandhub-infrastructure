# Plan
1. Add staged PostgreSQL connection/folder/object mapping and quota separation migration, capability/config gates disabled by default.
2. Implement account-bound encrypted OAuth, minimal Drive REST adapter, folder provisioning and private media gateway. Reuse existing material validation/publication, ACL and retention boundaries.
3. Introduce Drive-first reservation routing with S3-only paid quota; preserve legacy providers and historical reads. Fresh Drive capacity lookup occurs outside database locks; reserve capacity atomically.
4. Add repository storage controls and callback handling using existing API/query/auth components; update src/i18n/locales/{vi,en}/library.json together.
5. Verify policy, capacity concurrency, OAuth replay/account binding, private reads, roles and frontend. Review and commit current branches.

## Operational contract and rollout
- This feature supersedes the old first-20-GiB SYSTEM_GDRIVE routing only when REPOSITORY_CUSTOMER_DRIVE_ENABLED=true. With the flag off, existing behavior remains available. Existing material providers are never rewritten.
- Scope: one agency storage grant, managed by its Owner or an operational workspace Manager. The grant serves the agency workspaces. Google accounts may connect to multiple agencies; physical capacity revisions/holds serialize by immutable account_id across those agencies.
- Drive capacity includes a conservative 2x upload peak for staging plus immutable canonical promotion. Missing/unknown quota is unavailable, never evidence for paid overflow.
- Only explicit Google storageQuotaExceeded records a short-lived full observation; generic403, timeout and revoked grants do not. Browser retries a capacity failure once with a fresh idempotency key; all S3 entitlement/quota checks run again.
- isQuotaExceeded is not a global upload lock in CUSTOMER_DRIVE_FIRST mode. Usage fields report purchased S3 bytes only; Drive bytes do not consume the plan. S3 enforcement happens atomically when an overflow reservation is requested.
- Interrupted remote copy is discovered by stable appProperties brandhub_key, including from HEAD/recovery, before claiming absence. Confirmed404 permits idempotent deletion. Durable leases fence metadata/folder/object finalization without remote I/O inside SQL row locks.
- Disconnect advances a durable agency generation and fences grants/OAuth/quota commits under the agency operation lease. A durable disconnecting flag retains credentials on failure; cleanup deletes tracked files/folders and metadata, releases quota once and removes the connection. A pending callback cannot reconnect after it. Apply 2026-10-27-customer-drive-disconnect.sql before deploying. Native Drive permissions are never made public or granted directly to Clients.

Before activation:
1. Deploy Business, Gateway and Web together while the flag remains false. Review/apply 2026-10-26-customer-drive-overflow.sql after repository foundation and Trash SQL. No production migration was run by this task.
2. Reconcile historical SYSTEM_S3 material sizes, reservation committed_bytes and purge release receipts. Existing aggregate inventory alone is insufficient to prove S3-only accounting. Correct any unattributed historical S3 objects before activation; do not lower counters to make quota pass.
3. Configure a Google OAuth web client with Drive API enabled, drive.file scope, offline consent and the exact frontend callback https://<app>/storage/drive/callback. Complete the Google consent/test-user setup for intended accounts.
4. Set REPOSITORY_CUSTOMER_DRIVE_CLIENT_ID, CLIENT_SECRET, REDIRECT_URI, ENCRYPTION_KEY and PUBLIC_BASE_URL (each prefixed REPOSITORY_CUSTOMER_DRIVE_). ENCRYPTION_KEY is a persistent base64-encoded 32-byte secret in the secret manager. Do not regenerate it on restart; plan explicit reauthorization for key rotation. PUBLIC_BASE_URL points at the Gateway, not Google.
5. Keep existing Repository write/reference-inventory gates and verified private SYSTEM_S3 configuration. Enable REPOSITORY_CUSTOMER_DRIVE_ENABLED only after schema and inventory checks. Owner/Manager then connects through the UI and consents with their own Google account.
6. Verify private image/PDF/video range streaming and a real low-capacity overflow against an active paid plan. The capability route retains per-peer-IP rate limiting and fails closed on Redis failure; configure trusted reverse-proxy addressing so it is not accidentally one bucket for every user. Gateway logs redact capability query values.

No live OAuth connection, remote agency folder creation, production migration, provider activation or existing-object migration has been performed in this task.

## Workspace folder naming
Resolve workspaces.name for folder display names. Keep appProperties workspace UUID, folder ID, ordinal and existing mapping identity. Rename mapped/recovered workspace folders in place only when names differ. No schema change.
