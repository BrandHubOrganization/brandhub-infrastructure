// Additive metadata only. Run DRY_RUN before APPLY; no historical message backfill.
(() => {
  const target = db.getSiblingDB('brandhub');
  // Playground: set globalThis.BRANDHUB_CHAT_MENTION_APPLY = true before this script.
  const apply = globalThis.BRANDHUB_CHAT_MENTION_APPLY === true
    || (typeof process !== 'undefined' && process.env?.BRANDHUB_CHAT_MENTION_APPLY === 'true');
  const names = new Set(target.getCollectionNames());
  if (!names.has('chat_messages') || !names.has('chat_channels')) {
    throw new Error('Apply workspace chat baseline and collaboration migrations first; no writes performed.');
  }
  const validator = { $jsonSchema: {
    bsonType: 'object', required: ['_id', 'workspaceId', 'userId'],
    properties: {
      _id: { bsonType: 'string' }, workspaceId: { bsonType: 'string' }, userId: { bsonType: 'string' },
      dnd: { bsonType: 'bool' },
      mutedChannelIds: { bsonType: 'array', uniqueItems: true, items: { bsonType: 'string' } },
    },
  } };
  const exists = names.has('chat_notification_preferences');
  const invalid = exists ? target.chat_notification_preferences.countDocuments({ $nor: [validator] }) : 0;
  const duplicates = exists ? target.chat_notification_preferences.aggregate([
    { $group: { _id: { workspace: '$workspaceId', user: '$userId' }, count: { $sum: 1 } } },
    { $match: { count: { $gt: 1 } } }, { $limit: 1 },
  ]).toArray().length : 0;
  const indexes = [
    ['chat_notification_preferences', { workspaceId: 1, userId: 1 },
      { name: 'uq_chat_notification_preferences_user', unique: true }],
    ['chat_messages', { notificationAvailableAt: 1, _id: 1 },
      { name: 'idx_chat_notification_pending',
        partialFilterExpression: { notificationAvailableAt: { $type: 'date' } } }],
  ];
  const conflicts = [];
  for (const [collection, key, options] of indexes) {
    if (!names.has(collection)) continue;
    for (const index of target.getCollection(collection).getIndexes()) {
      const sameKey = JSON.stringify(index.key) === JSON.stringify(key);
      if (index.name !== options.name && !sameKey) continue;
      if (!sameKey || index.name !== options.name || !!index.unique !== !!options.unique
          || !!index.sparse || !!index.hidden || index.collation
          || JSON.stringify(index.partialFilterExpression) !== JSON.stringify(options.partialFilterExpression)) {
        conflicts.push({ collection, name: index.name });
      }
    }
  }
  print(JSON.stringify({ migration: 'chat-mention-inbox-2026-10-23', mode: apply ? 'APPLY' : 'DRY_RUN',
    database: target.getName(), blocked: invalid > 0 || duplicates > 0 || conflicts.length > 0,
    invalid, duplicateIdentities: duplicates, indexConflicts: conflicts,
    backfill: false }));
  if (!apply) return;
  if (invalid || duplicates || conflicts.length) throw new Error('Invalid/duplicate preferences or indexes; no writes performed.');
  if (!exists) target.createCollection('chat_notification_preferences',
    { validator, validationLevel: 'strict', validationAction: 'error' });
  else {
    const result = target.runCommand({ collMod: 'chat_notification_preferences', validator,
      validationLevel: 'strict', validationAction: 'error' });
    if (result.ok !== 1) throw new Error('Could not update preferences validator.');
  }
  for (const [collection, key, options] of indexes) target.getCollection(collection).createIndex(key, options);
  print('Chat notification metadata ready; no messages or preferences backfilled.');
})();
