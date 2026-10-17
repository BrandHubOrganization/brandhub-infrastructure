// Metadata only; default DRY_RUN. No Task/history writes or state conversion.
// Run after the Task foundation + five-state migrations, with old writers stopped.
(() => {
  const target = db.getSiblingDB('brandhub');
  const apply = globalThis.TASK_STRUCTURE_SIMPLIFICATION_APPLY === true;
  const info = target.getCollectionInfos({ name: 'tasks' })[0];
  const validator = info?.options?.validator;
  const schema = validator?.$jsonSchema;
  const properties = schema?.properties;
  const states = properties?.status?.enum ?? [];
  const requiredFields = ['workflowRevision', 'firstStartedAt', 'firstStartedBy',
    'inputReferences', 'assignedAt', 'assignedBy', 'reviewStep'];
  if (!properties || !requiredFields.every(field => properties[field])
      || !['TODO', 'IN_PROGRESS', 'IN_REVIEW', 'FINISHED', 'CANCELLED']
        .every(state => states.includes(state)))
    throw new Error('Apply Task foundation and five-state workflow first; no writes performed.');
  if ((info.options.validationLevel ?? 'strict') !== 'strict'
      || (info.options.validationAction ?? 'error') !== 'error')
    throw new Error('Unexpected validation options; review before applying.');
  const nextProperties = { ...properties };
  delete nextProperties.plannedPublishAt;
  const nextSchema = { ...schema, properties: nextProperties };
  if (schema.required) nextSchema.required = schema.required.filter(field => field !== 'plannedPublishAt');
  const nextValidator = { ...validator, $jsonSchema: nextSchema };
  const tasks = target.getCollection('tasks');
  const invalidDocuments = tasks.countDocuments({ $nor: [nextValidator] });
  const report = {
    database: target.getName(), mode: apply ? 'APPLY' : 'DRY_RUN',
    count: tasks.countDocuments({}), invalidDocuments, blocked: invalidDocuments > 0,
    legacyQcAssignments: tasks.countDocuments({ qcAssigneeId: { $type: 'string' } }),
    legacyQcReviews: tasks.countDocuments({ $or: [{ status: 'QC_REVIEW' }, { reviewStep: 'QC' }] }),
    legacyPublicationFields: tasks.countDocuments({ plannedPublishAt: { $exists: true } }),
    note: 'Only obsolete validation dependency removed. QC/history/Task documents remain unchanged.',
  };
  print(JSON.stringify(report));
  if (!apply) return report;
  if (report.blocked) throw new Error('Invalid existing Tasks; no writes performed.');
  const result = target.runCommand({ collMod: 'tasks', validator: nextValidator,
    validationLevel: 'strict', validationAction: 'error' });
  if (result.ok !== 1) throw new Error('Task schema update failed.');
  return { ...report, applied: true };
})();
