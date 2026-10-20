// ISOLATED LOCAL CONTAINER ONLY. Never run this test on Atlas/shared data.
// Invoke with mongosh --eval "globalThis.BRANDHUB_ISOLATED_SCHEMA_TEST=true; load('/schema/migrations/tests/task-workflow-foundation.integration.js')"
// Mount docs/database at /schema read-only; use a NEW disposable mongo container with
// --network none, no host ports/user data volume, and exec env BRANDHUB_SCHEMA_TEST_CONTAINER=1.
(() => {
  // mongosh does not expose the legacy Mongo shell assert.eq/commandWorked helpers.
  const assert = (condition, message = 'Assertion failed') => { if (!condition) throw new Error(message); };
  assert.eq = (expected, actual, message) => assert(expected === actual, message ?? 'Values differ');
  assert.throws = operation => {
    let threw = false; try { operation(); } catch (_) { threw = true; }
    assert(threw, 'Expected operation to throw');
  };
  assert.commandWorked = result => assert(result.ok === 1, 'Mongo command failed');
  if (globalThis.BRANDHUB_ISOLATED_SCHEMA_TEST !== true
      || process.env.BRANDHUB_SCHEMA_TEST_CONTAINER !== '1'
      || !/^mongodb:\/\/127\.0\.0\.1:27017\//.test(db.getMongo().getURI()))
    throw new Error('Refusing schema write test outside explicitly confirmed local isolated connection.');
  const target = db.getSiblingDB('brandhub');
  if (target.getCollectionNames().length !== 0)
    throw new Error('Refusing schema integration test: brandhub must be empty. No existing data may be used.');
  const files = [
    '2026-09-26-create-generic-tasks-collection.js', '2026-09-27-create-task-approvals-collection.js',
    '2026-10-02-create-workspace-chat-collections.js', '2026-10-04-create-post-versions-collection.js',
    '2026-10-09-campaign-task-deployment.js', '2026-10-13-content-requests-v2.js',
    '2026-10-13-content-request-acceptance.js', '2026-10-14-campaign-closure.js',
    '2026-10-12-create-mail-templates-collection.js', '2026-10-13-create-mail-recipient-groups-collection.js',
  ];
  globalThis.CONTENT_REQUEST_MIGRATION_APPLY = true;
  globalThis.CONTENT_REQUEST_ACCEPTANCE_APPLY = true;
  globalThis.CAMPAIGN_CLOSURE_APPLY = true;
  files.forEach(file => load('/schema/migrations/' + file));
  const foundation = '/schema/migrations/2026-10-14-task-detail-comments-foundation.js';
  const now = new Date();
  const task = { _id: 'legacy-task', workspaceId: 'isolated-ws', type: 'POST', name: 'Schema test',
    dueDate: null, status: 'BACKLOG', requiresClientApproval: false, approvalRound: NumberInt(1),
    typeMetadata: {}, createdAt: now, updatedAt: now };
  target.tasks.insertOne(task);
  const metadata = () => JSON.stringify(target.getCollectionInfos().sort((a, b) => a.name.localeCompare(b.name)));
  const before = metadata();
  globalThis.TASK_WORKFLOW_FOUNDATION_APPLY = false;
  load(foundation);
  assert.eq(before, metadata(), 'DRY_RUN changed metadata');
  assert.eq(1, target.tasks.countDocuments({}));
  globalThis.TASK_WORKFLOW_FOUNDATION_APPLY = true;
  load(foundation);
  const applied = metadata(); load(foundation);
  assert.eq(applied, metadata(), 'APPLY was not repeatable');
  assert.eq(1, target.tasks.countDocuments({ workflowRevision: { $exists: false }, firstStartedAt: { $exists: false } }),
    'Legacy Task was backfilled');
  const taskSchema = target.getCollectionInfos({ name: 'tasks' })[0].options.validator.$jsonSchema;
  assert(!Object.hasOwn(taskSchema.properties, 'visibility'), 'Removed Task visibility was reintroduced');
  assert(!target.tasks.getIndexes().some(item => Object.hasOwn(item.key, 'visibility')), 'Removed visibility index was reintroduced');
  target.tasks.insertOne({ ...task, _id: 'old-writer-after-migration' });
  // Q13 keeps result approval independent of Task source. This is a schema test, not an ACL test.
  target.tasks.insertOne({ ...task, _id: 'manual-requires-client-approval', sourceType: 'MANUAL',
    requiresClientApproval: true });
  const reject = (operation, code) => {
    let caught;
    try { operation(); } catch (error) { caught = error; }
    assert(caught, 'Expected rejection code=' + code);
    assert.eq(code, caught.code);
  };
  for (const fields of [ { workflowRevision: NumberInt(-1) },
    { workflowRevision: 1.5 }, { plannedPublishAt: '2026-10-14' } ]) {
    reject(() => target.tasks.insertOne({ ...task, _id: 'invalid-task', ...fields }), 121);
  }
  target.tasks.insertOne({ ...task, _id: 'new-writer', workflowRevision: NumberLong('0'),
    firstStartedAt: null, firstStartedBy: null, plannedPublishAt: now,
    inputReferences: [{ label: 'Reference', url: 'https://example.org' }] });
  const comment = { _id: 'comment-1', workspaceId: 'isolated-ws', taskId: task._id, authorId: 'user-1',
    authorRole: 'MANAGER', authorDisplayName: 'Test', content: 'Test', mentions: [], attachmentIds: [],
    clientRequestId: 'request-1', createdAt: now };
  target.task_comments.insertOne(comment);
  reject(() => target.task_comments.insertOne({ ...comment, _id: 'duplicate-comment' }), 11000);
  reject(() => target.task_comments.insertOne({ ...comment, _id: 'invalid-comment', clientRequestId: 'request-2',
    attachmentIds: ['1', '2', '3', '4', '5', '6'] }), 121);
  const upload = { _id: 'upload-1', workspaceId: 'isolated-ws', taskId: task._id, uploadedBy: 'user-1',
    storageKey: 'private-test-key', contentType: 'image/webp', byteSize: NumberLong('5242880'),
    state: 'DRAFT', createdAt: now, expiresAt: now };
  target.task_comment_uploads.insertOne(upload);
  for (const fields of [{ contentType: 'application/pdf' }, { byteSize: NumberLong('5242881') }, { byteSize: NumberInt(0) }])
    reject(() => target.task_comment_uploads.insertOne({ ...upload, _id: 'invalid-upload', ...fields }), 121);
  assert(target.task_comment_uploads.getIndexes().every(item => item.expireAfterSeconds === undefined), 'Unsafe upload TTL');
  const outbox = { _id: 'delivery-1', eventKey: 'comment-1:user-2', workspaceId: 'isolated-ws', taskId: task._id,
    actorId: 'user-1', recipientId: 'user-2', eventType: 'TASK_COMMENTED',
    payload: { title: 'New comment', content: 'Open Task', actionUrl: '/workspaces/isolated-ws/tasks/legacy-task/detail' },
    status: 'PENDING', attempts: NumberInt(0), availableAt: now, createdAt: now, updatedAt: now };
  target.task_notification_outbox.insertOne(outbox);
  reject(() => target.task_notification_outbox.insertOne({ ...outbox, _id: 'duplicate-delivery' }), 11000);
  const driftedTask = { ...task, _id: 'legacy-invalid', workflowRevision: NumberInt(-1) };
  target.tasks.insertOne(driftedTask, { bypassDocumentValidation: true });
  const beforeBlocked = metadata();
  assert.throws(() => load(foundation));
  assert.eq(beforeBlocked, metadata(), 'Invalid legacy document caused partial DDL');
  target.tasks.deleteOne({ _id: 'legacy-invalid' }); // Only this test's own isolated fixture.
  const options = target.getCollectionInfos({ name: 'task_notification_outbox' })[0].options;
  const originalValidator = EJSON.parse(EJSON.stringify(options.validator));
  options.validator.$jsonSchema.properties.attempts = { bsonType: 'string' };
  assert.commandWorked(target.runCommand({ collMod: 'task_notification_outbox', validator: options.validator }));
  const beforeConflict = metadata();
  assert.throws(() => load(foundation));
  assert.eq(beforeConflict, metadata(), 'Late conflict caused partial DDL');
  assert.commandWorked(target.runCommand({ collMod: 'task_notification_outbox', validator: originalValidator }));
  const fiveStates = '/schema/migrations/2026-10-15-task-five-state-workflow.js';
  const beforeFive = metadata(); const documentsBeforeFive = EJSON.stringify(target.tasks.find({}).sort({ _id: 1 }).toArray());
  globalThis.TASK_FIVE_STATE_APPLY = false; load(fiveStates);
  assert.eq(beforeFive, metadata(), 'Five-state DRY_RUN changed metadata');
  globalThis.TASK_FIVE_STATE_APPLY = true; load(fiveStates);
  const appliedFive = metadata(); load(fiveStates);
  assert.eq(appliedFive, metadata(), 'Five-state APPLY is not repeatable');
  assert.eq(documentsBeforeFive, EJSON.stringify(target.tasks.find({}).sort({ _id: 1 }).toArray()), 'Five-state migration changed documents');
  for (const status of ['TODO', 'IN_REVIEW', 'FINISHED'])
    target.tasks.insertOne({ ...task, _id: 'canonical-' + status, status, reviewStep: status === 'IN_REVIEW' ? 'MANAGER' : null });
  reject(() => target.tasks.insertOne({ ...task, _id: 'invalid-review-step', status: 'IN_REVIEW', reviewStep: 'OWNER' }), 121);
  load('/schema/migrations/check-mongo-migrations.mongodb.js');
  const checker = globalThis.BRANDHUB_MONGO_MIGRATION_REPORT;
  assert.eq(12, checker.summary.MATCH, 'Real metadata does not match all migration effects');
  assert.eq(true, checker.schemaChecks.taskWorkflowFoundation, 'Foundation readiness missing');
  assert.eq(true, checker.schemaChecks.taskFiveState, 'Five-state readiness missing');
  print('PASS task workflow foundation: real Mongo schema, DRY_RUN/APPLY/repeat, legacy preservation, validation, idempotency, preflight conflicts.');
})();
