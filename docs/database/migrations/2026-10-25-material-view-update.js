// Operational indexes only; no TTL, provider migration, audience backfill, or data deletion.
(() => {
  if (db.getName() !== 'brandhub') throw new Error('Select brandhub explicitly');
  const apply = globalThis.MATERIAL_VIEW_UPDATE_APPLY === true;
  const indexes = [
    { name: 'idx_material_active_page', key: { workspace_id: 1, deleted_at: 1, status: 1, created_at: -1, _id: -1 } },
    { name: 'idx_material_client_page', key: { workspace_id: 1, visibility: 1, client_profile_id: 1, deleted_at: 1, status: 1, created_at: -1, _id: -1 } },
    { name: 'idx_material_name_prefix', key: { workspace_id: 1, deleted_at: 1, normalized_name: 1, created_at: -1, _id: -1 } },
    { name: 'idx_material_parent_scope', key: { workspace_id: 1, parent_material_id: 1, status: 1 } }
  ];
  const existing = db.materials.getIndexes();
  for (const index of existing) {
    if (index.expireAfterSeconds !== undefined && (index.key.deleted_at || index.key.purge_after)) {
      throw new Error('Unsafe retention TTL requires manual review');
    }
  }
  for (const index of indexes) {
    const current = existing.find(row => row.name === index.name);
    if (current && JSON.stringify(current.key) !== JSON.stringify(index.key)) throw new Error('Conflicting index: ' + index.name);
  }
  printjson({ mode: apply ? 'APPLY' : 'DRY_RUN', indexes, legacyInventory: 'Verify normalized_name and private object identities separately' });
  if (apply) for (const { key, name } of indexes) db.materials.createIndex(key, { name });
})();
