// Video Space indexes only. Default is read-only; no document backfill or deletion.
// Set globalThis.VIDEO_PROJECT_INDEXES_APPLY = true after reviewing the target.
(() => {
  const target = db.getSiblingDB('brandhub');
  const apply = globalThis.VIDEO_PROJECT_INDEXES_APPLY === true;
  const definitions = [
    { collection: 'video_projects', name: 'idx_video_projects_owner_list',
      key: { workspaceId: 1, ownerId: 1, revision: 1, updatedAt: -1, _id: -1 } },
    { collection: 'video_project_assets', name: 'idx_video_project_assets_scope',
      key: { workspaceId: 1, ownerId: 1, projectId: 1, state: 1 } },
    { collection: 'video_project_assets', name: 'idx_video_project_assets_usage',
      key: { workspaceId: 1, state: 1 } },
    { collection: 'video_project_upload_sessions', name: 'idx_video_project_upload_sessions_scope',
      key: { workspaceId: 1, ownerId: 1, projectId: 1, assetId: 1 } },
  ];
  const report = definitions.map(definition => {
    const exists = target.getCollectionInfos({ name: definition.collection }).length > 0;
    const current = exists ? target.getCollection(definition.collection).getIndexes() : [];
    const named = current.find(index => index.name === definition.name);
    const matches = named && JSON.stringify(named.key) === JSON.stringify(definition.key);
    if (named && !matches) throw new Error('Index differs; inspect before changing: ' + definition.name);
    return { ...definition, status: matches ? 'MATCH' : 'MISSING' };
  });
  print(JSON.stringify({ database: target.getName(), mode: apply ? 'APPLY' : 'DRY_RUN', indexes: report }));
  if (!apply) return;
  for (const definition of definitions) {
    target.getCollection(definition.collection).createIndex(definition.key, { name: definition.name });
  }
  print('Video Space indexes are ready. No documents were modified.');
})();
