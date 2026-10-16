// DA-978 / DA-1236: optional Task workflow fields + private comments/uploads/outbox.
// MongoDB VS Code Playground / mongosh. Always targets brandhub, NOT test.
// DEFAULT DRY_RUN. Backup and freeze writers before setting:
// globalThis.TASK_WORKFLOW_FOUNDATION_APPLY = true;
// Run AFTER 2026-10-14-campaign-closure.js. No document inserts/updates/deletes/backfill.
// New fields stay optional for existing writers. Missing legacy start evidence
// MUST NOT be interpreted as not-started. All active Workspace members may read/comment Tasks.
(() => {
  const target = db.getSiblingDB('brandhub');
  const apply = globalThis.TASK_WORKFLOW_FOUNDATION_APPLY === true;
  const string = { bsonType: 'string' };
  const date = { bsonType: 'date' };
  const nullableString = { bsonType: ['string', 'null'] };
  const nullableDate = { bsonType: ['date', 'null'] };
  const schema = (required, properties) => ({ bsonType: 'object', required, properties });
  const index = (name, key, extra = {}) => ({ name, key, ...extra });

  // BEGIN FOUNDATION DEFINITIONS: duplicated intentionally in init/checker, guarded by parity tests.
  const taskProperties = {
    workflowRevision: { bsonType: ['long', 'int'], minimum: 0 },
    plannedPublishAt: nullableDate,
    inputReferences: { bsonType: 'array', maxItems: 20, items: schema(['label', 'url'], {
      label: { bsonType: 'string', minLength: 1, maxLength: 200 },
      url: { bsonType: 'string', minLength: 1, maxLength: 2048, pattern: '^https?://' },
    }) },
    detailIdentifiedAt: nullableDate, detailIdentifiedBy: nullableString,
    assignedAt: nullableDate, assignedBy: nullableString,
    firstStartedAt: nullableDate, firstStartedBy: nullableString,
  };
  const additions = [
    { name: 'tasks', properties: taskProperties, indexes: [
      index('idx_tasks_workspace_workflow_created', { workspaceId: 1, createdAt: -1, _id: -1 }),
    ] },
    { name: 'task_comments', validator: schema(['_id', 'workspaceId', 'taskId', 'authorId',
      'authorRole', 'authorDisplayName', 'content', 'mentions', 'attachmentIds', 'clientRequestId', 'createdAt'], {
      _id: string, workspaceId: string, taskId: string, authorId: string,
      authorRole: { enum: ['MANAGER', 'CREATOR', 'CLIENT'] }, authorDisplayName: string,
      content: { bsonType: 'string', minLength: 1, maxLength: 10000 },
      mentions: { bsonType: 'array', uniqueItems: true, items: string },
      attachmentIds: { bsonType: 'array', maxItems: 5, uniqueItems: true, items: string },
      clientRequestId: string, createdAt: date,
    }), indexes: [
      index('idx_task_comments_timeline', { workspaceId: 1, taskId: 1, createdAt: -1, _id: -1 }),
      index('uq_task_comments_client_request', { workspaceId: 1, taskId: 1, authorId: 1, clientRequestId: 1 }, { unique: true }),
    ] },
    { name: 'task_comment_uploads', validator: schema(['_id', 'workspaceId', 'taskId', 'uploadedBy',
      'storageKey', 'contentType', 'byteSize', 'state', 'createdAt', 'expiresAt'], {
      _id: string, workspaceId: string, taskId: string, uploadedBy: string, storageKey: string,
      originalName: { bsonType: 'string', maxLength: 255 },
      contentType: { enum: ['image/jpeg', 'image/png', 'image/webp'] },
      byteSize: { bsonType: ['long', 'int'], minimum: 1, maximum: 5242880 },
      state: { enum: ['DRAFT', 'ATTACHED', 'CLEANUP_PENDING'] },
      commentId: nullableString, attachedAt: nullableDate, leaseUntil: nullableDate,
      createdAt: date, expiresAt: date,
    }), indexes: [
      index('uq_task_comment_uploads_storage_key', { storageKey: 1 }, { unique: true }),
      index('idx_task_comment_uploads_owner', { workspaceId: 1, taskId: 1, uploadedBy: 1, state: 1 }),
      index('idx_task_comment_uploads_cleanup', { state: 1, expiresAt: 1 }),
    ] },
    { name: 'task_notification_outbox', validator: schema(['_id', 'eventKey', 'workspaceId', 'taskId',
      'actorId', 'recipientId', 'eventType', 'payload', 'status', 'attempts', 'availableAt', 'createdAt', 'updatedAt'], {
      _id: string, eventKey: string, workspaceId: string, taskId: string, actorId: string, recipientId: string,
      eventType: { enum: ['TASK_ASSIGNED', 'TASK_COMMENTED'] },
      payload: schema(['title', 'content', 'actionUrl'], {
        title: { bsonType: 'string', maxLength: 200 }, content: { bsonType: 'string', maxLength: 5000 },
        actionUrl: { bsonType: 'string', maxLength: 500 },
      }),
      status: { enum: ['PENDING', 'LEASED', 'SENT', 'SUPPRESSED'] },
      attempts: { bsonType: ['long', 'int'], minimum: 0 },
      availableAt: date, createdAt: date, updatedAt: date,
      leaseOwner: nullableString, leaseUntil: nullableDate, deliveredAt: nullableDate,
    }), indexes: [
      index('uq_task_notification_outbox_event', { eventKey: 1 }, { unique: true }),
      index('idx_task_notification_outbox_due', { status: 1, availableAt: 1 }),
      index('idx_task_notification_outbox_lease', { status: 1, leaseUntil: 1 }),
    ] },
  ];
  // END FOUNDATION DEFINITIONS

  function sorted(value) {
    if (Array.isArray(value)) return value.map(sorted);
    if (value && typeof value === 'object') return Object.fromEntries(
      Object.keys(value).sort().map(key => [key, sorted(value[key])]));
    return value;
  }
  const canonical = value => JSON.stringify(sorted(value));
  const sameKeys = (left, right) => JSON.stringify(Object.entries(left)) === JSON.stringify(Object.entries(right));
  function indexMatches(actual, expected) {
    return sameKeys(actual.key, expected.key) && !!actual.unique === !!expected.unique
      && canonical(actual.partialFilterExpression) === canonical(expected.partialFilterExpression)
      && !actual.sparse && !actual.hidden && actual.expireAfterSeconds === undefined && !actual.collation;
  }
  const taskInfo = target.getCollectionInfos({ name: 'tasks' })[0];
  const base = taskInfo?.options?.validator?.$jsonSchema;
  if (!base || !Array.isArray(base.properties?.type?.enum)
      || !base.properties.type.enum.includes('EVENT_PLAN')
      || !base.properties.type.enum.includes('PRESS_RECOMMENDATION')
      || !Array.isArray(base.properties?.status?.enum)
      || !base.properties.status.enum.includes('CANCELLED') || !base.properties.cancellation)
    throw new Error('Task V2/Campaign closure foundation missing; no writes performed.');
  const requiredIndexes = [
    index('uq_tasks_campaign_work_item', { campaignId: 1, campaignWorkItemId: 1 }, {
      unique: true, partialFilterExpression: { campaignId: { $type: 'string' }, campaignWorkItemId: { $type: 'string' } },
    }),
    index('uq_tasks_content_request_source', { sourceType: 1, sourceRefId: 1 }, {
      unique: true, partialFilterExpression: { sourceType: 'CONTENT_REQUEST', sourceRefId: { $type: 'string' } },
    }),
  ];
  const taskIndexes = target.getCollection('tasks').getIndexes();
  if (!requiredIndexes.every(expected => taskIndexes.some(actual => actual.name === expected.name && indexMatches(actual, expected))))
    throw new Error('Campaign deployment/Request acceptance indexes missing or incompatible; no writes performed.');

  // Preflight ALL collections before the first DDL operation. No destructive conflict repair.
  const plans = additions.map(addition => {
    const info = target.getCollectionInfos({ name: addition.name })[0];
    const current = info?.options?.validator;
    if (info && (!current?.$jsonSchema || current.$jsonSchema.bsonType !== 'object'
        || (info.options.validationLevel ?? 'strict') !== 'strict'
        || (info.options.validationAction ?? 'error') !== 'error'
        || info.options.capped || info.options.collation || info.options.timeseries || info.type === 'view'))
      throw new Error(addition.name + ': incompatible validator/options; no writes performed.');
    const existingSchema = current?.$jsonSchema;
    const expected = addition.validator ?? schema([], addition.properties);
    for (const [field, definition] of Object.entries(expected.properties)) {
      if (existingSchema?.properties?.[field] && canonical(existingSchema.properties[field]) !== canonical(definition))
        throw new Error(addition.name + ': incompatible field ' + field + '; review instead of overwriting. No writes performed.');
    }
    const merged = existingSchema ? {
      ...existingSchema,
      required: [...new Set([...(existingSchema.required ?? []), ...(expected.required ?? [])])],
      properties: { ...existingSchema.properties, ...expected.properties },
    } : expected;
    const validator = { ...current, $jsonSchema: merged };
    const indexes = info ? target.getCollection(addition.name).getIndexes() : [];
    for (const expectedIndex of addition.indexes) {
      const named = indexes.find(actual => actual.name === expectedIndex.name);
      const sameKey = indexes.find(actual => sameKeys(actual.key, expectedIndex.key));
      if ((named && !indexMatches(named, expectedIndex)) || (sameKey && sameKey.name !== expectedIndex.name))
        throw new Error(addition.name + ': index conflict ' + expectedIndex.name + '; no writes performed.');
    }
    const invalidDocuments = info ? target.getCollection(addition.name).countDocuments({ $nor: [validator] }) : 0;
    const duplicateGroups = addition.indexes.filter(item => item.unique).map(expectedIndex => {
      if (!info) return 0;
      const keys = Object.fromEntries(Object.keys(expectedIndex.key).map(key => [key, '$' + key]));
      const counts = target.getCollection(addition.name).aggregate([
        { $group: { _id: keys, count: { $sum: 1 } } }, { $match: { count: { $gt: 1 } } }, { $count: 'groups' },
      ]).toArray();
      return counts[0]?.groups ?? 0;
    });
    return { ...addition, exists: !!info, validator, invalidDocuments, duplicateGroups };
  });
  const blocked = plans.some(plan => plan.invalidDocuments > 0 || plan.duplicateGroups.some(count => count > 0));
  const report = { database: target.getName(), mode: apply ? 'APPLY' : 'DRY_RUN', blocked,
    collections: plans.map(plan => ({ name: plan.name, exists: plan.exists, invalidDocuments: plan.invalidDocuments,
      duplicateGroups: plan.duplicateGroups, indexes: plan.indexes.map(item => item.name) })),
    note: 'No document backfill. Legacy missing first-start evidence requires review before workflow mutations; read/comment uses Workspace membership.' };
  print(JSON.stringify(report));
  if (!apply) return report;
  if (blocked) throw new Error('Foundation preflight blocked by invalid documents/duplicates; no writes performed.');
  // Mongo DDL is NOT a multi-collection transaction. On operational failure keep feature disabled,
  // inspect metadata and safely rerun; do not drop collections/indexes to "repair" automatically.
  for (const plan of plans) {
    const options = { validator: plan.validator, validationLevel: 'strict', validationAction: 'error' };
    const result = plan.exists ? target.runCommand({ collMod: plan.name, ...options })
      : target.createCollection(plan.name, options);
    if (result?.ok !== undefined && result.ok !== 1)
      throw new Error('Foundation DDL failed; inspect partial metadata and keep feature disabled.');
    for (const { key, ...options } of plan.indexes) target.getCollection(plan.name).createIndex(key, options);
  }
  return { ...report, applied: true };
})();
