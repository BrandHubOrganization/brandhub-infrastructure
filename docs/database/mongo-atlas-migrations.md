# Update an existing BrandHub MongoDB Atlas database

`init-mongo.js` is only for a **fresh local MongoDB volume**. Do not run it on
Atlas: it contains `createCollection` calls for the whole database. Apply the
incremental migration files below to the existing Atlas deployment instead.
These scripts select the database named `brandhub` with `db.getSiblingDB`.

## Before running

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
