# Implementation

UI refinement: add request-scoped deadline helper and useRequestDeadline hook, reading existing campaignService.list/workspaceService.getById only while the form is mounted. Compute timezone-aware day boundaries, convert to browser-local min/max, refresh on focus/60-second tick. Pass workspaceId from WorkspaceRequestPage; WorkspaceRequestForm displays loading/error/empty/range and blocks invalid saves. Add parallel requests locale keys. No auth/global input or backend/schema changes.

Serialize creation, Client mutation and Manager receipt with the existing PostgreSQL agreement row lock used by Campaign completion. Validate Request deadlines using Campaign timeline and Workspace timezone on server.

Write a cancellation outbox entry in the same PostgreSQL transaction as Campaign completion. A scheduled worker consumes entries with FOR UPDATE SKIP LOCKED; Mongo updates only PENDING documents, atomically increasing version and appending CANCEL history with completion reason. Retry is idempotent and survives restarts. Never claim a distributed transaction across PostgreSQL and Mongo. Request edits/receipt are blocked immediately after completion even while the worker catches up. Existing completed Campaigns are not backfilled without approval.

Add SQL migration and matching fresh init table. Mongo document fields and validators unchanged. Do not run migrations on live DB in this task.

Partner input validator validates known contact fields while preserving unknown legacy JSON. UI adds matching validation and vi/en keys in collaborators locale files, reusing semantic error styles. Test unit rules and compile/type-check, and isolated DB where available.
