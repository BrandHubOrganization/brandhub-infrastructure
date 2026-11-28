// Metadata only; Playground accepts globalThis.BRANDHUB_CHAT_CALLS_APPLY = true.
(() => {
  const target = db.getSiblingDB('brandhub');
  const apply = globalThis.BRANDHUB_CHAT_CALLS_APPLY === true
    || (typeof process !== 'undefined' && process.env?.BRANDHUB_CHAT_CALLS_APPLY === 'true');
  const names = new Set(target.getCollectionNames());
  if (!names.has('chat_channels')) throw new Error('Apply chat collaboration first; no writes performed.');
  const validator = { $and: [
    { $jsonSchema: {
      bsonType: 'object',
      required: ['_id', 'workspaceId', 'channelId', 'callerId', 'calleeId', 'participantIds',
        'state', 'revision', 'createdAt', 'updatedAt', 'expiresAt'],
      additionalProperties: false,
      properties: {
        _id: { bsonType: 'string' }, _class: { bsonType: 'string' },
        workspaceId: { bsonType: 'string' }, channelId: { bsonType: 'string' },
        callerId: { bsonType: 'string' }, calleeId: { bsonType: 'string' },
        participantIds: { bsonType: 'array', minItems: 2, maxItems: 2, uniqueItems: true, items: { bsonType: 'string' } },
        activeParticipantIds: { bsonType: 'array', minItems: 2, maxItems: 2, uniqueItems: true, items: { bsonType: 'string' } },
        state: { enum: ['RINGING', 'CONNECTING', 'ACTIVE', 'DECLINED', 'CANCELLED', 'MISSED', 'ENDED', 'FAILED'] },
        revision: { bsonType: ['int', 'long'], minimum: 0 },
        createdAt: { bsonType: 'date' }, updatedAt: { bsonType: 'date' }, expiresAt: { bsonType: 'date' },
        acceptedAt: { bsonType: ['date', 'null'] }, connectedAt: { bsonType: ['date', 'null'] },
        callerHeartbeatAt: { bsonType: ['date', 'null'] }, calleeHeartbeatAt: { bsonType: ['date', 'null'] },
        connectedParticipantIds: { bsonType: 'array', maxItems: 2, uniqueItems: true, items: { bsonType: 'string' } },
        endedAt: { bsonType: ['date', 'null'] }, endedBy: { bsonType: ['string', 'null'] },
        endReason: { bsonType: ['string', 'null'], maxLength: 200 },
      },
    } },
    { $expr: { $and: [
      { $ne: ['$callerId', '$calleeId'] },
      { $setEquals: [{ $cond: [{ $isArray: '$participantIds' }, '$participantIds', []] }, ['$callerId', '$calleeId']] },
      { $cond: [
        { $in: ['$state', ['RINGING', 'CONNECTING', 'ACTIVE']] },
        { $setEquals: [
          { $cond: [{ $isArray: '$activeParticipantIds' }, '$activeParticipantIds', []] },
          { $cond: [{ $isArray: '$participantIds' }, '$participantIds', []] },
        ] },
        { $eq: [{ $type: '$activeParticipantIds' }, 'missing'] },
      ] },
    ] } },
  ] };
  const indexes = [
    [{ activeParticipantIds: 1 }, { name: 'uq_chat_calls_active_participant', unique: true,
      partialFilterExpression: { activeParticipantIds: { $type: 'array' } } }],
    [{ workspaceId: 1, channelId: 1, createdAt: -1, _id: -1 }, { name: 'idx_chat_calls_history' }],
    [{ state: 1, expiresAt: 1 }, { name: 'idx_chat_calls_expiry' }],
  ];
  const exists = names.has('chat_calls');
  const invalid = exists ? target.chat_calls.countDocuments({ $nor: [validator] }) : 0;
  const duplicates = exists ? target.chat_calls.aggregate([
    { $unwind: '$activeParticipantIds' },
    { $group: { _id: '$activeParticipantIds', count: { $sum: 1 } } },
    { $match: { count: { $gt: 1 } } }, { $limit: 1 },
  ]).toArray().length : 0;
  const conflicts = [];
  if (exists) for (const [key, options] of indexes) {
    for (const index of target.chat_calls.getIndexes()) {
      const sameKey = JSON.stringify(index.key) === JSON.stringify(key);
      if (index.name !== options.name && !sameKey) continue;
      if (!sameKey || index.name !== options.name || !!index.unique !== !!options.unique
          || !!index.sparse || !!index.hidden || index.collation
          || JSON.stringify(index.partialFilterExpression) !== JSON.stringify(options.partialFilterExpression)) {
        conflicts.push(index.name);
      }
    }
  }
  const blocked = invalid > 0 || duplicates > 0 || conflicts.length > 0;
  print(JSON.stringify({ migration: 'chat-voice-calls-2026-10-23', database: target.getName(),
    mode: apply ? 'APPLY' : 'DRY_RUN', blocked, invalid, duplicates, conflicts, backfill: false }));
  if (!apply) return;
  if (blocked) throw new Error('Call metadata preflight blocked; no writes performed.');
  if (!exists) target.createCollection('chat_calls', { validator, validationLevel: 'strict', validationAction: 'error' });
  else if (target.runCommand({ collMod: 'chat_calls', validator, validationLevel: 'strict', validationAction: 'error' }).ok !== 1) {
    throw new Error('Could not update chat_calls validator.');
  }
  for (const [key, options] of indexes) target.chat_calls.createIndex(key, options);
  print('Call metadata ready. No calls, invitations or history were seeded.');
})();
