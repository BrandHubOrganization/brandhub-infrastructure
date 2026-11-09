// Existing DB only. Playground: use('brandhub'); globalThis.TASK_TIMELINE_APPLY = false/true.
// Add optional planned dates, preserving the entire validator and all data/indexes.
(() => {
  const apply = globalThis.TASK_TIMELINE_APPLY === true;
  const info = db.getCollectionInfos({ name: 'tasks' })[0];
  if (!info) throw new Error('Apply the tasks baseline first; no writes performed.');
  const validator = info.options.validator || {};
  const copy = EJSON.parse(EJSON.stringify(validator));
  const schemas = [];
  const walk = value => {
    if (!value || typeof value !== 'object') return;
    if (value.$jsonSchema) schemas.push(value.$jsonSchema);
    Object.keys(value).forEach(key => { if (key !== '$jsonSchema') walk(value[key]); });
  };
  walk(copy);
  if (schemas.length !== 1) throw new Error('Expected one tasks JSON schema baseline; no writes performed.');
  const invalid = db.tasks.countDocuments({ $or: [
    { plannedStartDate: { $exists: true, $not: { $type: ['date', 'null'] } } },
    { subtasks: { $elemMatch: { plannedStartDate: { $exists: true, $not: { $type: ['date', 'null'] } } } } },
  ] });
  print(JSON.stringify({ migration: 'campaign-timeline-2026-11-07', database: db.getName(),
    mode: apply ? 'APPLY' : 'DRY_RUN', blocked: invalid > 0, invalid, backfill: false }));
  if (invalid) throw new Error('Invalid existing plannedStartDate values; no writes performed.');
  if (!apply) return;
  const schema = schemas[0];
  schema.properties = schema.properties || {};
  schema.properties.plannedStartDate = { bsonType: ['date', 'null'] };
  const subtasks = schema.properties.subtasks || { bsonType: 'array' };
  if (subtasks.items && (Array.isArray(subtasks.items) || subtasks.items.$ref))
    throw new Error('Unsupported embedded subtask schema; no writes performed.');
  subtasks.items = subtasks.items || { bsonType: 'object' };
  subtasks.items.properties = subtasks.items.properties || {};
  subtasks.items.properties.plannedStartDate = { bsonType: ['date', 'null'] };
  schema.properties.subtasks = subtasks;
  const result = db.runCommand({ collMod: 'tasks', validator: copy,
    validationLevel: info.options.validationLevel || 'strict',
    validationAction: info.options.validationAction || 'error' });
  if (!result.ok) throw new Error('Could not update tasks validator.');
  print('Task planning metadata ready. No records, indexes, actual-start history or other collections changed.');
})();
