const { test } = require('node:test');
const assert = require('node:assert/strict');
const { readFileSync } = require('node:fs');
const { join } = require('node:path');
const vm = require('node:vm');
const source = readFileSync(join(__dirname, '../check-mongo-migrations.mongodb.js'), 'utf8');
const files = [
  '2026-09-26-create-generic-tasks-collection.js',
  '2026-09-27-create-task-approvals-collection.js',
  '2026-10-02-create-workspace-chat-collections.js',
  '2026-10-04-create-post-versions-collection.js',
  '2026-10-09-campaign-task-deployment.js',
  '2026-10-13-content-requests-v2.js',
  '2026-10-13-content-request-acceptance.js',
  '2026-10-14-campaign-closure.js',
  '2026-10-12-create-mail-templates-collection.js',
  '2026-10-13-create-mail-recipient-groups-collection.js',
  '2026-10-14-task-detail-comments-foundation.js',
  '2026-10-15-task-five-state-workflow.js',
];
const clone = value => JSON.parse(JSON.stringify(value));

// Execute the REAL migration sources against an in-memory metadata recorder.
// No Mongo/network dependency; writes below exist only in RAM to construct fixtures.
function fixture() {
  const metadata = new Map();
  let readOnly = false;
  const calls = [];
  const invalidCounts = new Map();
  const duplicateCounts = new Map();
  function write(name) {
    calls.push(name);
    if (readOnly) throw new Error('Checker attempted a write: ' + name);
  }
  const collection = name => ({
    getIndexes: () => { calls.push('getIndexes'); return clone(metadata.get(name).indexes); },
    createIndex: (key, options) => {
      write('createIndex');
      const indexes = metadata.get(name).indexes;
      const previous = indexes.findIndex(index => index.name === options.name);
      const index = clone({ key, ...options });
      if (previous < 0) indexes.push(index); else indexes[previous] = index;
    },
    aggregate: () => { if (readOnly) throw new Error('Checker read documents');
      return { toArray: () => duplicateCounts.has(name) ? [{ groups: duplicateCounts.get(name) }] : [] }; },
    find: () => { if (readOnly) throw new Error('Checker read documents'); return { forEach: () => {} }; },
    countDocuments: () => { if (readOnly) throw new Error('Checker counted documents'); return invalidCounts.get(name) || 0; },
  });
  const target = new Proxy({
    getName: () => 'brandhub',
    getSiblingDB: name => { assert.equal(name, 'brandhub'); return target; },
    getCollection: collection,
    getCollectionNames: () => [...metadata.keys()],
    getCollectionInfos: ({ name }) => metadata.has(name)
      ? [{ name, options: clone(metadata.get(name).options) }] : [],
    createCollection: (name, options = {}) => {
      write('createCollection'); metadata.set(name, { options: clone(options), indexes: [{ name: '_id_', key: { _id: 1 } }] });
    },
    runCommand: command => {
      write('runCommand');
      assert.ok(command.collMod, 'Fixture supports collMod only');
      const { collMod, ...options } = command;
      Object.assign(metadata.get(collMod).options, clone(options)); return { ok: 1 };
    },
  }, { get: (object, key) => key in object ? object[key] : collection(key) });
  function apply(file, flags = {}) {
    return vm.runInNewContext(readFileSync(join(__dirname, '..', file), 'utf8'), {
      db: target, print: () => {}, CONTENT_REQUEST_MIGRATION_APPLY: true, CONTENT_REQUEST_ACCEPTANCE_APPLY: true,
      CAMPAIGN_CLOSURE_APPLY: true, TASK_WORKFLOW_FOUNDATION_APPLY: true, TASK_FIVE_STATE_APPLY: true,
      ...flags,
    });
  }
  function check(initial = 'test', denied = false) {
    readOnly = true; calls.length = 0;
    const before = JSON.stringify([...metadata]);
    const readonlyTarget = denied ? {
      getName: () => 'brandhub', getCollectionInfos: () => { throw Object.assign(new Error('private credential'), { code: 13 }); },
    } : target;
    const report = vm.runInNewContext(source, { db: {
      getName: () => initial,
      getSiblingDB: name => { assert.equal(name, 'brandhub'); return readonlyTarget; },
    } });
    assert.equal(JSON.stringify([...metadata]), before, 'Checker changed metadata');
    assert.ok(!calls.some(name => ['createCollection', 'runCommand', 'createIndex'].includes(name)));
    return clone(report);
  }
  return { metadata, apply, check, calls, invalidCounts, duplicateCounts };
}
const complete = () => { const f = fixture(); files.forEach(f.apply); return f; };
const result = (report, file) => report.results.find(entry => entry.migration === file);

test('all real migration effects MATCH, including superseded Task schemas; checker is read-only', () => {
  const report = complete().check();
  assert.deepEqual(report.summary, { MATCH: 12, MISSING: 0, DRIFT: 0, UNKNOWN: 0 });
  assert.equal(report.database, 'brandhub'); assert.equal(report.initialDatabase, 'test');
  assert.equal(report.mode, 'READ_ONLY');
  assert.deepEqual(report.schemaChecks, { taskFiveState: true, taskWorkflowFoundation: true, contentRequestV2: true, contentRequestAcceptance: true, campaignDeployment: true });
});
test('empty database reports missing collections, never creates them', () => {
  assert.equal(fixture().check().summary.MISSING, 12);
});

test('fresh Mongo init matches all twelve migration effects and their exact validators/indexes', () => {
  const initialized = fixture(); initialized.apply('../init-mongo.js');
  assert.deepEqual(initialized.check().summary, { MATCH: 12, MISSING: 0, DRIFT: 0, UNKNOWN: 0 });
  const migrated = complete();
  for (const [name, expected] of migrated.metadata) {
    const actual = initialized.metadata.get(name);
    assert.ok(actual, name);
    assert.deepEqual(actual.options.validator, expected.options.validator, name + ' validator');
    assert.equal(actual.options.validationAction || 'error', expected.options.validationAction || 'error', name);
    assert.equal(actual.options.validationLevel || 'strict', expected.options.validationLevel || 'strict', name);
    assert.deepEqual(actual.indexes, expected.indexes, name + ' indexes');
  }
  assert.equal(initialized.metadata.size, 24);
});
test('missing readiness index is caught even with a valid Request validator', () => {
  const f = complete();
  f.metadata.get('content_requests').indexes = f.metadata.get('content_requests').indexes
    .filter(index => index.name !== 'idx_content_requests_v2_workspace_created');
  assert.equal(f.check().schemaChecks.contentRequestV2, false);
});

test('closure dry run does not change schema; APPLY preserves earlier fields/indexes and is repeatable', () => {
  const f = complete();
  const task = f.metadata.get('tasks');
  task.options.validator.$jsonSchema.properties.status.enum = task.options.validator.$jsonSchema.properties.status.enum
    .filter(value => value !== 'CANCELLED');
  delete task.options.validator.$jsonSchema.properties.cancellation;
  const before = JSON.stringify([...f.metadata]);
  f.apply(files[7], { CAMPAIGN_CLOSURE_APPLY: false });
  assert.equal(JSON.stringify([...f.metadata]), before);
  const indexes = clone(task.indexes);
  f.apply(files[7]); f.apply(files[7]);
  assert.deepEqual(task.indexes, indexes);
  assert.equal(f.check().summary.MATCH, 12);
});
test('same index name but incorrect compound key order is DRIFT', () => {
  const f = complete();
  const index = f.metadata.get('tasks').indexes.find(index => index.name === 'uq_tasks_campaign_work_item');
  index.key = { campaignWorkItemId: 1, campaignId: 1 };
  assert.equal(result(f.check(), files[4]).status, 'DRIFT');
});
test('unique and partial filter are verified, not just index names', () => {
  const f = complete();
  const index = f.metadata.get('tasks').indexes.find(index => index.name === 'uq_tasks_content_request_source');
  index.unique = false; index.partialFilterExpression = { sourceType: 'CAMPAIGN' };
  assert.equal(f.check().schemaChecks.contentRequestAcceptance, false);
});
test('partial filter object key ordering does not create false drift', () => {
  const f = complete();
  const index = f.metadata.get('tasks').indexes.find(index => index.name === 'uq_tasks_campaign_work_item');
  index.partialFilterExpression = { campaignWorkItemId: { $type: 'string' }, campaignId: { $type: 'string' } };
  assert.equal(result(f.check(), files[4]).status, 'MATCH');
});
test('rerunning old Task migration is detected as Campaign schema regression', () => {
  const f = complete(); f.apply(files[1]);
  assert.equal(result(f.check(), files[4]).status, 'DRIFT');
});
test('phase 2 after acceptance loses decision validator and is detected', () => {
  const f = complete(); f.apply(files[5]);
  const report = f.check();
  assert.equal(report.schemaChecks.contentRequestV2, true);
  assert.equal(report.schemaChecks.contentRequestAcceptance, false);
});
test('warn or moderate validator policies are DRIFT', () => {
  const f = complete(); f.metadata.get('content_requests').options.validationAction = 'warn';
  f.metadata.get('content_requests').options.validationLevel = 'moderate';
  assert.equal(f.check().schemaChecks.contentRequestV2, false);
});
test('permission errors are UNKNOWN, not a false missing migration; no secret details', () => {
  const report = fixture().check('test', true);
  assert.equal(report.summary.UNKNOWN, 12);
  assert.ok(!JSON.stringify(report).includes('private credential'));
});

test('foundation dry run preserves metadata, APPLY is repeatable and does not require new fields on legacy Tasks', () => {
  const f = fixture(); files.slice(0, 10).forEach(f.apply);
  const before = JSON.stringify([...f.metadata]);
  f.apply(files[10], { TASK_WORKFLOW_FOUNDATION_APPLY: false });
  assert.equal(JSON.stringify([...f.metadata]), before);
  const required = clone(f.metadata.get('tasks').options.validator.$jsonSchema.required);
  f.apply(files[10]);
  const applied = JSON.stringify([...f.metadata]);
  f.apply(files[10]);
  assert.equal(JSON.stringify([...f.metadata]), applied);
  assert.deepEqual(f.metadata.get('tasks').options.validator.$jsonSchema.required, required);
});

test('foundation preserves unrelated validator fields, root clauses and indexes', () => {
  const f = fixture(); files.slice(0, 10).forEach(f.apply);
  const task = f.metadata.get('tasks');
  task.options.validator.$jsonSchema.properties.otherTeamField = { bsonType: 'string' };
  task.options.validator.$and = [{ otherTeamField: { $exists: true } }];
  task.indexes.push({ name: 'other_team_index', key: { otherTeamField: 1 } });
  f.apply(files[10]);
  assert.deepEqual(task.options.validator.$jsonSchema.properties.otherTeamField, { bsonType: 'string' });
  assert.deepEqual(task.options.validator.$and, [{ otherTeamField: { $exists: true } }]);
  assert.ok(task.indexes.some(index => index.name === 'other_team_index'));
});

test('foundation aborts BEFORE any DDL if a later collection has an incompatible field or index', () => {
  for (const conflict of ['field', 'index']) {
    const f = complete();
    const outbox = f.metadata.get('task_notification_outbox');
    if (conflict === 'field') outbox.options.validator.$jsonSchema.properties.attempts = { bsonType: 'string' };
    else outbox.indexes.find(item => item.name === 'uq_task_notification_outbox_event').unique = false;
    const before = JSON.stringify([...f.metadata]); f.calls.length = 0;
    assert.throws(() => f.apply(files[10]), /incompatible field|index conflict/);
    assert.equal(JSON.stringify([...f.metadata]), before);
    assert.ok(!f.calls.some(name => ['runCommand', 'createCollection', 'createIndex'].includes(name)));
  }
});

test('foundation refuses missing closure and wrong prior source index shape', () => {
  const f = fixture(); files.slice(0, 7).forEach(f.apply);
  assert.throws(() => f.apply(files[10]), /closure foundation missing/);
  f.apply(files[7]);
  f.metadata.get('tasks').indexes.find(item => item.name === 'uq_tasks_content_request_source').unique = false;
  assert.throws(() => f.apply(files[10]), /indexes missing or incompatible/);
});

test('foundation drift is caught and uploads never use TTL', () => {
  const f = complete();
  const upload = f.metadata.get('task_comment_uploads');
  assert.ok(upload.indexes.every(item => item.expireAfterSeconds === undefined));
  upload.indexes.find(item => item.name === 'idx_task_comment_uploads_cleanup').expireAfterSeconds = 0;
  assert.equal(f.check().schemaChecks.taskWorkflowFoundation, false);
});

test('Q13 foundation has no Task visibility field/index and keeps legacy revision/start fields optional', () => {
  for (const f of [complete(), (() => { const initialized = fixture(); initialized.apply('../init-mongo.js'); return initialized; })()]) {
    const tasks = f.metadata.get('tasks');
    assert.ok(!Object.hasOwn(tasks.options.validator.$jsonSchema.properties, 'visibility'));
    assert.ok(tasks.indexes.every(item => !Object.hasOwn(item.key, 'visibility')));
    assert.deepEqual(tasks.indexes.find(item => item.name === 'idx_tasks_workspace_workflow_created').key,
      { workspaceId: 1, createdAt: -1, _id: -1 });
    assert.ok(!tasks.options.validator.$jsonSchema.required.includes('workflowRevision'));
    assert.ok(!tasks.options.validator.$jsonSchema.required.includes('firstStartedAt'));
  }
});

test('Q13 migration never drops unused metadata if an operator applied the older unmerged draft', () => {
  const f = fixture(); files.slice(0, 10).forEach(f.apply);
  const tasks = f.metadata.get('tasks');
  const oldVisibility = { enum: ['INTERNAL', 'CLIENT_VISIBLE'] };
  tasks.options.validator.$jsonSchema.properties.visibility = clone(oldVisibility);
  const oldIndex = { name: 'idx_tasks_workspace_visibility_created',
    key: { workspaceId: 1, visibility: 1, createdAt: -1, _id: -1 } };
  tasks.indexes.push(clone(oldIndex));
  f.apply(files[10]);
  assert.deepEqual(tasks.options.validator.$jsonSchema.properties.visibility, oldVisibility);
  assert.ok(tasks.indexes.some(item => item.name === oldIndex.name));
  assert.equal(f.check().schemaChecks.taskWorkflowFoundation, true, 'Unused metadata must not become a readiness/permission gate');
});

test('mail metadata from develop is checked without changing Mail contracts', () => {
  const f = complete();
  f.metadata.get('mail_templates').options.validator.$jsonSchema.properties.subject.maxLength = 300;
  assert.equal(result(f.check(), files[8]).status, 'DRIFT');
});

test('invalid legacy documents or duplicate unique keys block foundation before ALL metadata writes', () => {
  for (const kind of ['invalid', 'duplicate']) {
    const f = fixture(); files.slice(0, 10).forEach(f.apply);
    // Pretend the final collection already exists, with data reported by read-only preflight.
    f.metadata.set('task_notification_outbox', { options: {
      validator: { $jsonSchema: { bsonType: 'object', properties: {} } },
    }, indexes: [] });
    (kind === 'invalid' ? f.invalidCounts : f.duplicateCounts).set('task_notification_outbox', 2);
    const before = JSON.stringify([...f.metadata]); f.calls.length = 0;
    const report = f.apply(files[10], { TASK_WORKFLOW_FOUNDATION_APPLY: false });
    assert.equal(report.blocked, true);
    assert.throws(() => f.apply(files[10]), /preflight blocked/);
    assert.equal(JSON.stringify([...f.metadata]), before);
    assert.ok(!f.calls.some(name => ['runCommand', 'createCollection', 'createIndex'].includes(name)));
  }
});

test('Task inventory playground selects brandhub and returns counts/metadata without writing', () => {
  const f = complete(); const before = JSON.stringify([...f.metadata]); f.calls.length = 0;
  const report = f.apply('task-workflow-inventory.mongodb.js');
  assert.equal(report.database, 'brandhub'); assert.equal(report.mode, 'READ_ONLY');
  assert.equal(report.collections.tasks.validatorSupportsCancellation, true);
  assert.equal(report.collections.tasks.missingRevision, 0);
  assert.equal(report.collections.task_comments.exists, true);
  assert.equal(JSON.stringify([...f.metadata]), before);
  assert.ok(!f.calls.some(name => ['runCommand', 'createCollection', 'createIndex'].includes(name)));
});

test('five-state migration is additive, optional, dry-run safe and repeatable', () => {
  const f = fixture(); files.slice(0, 11).forEach(f.apply);
  const before = JSON.stringify([...f.metadata]);
  f.apply(files[11], { TASK_FIVE_STATE_APPLY: false });
  assert.equal(JSON.stringify([...f.metadata]), before);
  f.apply(files[11]); const applied = JSON.stringify([...f.metadata]); f.apply(files[11]);
  assert.equal(JSON.stringify([...f.metadata]), applied);
  const schema = f.metadata.get('tasks').options.validator.$jsonSchema;
  assert.ok(['TODO', 'IN_REVIEW', 'FINISHED', 'BACKLOG', 'ASSIGNED'].every(value => schema.properties.status.enum.includes(value)));
  assert.ok(!schema.required.includes('reviewStep'));
  assert.deepEqual(schema.properties.reviewStep.enum, ['QC', 'MANAGER', 'CLIENT', null]);
  assert.equal(f.check().schemaChecks.taskFiveState, true);
});

test('five-state migration blocks incompatible reviewStep or invalid documents without DDL', () => {
  for (const kind of ['field', 'invalid']) {
    const f = fixture(); files.slice(0, 11).forEach(f.apply);
    if (kind === 'field') f.metadata.get('tasks').options.validator.$jsonSchema.properties.reviewStep = { bsonType: 'int' };
    else f.invalidCounts.set('tasks', 1);
    const before = JSON.stringify([...f.metadata]); f.calls.length = 0;
    assert.throws(() => f.apply(files[11]), /Incompatible reviewStep|Invalid existing/);
    assert.equal(JSON.stringify([...f.metadata]), before);
    assert.ok(!f.calls.some(name => ['runCommand', 'createCollection', 'createIndex'].includes(name)));
  }
});

test('closure refuses incompatible cancellation and invalid existing documents before DDL', () => {
  for (const kind of ['field', 'invalid']) {
    const f = fixture(); files.slice(0, 7).forEach(f.apply);
    if (kind === 'field') f.metadata.get('tasks').options.validator.$jsonSchema.properties.cancellation = { bsonType: 'string' };
    else f.invalidCounts.set('tasks', 1);
    const before = JSON.stringify([...f.metadata]); f.calls.length = 0;
    assert.throws(() => f.apply(files[7]), /Incompatible Task|Invalid existing/);
    assert.equal(JSON.stringify([...f.metadata]), before);
    assert.ok(!f.calls.some(name => ['runCommand', 'createCollection', 'createIndex'].includes(name)));
  }
});
