// DA-978: canonical Task states; legacy values are read-compatible only.
// After campaign-closure + task-detail-comments-foundation. No document backfill.
// DEFAULT DRY_RUN. Backup/freeze writers, review before TASK_FIVE_STATE_APPLY=true.
(() => {
  const target = db.getSiblingDB('brandhub');
  const apply = globalThis.TASK_FIVE_STATE_APPLY === true;
  const info = target.getCollectionInfos({ name: 'tasks' })[0];
  const schema = info?.options?.validator?.$jsonSchema;
  const properties = schema?.properties;
  const oldStates = properties?.status?.enum;
  const eventIndex = target.getCollectionInfos({ name: 'task_notification_outbox' }).length
    && target.getCollection('task_notification_outbox').getIndexes().some(index =>
      index.name === 'uq_task_notification_outbox_event' && index.unique);
  if (!Array.isArray(oldStates) || !oldStates.includes('CANCELLED') || !properties.cancellation
      || !['workflowRevision', 'firstStartedAt', 'firstStartedBy', 'inputReferences', 'plannedPublishAt', 'assignedAt', 'assignedBy']
        .every(field => properties[field]) || !eventIndex)
    throw new Error('Apply Campaign closure and Task workflow foundation first; no writes performed.');
  const reviewStep = { bsonType: ['string', 'null'], enum: ['QC', 'MANAGER', 'CLIENT', null] };
  const sorted = value => Array.isArray(value) ? value.map(sorted) : value && typeof value === 'object'
    ? Object.fromEntries(Object.keys(value).sort().map(key => [key, sorted(value[key])])) : value;
  if ((info.options.validationLevel ?? 'strict') !== 'strict'
      || (info.options.validationAction ?? 'error') !== 'error')
    throw new Error('Incompatible Task validation options; no writes performed.');
  if (properties.reviewStep && JSON.stringify(sorted(properties.reviewStep)) !== JSON.stringify(sorted(reviewStep)))
    throw new Error('Incompatible reviewStep definition; review instead of overwriting.');
  const validator = { ...info.options.validator, $jsonSchema: { ...schema, properties: {
    ...properties, status: { ...properties.status, enum: [...new Set([...oldStates, 'TODO', 'IN_REVIEW', 'FINISHED'])] }, reviewStep,
  } } };
  const invalidDocuments = target.getCollection('tasks').countDocuments({ $nor: [validator] });
  const report = { database: target.getName(), mode: apply ? 'APPLY' : 'DRY_RUN', blocked: invalidDocuments > 0,
    invalidDocuments, note: 'No document writes/backfill. Legacy states/evidence remain unchanged; API maps to five business states.' };
  print(JSON.stringify(report));
  if (!apply) return report;
  if (report.blocked) throw new Error('Invalid existing documents; no writes performed.');
  const result = target.runCommand({ collMod: 'tasks', validator, validationLevel: 'strict', validationAction: 'error' });
  if (result.ok !== 1) throw new Error('Five-state schema update failed; keep feature locked.');
  return { ...report, applied: true };
})();
