// mongosh, dry-run by default. Does not delete documents or objects; never creates a TTL index.
(() => {
  if (db.getName() !== 'brandhub') throw new Error('Select brandhub explicitly');
  const apply = globalThis.MATERIAL_TRASH_APPLY === true;
  const collection = db.getCollection('materials');
  const ttl = collection.getIndexes().filter(index => index.expireAfterSeconds !== undefined &&
    (index.key.deleted_at !== undefined || index.key.purge_after !== undefined));
  if (ttl.length) throw new Error('Unsafe materials TTL requires manual removal before rollout');
  const options = db.getCollectionInfos({ name: 'materials' })[0]?.options;
  if (!options?.validator?.$or) throw new Error('Apply repository foundation first; unexpected validator');
  const validator = options.validator;
  const schema = validator.$or.find(entry => entry.$jsonSchema)?.$jsonSchema;
  if (!schema?.properties?.status?.enum) throw new Error('Unexpected status validator');
  const states = schema.properties.status.enum;
  for (const state of ['DELETED', 'PURGE_IN_PROGRESS', 'PURGED']) if (!states.includes(state)) states.push(state);
  printjson({ mode: apply ? 'APPLY' : 'DRY_RUN', validator, ttl: false });
  if (!apply) return;
  if (globalThis.REPOSITORY_WRITERS_PAUSED !== true) throw new Error('Pause writers before APPLY');
  const result = db.runCommand({ collMod: 'materials', validator,
    validationLevel: options.validationLevel || 'moderate', validationAction: 'error' });
  if (!result.ok) throw new Error('Validator update failed');
  collection.createIndex({ workspace_id: 1, status: 1, deleted_at: -1, _id: -1 }, { name: 'idx_material_trash' });
  collection.createIndex({ status: 1, purge_after: 1, next_purge_attempt_at: 1, purge_lease_until: 1 },
    { name: 'idx_material_purge_due' });
  db.material_audit_outbox.createIndex({ delivered: 1, created_at: 1 }, { name: 'idx_material_audit_pending' });
})();
