// Existing DB only. Playground: use('brandhub'); globalThis.TASK_FINISHED_AT_APPLY = false/true.
// Role-based dashboards (docs/feature/role-based-dashboards):
// 1) Backfill tasks.finishedAt for FINISHED tasks that lack it: lastSubmission.closedAt, else updatedAt.
// 2) Add the dashboard indexes on tasks and posts.
// Additive and idempotent: a second run finds nothing to backfill and createIndex is a no-op.
// Run BEFORE deploying the new web, or finished counts read 0 for old tasks.
(() => {
  const apply = globalThis.TASK_FINISHED_AT_APPLY === true;
  const missing = { status: 'FINISHED', finishedAt: { $exists: false } };
  const pending = db.tasks.countDocuments(missing);
  print(JSON.stringify({
    migration: 'task-finished-at-2026-11-23',
    database: db.getName(),
    mode: apply ? 'APPLY' : 'DRY_RUN',
    pending,
  }));
  if (!apply) return;

  const result = db.tasks.updateMany(missing, [
    { $set: { finishedAt: { $ifNull: ['$lastSubmission.closedAt', '$updatedAt'] } } },
  ]);
  db.tasks.createIndex({ workspaceId: 1, finishedAt: -1 }, { name: 'idx_tasks_workspace_finished_at' });
  db.tasks.createIndex({ workspaceId: 1, dueDate: 1 }, { name: 'idx_tasks_workspace_due_date' });
  db.posts.createIndex(
    { workspace_id: 1, status: 1, published_at: -1 },
    { name: 'idx_posts_ws_status_published' },
  );
  print(JSON.stringify({ backfilled: result.modifiedCount, indexes: 'ready' }));
})();
