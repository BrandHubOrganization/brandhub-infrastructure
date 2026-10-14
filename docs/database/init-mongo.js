// BrandHub — MongoDB initialization script
// For a fresh local MongoDB volume only (docker-entrypoint-initdb.d/init-mongo.js).
// Do NOT run this file against existing MongoDB Atlas data. Apply the ordered
// scripts in docs/database/migrations instead; see mongo-atlas-migrations.md.
// Includes Mongo migration effects through 2026-10-14 (8 migration scripts).

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
        status:                 { enum: ['BACKLOG', 'DETAIL_IDENTIFIED', 'ASSIGNED', 'IN_PROGRESS', 'QC_REVIEW', 'MANAGER_REVIEW', 'CLIENT_REVIEW', 'COMPLETED', 'CANCELLED'] },
        assigneeId:             { bsonType: ['string', 'null'] },
        qcAssigneeId:           { bsonType: ['string', 'null'] },
        requiresClientApproval: { bsonType: 'bool' },
        description:            { bsonType: ['string', 'null'] },
        approvalRound:          { bsonType: 'int', minimum: 1 },
        typeMetadata:           { bsonType: 'object' },
        sourceType:             { bsonType: ['string', 'null'] },
        sourceRefId:            { bsonType: ['string', 'null'] },
        createdBy:              { bsonType: ['string', 'null'] },
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

// task_approvals (V2) — supports latest action per step in the active round.
db.task_approvals.createIndex(
  { taskId: 1, approvalRound: 1, step: 1, createdAt: 1 },
  { name: 'idx_task_approvals_task_round_step_created' }
);
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

print('BrandHub MongoDB initialized: 19 collections, all indexes created.');
