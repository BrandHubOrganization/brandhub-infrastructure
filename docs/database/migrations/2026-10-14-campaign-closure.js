// Run AFTER Task V2, Campaign deployment and Request acceptance. Default read-only.
// Backup/freeze writers before globalThis.CAMPAIGN_CLOSURE_APPLY = true.
// Preserves all existing validator fields/indexes/documents; NO legacy Task backfill.
(() => {
  const target = db.getSiblingDB('brandhub');
  const apply = globalThis.CAMPAIGN_CLOSURE_APPLY === true;
  const info = target.getCollectionInfos({ name: 'tasks' })[0];
  const properties = info?.options?.validator?.$jsonSchema?.properties;
  const statuses = properties && properties.status && properties.status.enum;
  if (!Array.isArray(statuses) || !statuses.includes('CLIENT_REVIEW') || !properties.campaignId)
    throw new Error('Task V2 validator missing; no writes performed.');
  const indexes = target.getCollection('tasks').getIndexes();
  if (!indexes.some(index => index.name === 'uq_tasks_content_request_source' && index.unique))
    throw new Error('Apply Request acceptance first; no writes performed.');
  const unlinkedRequestTasks = target.getCollection('tasks').countDocuments({ sourceType: 'CONTENT_REQUEST', campaignId: null });
  print(JSON.stringify({ database: target.getName(), mode: apply ? 'APPLY' : 'DRY_RUN', unlinkedRequestTasks,
    note: 'Legacy unlinked Tasks are reported only; reconcile explicitly before closing their Workspace Campaign.' }));
  if (!apply) return;
  properties.status.enum = [...new Set([...properties.status.enum, 'CANCELLED'])];
  properties.cancellation = {
    bsonType: 'object', required: ['actorId', 'at', 'reasonCode', 'previousStatus'],
    properties: {
      actorId: { bsonType: 'string' }, at: { bsonType: 'date' },
      reasonCode: { enum: ['CLIENT_NO_LONGER_NEEDS', 'MUTUAL_AGREEMENT', 'DUPLICATE_OR_REPLACED', 'NO_LONGER_SUITABLE', 'OTHER'] },
      note: { bsonType: ['string', 'null'], maxLength: 2000 }, previousStatus: { bsonType: 'string' },
    },
  };
  const result = target.runCommand({ collMod: 'tasks', validator: info.options.validator,
    validationLevel: 'strict', validationAction: 'error' });
  if (result.ok !== 1) throw new Error('Task validator update failed; keep cancellation disabled.');
  print('Campaign closure schema ready; no documents or approval history changed.');
})();
