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
        status:        { enum: ['DRAFT', 'PENDING_APPROVAL', 'APPROVED', 'REJECTED', 'SCHEDULED', 'IN_PROGRESS', 'PUBLISHING', 'PUBLISHED', 'FAILED', 'CANCELLED'] },
        scheduled_at:  { bsonType: ['date', 'null'] },
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
    // Per-section state of role-split task editors (DA-1274). Missing document = virtual DRAFT.
    { name: 'task_sections', validator: schema(['_id', 'workspaceId', 'taskId', 'sectionKey', 'visibility',
      'status', 'revision', 'updatedAt'], {
      _id: string, workspaceId: string, taskId: string, sectionKey: { bsonType: 'string', maxLength: 64 },
      visibility: { enum: ['OUTPUT', 'INTERNAL'] },
      status: { enum: ['DRAFT', 'SUBMITTED', 'INTERNAL_APPROVED', 'CLIENT_APPROVED', 'RETURNED'] },
      revision: { bsonType: ['long', 'int'], minimum: 0 },
      content: { bsonType: ['object', 'null'] },
      returnNote: { bsonType: ['string', 'null'], maxLength: 2000 }, returnedBy: nullableString,
      lastEditorRole: nullableString, clientPendingSince: nullableDate, clientReminderSentAt: nullableDate,
      updatedAt: date,
    }), indexes: [
      index('uq_task_sections_task_key', { taskId: 1, sectionKey: 1 }, { unique: true }),
      index('idx_task_sections_workspace_status', { workspaceId: 1, status: 1 }),
      index('idx_task_sections_client_pending', { status: 1, clientPendingSince: 1 }),
    ] },
    // Immutable snapshot per section submit (§16.12); never deleted.
    { name: 'task_section_versions', validator: schema(['_id', 'workspaceId', 'taskId', 'sectionKey',
      'versionNo', 'submittedBy', 'submittedAt'], {
      _id: string, workspaceId: string, taskId: string, sectionKey: string,
      versionNo: { bsonType: ['long', 'int'], minimum: 1 },
      content: { bsonType: ['object', 'null'] }, submittedBy: string, submittedAt: date,
    }), indexes: [
      index('uq_task_section_versions_no', { taskId: 1, sectionKey: 1, versionNo: 1 }, { unique: true }),
    ] },
    // Section audit log: submit/approve/return/reopen/restore (§16.12); never deleted.
    { name: 'task_section_events', validator: schema(['_id', 'workspaceId', 'taskId', 'sectionKey',
      'action', 'actorId', 'at'], {
      _id: string, workspaceId: string, taskId: string, sectionKey: string,
      action: { enum: ['SUBMIT', 'APPROVE', 'CLIENT_APPROVE', 'RETURN', 'CLIENT_RETURN', 'REOPEN', 'RESTORE'] },
      actorId: string, note: { bsonType: ['string', 'null'], maxLength: 2000 }, at: date,
    }), indexes: [
      index('idx_task_section_events_timeline', { taskId: 1, at: 1 }),
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
        type:                   { enum: ['POST', 'LIVESTREAM', 'SURVEY', 'EVENT_PLAN', 'PRESS_RECOMMENDATION',
                                         'SHORT_VIDEO', 'KOL_BOOKING', 'WORKSHOP', 'EMAIL_NEWSLETTER'] },
        name:                   { bsonType: 'string' },
        dueDate:                { bsonType: ['date', 'null'] },
        plannedStartDate:       { bsonType: ['date', 'null'] },
        subtasks: { bsonType: 'array', items: { bsonType: 'object', properties: {
          plannedStartDate: { bsonType: ['date', 'null'] },
          // Catalogue role (DA-1274); null = free or legacy subtask.
          subtaskRole: { bsonType: ['string', 'null'] },
          description: { bsonType: ['string', 'null'] },
          acceptanceCriteria: { bsonType: ['string', 'null'] },
        } } },
        publishDate:            { bsonType: ['date', 'null'] },
        status:                 { enum: ['TODO', 'IN_PROGRESS', 'IN_REVIEW', 'FINISHED', 'CANCELLED'] },
        reviewStep: { bsonType: ['string', 'null'], enum: ['MANAGER', 'CLIENT', null] },
        assigneeId:             { bsonType: ['string', 'null'] },
        supervisorId:           { bsonType: ['string', 'null'] },
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
        partnerIds:             { bsonType: ['array', 'null'], items: { bsonType: 'string' } },
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
      richContent: { bsonType: ['object', 'null'], properties: {
        type: { enum: ['doc'] }, content: { bsonType: 'array', maxItems: 500 },
      } },
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

// Exact schema/index effects of 2026-10-12-create-mail-templates-collection.js + 2026-10-28-mail-template-scope.js.
(() => {
  const validator = {
  $jsonSchema: {
    bsonType: 'object',
    required: ['_id', 'name', 'subject', 'type', 'createdAt', 'updatedAt'],
    properties: {
      workspaceId:  { bsonType: ['string', 'null'], description: 'null for SYSTEM_DEFAULT' },
      name:         { bsonType: 'string', minLength: 1, maxLength: 120 },
      subject:      { bsonType: 'string', minLength: 1, maxLength: 200 },
      bodyHtml:     { bsonType: 'string', maxLength: 102400, description: 'Render-cache từ layoutJson (Addendum B); có thể rỗng tới khi save lần đầu' },
      type:         { enum: ['SYSTEM_DEFAULT', 'CUSTOM'] },
      scope:        {
        enum: [
          'CAMPAIGN_BROADCAST',
          'ADMIN_SYSTEM_BROADCAST',
          'AGENCY_INTERNAL',
          'WORKSPACE_MANAGER',
          'AGENCY_CLIENT',
          'TRANSACTIONAL_AUTO',
        ],
        description: 'Addendum B: thay type nhị phân cũ',
      },
      agencyId:     { bsonType: ['string', 'null'], description: 'Addendum B: set cho AGENCY_INTERNAL/AGENCY_CLIENT' },
      layoutJson:   { bsonType: ['string', 'null'], description: 'Addendum B: danh sách block JSON, nguồn thật của nội dung' },
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
  db.createCollection('mail_templates', { validator, validationLevel: 'strict', validationAction: 'error' });
  db.mail_templates.createIndex(
    { workspaceId: 1, deletedAt: 1, createdAt: -1 },
    { name: 'ix_mail_templates_workspace_created' });
  db.mail_templates.createIndex(
    { type: 1, deletedAt: 1 },
    { name: 'ix_mail_templates_type' });
  db.mail_templates.createIndex(
    { scope: 1, workspaceId: 1 },
    { name: 'ix_mail_templates_scope_workspace' });
  db.mail_templates.createIndex(
    { scope: 1, agencyId: 1 },
    { name: 'ix_mail_templates_scope_agency' });
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
db.tasks.createIndex({ partnerIds: 1 }, {
  name: 'idx_tasks_partner_ids',
  partialFilterExpression: { partnerIds: { $type: 'array' } },
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

// Scheduled messages: metadata only. Delivery requires a replica set/Atlas.
(() => {
  // BEGIN CHAT SCHEDULE CONTRACT (mirrored in fresh init)
  const chatScheduleUuid = '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$';
  const chatScheduleValidator = { $and: [
    { $jsonSchema: { bsonType: 'object', required: ['workspaceId', 'channelId', 'senderUserId',
      'clientMessageId', 'requestHash', 'deliveryMessageId', 'content', 'mentionUserIds',
      'contextType', 'scheduledAt', 'timeZone', 'status', 'revision', 'attempts',
      'availableAt', 'createdAt', 'updatedAt'], properties: {
      _id: { bsonType: 'objectId' },
      workspaceId: { bsonType: 'string', pattern: chatScheduleUuid },
      senderUserId: { bsonType: 'string', pattern: chatScheduleUuid },
      channelId: { bsonType: 'string', minLength: 1, maxLength: 100 },
      clientMessageId: { bsonType: 'string', pattern: chatScheduleUuid },
      deliveryMessageId: { bsonType: 'string', pattern: chatScheduleUuid },
      requestHash: { bsonType: 'string', pattern: '^[0-9a-f]{64}$' },
      content: { bsonType: 'string', minLength: 1, maxLength: 4000 },
      richContent: { bsonType: ['object', 'null'], properties: {
        type: { enum: ['doc'] }, content: { bsonType: 'array', maxItems: 500 } } },
      mentionUserIds: { bsonType: 'array', uniqueItems: true, maxItems: 20,
        items: { bsonType: 'string', pattern: chatScheduleUuid } },
      contextType: { enum: ['GENERAL', 'MEDIA_PACKAGE', 'MEDIA_CAMPAIGN'] },
      contextId: { bsonType: ['string', 'null'], pattern: chatScheduleUuid },
      threadRootId: { bsonType: ['string', 'null'], pattern: '^[0-9a-f]{24}$' },
      scheduledAt: { bsonType: 'date' }, availableAt: { bsonType: 'date' },
      timeZone: { bsonType: 'string', minLength: 1, maxLength: 64 },
      status: { enum: ['PENDING', 'SENDING', 'SENT', 'FAILED', 'CANCELLED'] },
      revision: { bsonType: ['int', 'long'], minimum: 0 },
      attempts: { bsonType: ['int', 'long'], minimum: 0 },
      leaseOwner: { bsonType: 'string', pattern: chatScheduleUuid },
      leaseUntil: { bsonType: 'date' },
      createdAt: { bsonType: 'date' }, updatedAt: { bsonType: 'date' },
      sentAt: { bsonType: 'date' }, cancelledAt: { bsonType: 'date' },
      sentMessageId: { bsonType: 'string', pattern: '^[0-9a-f]{24}$' },
      errorCode: { bsonType: 'string', minLength: 1, maxLength: 100 },
      broadcastPending: { bsonType: 'bool' },
    } } },
    { $or: [
      { status: 'SENDING', leaseOwner: { $type: 'string' }, leaseUntil: { $type: 'date' } },
      { status: 'PENDING', leaseOwner: { $exists: false }, leaseUntil: { $exists: false } },
      { status: 'FAILED', errorCode: { $type: 'string' }, leaseOwner: { $exists: false }, leaseUntil: { $exists: false } },
      { status: 'CANCELLED', cancelledAt: { $type: 'date' }, leaseOwner: { $exists: false }, leaseUntil: { $exists: false } },
      { status: 'SENT', sentAt: { $type: 'date' }, sentMessageId: { $type: 'string' },
        leaseOwner: { $exists: false }, leaseUntil: { $exists: false } },
    ] },
  ] };
  const chatScheduleIndexes = [
    { key: { workspaceId: 1, senderUserId: 1, clientMessageId: 1 }, name: 'uq_chat_schedule_request', unique: true },
    { key: { workspaceId: 1, senderUserId: 1, scheduledAt: 1, _id: 1 }, name: 'idx_chat_schedule_own' },
    { key: { status: 1, availableAt: 1, _id: 1 }, name: 'idx_chat_schedule_due' },
    { key: { status: 1, leaseUntil: 1 }, name: 'idx_chat_schedule_lease' },
    { key: { status: 1, broadcastPending: 1, updatedAt: 1, _id: 1 }, name: 'idx_chat_schedule_broadcast' },
  ];
  // END CHAT SCHEDULE CONTRACT
  db.createCollection('chat_scheduled_messages', { validator: chatScheduleValidator,
    validationLevel: 'strict', validationAction: 'error' });
  for (const { key, ...options } of chatScheduleIndexes) db.chat_scheduled_messages.createIndex(key, options);
})();

// Repository / Materials foundation, trash, and view indexes (2026-10-24..2026-10-25).
(() => {
  const materialSchema = {
    bsonType: 'object',
    required: ['workspace_id', 'status', 'storage_provider', 'visibility', 'purpose', 'media_kind', 'created_by', 'version'],
    properties: {
      workspace_id:     { bsonType: 'string' },
      status:           { enum: ['UPLOADING', 'VALIDATING', 'READY', 'REJECTED', 'FAILED', 'DELETED', 'PURGE_IN_PROGRESS', 'PURGED'] },
      storage_provider: { enum: ['SYSTEM_GDRIVE', 'SYSTEM_S3', 'USER_GDRIVE'] },
      visibility:       { enum: ['INTERNAL', 'CLIENT'] },
      purpose:          { enum: ['MATERIAL', 'BRAND_REFERENCE'] },
      media_kind:       { enum: ['IMAGE', 'VIDEO', 'FILE'] },
      created_by:       { bsonType: 'string' },
      version:          { bsonType: ['long', 'int'], minimum: 0 },
    },
  };
  db.createCollection('materials', {
    validator: { $or: [{ status: { $exists: false } }, { $jsonSchema: materialSchema }] },
    validationLevel: 'moderate',
    validationAction: 'error',
  });
  db.materials.createIndex(
    { workspace_id: 1, status: 1, deleted_at: 1, created_at: -1, _id: -1 },
    { name: 'idx_repository_scope_ready' }
  );
  db.materials.createIndex(
    { storage_provider: 1, s3_key: 1 },
    {
      name: 'uq_repository_provider_key',
      unique: true,
      partialFilterExpression: { storage_provider: { $type: 'string' }, s3_key: { $type: 'string' } },
    }
  );
  db.materials.createIndex(
    { workspace_id: 1, status: 1, deleted_at: -1, _id: -1 },
    { name: 'idx_material_trash' }
  );
  db.materials.createIndex(
    { status: 1, purge_after: 1, next_purge_attempt_at: 1, purge_lease_until: 1 },
    { name: 'idx_material_purge_due' }
  );
  db.materials.createIndex(
    { workspace_id: 1, deleted_at: 1, status: 1, created_at: -1, _id: -1 },
    { name: 'idx_material_active_page' }
  );
  db.materials.createIndex(
    { workspace_id: 1, visibility: 1, client_profile_id: 1, deleted_at: 1, status: 1, created_at: -1, _id: -1 },
    { name: 'idx_material_client_page' }
  );
  db.materials.createIndex(
    { workspace_id: 1, deleted_at: 1, normalized_name: 1, created_at: -1, _id: -1 },
    { name: 'idx_material_name_prefix' }
  );
  db.materials.createIndex(
    { workspace_id: 1, parent_material_id: 1, status: 1 },
    { name: 'idx_material_parent_scope' }
  );

  db.createCollection('material_upload_sessions');
  db.material_upload_sessions.createIndex(
    { workspace_id: 1, staging_key: 1 },
    { name: 'uq_repository_session_key', unique: true }
  );
  db.material_upload_sessions.createIndex(
    { state: 1, expires_at: 1 },
    { name: 'idx_repository_session_recovery' }
  );

  db.createCollection('material_references');
  db.material_references.createIndex(
    { workspace_id: 1, material_id: 1, source_id: 1 },
    { name: 'uq_repository_reference', unique: true }
  );

  db.createCollection('material_audit_outbox');
  db.material_audit_outbox.createIndex(
    { delivered: 1, created_at: 1 },
    { name: 'idx_material_audit_pending' }
  );
})();

// Monitoring collections (servers, collectors, enrollments, health_targets).
(() => {
  const uuidPattern = '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$';
  db.createCollection('monitoring_servers', {
    validator: {
      $jsonSchema: {
        bsonType: 'object',
        required: ['_id', 'name', 'ipAddress', 'environment', 'deployedServices', 'agentTokenHash', 'createdAt', 'updatedAt'],
        properties: {
          _id:              { bsonType: 'string', pattern: uuidPattern },
          name:             { bsonType: 'string', minLength: 1 },
          ipAddress:        { bsonType: 'string', minLength: 1 },
          environment:      { bsonType: 'string', minLength: 1 },
          deployedServices: { bsonType: 'array', items: { bsonType: 'string' } },
          agentTokenHash:   { bsonType: 'string', minLength: 1 },
          cpuPercent:       { bsonType: ['decimal', 'double', 'null'] },
          ramPercent:       { bsonType: ['decimal', 'double', 'null'] },
          diskPercent:      { bsonType: ['decimal', 'double', 'null'] },
          uptimeSeconds:    { bsonType: ['long', 'int', 'null'] },
          lastSeenAt:       { bsonType: ['date', 'null'] },
          createdAt:        { bsonType: 'date' },
          updatedAt:        { bsonType: 'date' },
        },
      },
    },
    validationLevel: 'strict',
    validationAction: 'error',
  });
  db.monitoring_servers.createIndex({ name: 1, _id: 1 }, { name: 'idx_monitoring_servers_name_id' });
  db.monitoring_servers.createIndex({ environment: 1, name: 1, _id: 1 }, { name: 'idx_monitoring_servers_env_name_id' });

  db.createCollection('monitoring_collectors', {
    validator: {
      $jsonSchema: {
        bsonType: 'object',
        required: ['_id', 'name', 'tokenHash', 'createdAt', 'updatedAt'],
        properties: {
          _id:        { bsonType: 'string', pattern: uuidPattern },
          name:       { bsonType: 'string', minLength: 1 },
          serverId:   { bsonType: ['string', 'null'] },
          tokenHash:  { bsonType: 'string', minLength: 1 },
          lastSeenAt: { bsonType: ['date', 'null'] },
          createdAt:  { bsonType: 'date' },
          updatedAt:  { bsonType: 'date' },
        },
      },
    },
    validationLevel: 'strict',
    validationAction: 'error',
  });
  db.monitoring_collectors.createIndex({ serverId: 1 }, { name: 'idx_monitoring_collectors_server_id' });

  db.createCollection('monitoring_enrollments', {
    validator: {
      $jsonSchema: {
        bsonType: 'object',
        required: ['_id', 'name', 'environment', 'expiresAt'],
        properties: {
          _id:         { bsonType: 'string', pattern: '^[0-9a-f]{64}$' },
          name:        { bsonType: 'string', minLength: 1 },
          environment: { bsonType: 'string', minLength: 1 },
          expiresAt:   { bsonType: 'date' },
        },
      },
    },
    validationLevel: 'strict',
    validationAction: 'error',
  });
  db.monitoring_enrollments.createIndex({ expiresAt: 1 }, { name: 'idx_monitoring_enrollments_ttl', expireAfterSeconds: 0 });

  db.createCollection('monitoring_health_targets', {
    validator: {
      $jsonSchema: {
        bsonType: 'object',
        required: [
          '_id', 'name', 'kind', 'environment', 'collectorId', 'checkScope', 'probeType',
          'intervalSeconds', 'timeoutSeconds', 'staleAfterSeconds', 'catalogVersion', 'createdAt', 'updatedAt',
        ],
        properties: {
          _id:               { bsonType: 'string', pattern: uuidPattern },
          name:              { bsonType: 'string', minLength: 1 },
          kind:              { enum: ['SERVICE', 'CONTAINER', 'DATABASE', 'ENDPOINT'] },
          environment:       { bsonType: 'string', minLength: 1 },
          serverId:          { bsonType: ['string', 'null'] },
          serviceName:       { bsonType: ['string', 'null'] },
          instanceId:        { bsonType: ['string', 'null'] },
          collectorId:       { bsonType: 'string' },
          checkScope:        { bsonType: 'string', minLength: 1 },
          probeType:         { enum: ['HTTP', 'DOCKER', 'POSTGRESQL', 'REDIS', 'MONGODB', 'NEO4J'] },
          probeConfig:       { bsonType: 'object' },
          assertion:         { bsonType: 'object' },
          credentialRef:     { bsonType: ['string', 'null'] },
          intervalSeconds:   { bsonType: 'int', minimum: 1 },
          timeoutSeconds:    { bsonType: 'int', minimum: 1 },
          staleAfterSeconds: { bsonType: 'int', minimum: 1 },
          catalogVersion:    { bsonType: 'long', minimum: 1 },
          createdAt:         { bsonType: 'date' },
          updatedAt:         { bsonType: 'date' },
          latestResult:      {
            bsonType: ['object', 'null'],
            properties: {
              checkId:         { bsonType: 'string' },
              collectorId:     { bsonType: 'string' },
              outcome:         { enum: ['PASS', 'FAIL', 'ERROR'] },
              checkedAt:       { bsonType: 'date' },
              checkedAtMicros: { bsonType: ['long', 'null'] },
              receivedAt:      { bsonType: 'date' },
              latencyMs:       { bsonType: ['decimal', 'double', 'null'] },
              reasonCode:      { bsonType: ['string', 'null'] },
              httpStatus:      { bsonType: ['int', 'null'] },
              runtimeState:    { bsonType: ['string', 'null'] },
              runtimeHealth:   { bsonType: ['string', 'null'] },
            },
          },
        },
      },
    },
    validationLevel: 'strict',
    validationAction: 'error',
  });
  db.monitoring_health_targets.createIndex({ name: 1, _id: 1 }, { name: 'idx_monitoring_targets_name_id' });
  db.monitoring_health_targets.createIndex({ environment: 1, kind: 1, name: 1, _id: 1 }, { name: 'idx_monitoring_targets_env_kind_name_id' });
  db.monitoring_health_targets.createIndex({ serverId: 1, name: 1, _id: 1 }, { name: 'idx_monitoring_targets_server_name_id' });
  db.monitoring_health_targets.createIndex({ collectorId: 1 }, { name: 'idx_monitoring_targets_collector_id' });
})();

// Seed run audit markers.
db.createCollection('seed_runs');

print('BrandHub MongoDB initialized: collections and indexes created.');


// Chat uploads and immutable repository references (2026-11-08). Metadata only; no seed/storage writes.
(() => {
  const uuid = '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$';
  // BEGIN CHAT ATTACHMENT CONTRACT
  const attachmentIds = { bsonType: ['array', 'null'], maxItems: 5, uniqueItems: true,
    items: { bsonType: 'string', pattern: uuid } };
  const attachmentValidator = { $jsonSchema: { bsonType: 'object', required: ['_id', 'workspaceId',
    'channelId', 'uploadedBy', 'source', 'state', 'filename', 'mimeType', 'byteSize',
    'storageProvider', 'storageKey', 'createdAt'], properties: {
    _id: { bsonType: 'string', pattern: uuid }, workspaceId: { bsonType: 'string', pattern: uuid },
    channelId: { bsonType: 'string', minLength: 1, maxLength: 100 }, uploadedBy: { bsonType: 'string', pattern: uuid },
    source: { enum: ['UPLOAD', 'REPOSITORY'] }, state: { enum: ['UPLOADING', 'READY', 'ATTACHED', 'FAILED', 'DELETING'] },
    filename: { bsonType: 'string', minLength: 1, maxLength: 255 }, mimeType: { bsonType: 'string', minLength: 1, maxLength: 255 },
    byteSize: { bsonType: ['int', 'long'], minimum: 1 }, storageProvider: { bsonType: 'string', minLength: 1 },
    storageKey: { bsonType: 'string', minLength: 1 }, materialId: { bsonType: ['string', 'null'] },
    materialWorkspaceId: { bsonType: ['string', 'null'] }, versionNumber: { bsonType: ['int', 'long', 'null'], minimum: 1 },
    createdAt: { bsonType: 'date' }, expiresAt: { bsonType: ['date', 'null'] },
  } } };
  const attachmentIndexes = [
    { name: 'idx_chat_attachments_owner', key: { workspaceId: 1, channelId: 1, uploadedBy: 1, state: 1 } },
    { name: 'idx_chat_attachments_cleanup', key: { expiresAt: 1, _id: 1 } },
  ];
  const messageAttachmentIndexes = [{ name: 'idx_chat_message_attachments', key: { workspaceId: 1, channelId: 1, attachmentIds: 1 } }];
  const scheduleAttachmentIndexes = [{ name: 'idx_chat_schedule_attachments', key: { workspaceId: 1, channelId: 1, attachmentIds: 1, status: 1 } }];
  const referenceAttachmentIndexes = [{ name: 'idx_material_chat_references', key: { source_type: 1, source_id: 1 } }];
  const textOrAttachment = { $or: [{ content: { $regex: '\\S' } }, { 'attachmentIds.0': { $exists: true } }] };
  function extendChatValidator(existing) {
    const next = typeof EJSON !== 'undefined' ? EJSON.parse(EJSON.stringify(existing)) : JSON.parse(JSON.stringify(existing));
    const find = value => value.$jsonSchema || (value.$and || []).map(find).find(Boolean);
    const schema = find(next);
    if (!schema || !schema.properties) throw new Error('Expected chat JSON schema baseline');
    // Earlier rich-content rollout may have installed only its own field contract.
    // Preserve that validator and add the missing text field rather than replace the baseline.
    if (!schema.properties.content) schema.properties.content = { bsonType: 'string', maxLength: 4000 };
    if (schema.properties.content.bsonType !== 'string') throw new Error('Incompatible chat content schema');
    schema.properties.attachmentIds = attachmentIds;
    schema.properties.content.minLength = 0;
    // Keep existing predicates and fields; this additive rule enables attachment-only messages.
    const isTextOrAttachment = clause => {
      if (!clause.$or || clause.$or.length !== 2) return false;
      const text = clause.$or.find(part => part.content)?.content;
      const expression = text?.$regex ?? text?.$regularExpression?.pattern ?? text?.pattern ?? text?.source;
      return expression === '\\S' && clause.$or.some(part => part['attachmentIds.0']?.$exists === true);
    };
    if (next.$and) {
      if (!next.$and.some(isTextOrAttachment)) next.$and.push(textOrAttachment);
    } else if (!next.$or) next.$or = textOrAttachment.$or;
    else if (!isTextOrAttachment(next)) return { $and: [next, textOrAttachment] };
    return next;
  }
  // END CHAT ATTACHMENT CONTRACT
  db.createCollection('chat_attachments', {validator:attachmentValidator, validationLevel:'strict', validationAction:'error'});
  for (const {key,...options} of attachmentIndexes) db.chat_attachments.createIndex(key,options);
  for (const [name,indexes] of [['chat_messages',messageAttachmentIndexes],['chat_scheduled_messages',scheduleAttachmentIndexes]]) {
    const current=db.getCollectionInfos({name})[0];
    db.runCommand({collMod:name,validator:extendChatValidator(current.options.validator),validationLevel:'strict',validationAction:'error'});
    for (const {key,...options} of indexes) db.getCollection(name).createIndex(key,options);
  }
  for (const {key,...options} of referenceAttachmentIndexes) db.material_references.createIndex(key,options);
})();

// Repository Folders, Material Versions, Client Vault Shares, Surveys, Video Projects, and Watermark Presets
(() => {
  const ensureCollection = (name) => {
    if (!db.getCollectionInfos({ name }).length) {
      db.createCollection(name);
    }
  };

  // 1. material_folders
  ensureCollection('material_folders');
  db.material_folders.createIndex(
    { scope_type: 1, workspace_id: 1, parent_folder_id: 1, normalized_name: 1 },
    { name: 'uq_workspace_folder_name', unique: true, partialFilterExpression: { scope_type: 'WORKSPACE', deleted_at: null } }
  );
  db.material_folders.createIndex(
    { scope_type: 1, owner_user_id: 1, parent_folder_id: 1, normalized_name: 1 },
    { name: 'uq_vault_folder_name', unique: true, partialFilterExpression: { scope_type: 'CLIENT_VAULT', deleted_at: null } }
  );
  db.material_folders.createIndex({ ancestor_ids: 1 }, { name: 'idx_material_folders_ancestors' });

  // 2. material_versions
  ensureCollection('material_versions');
  db.material_versions.createIndex(
    { material_id: 1, version_number: 1 },
    { name: 'uq_material_versions_no', unique: true }
  );

  // 3. client_vault_shares
  ensureCollection('client_vault_shares');
  db.client_vault_shares.createIndex(
    { workspace_id: 1, owner_user_id: 1, resource_type: 1, resource_id: 1 },
    { name: 'uq_client_vault_shares_resource', unique: true }
  );

  // 4. materials & upload sessions
  ensureCollection('material_upload_sessions');
  db.material_upload_sessions.createIndex({ workspace_id: 1, staging_key: 1 }, { name: 'uq_repository_session_key', unique: true });
  db.materials.createIndex({ workspace_id: 1, folder_id: 1, deleted_at: 1, sort_key: 1, normalized_name: 1, created_at: -1 }, { name: 'idx_materials_folder_sort' });
  db.materials.createIndex({ scope_type: 1, owner_user_id: 1, folder_id: 1, deleted_at: 1 }, { name: 'idx_materials_vault_folder' });
  db.materials.createIndex({ ancestor_folder_ids: 1 }, { name: 'idx_materials_ancestor_folders' });
  db.materials.createIndex({ workspace_id: 1, content_hash: 1 }, { name: 'idx_materials_content_hash' });

  // 5. surveys & survey_responses
  ensureCollection('surveys');
  db.surveys.createIndex({ taskId: 1 }, { name: 'idx_surveys_task_id' });
  db.surveys.createIndex({ publicToken: 1 }, { name: 'uq_surveys_public_token', unique: true, sparse: true });
  db.surveys.createIndex({ workspaceId: 1, taskId: 1 }, { name: 'idx_surveys_workspace_task' });

  ensureCollection('survey_responses');
  db.survey_responses.createIndex({ surveyId: 1, submittedAt: -1 }, { name: 'idx_survey_responses_survey_submitted' });
  db.survey_responses.createIndex({ taskId: 1, submittedAt: -1 }, { name: 'idx_survey_responses_task_submitted' });

  // 6. video_projects, video_project_assets, video_project_upload_sessions, video_auto_edits
  ensureCollection('video_projects');
  db.video_projects.createIndex({ workspaceId: 1, projectId: 1 }, { name: 'uq_video_projects_ws_project', unique: true });
  db.video_projects.createIndex({ workspaceId: 1, updatedAt: -1 }, { name: 'idx_video_projects_ws_updated' });

  ensureCollection('video_project_assets');
  db.video_project_assets.createIndex({ workspaceId: 1, projectId: 1, state: 1 }, { name: 'idx_video_assets_ws_project_state' });
  db.video_project_assets.createIndex({ projectId: 1, assetId: 1 }, { name: 'uq_video_assets_project_asset', unique: true });

  ensureCollection('video_project_upload_sessions');
  db.video_project_upload_sessions.createIndex({ workspaceId: 1, projectId: 1, state: 1 }, { name: 'idx_video_upload_sessions_ws_project' });
  db.video_project_upload_sessions.createIndex({ expiresAt: 1 }, { name: 'idx_video_upload_sessions_expires' });

  ensureCollection('video_auto_edits');
  db.video_auto_edits.createIndex({ workspaceId: 1, projectId: 1, createdAt: -1 }, { name: 'idx_video_auto_edits_ws_project' });
  db.video_auto_edits.createIndex({ state: 1, leaseUntil: 1 }, { name: 'idx_video_auto_edits_lease' });

  // 7. watermark_presets
  ensureCollection('watermark_presets');
  db.watermark_presets.createIndex({ workspace_id: 1, created_at: -1 }, { name: 'idx_watermark_presets_workspace_created' });
  db.watermark_presets.createIndex({ workspace_id: 1, client_profile_id: 1, created_at: -1 }, { name: 'idx_watermark_presets_workspace_client_created' });
  db.watermark_presets.createIndex({ workspace_id: 1, client_profile_id: 1, is_default: 1 }, { name: 'idx_watermark_presets_default' });
})();
