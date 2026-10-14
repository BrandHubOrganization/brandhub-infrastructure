// DA-951 phase 3. Run AFTER content-requests-v2 and existing Task V2 migrations.
// Default READ-ONLY. Backup and freeze writers before explicit APPLY.
(function () {
  const apply = globalThis.CONTENT_REQUEST_ACCEPTANCE_APPLY === true;
  const requestsInfo = db.getCollectionInfos({ name: 'content_requests' })[0];
  const tasksInfo = db.getCollectionInfos({ name: 'tasks' })[0];
  if (!requestsInfo || !tasksInfo) throw new Error('Apply Request/Task V2 migrations first; no writes performed.');
  const requests = db.getCollection('content_requests');
  const tasks = db.getCollection('tasks');
  const requestIndexes = requests.getIndexes();
  if (!requestIndexes.some(index => index.name === 'idx_content_requests_v2_workspace_created'))
    throw new Error('Request V2 readiness index missing; no writes performed.');
  if (!tasks.getIndexes().some(index => index.name === 'uq_tasks_campaign_work_item'))
    throw new Error('Task V2 readiness index missing; no writes performed.');
  const sourceFilter = { sourceType: 'CONTENT_REQUEST' };
  const invalidSources = tasks.countDocuments({ sourceType: 'CONTENT_REQUEST', $or: [
    { sourceRefId: { $not: { $type: 'string' } } }, { sourceRefId: '' },
  ] });
  const duplicateSources = tasks.aggregate([
    { $match: sourceFilter },
    { $group: { _id: '$sourceRefId', count: { $sum: 1 } } },
    { $match: { count: { $gt: 1 } } }, { $count: 'count' },
  ]).toArray()[0]?.count || 0;
  let invalidDecisionMetadata = 0;
  requests.find({}).forEach(record => {
    if (record.decisionNote != null && (typeof record.decisionNote !== 'string' || record.decisionNote.length > 2000))
      invalidDecisionMetadata++;
    if (record.decidedBy != null && typeof record.decidedBy !== 'string') invalidDecisionMetadata++;
    if (record.decidedAt != null && (!(record.decidedAt instanceof Date) || !Number.isFinite(record.decidedAt.getTime())))
      invalidDecisionMetadata++;
  });
  print(JSON.stringify({ database: db.getName(), mode: apply ? 'APPLY' : 'DRY_RUN',
    requestCount: requests.countDocuments({}), taskCount: tasks.countDocuments({}),
    invalidSources, duplicateSources, invalidDecisionMetadata }));
  if (invalidSources || duplicateSources || invalidDecisionMetadata)
    throw new Error('Acceptance preflight blocked; review legacy data. No writes performed.');
  const validator = requestsInfo.options?.validator;
  if (!validator?.$jsonSchema?.properties?.workspaceId)
    throw new Error('Request V2 validator missing; no writes performed.');
  if (!apply) return;
  // Preserve all existing validation and data; extend only optional decision metadata.
  validator.$jsonSchema.properties.decisionNote = { bsonType: ['string', 'null'], maxLength: 2000 };
  validator.$jsonSchema.properties.decidedBy = { bsonType: ['string', 'null'] };
  validator.$jsonSchema.properties.decidedAt = { bsonType: ['date', 'null'] };
  const result = db.runCommand({ collMod: 'content_requests', validator,
    validationLevel: 'strict', validationAction: 'error' });
  if (result.ok !== 1) throw new Error('Validator update failed; keep acceptance disabled.');
  tasks.createIndex({ sourceType: 1, sourceRefId: 1 }, {
    name: 'uq_tasks_content_request_source', unique: true,
    partialFilterExpression: { sourceType: 'CONTENT_REQUEST', sourceRefId: { $type: 'string' } },
  });
  print('DA-951 acceptance ready; no Request or Task document was inserted/updated/deleted.');
})();
