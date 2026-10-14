# Update an existing BrandHub MongoDB Atlas database

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
touched by the eight migrations against their cumulative effects. Fresh init
includes Chat and Post Versions as well as Tasks, approvals, Campaign deployment
and Content Request acceptance. This is an offline metadata check, not a live
MongoDB integration test or a validation of existing Atlas documents.

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
