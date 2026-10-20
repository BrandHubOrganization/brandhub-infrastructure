const { test } = require('node:test');
const assert = require('node:assert/strict');
const { readFileSync } = require('node:fs');
const { join } = require('node:path');
const vm = require('node:vm');
const script = readFileSync(join(__dirname, '../2026-10-13-content-request-acceptance.js'), 'utf8');
const init = readFileSync(join(__dirname, '../../init-mongo.js'), 'utf8');
function fixture(taskRecords = [], requestRecords = [], ready = true) {
  const writes = []; let validator; let sourceIndex;
  const initialSchema = { $jsonSchema: { properties: { workspaceId: { bsonType: 'string' },
    title: { bsonType: 'string', minLength: 1, maxLength: 255 } } } };
  const requests = { getIndexes: () => ready ? [{ name: 'idx_content_requests_v2_workspace_created' }] : [],
    find: () => ({ forEach: callback => requestRecords.forEach(callback) }),
    countDocuments: () => requestRecords.length };
  const sourceTasks = taskRecords.filter(record => record.sourceType === 'CONTENT_REQUEST');
  const tasks = { getIndexes: () => [{ name: 'uq_tasks_campaign_work_item' }],
    countDocuments: query => query?.$or ? sourceTasks.filter(record => typeof record.sourceRefId !== 'string'
      || record.sourceRefId === '').length : taskRecords.length,
    aggregate: () => ({ toArray: () => {
      const counts = new Map(); sourceTasks.forEach(record => counts.set(record.sourceRefId, (counts.get(record.sourceRefId) || 0) + 1));
      return [{ count: [...counts.values()].filter(count => count > 1).length }];
    } }),
    createIndex: (keys, options) => { sourceIndex = { keys, options }; writes.push('index'); } };
  const db = { getName: () => 'offline', getCollectionInfos: ({ name }) => [{ name, options: { validator: initialSchema } }],
    getCollection: name => name === 'tasks' ? tasks : requests,
    runCommand: command => { writes.push('collMod'); validator = command.validator; return { ok: 1 }; } };
  return { writes, validator: () => validator, sourceIndex: () => sourceIndex,
    run: apply => vm.runInNewContext(script, { db, Date, print: () => {}, CONTENT_REQUEST_ACCEPTANCE_APPLY: apply }) };
}
test('default dry-run has no writes', () => {
  const state = fixture(); state.run(false); assert.deepEqual(state.writes, []);
});
test('duplicate Request source aborts before any metadata/index write', () => {
  const state = fixture([{ sourceType: 'CONTENT_REQUEST', sourceRefId: 'request' },
    { sourceType: 'CONTENT_REQUEST', sourceRefId: 'request' }]);
  assert.throws(() => state.run(true), /preflight blocked/); assert.deepEqual(state.writes, []);
});
test('missing source reference aborts; unrelated duplicate Campaign sources are unaffected', () => {
  const invalid = fixture([{ sourceType: 'CONTENT_REQUEST' }]);
  assert.throws(() => invalid.run(true), /preflight blocked/); assert.deepEqual(invalid.writes, []);
  const valid = fixture([{ sourceType: 'CAMPAIGN', sourceRefId: 'same' }, { sourceType: 'CAMPAIGN', sourceRefId: 'same' }]);
  valid.run(true); assert.deepEqual(valid.writes, ['collMod', 'index']);
});
test('phase 2 readiness and metadata validation enforced before writes', () => {
  for (const state of [fixture([], [], false), fixture([], [{ decisionNote: 'x'.repeat(2001) }]),
    fixture([], [{ decidedAt: 'not a BSON date' }]), fixture([], [{ decidedBy: 123 }])]) {
    assert.throws(() => state.run(true)); assert.deepEqual(state.writes, []);
  }
});
test('apply and rerun preserve existing schema; init metadata and source index match', () => {
  const state = fixture(); state.run(true); state.run(true);
  assert.deepEqual(state.writes, ['collMod', 'index', 'collMod', 'index']);
  const collections = new Map(); let initSourceIndex;
  const db = new Proxy({ createCollection: (name, options) => collections.set(name, options) }, {
    get(target, key) {
      if (key === 'getSiblingDB') return () => db;
      if (key === 'getCollection') return name => db[name];
      if (key in target) return target[key];
      return { createIndex: (keys, options) => {
        if (options.name === 'uq_tasks_content_request_source') initSourceIndex = { keys, options };
      } };
    },
  });
  vm.runInNewContext(init, { db, print: () => {} });
  const plain = value => JSON.parse(JSON.stringify(value));
  assert.deepEqual(plain(state.sourceIndex()), plain(initSourceIndex));
  for (const field of ['decisionNote', 'decidedBy', 'decidedAt']) assert.deepEqual(
    plain(state.validator().$jsonSchema.properties[field]), plain(collections.get('content_requests').validator.$jsonSchema.properties[field]));
  assert.equal(state.validator().$jsonSchema.properties.title.maxLength, 255);
});
