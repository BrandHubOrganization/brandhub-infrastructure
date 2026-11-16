// Existing DB only. Playground: use('brandhub'); globalThis.TASK_PARTNERS_APPLY = false/true.
// 1) tasks validator: add optional partnerIds[] and subtasks[].description / acceptanceCriteria.
// 2) Add partial index on tasks.partnerIds for campaign partner lookup.
// Additive only: no document is rewritten or deleted. Re-runnable.
(() => {
  const apply = globalThis.TASK_PARTNERS_APPLY === true;
  const info = db.getCollectionInfos({ name: 'tasks' })[0];
  if (!info) throw new Error('Apply the tasks baseline first; no writes performed.');
  const copy = EJSON.parse(EJSON.stringify(info.options.validator || {}));
  const schemas = [];
  const walk = value => {
    if (!value || typeof value !== 'object') return;
    if (value.$jsonSchema) schemas.push(value.$jsonSchema);
    Object.keys(value).forEach(key => { if (key !== '$jsonSchema') walk(value[key]); });
  };
  walk(copy);
  if (schemas.length !== 1) throw new Error('Expected one tasks JSON schema baseline; no writes performed.');
  const invalidPartners = db.tasks.countDocuments({
    partnerIds: { $exists: true, $not: { $type: ['array', 'null'] } },
  });
  print(JSON.stringify({
    migration: 'task-partner-contacts-2026-11-12',
    database: db.getName(),
    mode: apply ? 'APPLY' : 'DRY_RUN',
    blocked: invalidPartners > 0,
    invalidPartners,
    backfill: false,
  }));
  if (invalidPartners) throw new Error('Existing partnerIds values are not array/null; no writes performed.');
  if (!apply) return;

  const schema = schemas[0];
  schema.properties = schema.properties || {};
  schema.properties.partnerIds = schema.properties.partnerIds || {
    bsonType: ['array', 'null'],
    items: { bsonType: 'string' },
  };
  const subtasks = schema.properties.subtasks || { bsonType: 'array' };
  if (subtasks.items && (Array.isArray(subtasks.items) || subtasks.items.$ref)) {
    throw new Error('Unsupported embedded subtask schema; no writes performed.');
  }
  subtasks.items = subtasks.items || { bsonType: 'object' };
  subtasks.items.properties = subtasks.items.properties || {};
  subtasks.items.properties.description = subtasks.items.properties.description || { bsonType: ['string', 'null'] };
  subtasks.items.properties.acceptanceCriteria = subtasks.items.properties.acceptanceCriteria || { bsonType: ['string', 'null'] };
  schema.properties.subtasks = subtasks;

  const result = db.runCommand({
    collMod: 'tasks',
    validator: copy,
    validationLevel: info.options.validationLevel || 'strict',
    validationAction: info.options.validationAction || 'error',
  });
  if (!result.ok) throw new Error('Could not update tasks validator.');

  db.tasks.createIndex(
    { partnerIds: 1 },
    { name: 'idx_tasks_partner_ids', partialFilterExpression: { partnerIds: { $type: 'array' } } },
  );
  print('Task partnerIds & subtask description/acceptanceCriteria schema and index are ready.');
})();
