const { test } = require('node:test');
const assert = require('node:assert/strict');
const { readFileSync } = require('node:fs');
const { join } = require('node:path');
const vm = require('node:vm');
const source = readFileSync(join(__dirname, '../2026-10-13-content-requests-v2.js'), 'utf8');
const init = readFileSync(join(__dirname, '../../init-mongo.js'), 'utf8');

function fixture(records = [], exists = true) {
  const writes = []; const indexes = []; let validator;
  const collection = {
    find: () => ({ forEach: fn => records.forEach(fn) }),
    updateOne: (query, update, options) => {
      writes.push({ query, update, options });
      Object.assign(records.find(item => item._id === query._id), update.$set);
    },
    countDocuments: () => records.length,
    createIndex: (keys, options) => indexes.push({ keys, options }),
  };
  const db = {
    getName: () => 'offline_test', getCollectionInfos: () => exists ? [{}] : [],
    getCollection: () => collection, createCollection: () => writes.push('create'),
    runCommand: command => { validator = command.validator; writes.push('collMod'); return { ok: 1 }; },
  };
  return { writes, indexes, records, validator: () => validator,
    run: apply => vm.runInNewContext(source,
      { db, Date, NumberLong: Number, print: () => {}, CONTENT_REQUEST_MIGRATION_APPLY: apply }) };
}
function record() {
  return { _id: 'request', workspace_id: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    requested_by: 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', title: 'Brief', description: '',
    type: 'POST', status: 'PENDING', due_date: new Date('2026-11-01T12:34:56Z'),
    created_at: new Date(), updated_at: new Date() };
}
test('dry-run existing and absent collections performs no writes', () => {
  for (const state of [fixture([record()]), fixture([], false)]) {
    state.run(false); assert.equal(state.writes.length, 0); assert.equal(state.indexes.length, 0);
  }
});
test('ambiguous status blocks before writing even with a valid preceding record', () => {
  const invalid = { ...record(), _id: 'bad', status: 'SUBMITTED' };
  const state = fixture([record(), invalid]);
  assert.throws(() => state.run(true), /Preflight blocked/); assert.equal(state.writes.length, 0);
});
test('conflicting fields and invalid dates abort', () => {
  for (const extra of [{ workspaceId: 'different' }, { due_date: '2026-11-01' }, { type: 'EVENT' }]) {
    const state = fixture([{ ...record(), ...extra }]);
    assert.throws(() => state.run(true), /Preflight blocked/); assert.equal(state.writes.length, 0);
  }
});
test('invalid metadata and unverified ACCEPTED request block before writes', () => {
  for (const extra of [{ version: 0 }, { version: 1.5 }, { history: null },
    { generatedTaskId: {} }, { reviewedAt: 'not-a-date' }, { status: 'ACCEPTED' }]) {
    const state = fixture([{ ...record(), ...extra }]);
    assert.throws(() => state.run(true), /Preflight blocked/); assert.equal(state.writes.length, 0);
  }
});
test('apply on absent empty collection creates validator before readiness index', () => {
  const state = fixture([], false); state.run(true);
  assert.deepEqual(state.writes, ['create', 'collMod']);
  assert.equal(state.indexes.length, 3);
  assert.equal(state.indexes.at(-1).options.name, 'idx_content_requests_v2_workspace_created');
});
test('apply preserves legacy fields and audit; rerun preserves version', () => {
  const item = { ...record(), version: 7, history: [{ action: 'UPDATE', version: 7 }] };
  const state = fixture([item]); state.run(true); state.run(true);
  assert.equal(item.version, 7); assert.equal(item.history.length, 1);
  assert.equal(item.workspaceId, item.workspace_id);
  assert.equal(item.generatedTaskId, null);
  assert.equal(state.indexes.at(-1).options.name, 'idx_content_requests_v2_workspace_created');
  assert.equal(state.writes[0].options.bypassDocumentValidation, true);
});
test('init and migration content_requests validator/index parity', () => {
  const collections = new Map(); const initIndexes = new Map();
  const db = {
    createCollection: (name, options) => collections.set(name, options),
    getCollectionNames: () => [],
  };
  const proxy = new Proxy(db, { get(target, key) {
    if (key === 'getSiblingDB') return () => proxy;
    if (key in target) return target[key];
    return { createIndex: (keys, options) => {
      if (!initIndexes.has(key)) initIndexes.set(key, []);
      initIndexes.get(key).push({ keys, options });
    } };
  } });
  vm.runInNewContext(init, { db: proxy, print: () => {}, console: { log: () => {} } });
  const state = fixture(); state.run(true);
  // Phase 3 extends optional metadata; the phase-2 contract remains identical.
  for (const field of ['decisionNote', 'decidedBy', 'decidedAt'])
    delete collections.get('content_requests').validator.$jsonSchema.properties[field];
  assert.deepEqual(JSON.parse(JSON.stringify(collections.get('content_requests').validator)),
    JSON.parse(JSON.stringify(state.validator())));
  assert.deepEqual(JSON.parse(JSON.stringify(initIndexes.get('content_requests'))),
    JSON.parse(JSON.stringify(state.indexes)));
});
