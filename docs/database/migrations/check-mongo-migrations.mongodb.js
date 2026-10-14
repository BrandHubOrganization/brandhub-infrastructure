// MongoDB VS Code Playground / mongosh: READ ONLY, safe to run repeatedly.
// Run this WHOLE file on the intended Atlas connection. No load(), APPLY flags or init.
// Always checks brandhub, even when the Playground initially selected test.
// This verifies CURRENT schema effects, not historical execution (there is no migration ledger).
(() => {
  const initialDatabase = db.getName();
  const target = db.getSiblingDB('brandhub');
  const string = { bsonType: 'string' };
  const date = { bsonType: 'date' };
  const nullableString = { bsonType: ['string', 'null'] };
  const taskStatuses = ['BACKLOG', 'DETAIL_IDENTIFIED', 'ASSIGNED', 'IN_PROGRESS',
    'QC_REVIEW', 'MANAGER_REVIEW', 'CLIENT_REVIEW', 'COMPLETED'];
  const baseTaskProperties = {
    workspaceId: string, campaignId: nullableString, type: { enum: ['POST', 'LIVESTREAM', 'SURVEY'] },
    name: string, dueDate: date, status: { enum: taskStatuses }, assigneeId: nullableString,
    qcAssigneeId: nullableString, requiresClientApproval: { bsonType: 'bool' },
    description: nullableString, typeMetadata: { bsonType: 'object' }, createdAt: date, updatedAt: date,
  };
  const taskRequired = ['workspaceId', 'type', 'name', 'status', 'requiresClientApproval',
    'typeMetadata', 'createdAt', 'updatedAt'];
  const schema = (required, properties) => ({ bsonType: 'object', required, properties });
  const index = (name, key, extra = {}) => ({ name, key, ...extra });
  const collection = (name, validator, indexes = []) => ({ name, validator, indexes });
  const specialist = schema(['taskId', 'contentVersion', 'createdAt', 'updatedAt'], {
    taskId: string, contentVersion: { bsonType: 'int', minimum: 1 }, createdAt: date, updatedAt: date,
    planContent: nullableString, referenceLinks: { bsonType: 'array' }, recommendations: { bsonType: 'array' },
  });
  const requestSchema = schema(['workspaceId', 'requestedBy', 'title', 'description', 'type', 'dueDate',
    'status', 'version', 'history', 'createdAt', 'updatedAt'], {
    workspaceId: string, requestedBy: string, title: { bsonType: 'string', minLength: 1, maxLength: 255 },
    description: { bsonType: 'string', maxLength: 10000 }, type: { enum: ['POST', 'LIVESTREAM', 'SURVEY'] },
    dueDate: date, status: { enum: ['PENDING', 'IN_PROGRESS', 'ACCEPTED', 'DENIED', 'CANCELLED'] },
    version: { bsonType: ['long', 'int', 'double', 'decimal'], minimum: 1, multipleOf: 1 },
    history: { bsonType: 'array' }, generatedTaskId: nullableString, reviewedBy: nullableString,
    reviewedAt: { bsonType: ['date', 'null'] }, createdAt: date, updatedAt: date,
  });
  const migrationSpecs = [
    { file: '2026-09-26-create-generic-tasks-collection.js', collections: [
      collection('tasks', schema(taskRequired, baseTaskProperties), [
        index('idx_tasks_workspace_status', { workspaceId: 1, status: 1 }),
        index('idx_tasks_workspace_assignee', { workspaceId: 1, assigneeId: 1 }),
        index('idx_tasks_workspace_type', { workspaceId: 1, type: 1 }),
        index('idx_tasks_workspace_campaign', { workspaceId: 1, campaignId: 1 }),
      ]),
    ] },
    { file: '2026-09-27-create-task-approvals-collection.js', collections: [
      collection('tasks', schema([...taskRequired, 'approvalRound'], {
        ...baseTaskProperties, approvalRound: { bsonType: 'int', minimum: 0 },
      })),
      collection('task_approvals', schema(['taskId', 'approvalRound', 'step', 'action', 'actorId', 'createdAt'], {
        taskId: string, approvalRound: { bsonType: 'int', minimum: 1 }, step: { enum: ['QC', 'MANAGER', 'CLIENT'] },
        action: { enum: ['APPROVE', 'REJECT'] }, actorId: string, comment: nullableString, createdAt: date,
      }), [index('idx_task_approvals_task_round_step_created', { taskId: 1, approvalRound: 1, step: 1, createdAt: 1 })]),
    ] },
    { file: '2026-10-02-create-workspace-chat-collections.js', collections: [
      collection('chat_messages', schema(['workspaceId', 'senderMemberId', 'senderUserId', 'senderRole',
        'senderDisplayName', 'content', 'contextType', 'clientMessageId', 'createdAt'], {
        workspaceId: string, senderMemberId: string, senderUserId: string,
        senderRole: { enum: ['MANAGER', 'CREATOR', 'CLIENT'] }, senderDisplayName: string,
        content: { bsonType: 'string', minLength: 1, maxLength: 4000 },
        contextType: { enum: ['GENERAL', 'MEDIA_PACKAGE', 'MEDIA_CAMPAIGN'] }, contextId: nullableString,
        clientMessageId: string, createdAt: date,
      }), [
        index('idx_chat_messages_workspace_created', { workspaceId: 1, createdAt: -1, _id: -1 }),
        index('uq_chat_messages_client_message', { workspaceId: 1, senderUserId: 1, clientMessageId: 1 }, { unique: true }),
        index('idx_chat_messages_workspace_context', { workspaceId: 1, contextType: 1, contextId: 1, createdAt: -1 }),
      ]),
      collection('chat_read_states', schema(['workspaceId', 'userId', 'lastReadMessageId', 'lastReadAt'], {
        workspaceId: string, userId: string, lastReadMessageId: string, lastReadAt: date,
      }), [index('uq_chat_read_states_workspace_user', { workspaceId: 1, userId: 1 }, { unique: true })]),
    ] },
    { file: '2026-10-04-create-post-versions-collection.js', collections: [
      collection('post_versions', schema(['_id', 'post_id', 'version', 'content_hash', 'captured_at'], {
        _id: string, post_id: string, version: { bsonType: ['long', 'int'], minimum: 1 },
        workspace_id: nullableString, created_by: nullableString, content_text: nullableString,
        hashtags: { bsonType: 'array' }, media: { bsonType: 'array' }, target_platforms: { bsonType: 'array' },
        content_hash: { bsonType: 'string', minLength: 64, maxLength: 64 }, captured_at: date,
      }), [index('post_versions_post_version', { post_id: 1, version: -1 })]),
    ] },
    { file: '2026-10-09-campaign-task-deployment.js', collections: [
      collection('tasks', schema([...taskRequired, 'approvalRound'], {
        ...baseTaskProperties, dueDate: { bsonType: ['date', 'null'] },
        type: { enum: ['POST', 'LIVESTREAM', 'SURVEY', 'EVENT_PLAN', 'PRESS_RECOMMENDATION'] },
        approvalRound: { bsonType: 'int', minimum: 1 }, campaignWorkItemId: nullableString,
        sourceType: nullableString, sourceRefId: nullableString, createdBy: nullableString,
      }), [index('uq_tasks_campaign_work_item', { campaignId: 1, campaignWorkItemId: 1 }, {
        unique: true, partialFilterExpression: { campaignId: { $type: 'string' }, campaignWorkItemId: { $type: 'string' } },
      })]),
      collection('event_plans', specialist, [index('uq_event_plans_task', { taskId: 1 }, { unique: true })]),
      collection('press_recommendations', specialist, [index('uq_press_recommendations_task', { taskId: 1 }, { unique: true })]),
    ] },
    { file: '2026-10-13-content-requests-v2.js', collections: [collection('content_requests', requestSchema, [
      index('idx_content_requests_v2_workspace_status', { workspaceId: 1, status: 1, createdAt: -1 }),
      index('idx_content_requests_v2_requester', { workspaceId: 1, requestedBy: 1 }),
      index('idx_content_requests_v2_workspace_created', { workspaceId: 1, createdAt: -1, _id: -1 }),
    ])] },
    { file: '2026-10-13-content-request-acceptance.js', collections: [
      collection('content_requests', schema(requestSchema.required, {
        ...requestSchema.properties, decisionNote: { bsonType: ['string', 'null'], maxLength: 2000 },
        decidedBy: nullableString, decidedAt: { bsonType: ['date', 'null'] },
      }), [index('idx_content_requests_v2_workspace_created', { workspaceId: 1, createdAt: -1, _id: -1 })]),
      collection('tasks', schema([...taskRequired, 'approvalRound'], {
        ...baseTaskProperties, sourceType: nullableString, sourceRefId: nullableString,
        approvalRound: { bsonType: 'int', minimum: 1 },
      }), [index('uq_tasks_campaign_work_item', { campaignId: 1, campaignWorkItemId: 1 }, {
        unique: true, partialFilterExpression: { campaignId: { $type: 'string' }, campaignWorkItemId: { $type: 'string' } },
      }), index('uq_tasks_content_request_source', { sourceType: 1, sourceRefId: 1 }, {
        unique: true, partialFilterExpression: { sourceType: 'CONTENT_REQUEST', sourceRefId: { $type: 'string' } },
      })]),
    ] },
  ];

  migrationSpecs.push({ file: '2026-10-14-campaign-closure.js', collections: [
    collection('tasks', schema([...taskRequired, 'approvalRound'], {
      status: { enum: [...taskStatuses, 'CANCELLED'] },
      cancellation: schema(['actorId', 'at', 'reasonCode', 'previousStatus'], {
        actorId: string, at: date, previousStatus: string,
        reasonCode: { enum: ['CLIENT_NO_LONGER_NEEDS', 'MUTUAL_AGREEMENT', 'DUPLICATE_OR_REPLACED', 'NO_LONGER_SUITABLE', 'OTHER'] },
        note: { bsonType: ['string', 'null'], maxLength: 2000 },
      }),
    })),
  ] });

  const asArray = value => Array.isArray(value) ? value : [value];
  const canonical = value => JSON.stringify(sortObject(value));
  function sortObject(value) {
    if (Array.isArray(value)) return value.map(sortObject);
    if (value && typeof value === 'object') return Object.fromEntries(
      Object.keys(value).sort().map(key => [key, sortObject(value[key])]));
    return value;
  }
  // Later migrations extend enums/types/required fields and may tighten numeric bounds.
  // Accept those extensions for earlier migrations; do not require obsolete schema equality.
  function compareSchema(expected, actual, path, problems) {
    if (!actual || typeof actual !== 'object') { problems.push(path + ': missing schema'); return; }
    for (const [key, wanted] of Object.entries(expected)) {
      const found = actual[key];
      if (['required', 'enum', 'bsonType'].includes(key)) {
        if (!asArray(wanted).every(value => asArray(found).includes(value)))
          problems.push(path + '.' + key + ': missing expected values');
      } else if (key === 'properties') {
        for (const [field, definition] of Object.entries(wanted))
          compareSchema(definition, actual.properties?.[field], path + '.properties.' + field, problems);
      } else if (['minimum', 'minLength'].includes(key)) {
        if (typeof found !== 'number' || found < wanted) problems.push(path + '.' + key + ': absent/weaker bound');
      } else if (['maximum', 'maxLength'].includes(key)) {
        if (typeof found !== 'number' || found > wanted) problems.push(path + '.' + key + ': absent/weaker bound');
      } else if (canonical(wanted) !== canonical(found)) problems.push(path + '.' + key + ': differs');
    }
  }
  function compareIndex(expected, indexes, problems) {
    const actual = indexes.find(item => item.name === expected.name);
    if (!actual) { problems.push('index ' + expected.name + ': missing'); return; }
    // Compound key order is significant; partial-filter object field order is not.
    if (JSON.stringify(Object.entries(actual.key)) !== JSON.stringify(Object.entries(expected.key)))
      problems.push('index ' + expected.name + ': keys/order differ');
    if (!!actual.unique !== !!expected.unique) problems.push('index ' + expected.name + ': unique differs');
    if (canonical(actual.partialFilterExpression) !== canonical(expected.partialFilterExpression))
      problems.push('index ' + expected.name + ': partialFilterExpression differs');
    if (actual.sparse || actual.hidden || actual.expireAfterSeconds !== undefined || actual.collation)
      problems.push('index ' + expected.name + ': unexpected sparse/hidden/TTL/collation; review');
  }
  const metadata = new Map();
  function inspect(expected) {
    try {
      if (!metadata.has(expected.name)) {
        const info = target.getCollectionInfos({ name: expected.name })[0];
        metadata.set(expected.name, { info, indexes: info ? target.getCollection(expected.name).getIndexes() : [] });
      }
      const { info, indexes } = metadata.get(expected.name);
      if (!info) return { collection: expected.name, status: 'MISSING', problems: ['collection missing'] };
      const problems = [];
      if ((info.options?.validationLevel ?? 'strict') !== 'strict') problems.push('validationLevel is not strict');
      if ((info.options?.validationAction ?? 'error') !== 'error') problems.push('validationAction is not error');
      compareSchema(expected.validator, info.options?.validator?.$jsonSchema, 'validator.$jsonSchema', problems);
      expected.indexes.forEach(wanted => compareIndex(wanted, indexes, problems));
      return { collection: expected.name, status: problems.length ? 'DRIFT' : 'MATCH', problems,
        indexNames: indexes.map(item => item.name) };
    } catch (failure) {
      return { collection: expected.name, status: 'UNKNOWN', problems: [
        'Cannot read metadata; verify selected connection and listCollections/listIndexes permissions.'
      ], errorCode: typeof failure.code === 'number' ? failure.code : null };
    }
  }
  const results = migrationSpecs.map(spec => {
    const checks = spec.collections.map(inspect);
    const status = ['UNKNOWN', 'MISSING', 'DRIFT'].find(value => checks.some(check => check.status === value)) ?? 'MATCH';
    return { migration: spec.file, status, checks };
  });
  const matches = file => results.find(result => result.migration === file)?.status === 'MATCH';
  const report = {
    database: target.getName(), initialDatabase, mode: 'READ_ONLY', checkedAt: new Date().toISOString(),
    summary: Object.fromEntries(['MATCH', 'MISSING', 'DRIFT', 'UNKNOWN'].map(status =>
      [status, results.filter(result => result.status === status).length])),
    schemaChecks: {
      contentRequestV2: matches('2026-10-13-content-requests-v2.js'),
      contentRequestAcceptance: matches('2026-10-13-content-requests-v2.js')
        && matches('2026-10-13-content-request-acceptance.js'),
      campaignDeployment: matches('2026-09-26-create-generic-tasks-collection.js')
        && matches('2026-09-27-create-task-approvals-collection.js')
        && matches('2026-10-09-campaign-task-deployment.js'),
    },
    results,
    excludedReadOnlyUtility: '2026-10-09-campaign-task-preflight.js (no persisted migration effect)',
    notes: [
      'MATCH means current metadata matches expected effects, NOT proof that the migration was executed.',
      'No documents are read or validated; no permission/transaction/API readiness guarantee.',
      'Do not blindly rerun old migrations: they can overwrite newer validators.',
      'If Request V2 is missing, review/apply it BEFORE acceptance, never phase 2 after phase 3.',
      'No create/update/delete/collMod/createIndex/init operations were performed.',
    ],
  };
  // Return the report so VS Code Playground displays it (no trailing undefined).
  return report;
})();
