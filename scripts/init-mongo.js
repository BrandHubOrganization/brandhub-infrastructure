// BrandHub — MongoDB initialization script
// Runs inside mongosh automatically on first container start
// Path in container: /docker-entrypoint-initdb.d/init-mongo.js
// Idempotent: createCollection + createIndex are no-ops if already exist

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
        role:         { enum: ['OWNER', 'MANAGER', 'CREATOR', 'VIEWER'] },
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
      required: ['workspace_id', 'requested_by', 'title', 'status', 'created_at', 'updated_at'],
      properties: {
        workspace_id:  { bsonType: 'string' },
        requested_by:  { bsonType: 'string' },
        title:         { bsonType: 'string' },
        status:        { enum: ['SUBMITTED', 'ASSIGNED', 'IN_PROGRESS', 'PENDING_REVIEW', 'SENT_TO_CLIENT', 'APPROVED', 'REJECTED', 'CANCELLED'] },
      },
    },
  },
  validationAction: 'warn',
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
db.content_requests.createIndex({ workspace_id: 1, status: 1 }, { name: 'idx_content_requests_ws_status' });
db.content_requests.createIndex({ workspace_id: 1, client_id: 1 }, { name: 'idx_content_requests_ws_client_id' });
db.content_requests.createIndex({ workspace_id: 1, assigned_to: 1 }, { name: 'idx_content_requests_ws_assigned_to' });

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

print('✅ BrandHub MongoDB initialized: 12 collections, all indexes created.');
