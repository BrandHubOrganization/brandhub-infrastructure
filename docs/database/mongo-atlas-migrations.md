# Update an existing BrandHub MongoDB Atlas database

## Workspace chat collaboration — 2026-10-22

Prepared migration: [2026-10-22-workspace-chat-collaboration.js](migrations/2026-10-22-workspace-chat-collaboration.js).
Default DRY_RUN prints the intended new collections and indexes. APPLY requires
`BRANDHUB_CHAT_COLLABORATION_APPLY=true` in the mongosh process environment after reviewing the target deployment.
It adds `chat_channels`, `chat_channel_reads`, channel/thread/pin indexes and channel-name uniqueness;
the existing sender/client-message unique index is retained. No message backfill/deletion or PostgreSQL migration.
Run the existing workspace-chat baseline first. This change has not been applied to Atlas by the coding agent.
Deploy the indexes before enabling the new frontend/backend and restart Business Service.

## FR 3.6.9 — Task Approval foundation (2026-10-18)

Current incremental migration: [2026-10-18-task-approval-foundation.js](migrations/2026-10-18-task-approval-foundation.js).
Read [setup/inventory/results](task-approval-setup.md) first. It adds optional latest-submission metadata,
one-Post-per-Task partial uniqueness, per-round/step decision uniqueness and review notification metadata.
No snapshots, document backfill/cleanup, PostgreSQL changes or Approval API implementation.
Fresh init and checker include this effect; do not run init or old foundation scripts against existing data.

Defaults to DRY_RUN. APPLY requires clean preflight, operator approval, all shared writers stopped and both
`TASK_APPROVAL_FOUNDATION_APPLY=true` / `TASK_APPROVAL_WRITERS_PAUSED=true` in the same run, reset in finally.
**Atlas APPLY completed on 2026-10-18 after the user approved resetting exactly five legacy review Tasks to TODO.**
Post-APPLY checker confirms Approval foundation and Task structure; the DDL step changed no documents.
See [operator report](task-approval-preflight-2026-10-18.md). Other deployments must run their own DRY_RUN;
the five-Task reset is not a general migration/backfill and must not be repeated automatically.
Application mutation rollout remains disabled pending integration; schema readiness does not enable editing/submission.

## DA-978 — Task five-state / inline workflow (2026-10-15)

Order: `2026-10-14-campaign-closure.js` →
`2026-10-14-task-detail-comments-foundation.js` →
`2026-10-15-task-five-state-workflow.js`.
All default to DRY_RUN. Inspect metadata/invalid-document/duplicate-index preflight and back up first.
Only set the matching global flag to true after review, then reset it in `finally`:
`CAMPAIGN_CLOSURE_APPLY`, `TASK_WORKFLOW_FOUNDATION_APPLY`, `TASK_FIVE_STATE_APPLY`.
Scripts explicitly target `brandhub`, not the default `test` database.

The new migration adds TODO / IN_REVIEW / FINISHED and optional `reviewStep`
(QC / MANAGER / CLIENT). Legacy enum values remain temporarily for read/writer
compatibility; the new workflow API/UI exposes five business states only.
No PostgreSQL change. `init-mongo.js` contains the final fresh schema; **do not run init on Atlas**.

Authorized APPLY completed 2026-10-15 after an all-three read-only staged preflight.
Metadata before/after saved locally under `.local-backups/task-ui-audit-20261015/`
(`atlas-metadata-2026-10-15T07-59-06-369Z-{before,after}.json`).
31 Task documents have identical count and SHA-256 before/after; no document
insert/update/delete/backfill was performed. Checker verifies all three effects MATCH
and `schemaChecks.taskFiveState=true`, `taskWorkflowFoundation=true`.
One legacy Content Request Task has no campaign link; reported only, not repaired.
Unrelated Chat/Mail/Post-version schema drift/missing effects were reported but not changed.

Missing revision/explicit first-start evidence on legacy Tasks is **not** repaired
by metadata migration. Those Tasks remain readable but management mutations stay
locked. Test edit/assign/start using a Task created by the new writers, or request a
separately reviewed reconciliation; never infer “never started” from a legacy status.
Restart Business Service with the updated code before testing API/UI readiness.

Separate operator-approved TEST DATA reconciliation was subsequently completed on
2026-10-15: user waived document backup, approved deletion of exactly six identified
empty drafts and confirmed the remaining 25 test Tasks had never started. Those 25
were explicitly initialized to TODO/revision=0/first-start markers=null in one Mongo
transaction, preserving content/deadlines/identity/source links. Post-check found 25
workflow-ready Tasks, the six deleted IDs absent, and all nine Campaign/two Request
Task links preserved. No PostgreSQL writes. This is **not** a general migration rule:
do not initialize unknown legacy start history in other datasets without review.
Cleanup scripts/allowlists and operational receipts remain local, not in the repo.


`init-mongo.js` is only for a **fresh local MongoDB volume**. Do not run it on
Atlas: it contains `createCollection` calls for the whole database. Apply the
incremental migration files below to the existing Atlas deployment instead.
These scripts select the database named `brandhub` with `db.getSiblingDB`.

## Before running

### Read-only migration check in VS Code Playground

Open [check-mongo-migrations.mongodb.js](migrations/check-mongo-migrations.mongodb.js),
select the intended Atlas connection and run the **whole file** using Run All.
It explicitly checks `brandhub`, even if the Playground initially selected `test`.
No `load()`, APPLY flag, init, document read/write or metadata write is performed.

The returned report contains `database`, `initialDatabase`, `summary`, `results`
and per-collection `problems`. `MATCH` means current schema effects match,
`MISSING` means collection absent, `DRIFT` means validator/index mismatch,
`UNKNOWN` means metadata could not be read (check permissions/connection).
There is no migration ledger: MATCH cannot prove when/how a migration ran and
does not validate existing documents, transactions, authorization or API behavior.
Later Task schema extensions are accepted when checking older migration effects.
The Campaign preflight script is listed as a read-only utility, not a migration.

Do not automatically rerun all migrations because the report has missing/drift
items: earlier scripts can replace newer validators. Review `problems`, back up,
and apply only the required fixes in dependency order. Request V2 precedes acceptance.

Offline checker regression tests (no Mongo connection):
`node docs/database/migrations/tests/check-mongo-migrations.test.cjs`.

The regression suite also executes `init-mongo.js` in an in-memory metadata
recorder and compares the exact validators and indexes of every collection
touched by the twelve migrations against their cumulative effects. Fresh init
includes Chat and Post Versions as well as Tasks, approvals, Campaign deployment
and Content Request acceptance, Mail Template/Recipient Groups and Task workflow foundation.
This is an offline metadata check, not a live
MongoDB integration test or a validation of existing Atlas documents.

In mongosh, `load()` returns true rather than the report: after loading the checker,
inspect `globalThis.BRANDHUB_MONGO_MIGRATION_REPORT`. VS Code Run All still displays the returned report.

### Task workflow foundation — DA-978 / DA-1236 (2026-10-14)

Schema only; API/UI are not implemented by applying this migration. Read
[phase-1 inventory/setup](../feature/content-task-workflow/task-workflow-phase-1.md) first.
Run `task-workflow-inventory.mongodb.js` read-only to inventory legacy source/revision/start
evidence. Missing firstStartedAt is unknown history, not proof of never-started work.
Current BA (Q13): active Clients may read/comment every Task in their Workspace, including manual
and legacy Tasks. No internal/public Task classification is added. Missing legacy start/revision
only gates management mutations, not read/comment access. requiresClientApproval configures approvals only.

Dependency order: Task V2 → Campaign deployment → Request acceptance → Campaign closure →
`2026-10-14-task-detail-comments-foundation.js`. The new migration defaults to DRY_RUN,
always selects brandhub and does NOT backfill/delete any documents. It adds optional Task fields
and private task_comments/task_comment_uploads/task_notification_outbox collections/indexes.
Back up/freeze writers, review conflicts/invalidDocuments/duplicateGroups before setting
`globalThis.TASK_WORKFLOW_FOUNDATION_APPLY = true` in the same full-script run. Reset the flag afterward.
No TTL for private uploads: cleanup must delete the object before its metadata.
DDL is not atomic across collections; keep feature disabled on partial operational failure.
Rerun checker and verify taskWorkflowFoundation readiness; never rerun init or old Task validators
against existing data. No PostgreSQL migration is introduced for this foundation.

### Campaign closure / Task cancellation (2026-10-14)

After Task V2, Campaign deployment and Request acceptance, run
`2026-10-14-campaign-closure.js` in full. It explicitly selects `brandhub` and
defaults to read-only preflight. Review `unlinkedRequestTasks`: legacy source
Tasks are NOT automatically backfilled, and will block their Campaign closure
until explicitly reconciled. Back up/freeze writers before setting
`globalThis.CAMPAIGN_CLOSURE_APPLY = true` in the same Playground run as the full
script. APPLY only extends the existing Task validator with CANCELLED and
optional cancellation audit; it preserves documents, indexes and approvals.
Never rerun older Task validators afterward (they can remove this extension).
See ../feature/media-package-campaign/campaign-closure/test.md for test/setup.

### Applying migrations

1. In Atlas, confirm the connected cluster is the intended BrandHub deployment.
   Open **Browse Collections** and confirm the database name `brandhub`.
2. Arrange a recoverable backup/snapshot appropriate to the environment. The
   migration is additive but changes the `tasks` validator and creates indexes.
3. Click **Connect → Shell** in Atlas. Ensure your IP is allowed and the database
   user has permissions to create collections/indexes and modify validators.
   If `mongosh` is not installed, follow the Atlas Connect dialog to install it
   ([MongoDB instructions](https://www.mongodb.com/docs/atlas/mongo-shell-connection/)).
   Connect with `mongosh`; let the shell prompt for the password rather than
   putting a password in commands or sharing it in chat.
4. Use the `load()` calls below **inside the connected mongosh session**. On
   Windows, forward slashes in the local path avoid escaping backslashes.

## DA-E51-01, DA-E51-02, DA-948 order

First run the read-only preflight:

```javascript
load('D:/FPT/FA26/SEP490/brandhub-infrastructure/docs/database/migrations/2026-10-09-campaign-task-preflight.js')
```

Check `database` is `brandhub`. If `tasks` already contains documents, review
their compatibility before tightening validation. If
`duplicateCampaignWorkItemKeys` is nonempty, resolve those duplicate records
before DA-948; its unique index will not build otherwise.

Run each file in order, stopping if one throws an error:

```javascript
load('D:/FPT/FA26/SEP490/brandhub-infrastructure/docs/database/migrations/2026-09-26-create-generic-tasks-collection.js')
load('D:/FPT/FA26/SEP490/brandhub-infrastructure/docs/database/migrations/2026-09-27-create-task-approvals-collection.js')
load('D:/FPT/FA26/SEP490/brandhub-infrastructure/docs/database/migrations/2026-10-09-campaign-task-deployment.js')
```

These migrations do **not** insert, rewrite or delete existing documents. They
create/update `tasks`, `task_approvals`, `event_plans`, and
`press_recommendations`; DA-948 creates the partial unique index
`uq_tasks_campaign_work_item`. They do not initialize a new Atlas cluster.

Run preflight again. It should show `tasksCollectionExists: true`, an empty
`duplicateCampaignWorkItemKeys`, and `uq_tasks_campaign_work_item` in
`indexNames`. For a direct index check:

```javascript
db.getSiblingDB('brandhub').tasks.getIndexes().filter(i => i.name === 'uq_tasks_campaign_work_item')
```

Afterwards retry the failed Campaign deployment from the UI. The existing
PostgreSQL deployment record is retryable; the retry should generate one Mongo
Task per Campaign work item without overwriting any already-created Task.

Do not paste Atlas connection strings, passwords or tokens into a ticket/chat.

## DA-951 — Content Requests V2 (2026-10-13)

Phase 2 adds create/list/detail/edit/soft-cancel only; no Task is generated.
Do not rerun `init-mongo.js` on Atlas. Back up the collection and pause all
Content Request writers for the entire cutover. The script preserves legacy
fields/indexes and audit; it does not guess ambiguous statuses or missing dates.
The operator needs `collMod`, index creation and permission to bypass the old
validator while converting existing documents. Writes are not one transaction:
keep the API disabled until the script and verification complete.

Select and verify the intended database in connected mongosh:

```javascript
use brandhub
db.getName()
globalThis.CONTENT_REQUEST_MIGRATION_APPLY = false
load('D:/FPT/FA26/SEP490/brandhub-infrastructure/docs/database/migrations/2026-10-13-content-requests-v2.js')
```

Default mode is read-only. If `blocked` is nonzero, stop and review the mapping
with the team; do not delete records or invent default fields to bypass it.
After reviewing `database`, counts and backup, explicitly apply:

```javascript
globalThis.CONTENT_REQUEST_MIGRATION_APPLY = true
try {
  load('D:/FPT/FA26/SEP490/brandhub-infrastructure/docs/database/migrations/2026-10-13-content-requests-v2.js')
} finally {
  globalThis.CONTENT_REQUEST_MIGRATION_APPLY = false
}
db.getCollectionInfos({name: 'content_requests'})[0].options
db.content_requests.getIndexes()
db.content_requests.countDocuments({})
```

Verify strict/error validation, five V2 statuses, required camelCase fields,
unchanged document count and the three `idx_content_requests_v2_*` indexes.
`idx_content_requests_v2_workspace_created` is the API readiness marker.
Rerun dry-run; only then resume writers/restart the Business Service. Before
migration the new API intentionally returns `503 REQUEST_SCHEMA_NOT_READY`.
Existing rollback binaries are not compatible with new requests; do not roll
back writers against V2 data without a reviewed compatibility plan/backup.

Read-only inventory on 2026-10-13 found **0 documents** and the three legacy
indexes. No migration write was performed during implementation. Offline tests:
`node docs/database/migrations/tests/content-requests-v2.test.cjs`.

## DA-951 phase 3 — acceptance transaction/source uniqueness


After the existing generic Task/Campaign deployment migrations and Request V2,
review and run the NEW `2026-10-13-content-request-acceptance.js`. Do not rerun the
phase-2 script after phase 3, because it installs the earlier validator revision.
No PostgreSQL change is needed. No Task or Request document is inserted/updated/deleted
by this migration: it extends optional decision validation and creates one unique
partial index for `sourceType=CONTENT_REQUEST, sourceRefId` only. Other Task sources
retain their existing rules/indexes. Duplicate/missing legacy source references or
invalid decision metadata abort before metadata/index writes; do not auto-delete them.

Backup and pause writers; confirm the selected database before running:

```javascript
use brandhub
globalThis.CONTENT_REQUEST_ACCEPTANCE_APPLY = false
load('D:/FPT/FA26/SEP490/brandhub-infrastructure/docs/database/migrations/2026-10-13-content-request-acceptance.js')
```

If preflight is clean and reviewed, apply explicitly:

```javascript
globalThis.CONTENT_REQUEST_ACCEPTANCE_APPLY = true
try {
  load('D:/FPT/FA26/SEP490/brandhub-infrastructure/docs/database/migrations/2026-10-13-content-request-acceptance.js')
} finally {
  globalThis.CONTENT_REQUEST_ACCEPTANCE_APPLY = false
}
db.tasks.getIndexes().filter(index => index.name === 'uq_tasks_content_request_source')
db.getCollectionInfos({name: 'content_requests'})[0].options.validator
```

Verify `unique:true`, keys `{sourceType:1,sourceRefId:1}`, partial filter
`{sourceType:'CONTENT_REQUEST',sourceRefId:{$type:'string'}}`, and optional
`decisionNote` (string/null, max2000), `decidedBy`, `decidedAt`. Acceptance returns
`TASK_SCHEMA_NOT_READY` until this index exists. Receive/deny do not generate Tasks.
Read-only Atlas `hello` verified replica set + sessions on 2026-10-13; application
also checks transaction prerequisites before acceptance. Never fallback to separate
Task/Request writes on standalone Mongo. Shared Atlas migration was NOT applied
during implementation; transaction write tests use an isolated local replica set.

## Chat mention inbox foundation — 2026-10-23

Prerequisite: current chat baseline and `2026-10-22-workspace-chat-collaboration.js`.
Review `2026-10-23-chat-mention-inbox.js` with all shared writers paused before APPLY.
Default execution is read-only; target DB is explicitly `brandhub`.
For mongosh, set `process.env.BRANDHUB_CHAT_MENTION_APPLY = 'false'` then load the script.
Only after reviewing clean output, set that variable to `'true'`, load again, and
reset it to `'false'` in finally. No APPLY was performed on Atlas during development.

This adds one preferences collection and the pending-message delivery index. It
does not backfill historical notifications or change PostgreSQL tables. Existing
`user_notifications` is reused. The worker is inert until the delivery index exists.
Do not rerun a fresh-init script on an existing database. Preferences errors return
`CHAT_NOTIFICATION_SCHEMA_NOT_READY` until their collection has been installed.
The migration preflights invalid preferences, duplicate identities and conflicting
index definitions. Mongo metadata operations are not transactional: if deployment
is interrupted, inspect the resulting metadata and rerun the idempotent script.

### VS Code MongoDB Playground

Playground does not provide Node's `process.env`. Both chat migrations also accept
boolean global flags: `globalThis.BRANDHUB_CHAT_COLLABORATION_APPLY` (22 October)
and `globalThis.BRANDHUB_CHAT_MENTION_APPLY` (23 October). Omitted/false flags keep
DRY_RUN. Set the appropriate flag immediately before the complete script and run
them together in the same Playground execution; setting it in an earlier run is
not sufficient. First use false and review output, then true only for APPLY.
Do not use mongosh `load()` or `process.env` commands in Playground. Choose the
intended connection; scripts explicitly target `brandhub`. Remove/reset flags
after use. No shared deployment was changed when adding Playground support.

### Chat rich composer (24 October 2026)

`2026-10-24-chat-rich-content.js` adds explicit optional `richContent` object typing
to the existing chat_messages validator, preserving its other rules and indexes.
No message backfill, reset, new collection or PostgreSQL change. Seed samples now
include one formatted reply; existing rows are not overwritten by the seeder.
Use `globalThis.BRANDHUB_CHAT_RICH_APPLY = false;` before the complete script for
DRY_RUN; use true only after clean preflight. Restart Business before sending rich
messages, because an older server does not persist the new optional field.
If the existing collection has no validator, this migration installs only optional
richContent typing. It deliberately does not impose fresh-init required fields on
legacy messages. Unsupported non-empty validator structures still require review.
