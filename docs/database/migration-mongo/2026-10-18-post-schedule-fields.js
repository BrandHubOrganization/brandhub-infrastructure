// Migration for posts collection to add task_id and scheduled_at attributes
// Default mode is read-only (DRY_RUN).
// Run with globalThis.POST_SCHEDULE_FIELDS_APPLY = true to apply schema modification.
(() => {
  const target = db.getSiblingDB('brandhub');
  const apply = globalThis.POST_SCHEDULE_FIELDS_APPLY === true;
  const info = target.getCollectionInfos({ name: 'posts' })[0];
  if (!info) {
    throw new Error('Collection posts not found in brandhub database.');
  }

  const validator = info?.options?.validator || { $jsonSchema: { bsonType: 'object', properties: {} } };
  const schema = validator.$jsonSchema || { bsonType: 'object', properties: {} };
  const properties = schema.properties || {};

  const nextProperties = {
    ...properties,
    task_id: { bsonType: ['string', 'null'], description: 'Associated Task ID generated from media campaign' },
    scheduled_at: { bsonType: ['date', 'null'], description: 'Auto-publish trigger timestamp' },
  };

  const nextValidator = {
    ...validator,
    $jsonSchema: {
      ...schema,
      properties: nextProperties,
    },
  };

  const posts = target.getCollection('posts');
  const invalidDocuments = posts.countDocuments({ $nor: [nextValidator] });
  const totalCount = posts.countDocuments({});

  const report = {
    database: target.getName(),
    collection: 'posts',
    mode: apply ? 'APPLY' : 'DRY_RUN',
    totalDocuments: totalCount,
    invalidDocuments,
    blocked: invalidDocuments > 0,
    note: 'Adds task_id and scheduled_at properties to collection posts schema validation.',
  };

  print(JSON.stringify(report));

  if (!apply) return report;

  if (report.blocked) {
    throw new Error('Invalid existing posts documents found; aborting schema migration.');
  }

  const result = target.runCommand({
    collMod: 'posts',
    validator: nextValidator,
    validationAction: info.options?.validationAction || 'warn',
    validationLevel: info.options?.validationLevel || 'off',
  });

  if (result.ok !== 1) {
    throw new Error('Updating collection posts validator failed: ' + JSON.stringify(result));
  }

  print('Successfully migrated posts schema with task_id and scheduled_at fields.');
  return { ...report, applied: true };
})();
