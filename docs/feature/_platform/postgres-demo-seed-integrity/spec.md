# PostgreSQL demo seed integrity

## Objective
Repair the four reviewed defects in the explicit PostgreSQL demo dataset without changing existing databases.

## Acceptance criteria
- Only approved package agreements produce campaigns. Agreements contain valid package terms; campaigns retain the agreed snapshot, version, deliverables and allocations, initially in DRAFT.
- A database failure during flush or commit rolls back demo rows and leaves a durable failed seed marker. Successful data and the complete marker commit together; completed runs skip.
- The reserved quick-login Client has a CLIENT membership in each of the first two demo workspaces, independently of legacy user numbers and input ordering.
- Seeded ACTIVE subscriptions have an end date in the future; elapsed periods use EXPIRED.

## Scope
Seed entrypoints and their persisted outputs are the regression boundaries identified in the review and accepted by the request to resolve all four defects. No schema migration, deletion, automatic repair of existing datasets, API or UI changes. Keep dataset version 2: marked completed databases remain untouched.

## Definition of done
Regression checks cover these behaviors, including a real PostgreSQL deferred commit failure in an isolated database. Existing seed tests pass; document any unrelated suite failures.
