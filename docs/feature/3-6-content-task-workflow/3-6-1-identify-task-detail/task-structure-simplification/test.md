# Test cases

1. New Task has no QC/plannedPublishAt property; keeps dueDate, revision, start evidence.
2. Removed plannedPublishAt PATCH returns validation error, not successful ignored update.
3. Old assignment sending non-null qcAssigneeId fails validation; null/omitted remains compatible.
4. Manager assignment requires description, valid dueDate and active Creator; stale revision fails; after start cannot edit/reassign.
5. Task response/form omit obsolete fields; Creator start and Client read remain functional.
6. Schema readiness no longer requires plannedPublishAt; metadata migration preserves unrelated validators/indexes and old documents; missing foundation/incompatible data blocks APPLY; second run safe.
7. Old QC_REVIEW/approval history remains readable and unchanged. No snapshot/publishing changes.
8. Scoped lint; Web type-check; light/dark, responsive and keyboard manual verification remain explicitly reported if not run.

## Results 2026-10-17

- 80 focused Task tests passed, including 6 opt-in isolated Mongo integration tests and 3 structure-contract tests; 1 Atlas inventory test skipped intentionally. Initial incremental build contained invalid IDE-produced classes; clean Maven rebuild resolved this.
- Fresh init, migration DRY_RUN/no mutation, APPLY/idempotency, unchanged legacy QC/publication fields and read-only checker MATCH verified on disposable Mongo 7 replica set. Shared Atlas not accessed/applied.
- Scoped ESLint and formatting passed; migration/init/checker JavaScript syntax checks passed.
- Whole-Web TypeScript still reports pre-existing errors in content-writing/useTaskContentSync, editor/MediaDropzone, workspace/dashboard, AppRoutes. These modules were not changed.
- Browser/light-dark/responsive manual checks not performed; no live UI-flow or specialist content/approval claims.
