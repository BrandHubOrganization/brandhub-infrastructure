# Plan
1. Add optional attachmentIds to send/message/schedule contracts; absent means legacy empty. Resolve metadata through authenticated per-attachment endpoints, never broadcast filename/URLs to unauthorized recipients.
2. Add chat_attachments for owner/channel-bound draft uploads and captured repository references. Reuse encrypted SYSTEM_S3 IO without repository accounting. MIME/size verification, bounded abandoned draft cleanup and sender ownership checks.
3. Capture repository version under existing material mutation fence and Mongo transaction, with material_references pins. Prevent deletion of a captured historical version using the same root fence; ordinary purge already honors reference pins. Keep repository permissions authoritative.
4. Wire retry/idempotency and schedule hashing/delivery, including file-only bodies, attachment scope and retain/reconcile cleanup.
5. Reuse paginated repository browser in a picker beside composer; upload/paste/drop, progress/error/remove chips, locked attachment state and authenticated open/download. Update VI/EN.
6. Add additive playground-compatible DRY_RUN/APPLY metadata migration, fresh init and seeder; run isolated QA and build checks. Do not commit QA files or touch production.

QA correction: replace absolute picker positioning with shared Popover/Anchor/Content, retain menu-to-picker focus and cap the content by available viewport height. No changes to Repository endpoints or access policy.
