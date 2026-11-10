# Plan
1. Safe empty-inventory initializer used before usage/reserve; add explicit writes property and diagnostic errors.
2. Add configurable Drive sync flag + scope. Store granted scope; require correct grant for polling. Scheduled scanner + idempotent import store use existing folder/file mapping, PG committed reservations/ledger and Mongo metadata.
3. Traverse mapped subfolders with bounded per-run pages; stable identity and provider routing. Skip BrandHub-generated files and files already mapped. Protect imported media content validation and isolate accounts.
4. Update vi/en library.json and upload error mapping. Regression tests use PG/Mongo and mocked Google APIs; no real consent or external file uploads.

Migration: 2026-10-27-customer-drive-sync.sql adds granted_scope; 2026-10-27-repository-upload-indexes.py adds only repository indexes after duplicate/definition preflight, without replacing validators. Inventory initialization occurs only after Mongo/PG prove an agency has no repository history. A per-file lease serializes import publication with disconnect while letting normal uploads run between files.
Locale files: vi/en library.json (repositoryUpload.driveNotConnected), vi/en workspace.json (agencyStorage.syncHint, syncReconnectRequired). The existing repository query polls every 60 seconds.
