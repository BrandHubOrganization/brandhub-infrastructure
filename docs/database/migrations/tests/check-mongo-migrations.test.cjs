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
];
const clone = value => JSON.parse(JSON.stringify(value));

// Execute the REAL migration sources against an in-memory metadata recorder.
// No Mongo/network dependency; writes below exist only in RAM to construct fixtures.
function fixture() {
  const metadata = new Map();
  let readOnly = false;
  const calls = [];
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
    aggregate: () => { if (readOnly) throw new Error('Checker read documents'); return { toArray: () => [] }; },
    find: () => { if (readOnly) throw new Error('Checker read documents'); return { forEach: () => {} }; },
    countDocuments: () => { if (readOnly) throw new Error('Checker counted documents'); return 0; },
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
    vm.runInNewContext(readFileSync(join(__dirname, '..', file), 'utf8'), {
      db: target, print: () => {}, CONTENT_REQUEST_MIGRATION_APPLY: true, CONTENT_REQUEST_ACCEPTANCE_APPLY: true,
      CAMPAIGN_CLOSURE_APPLY: true,
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
  return { metadata, apply, check };
}
const complete = () => { const f = fixture(); files.forEach(f.apply); return f; };
const result = (report, file) => report.results.find(entry => entry.migration === file);

test('all real migration effects MATCH, including superseded Task schemas; checker is read-only', () => {
  const report = complete().check();
  assert.deepEqual(report.summary, { MATCH: 8, MISSING: 0, DRIFT: 0, UNKNOWN: 0 });
  assert.equal(report.database, 'brandhub'); assert.equal(report.initialDatabase, 'test');
  assert.equal(report.mode, 'READ_ONLY');
  assert.deepEqual(report.schemaChecks, { contentRequestV2: true, contentRequestAcceptance: true, campaignDeployment: true });
});
test('empty database reports missing collections, never creates them', () => {
  assert.equal(fixture().check().summary.MISSING, 8);
});

test('fresh Mongo init matches all eight migration effects and their exact validators/indexes', () => {
  const initialized = fixture(); initialized.apply('../init-mongo.js');
  assert.deepEqual(initialized.check().summary, { MATCH: 8, MISSING: 0, DRIFT: 0, UNKNOWN: 0 });
  const migrated = complete();
  for (const [name, expected] of migrated.metadata) {
    const actual = initialized.metadata.get(name);
    assert.ok(actual, name);
    assert.deepEqual(actual.options.validator, expected.options.validator, name + ' validator');
    assert.equal(actual.options.validationAction || 'error', expected.options.validationAction || 'error', name);
    assert.equal(actual.options.validationLevel || 'strict', expected.options.validationLevel || 'strict', name);
    assert.deepEqual(actual.indexes, expected.indexes, name + ' indexes');
  }
  assert.equal(initialized.metadata.size, 19);
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
  assert.equal(f.check().summary.MATCH, 8);
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
  assert.equal(report.summary.UNKNOWN, 8);
  assert.ok(!JSON.stringify(report).includes('private credential'));
});
