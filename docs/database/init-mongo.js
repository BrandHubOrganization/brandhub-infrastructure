// BrandHub — MongoDB initialization script
// For a fresh local MongoDB volume only (docker-entrypoint-initdb.d/init-mongo.js).
// Do NOT run this file against existing MongoDB Atlas data. Apply the ordered
// scripts in docs/database/migrations instead; see mongo-atlas-migrations.md.
// Includes Task approval foundation metadata through 2026-10-18 (no snapshots/backfill).
// Task workflow foundation is schema only; application implementation/legacy review are separate.

db = db.getSiblingDB('brandhub');

// ============================================================
// COLLECTIONS WITH SCHEMA VALIDATION
// ============================================================

// users
db.createCollection('users', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['email', 'full_name', 'role', 'status', 'is_active', 'created_at', 'updated_at'],
      properties: {
        email:        { bsonType: 'string' },
        full_name:    { bsonType: 'string' },
        role:         { enum: ['ADMIN', 'AGENCY_OWNER', 'ACCOUNT_MANAGER', 'CONTENT_CREATOR', 'BRAND_CLIENT'] },
        status:       { enum: ['ACTIVE', 'SUSPENDED', 'DELETED'] },
        is_active:    { bsonType: 'bool' },
        created_at:   { bsonType: 'date' },
        updated_at:   { bsonType: 'date' },
      },
    },
  },
  validationAction: 'warn',
});

// workspaces
db.createCollection('workspaces', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['name', 'slug', 'owner_id', 'plan', 'is_active', 'created_at', 'updated_at'],
      properties: {
        name:      { bsonType: 'string' },
        slug:      { bsonType: 'string' },
        owner_id:  { bsonType: 'string' },
        plan:      { enum: ['FREE', 'BASIC', 'PRO', 'ENTERPRISE'] },
        is_active: { bsonType: 'bool' },
      },
    },
  },
  validationAction: 'warn',
});

// workspace_members
db.createCollection('workspace_members', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['workspace_id', 'user_id', 'role', 'is_active', 'created_at', 'updated_at'],
      properties: {
        workspace_id: { bsonType: 'string' },
        user_id:      { bsonType: 'string' },
        role:         { enum: ['OWNER', 'MANAGER', 'CREATOR', 'CLIENT'] },
        is_active:    { bsonType: 'bool' },
      },
    },
  },
  validationAction: 'warn',
});

// clients
db.createCollection('clients', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['workspace_id', 'name', 'portal_access_enabled', 'created_at', 'updated_at'],
      properties: {
        workspace_id:           { bsonType: 'string' },
        name:                   { bsonType: 'string' },
        portal_access_enabled:  { bsonType: 'bool' },
      },
    },
  },
  validationAction: 'warn',
});

// social_accounts
db.createCollection('social_accounts', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['workspace_id', 'platform', 'account_name', 'account_id', 'encrypted_token', 'encrypted_iv', 'token_expires_at', 'token_status', 'is_active', 'created_at', 'updated_at'],
      properties: {
        workspace_id:   { bsonType: 'string' },
        platform:       { enum: ['FACEBOOK', 'INSTAGRAM', 'TIKTOK', 'THREADS', 'ZALO_OA'] },
        account_name:   { bsonType: 'string' },
        account_id:     { bsonType: 'string' },
        encrypted_token:{ bsonType: 'string' },
        encrypted_iv:   { bsonType: 'string' },
        token_status:   { enum: ['ACTIVE', 'EXPIRING_SOON', 'EXPIRED', 'REVOKED'] },
        is_active:      { bsonType: 'bool' },
      },
    },
  },
  validationAction: 'warn',
});

// posts
db.createCollection('posts', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['workspace_id', 'created_by', 'content_text', 'platform', 'status', 'ai_generated', 'created_at', 'updated_at'],
      properties: {
        workspace_id:  { bsonType: 'string' },
        task_id:       { bsonType: ['string', 'null'], minLength: 1 },
        created_by:    { bsonType: 'string' },
        content_text:  { bsonType: 'string' },
        platform:      { enum: ['FACEBOOK', 'INSTAGRAM', 'TIKTOK', 'THREADS', 'ZALO_OA'] },
        status:        { enum: ['DRAFT', 'PENDING_APPROVAL', 'APPROVED', 'REJECTED', 'SCHEDULED', 'PUBLISHING', 'PUBLISHED', 'FAILED', 'CANCELLED'] },
        ai_generated:  { bsonType: 'bool' },
      },
    },
  },
  validationAction: 'warn',
});

// content_requests
db.createCollection('content_requests', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['workspaceId', 'requestedBy', 'title', 'description', 'type', 'dueDate',
        'status', 'version', 'history', 'createdAt', 'updatedAt'],
      properties: {
        workspaceId: { bsonType: 'string' }, requestedBy: { bsonType: 'string' },
        title: { bsonType: 'string', minLength: 1, maxLength: 255 },
        description: { bsonType: 'string', maxLength: 10000 },
        type: { enum: ['POST', 'LIVESTREAM', 'SURVEY'] }, dueDate: { bsonType: 'date' },
        status: { enum: ['PENDING', 'IN_PROGRESS', 'ACCEPTED', 'DENIED', 'CANCELLED'] },
        version: { bsonType: ['long', 'int', 'double', 'decimal'], minimum: 1, multipleOf: 1 },
        history: { bsonType: 'array' }, generatedTaskId: { bsonType: ['string', 'null'] },
        reviewedBy: { bsonType: ['string', 'null'] }, reviewedAt: { bsonType: ['date', 'null'] },
        decisionNote: { bsonType: ['string', 'null'], maxLength: 2000 },
        decidedBy: { bsonType: ['string', 'null'] }, decidedAt: { bsonType: ['date', 'null'] },
        createdAt: { bsonType: 'date' }, updatedAt: { bsonType: 'date' },
      },
    },
  },
  validationAction: 'error',
  validationLevel: 'strict',
});

// Optional Task workflow fields and private comment collections (DA-978/DA-1236).
const taskWorkflowFoundation = (() => {
  const string = { bsonType: 'string' };
  const date = { bsonType: 'date' };
  const nullableString = { bsonType: ['string', 'null'] };
  const nullableDate = { bsonType: ['date', 'null'] };
  const schema = (required, properties) => ({ bsonType: 'object', required, properties });
  const index = (name, key, extra = {}) => ({ name, key, ...extra });
  const taskProperties = {
    workflowRevision: { bsonType: ['long', 'int'], minimum: 0 },
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
      eventType: { enum: ['TASK_ASSIGNED', 'TASK_COMMENTED', 'TASK_REVIEW_REQUESTED', 'TASK_REVIEW_REJECTED', 'TASK_POST_SUBMITTED'] },
      approvalRound: { bsonType: 'int', minimum: 1 },
      reviewStep: { bsonType: ['string', 'null'], enum: ['MANAGER', 'CLIENT', null] },
      decisionId: nullableString,
      postId: { ...nullableString, minLength: 1 },
      postContentVersion: { bsonType: ['long', 'int'], minimum: 1 },
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
  return { taskProperties, additions };
})();

// tasks (V2) — one generic collection for all supported Task types.
// New accepted Content Request Tasks link to the current Campaign; manual/legacy Tasks may have campaignId = null.
db.createCollection('tasks', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: [
        'workspaceId', 'type', 'name', 'status', 'requiresClientApproval',
        'approvalRound', 'typeMetadata', 'createdAt', 'updatedAt',
      ],
      properties: {
        workspaceId:            { bsonType: 'string' },
        campaignId:             { bsonType: ['string', 'null'] },
        campaignWorkItemId:     { bsonType: ['string', 'null'] },
        type:                   { enum: ['POST', 'LIVESTREAM', 'SURVEY', 'EVENT_PLAN', 'PRESS_RECOMMENDATION'] },
        name:                   { bsonType: 'string' },
        dueDate:                { bsonType: ['date', 'null'] },
        // Legacy states accepted for compatibility; new writers/API use five canonical states.
        status:                 { enum: ['BACKLOG', 'DETAIL_IDENTIFIED', 'ASSIGNED', 'IN_PROGRESS', 'QC_REVIEW', 'MANAGER_REVIEW', 'CLIENT_REVIEW', 'COMPLETED', 'CANCELLED', 'TODO', 'IN_REVIEW', 'FINISHED'] },
        reviewStep: { bsonType: ['string', 'null'], enum: ['QC', 'MANAGER', 'CLIENT', null] },
        assigneeId:             { bsonType: ['string', 'null'] },
        // Historical compatibility only; new workflow does not assign QC.
        qcAssigneeId:           { bsonType: ['string', 'null'] },
        requiresClientApproval: { bsonType: 'bool' },
        description:            { bsonType: ['string', 'null'] },
        approvalRound:          { bsonType: 'int', minimum: 1 },
        // Latest submission metadata only; not a content snapshot or review-round collection.
        lastSubmission: {
          bsonType: ['object', 'null'], required: ['round', 'submittedBy', 'submittedAt'],
          properties: {
            round: { bsonType: 'int', minimum: 1 }, submittedBy: { bsonType: 'string' },
            submittedAt: { bsonType: 'date' }, closedBy: { bsonType: ['string', 'null'] },
            closedAt: { bsonType: ['date', 'null'] },
            outcome: { enum: ['APPROVED', 'REJECTED', 'WITHDRAWN', 'CANCELLED', null] },
          },
        },
        typeMetadata:           { bsonType: 'object' },
        sourceType:             { bsonType: ['string', 'null'] },
        sourceRefId:            { bsonType: ['string', 'null'] },
        createdBy:              { bsonType: ['string', 'null'] },
        ...taskWorkflowFoundation.taskProperties,
        cancellation: {
          bsonType: 'object', required: ['actorId', 'at', 'reasonCode', 'previousStatus'],
          properties: {
            actorId: { bsonType: 'string' }, at: { bsonType: 'date' },
            reasonCode: { enum: ['CLIENT_NO_LONGER_NEEDS', 'MUTUAL_AGREEMENT', 'DUPLICATE_OR_REPLACED', 'NO_LONGER_SUITABLE', 'OTHER'] },
            note: { bsonType: ['string', 'null'], maxLength: 2000 }, previousStatus: { bsonType: 'string' },
          },
        },
        createdAt:              { bsonType: 'date' },
        updatedAt:              { bsonType: 'date' },
      },
    },
  },
  validationAction: 'error',
});

// New private Task collections. No public URLs and no upload TTL.
for (const addition of taskWorkflowFoundation.additions.filter(item => item.name !== 'tasks')) {
  db.createCollection(addition.name, {
    validator: { $jsonSchema: addition.validator }, validationLevel: 'strict', validationAction: 'error',
  });
}

// task_approvals (V2) — append-only approval events. A reject never
// overwrites earlier approvals; approvalRound identifies the submit cycle.
db.createCollection('task_approvals', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['taskId', 'approvalRound', 'step', 'action', 'actorId', 'createdAt'],
      properties: {
        taskId:        { bsonType: 'string' },
        approvalRound: { bsonType: 'int', minimum: 1 },
        step:          { enum: ['QC', 'MANAGER', 'CLIENT'] },
        action:        { enum: ['APPROVE', 'REJECT'] },
        actorId:       { bsonType: 'string' },
        comment:       { bsonType: ['string', 'null'] },
        createdAt:     { bsonType: 'date' },
      },
    },
  },
  validationAction: 'error',
});

// Specialist content for EVENT_PLAN and PRESS_RECOMMENDATION stays outside
// the generic Task identity/workflow collection.
const specialistTaskValidator = {
  $jsonSchema: {
    bsonType: 'object',
    required: ['taskId', 'contentVersion', 'createdAt', 'updatedAt'],
    properties: {
      taskId: { bsonType: 'string' },
      contentVersion: { bsonType: 'int', minimum: 1 },
      createdAt: { bsonType: 'date' },
      updatedAt: { bsonType: 'date' },
      planContent: { bsonType: ['string', 'null'] },
      referenceLinks: { bsonType: 'array' },
      recommendations: { bsonType: 'array' },
    },
  },
};
db.createCollection('event_plans', {
  validator: specialistTaskValidator, validationAction: 'error',
});
db.createCollection('press_recommendations', {
  validator: specialistTaskValidator, validationAction: 'error',
});

// Workspace chat (2026-10-02 migration).
db.createCollection('chat_messages', {
  validator: { $jsonSchema: {
    bsonType: 'object',
    required: ['workspaceId', 'senderMemberId', 'senderUserId', 'senderRole',
      'senderDisplayName', 'content', 'contextType', 'clientMessageId', 'createdAt'],
    properties: {
      workspaceId: { bsonType: 'string' }, senderMemberId: { bsonType: 'string' },
      senderUserId: { bsonType: 'string' }, senderRole: { enum: ['MANAGER', 'CREATOR', 'CLIENT'] },
      senderDisplayName: { bsonType: 'string' },
      content: { bsonType: 'string', minLength: 1, maxLength: 4000 },
      contextType: { enum: ['GENERAL', 'MEDIA_PACKAGE', 'MEDIA_CAMPAIGN'] },
      contextId: { bsonType: ['string', 'null'] }, clientMessageId: { bsonType: 'string' },
      createdAt: { bsonType: 'date' },
    },
  } }, validationLevel: 'strict', validationAction: 'error',
});
db.createCollection('chat_read_states', {
  validator: { $jsonSchema: {
    bsonType: 'object', required: ['workspaceId', 'userId', 'lastReadMessageId', 'lastReadAt'],
    properties: {
      workspaceId: { bsonType: 'string' }, userId: { bsonType: 'string' },
      lastReadMessageId: { bsonType: 'string' }, lastReadAt: { bsonType: 'date' },
    },
  } }, validationLevel: 'strict', validationAction: 'error',
});

// Immutable post snapshots for moderation (2026-10-04 migration).
db.createCollection('post_versions', {
  validator: { $jsonSchema: {
    bsonType: 'object', required: ['_id', 'post_id', 'version', 'content_hash', 'captured_at'],
    properties: {
      _id: { bsonType: 'string' }, post_id: { bsonType: 'string' },
      version: { bsonType: ['long', 'int'], minimum: 1 },
      workspace_id: { bsonType: ['string', 'null'] }, created_by: { bsonType: ['string', 'null'] },
      content_text: { bsonType: ['string', 'null'] }, hashtags: { bsonType: 'array' },
      media: { bsonType: 'array' }, target_platforms: { bsonType: 'array' },
      content_hash: { bsonType: 'string', minLength: 64, maxLength: 64 },
      captured_at: { bsonType: 'date' },
    },
  } }, validationLevel: 'strict', validationAction: 'error',
});

// Exact schema/index effects of 2026-10-12-create-mail-templates-collection.js; no Mail behavior changes.
(() => {
  const validator = {
  $jsonSchema: {
    bsonType: 'object',
    required: ['_id', 'name', 'subject', 'bodyHtml', 'type', 'createdAt', 'updatedAt'],
    properties: {
      workspaceId:  { bsonType: ['string', 'null'], description: 'null for SYSTEM_DEFAULT' },
      name:         { bsonType: 'string', minLength: 1, maxLength: 120 },
      subject:      { bsonType: 'string', minLength: 1, maxLength: 200 },
      bodyHtml:     { bsonType: 'string', minLength: 1, maxLength: 102400 },
      type:         { enum: ['SYSTEM_DEFAULT', 'CUSTOM'] },
      attachments:  {
        bsonType: 'array',
        maxItems: 3,
        items: {
          bsonType: 'object',
          required: ['attachmentId', 's3Key'],
          properties: {
            attachmentId: { bsonType: 'string' },
            name:         { bsonType: 'string' },
            contentType:  { bsonType: 'string' },
            size:         { bsonType: ['long', 'int'] },
            s3Key:        { bsonType: 'string' },
          },
        },
      },
      clonedFromId: { bsonType: ['string', 'null'] },
      createdBy:    { bsonType: ['string', 'null'] },
      createdAt:    { bsonType: 'date' },
      updatedAt:    { bsonType: 'date' },
      deletedAt:    { bsonType: ['date', 'null'] },
    },
  },
};
  db.createCollection('mail_templates', { validator, validationAction: 'error' });
db.mail_templates.createIndex(
  { workspaceId: 1, deletedAt: 1, createdAt: -1 },
  { name: 'ix_mail_templates_workspace_created' });
db.mail_templates.createIndex(
  { type: 1, deletedAt: 1 },
  { name: 'ix_mail_templates_type' });

})();

// Exact schema/index effects of 2026-10-13-create-mail-recipient-groups-collection.js; no Mail behavior changes.
(() => {
  const validator = {
  $jsonSchema: {
    bsonType: 'object',
    required: ['_id', 'workspaceId', 'name', 'recipients', 'createdAt'],
    properties: {
      workspaceId: { bsonType: 'string' },
      name:        { bsonType: 'string', minLength: 1, maxLength: 80 },
      recipients:  {
        bsonType: 'array',
        maxItems: 200,
        items: {
          bsonType: 'object',
          required: ['email'],
          properties: {
            email: { bsonType: 'string', maxLength: 255 },
            name:  { bsonType: ['string', 'null'], maxLength: 120 },
          },
        },
      },
      createdBy:   { bsonType: ['string', 'null'] },
      createdAt:   { bsonType: 'date' },
    },
  },
};
  db.createCollection('mail_recipient_groups', { validator, validationAction: 'error' });
db.mail_recipient_groups.createIndex(
  { workspaceId: 1, name: 1 },
  { name: 'ix_mail_recipient_groups_workspace_name' });

})();

// knowledge_documents (ai-service)
db.createCollection('knowledge_documents', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['workspace_id', 'title', 'content', 'created_at', 'updated_at'],
      properties: {
        workspace_id: { bsonType: 'string' },
        title:        { bsonType: 'string' },
        content:      { bsonType: 'string' },
      },
    },
  },
  validationAction: 'warn',
});

// notifications
db.createCollection('notifications', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['workspace_id', 'user_id', 'type', 'title', 'is_read', 'created_at'],
      properties: {
        workspace_id: { bsonType: 'string' },
        user_id:      { bsonType: 'string' },
        type:         { enum: ['POST_APPROVED', 'POST_REJECTED', 'POST_FAILED', 'POST_PUBLISHED', 'REPORT_READY', 'MEMBER_INVITED', 'SUBSCRIPTION_EXPIRING', 'CONTENT_REQUEST_ASSIGNED'] },
        title:        { bsonType: 'string' },
        is_read:      { bsonType: 'bool' },
      },
    },
  },
  validationAction: 'warn',
});

// publish_logs (publisher-service)
db.createCollection('publish_logs', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['workspace_id', 'post_id', 'platform', 'result', 'retry_count', 'created_at'],
      properties: {
        workspace_id: { bsonType: 'string' },
        post_id:      { bsonType: 'string' },
        platform:     { enum: ['FACEBOOK', 'INSTAGRAM', 'TIKTOK', 'THREADS', 'ZALO_OA'] },
        result:       { enum: ['SUCCESS', 'FAILED', 'RETRYING'] },
        retry_count:  { bsonType: 'int' },
      },
    },
  },
  validationAction: 'warn',
});

// ai_usage_logs (ai-service)
db.createCollection('ai_usage_logs', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['workspace_id', 'feature', 'model', 'success', 'created_at'],
      properties: {
        workspace_id: { bsonType: 'string' },
        feature:      { bsonType: 'string' },
        model:        { bsonType: 'string' },
        success:      { bsonType: 'bool' },
      },
    },
  },
  validationAction: 'warn',
});

// report_jobs
db.createCollection('report_jobs', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['workspace_id', 'requested_by', 'status', 'date_from', 'date_to', 'created_at', 'updated_at'],
      properties: {
        workspace_id:  { bsonType: 'string' },
        requested_by:  { bsonType: 'string' },
        status:        { enum: ['PENDING', 'RUNNING', 'DONE', 'FAILED'] },
      },
    },
  },
  validationAction: 'warn',
});

// ============================================================
// INDEXES
// ============================================================

// users
db.users.createIndex({ email: 1 }, { unique: true, name: 'idx_users_email_unique' });
db.users.createIndex({ workspace_id: 1 }, { name: 'idx_users_workspace_id' });
db.users.createIndex({ role: 1 }, { name: 'idx_users_role' });

// workspaces
db.workspaces.createIndex({ slug: 1 }, { unique: true, name: 'idx_workspaces_slug_unique' });
db.workspaces.createIndex({ owner_id: 1 }, { name: 'idx_workspaces_owner_id' });

// workspace_members
db.workspace_members.createIndex(
  { workspace_id: 1, user_id: 1 },
  { unique: true, name: 'idx_workspace_members_ws_user_unique' }
);
db.workspace_members.createIndex({ workspace_id: 1 }, { name: 'idx_workspace_members_workspace_id' });

// clients
db.clients.createIndex({ workspace_id: 1 }, { name: 'idx_clients_workspace_id' });

// social_accounts
db.social_accounts.createIndex({ workspace_id: 1 }, { name: 'idx_social_accounts_workspace_id' });
db.social_accounts.createIndex(
  { workspace_id: 1, platform: 1, account_id: 1 },
  { unique: true, name: 'idx_social_accounts_ws_platform_account_unique' }
);
db.social_accounts.createIndex(
  { workspace_id: 1, token_status: 1 },
  { name: 'idx_social_accounts_ws_token_status' }
);
db.social_accounts.createIndex(
  { token_expires_at: 1 },
  { name: 'idx_social_accounts_token_expires_at' }
);

// posts
db.posts.createIndex({ workspace_id: 1, status: 1 }, { name: 'idx_posts_ws_status' });
db.posts.createIndex({ workspace_id: 1, scheduled_at: 1 }, { name: 'idx_posts_ws_scheduled_at' });
db.posts.createIndex({ workspace_id: 1, client_id: 1 }, { name: 'idx_posts_ws_client_id' });
db.posts.createIndex({ task_id: 1 }, { name: 'uq_posts_task', unique: true,
  partialFilterExpression: { task_id: { $type: 'string' } } });

// content_requests
db.content_requests.createIndex({ workspaceId: 1, status: 1, createdAt: -1 }, { name: 'idx_content_requests_v2_workspace_status' });
db.content_requests.createIndex({ workspaceId: 1, requestedBy: 1 }, { name: 'idx_content_requests_v2_requester' });
db.content_requests.createIndex({ workspaceId: 1, createdAt: -1, _id: -1 }, { name: 'idx_content_requests_v2_workspace_created' });

// tasks (V2) — every access is scoped by workspaceId.
db.tasks.createIndex({ workspaceId: 1, status: 1 }, { name: 'idx_tasks_workspace_status' });
db.tasks.createIndex({ workspaceId: 1, assigneeId: 1 }, { name: 'idx_tasks_workspace_assignee' });
db.tasks.createIndex({ workspaceId: 1, type: 1 }, { name: 'idx_tasks_workspace_type' });
db.tasks.createIndex({ workspaceId: 1, campaignId: 1 }, { name: 'idx_tasks_workspace_campaign' });
db.tasks.createIndex({ campaignId: 1, campaignWorkItemId: 1 }, {
  name: 'uq_tasks_campaign_work_item', unique: true,
  partialFilterExpression: {
    campaignId: { $type: 'string' }, campaignWorkItemId: { $type: 'string' },
  },
});

// tasks (V2) — one Task per accepted Content Request, independent of Campaign sources.
db.tasks.createIndex({ sourceType: 1, sourceRefId: 1 }, {
  name: 'uq_tasks_content_request_source', unique: true,
  partialFilterExpression: { sourceType: 'CONTENT_REQUEST', sourceRefId: { $type: 'string' } },
});

// Optional workflow list and private comment/upload/outbox indexes.
for (const addition of taskWorkflowFoundation.additions) {
  for (const { key, ...options } of addition.indexes) db.getCollection(addition.name).createIndex(key, options);
}

// task_approvals (V2) — supports latest action per step in the active round.
db.task_approvals.createIndex(
  { taskId: 1, approvalRound: 1, step: 1, createdAt: 1 },
  { name: 'idx_task_approvals_task_round_step_created' }
);
db.task_approvals.createIndex({ taskId: 1, approvalRound: 1, step: 1 },
  { name: 'uq_task_approvals_round_step', unique: true });
db.task_approvals.createIndex({ taskId: 1, createdAt: -1, _id: -1 },
  { name: 'idx_task_approvals_timeline' });
db.event_plans.createIndex({ taskId: 1 }, { name: 'uq_event_plans_task', unique: true });
db.press_recommendations.createIndex({ taskId: 1 }, { name: 'uq_press_recommendations_task', unique: true });

db.chat_messages.createIndex({ workspaceId: 1, createdAt: -1, _id: -1 },
  { name: 'idx_chat_messages_workspace_created' });
db.chat_messages.createIndex({ workspaceId: 1, senderUserId: 1, clientMessageId: 1 },
  { name: 'uq_chat_messages_client_message', unique: true });
db.chat_messages.createIndex({ workspaceId: 1, contextType: 1, contextId: 1, createdAt: -1 },
  { name: 'idx_chat_messages_workspace_context' });
db.chat_read_states.createIndex({ workspaceId: 1, userId: 1 },
  { name: 'uq_chat_read_states_workspace_user', unique: true });

// Workspace collaboration: null channelId retains the original General history.
db.createCollection('chat_channels', { validator: { $jsonSchema: {
  bsonType: 'object',
  required: ['_id', 'workspaceId', 'name', 'type', 'createdBy', 'creationKey', 'memberUserIds', 'createdAt'],
  properties: {
    _id: { bsonType: 'string' }, workspaceId: { bsonType: 'string' },
    name: { bsonType: 'string', minLength: 1, maxLength: 80 },
    description: { bsonType: ['string', 'null'], maxLength: 500 },
    type: { enum: ['PUBLIC', 'PRIVATE', 'DIRECT'] },
    createdBy: { bsonType: 'string' }, creationKey: { bsonType: 'string' },
    memberUserIds: { bsonType: 'array', maxItems: 100, uniqueItems: true, items: { bsonType: 'string' } },
    archived: { bsonType: 'bool' }, managersOnly: { bsonType: 'bool' }, createdAt: { bsonType: 'date' },
  },
} }, validationLevel: 'strict', validationAction: 'error' });
db.createCollection('chat_channel_reads', { validator: { $jsonSchema: {
  bsonType: 'object', required: ['_id', 'workspaceId', 'channelId', 'userId', 'lastReadAt', 'lastReadMessageId'],
  properties: {
    _id: { bsonType: 'string' }, workspaceId: { bsonType: 'string' }, channelId: { bsonType: 'string' },
    userId: { bsonType: 'string' }, lastReadAt: { bsonType: 'date' }, lastReadMessageId: { bsonType: 'string' },
  },
} }, validationLevel: 'strict', validationAction: 'error' });
db.chat_messages.createIndex({ workspaceId: 1, channelId: 1, threadRootId: 1, createdAt: -1, _id: -1 },
  { name: 'idx_chat_channel_thread_history' });
db.chat_messages.createIndex({ workspaceId: 1, channelId: 1, pinned: 1, createdAt: -1, _id: -1 },
  { name: 'idx_chat_channel_pins' });
db.chat_channels.createIndex({ workspaceId: 1, memberUserIds: 1, createdAt: 1, _id: 1 },
  { name: 'idx_chat_channels_members' });
db.chat_channels.createIndex({ workspaceId: 1, type: 1, createdAt: 1, _id: 1 },
  { name: 'idx_chat_channels_visibility' });
db.chat_channels.createIndex({ workspaceId: 1, nameKey: 1 },
  { name: 'uq_chat_channel_name', unique: true, partialFilterExpression: { nameKey: { $type: 'string' } } });
// Chat mentions/inbox: pending delivery intents live in the message's atomic insert.
db.createCollection('chat_notification_preferences', { validator: { $jsonSchema: {
  bsonType: 'object', required: ['_id', 'workspaceId', 'userId'],
  properties: {
    _id: { bsonType: 'string' }, workspaceId: { bsonType: 'string' }, userId: { bsonType: 'string' },
    dnd: { bsonType: 'bool' },
    mutedChannelIds: { bsonType: 'array', uniqueItems: true, items: { bsonType: 'string' } },
  },
} }, validationLevel: 'strict', validationAction: 'error' });
db.chat_notification_preferences.createIndex({ workspaceId: 1, userId: 1 },
  { name: 'uq_chat_notification_preferences_user', unique: true });
db.chat_messages.createIndex({ notificationAvailableAt: 1, _id: 1 },
  { name: 'idx_chat_notification_pending', partialFilterExpression: { notificationAvailableAt: { $type: 'date' } } });

db.post_versions.createIndex({ post_id: 1, version: -1 }, { name: 'post_versions_post_version' });

// knowledge_documents
db.knowledge_documents.createIndex({ workspace_id: 1 }, { name: 'idx_knowledge_docs_workspace_id' });
db.knowledge_documents.createIndex({ workspace_id: 1, client_id: 1 }, { name: 'idx_knowledge_docs_ws_client_id' });

// notifications — TTL 30 days
db.notifications.createIndex({ user_id: 1, is_read: 1 }, { name: 'idx_notifications_user_read' });
db.notifications.createIndex({ workspace_id: 1, user_id: 1 }, { name: 'idx_notifications_ws_user' });
db.notifications.createIndex(
  { created_at: 1 },
  { expireAfterSeconds: 2592000, name: 'idx_notifications_ttl_30d' }
);

// publish_logs
db.publish_logs.createIndex({ post_id: 1 }, { name: 'idx_publish_logs_post_id' });
db.publish_logs.createIndex({ workspace_id: 1, result: 1 }, { name: 'idx_publish_logs_ws_result' });

// ai_usage_logs
db.ai_usage_logs.createIndex({ workspace_id: 1, feature: 1 }, { name: 'idx_ai_usage_workspace_feature' });
db.ai_usage_logs.createIndex({ created_at: -1 }, { name: 'idx_ai_usage_created_at' });

// report_jobs
db.report_jobs.createIndex({ workspace_id: 1, status: 1 }, { name: 'idx_report_jobs_ws_status' });

// Voice-call metadata only; signaling/media are not enabled by initialization.
db.createCollection('chat_calls', { validator: { $and: [
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
] }, validationLevel: 'strict', validationAction: 'error' });
db.chat_calls.createIndex({ activeParticipantIds: 1 }, { name: 'uq_chat_calls_active_participant', unique: true,
  partialFilterExpression: { activeParticipantIds: { $type: 'array' } } });
db.chat_calls.createIndex({ workspaceId: 1, channelId: 1, createdAt: -1, _id: -1 }, { name: 'idx_chat_calls_history' });
db.chat_calls.createIndex({ state: 1, expiresAt: 1 }, { name: 'idx_chat_calls_expiry' });

print('BrandHub MongoDB initialized: collections and indexes created.');
