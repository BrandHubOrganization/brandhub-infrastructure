// mongosh: DRY_RUN unless both explicit APPLY and WRITERS_PAUSED flags are true.
(() => {
  if (db.getName() !== 'brandhub') throw new Error('Select brandhub explicitly before running this migration');
  const apply = globalThis.REPOSITORY_FOUNDATION_APPLY === true;
  if (apply && globalThis.REPOSITORY_WRITERS_PAUSED !== true) throw new Error('Pause shared writers before APPLY');
  const materialSchema = { bsonType: 'object', required: ['workspace_id', 'status', 'storage_provider',
    'visibility', 'purpose', 'media_kind', 'created_by', 'version'], properties: {
    workspace_id: { bsonType: 'string' }, status: { enum: ['UPLOADING', 'VALIDATING', 'READY', 'REJECTED', 'FAILED'] },
    storage_provider: { enum: ['SYSTEM_GDRIVE', 'SYSTEM_S3', 'USER_GDRIVE'] },
    visibility: { enum: ['INTERNAL', 'CLIENT'] }, purpose: { enum: ['MATERIAL', 'BRAND_REFERENCE'] },
    media_kind: { enum: ['IMAGE', 'VIDEO', 'FILE'] }, created_by: { bsonType: 'string' },
    version: { bsonType: ['long', 'int'], minimum: 0 }
  }};
  const collections = [
    { name: 'materials', validator: { $or: [{ status: { $exists: false } }, { $jsonSchema: materialSchema }] }, indexes: [
      { name: 'idx_repository_scope_ready', key: { workspace_id: 1, status: 1, deleted_at: 1, created_at: -1, _id: -1 } },
      { name: 'uq_repository_provider_key', key: { storage_provider: 1, s3_key: 1 }, unique: true,
        partialFilterExpression: { storage_provider: { $type: 'string' }, s3_key: { $type: 'string' } } }
    ] },
    { name: 'material_upload_sessions', indexes: [
      { name: 'uq_repository_session_key', key: { workspace_id: 1, staging_key: 1 }, unique: true },
      { name: 'idx_repository_session_recovery', key: { state: 1, expires_at: 1 } }
    ] },
    { name: 'material_references', indexes: [
      { name: 'uq_repository_reference', key: { workspace_id: 1, material_id: 1, source_id: 1 }, unique: true }
    ] }
  ];
  for (const collection of collections) {
    const exists = db.getCollectionNames().includes(collection.name);
    for (const index of collection.indexes) {
      const current = exists ? db.getCollection(collection.name).getIndexes().find(row => row.name === index.name) : null;
      if (current && (JSON.stringify(current.key) !== JSON.stringify(index.key) || !!current.unique !== !!index.unique
          || JSON.stringify(current.partialFilterExpression) !== JSON.stringify(index.partialFilterExpression))) {
        throw new Error('Conflicting index requires review: ' + index.name);
      }
    }
  }
  printjson({ mode: apply ? 'APPLY' : 'DRY_RUN', database: db.getName(), collections: collections.map(row => row.name),
    legacyBackfill: 'NOT PERFORMED; verify object inventory and PostgreSQL usage before enabling writes' });
  if (!apply) return;
  for (const collection of collections) {
    if (!db.getCollectionNames().includes(collection.name)) db.createCollection(collection.name);
    if (collection.validator) {
      const result = db.runCommand({ collMod: collection.name, validator: collection.validator,
        validationLevel: 'moderate', validationAction: 'error' });
      if (!result.ok) throw new Error('Validator update failed: ' + collection.name);
    }
    for (const index of collection.indexes) {
      const { key, ...options } = index;
      db.getCollection(collection.name).createIndex(key, options);
    }
  }
})();
