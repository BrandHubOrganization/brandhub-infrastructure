// Existing DB only (DA-1274). Playground: use('brandhub'); globalThis.SUBTASK_SECTIONS_APPLY = false/true.
// 1) tasks validator: add 4 task types + optional subtasks[].subtaskRole, preserving everything else.
// 2) Create task_sections, task_section_versions, task_section_events with validators + indexes.
// Additive only: no document is rewritten, no backfill (missing section document = virtual DRAFT).
// Re-runnable: existing enum values, properties, collections and indexes are left as they are.
(() => {
  const apply = globalThis.SUBTASK_SECTIONS_APPLY === true;
  const NEW_TYPES = ['SHORT_VIDEO', 'KOL_BOOKING', 'WORKSHOP', 'EMAIL_NEWSLETTER'];
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
  const schema = schemas[0];
  const typeProp = (schema.properties || {}).type;
  if (!typeProp || !Array.isArray(typeProp.enum)) throw new Error('tasks.type enum not found; no writes performed.');
  const subtasks = (schema.properties || {}).subtasks || { bsonType: 'array' };
  if (subtasks.items && (Array.isArray(subtasks.items) || subtasks.items.$ref))
    throw new Error('Unsupported embedded subtask schema; no writes performed.');
  const invalidRoles = db.tasks.countDocuments({
    subtasks: { $elemMatch: { subtaskRole: { $exists: true, $not: { $type: ['string', 'null'] } } } },
  });

  const s = { bsonType: 'string' }, d = { bsonType: 'date' };
  const ns = { bsonType: ['string', 'null'] }, nd = { bsonType: ['date', 'null'] };
  const obj = (required, properties) => ({ bsonType: 'object', required, properties });
  const collections = [
    { name: 'task_sections', validator: obj(['_id', 'workspaceId', 'taskId', 'sectionKey', 'visibility',
      'status', 'revision', 'updatedAt'], {
      _id: s, workspaceId: s, taskId: s, sectionKey: { bsonType: 'string', maxLength: 64 },
      visibility: { enum: ['OUTPUT', 'INTERNAL'] },
      status: { enum: ['DRAFT', 'SUBMITTED', 'INTERNAL_APPROVED', 'CLIENT_APPROVED', 'RETURNED'] },
      revision: { bsonType: ['long', 'int'], minimum: 0 },
      content: { bsonType: ['object', 'null'] },
      returnNote: { bsonType: ['string', 'null'], maxLength: 2000 }, returnedBy: ns,
      lastEditorRole: ns, clientPendingSince: nd, clientReminderSentAt: nd, updatedAt: d,
    }), indexes: [
      { name: 'uq_task_sections_task_key', key: { taskId: 1, sectionKey: 1 }, unique: true },
      { name: 'idx_task_sections_workspace_status', key: { workspaceId: 1, status: 1 } },
      { name: 'idx_task_sections_client_pending', key: { status: 1, clientPendingSince: 1 } },
    ] },
    { name: 'task_section_versions', validator: obj(['_id', 'workspaceId', 'taskId', 'sectionKey',
      'versionNo', 'submittedBy', 'submittedAt'], {
      _id: s, workspaceId: s, taskId: s, sectionKey: s, versionNo: { bsonType: ['long', 'int'], minimum: 1 },
      content: { bsonType: ['object', 'null'] }, submittedBy: s, submittedAt: d,
    }), indexes: [
      { name: 'uq_task_section_versions_no', key: { taskId: 1, sectionKey: 1, versionNo: 1 }, unique: true },
    ] },
    { name: 'task_section_events', validator: obj(['_id', 'workspaceId', 'taskId', 'sectionKey',
      'action', 'actorId', 'at'], {
      _id: s, workspaceId: s, taskId: s, sectionKey: s,
      action: { enum: ['SUBMIT', 'APPROVE', 'CLIENT_APPROVE', 'RETURN', 'CLIENT_RETURN', 'REOPEN', 'RESTORE'] },
      actorId: s, note: { bsonType: ['string', 'null'], maxLength: 2000 }, at: d,
    }), indexes: [
      { name: 'idx_task_section_events_timeline', key: { taskId: 1, at: 1 } },
    ] },
  ];
  const existing = new Set(db.getCollectionNames());
  const missingTypes = NEW_TYPES.filter(t => !typeProp.enum.includes(t));
  print(JSON.stringify({ migration: 'subtask-role-sections-2026-11-10', database: db.getName(),
    mode: apply ? 'APPLY' : 'DRY_RUN', blocked: invalidRoles > 0, invalidRoles, missingTypes,
    createCollections: collections.map(c => c.name).filter(n => !existing.has(n)), backfill: false }));
  if (invalidRoles) throw new Error('Existing subtaskRole values are not string/null; no writes performed.');
  if (!apply) return;

  missingTypes.forEach(t => typeProp.enum.push(t));
  subtasks.items = subtasks.items || { bsonType: 'object' };
  subtasks.items.properties = subtasks.items.properties || {};
  subtasks.items.properties.subtaskRole = subtasks.items.properties.subtaskRole || { bsonType: ['string', 'null'] };
  schema.properties.subtasks = subtasks;
  const result = db.runCommand({ collMod: 'tasks', validator: copy,
    validationLevel: info.options.validationLevel || 'strict',
    validationAction: info.options.validationAction || 'error' });
  if (!result.ok) throw new Error('Could not update tasks validator.');

  for (const c of collections) {
    if (!existing.has(c.name)) {
      db.createCollection(c.name, { validator: { $jsonSchema: c.validator },
        validationLevel: 'strict', validationAction: 'error' });
    }
    for (const { key, ...options } of c.indexes) db.getCollection(c.name).createIndex(key, options);
  }
  print('Subtask roles and section collections ready. No task documents rewritten.');
})();
