# Remove hashtag test contract

Public seams: authenticated DELETE API and the visible workspace collection UI.

- Create and remove an owned hashtag; expect HTTP 200, deletedBy/deletedAt persistence,
  and no result in the active list.
- Repeat removal; expect `HASHTAG_ALREADY_REMOVED` without another side effect.
- Send a stale `expectedVersion`; expect `HASHTAG_CHANGED` and no removal.
- On `HASHTAG_CHANGED`, reload the entry and require review of the changed details before retrying removal.
- Check Creator/Client ownership and Manager workspace-wide permission; reject other roles
  and cross-workspace identifiers.
- Remove a required entry; UI warning identifies Client-required status, campaign scope,
  and preservation of hashtags already used in posts.
- Validate the migration and partial unique index with PostgreSQL when available.

Current verification: backend compile and web production build passed. The targeted API
test and Playwright run stalled during local Java attach/browser startup without producing
a test report. Live PostgreSQL migration verification is also pending.
