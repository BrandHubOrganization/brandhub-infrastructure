# Before testing

1. Pull/build the updated Business and Web together. Stop old Business writers before metadata APPLY. No PostgreSQL migration needed for this Task change.
2. In the VS Code MongoDB playground, open the entire `docs/database/migrations/2026-10-17-task-structure-simplification.js` file. Default is DRY_RUN against `brandhub` (even if the playground started in `test`). Execute the whole file, not only the flag assignment.
3. Confirm `blocked=false`, `invalidDocuments=0`. The legacy QC/date counts are inventory, not permission to delete or reinterpret old data. If prerequisites or validation fail, stop and review; do not run init-mongo.js on Atlas.
4. To apply metadata only, prepend this line and run the entire migration:

```javascript
globalThis.TASK_STRUCTURE_SIMPLIFICATION_APPLY = true;
```

5. Run the read-only checker `check-mongo-migrations.mongodb.js`; the new migration should report MATCH. It checks schema effects, not historical execution proof. Restart the new Business build and refresh Web.
6. Test description/deadline autosave, Creator assignment, explicit Start and lock after Start. QC and planned publication controls should be absent. Old QC review Tasks remain read-compatible, not silently advanced to Manager review.

## Atlas application — 2026-10-17

User explicitly authorized metadata APPLY. Preflight: 14 Tasks, 0 invalid, 5 historical QC assignments and 1 QC review; 0 approval/comment documents. Migration applied successfully; plannedPublishAt validator property removed. Before/after checksums of tasks, task_approvals and task_comments match. No Task/history documents changed; QC data/states retained. Fresh init already reflects this schema change. Each other environment still needs its own preflight.
