// ============================================================
// BrandHub MongoDB Init Script
// DA-E06-07 | Run via: mongosh <connection-string> --file init-mongo.js
// Collections: social_accounts, posts, content_requests,
//              knowledge_documents, notifications, publish_logs,
//              ai_usage_logs, report_jobs
// ============================================================

// Switch to brandhub database
use('brandhub');

// ── social_accounts ──────────────────────────────────────────
db.social_accounts.createIndex(
  { workspaceId: 1 },
  { name: 'idx_sa_workspace' }
);
db.social_accounts.createIndex(
  { workspaceId: 1, platform: 1, accountId: 1 },
  { unique: true, name: 'idx_sa_workspace_platform_account' }
);
db.social_accounts.createIndex(
  { workspaceId: 1, tokenStatus: 1 },
  { name: 'idx_sa_workspace_status' }
);

// ── posts ────────────────────────────────────────────────────
db.posts.createIndex(
  { workspaceId: 1, status: 1, createdAt: -1 },
  { name: 'idx_posts_ws_status' }
);
db.posts.createIndex(
  { workspaceId: 1, scheduledAt: 1 },
  { name: 'idx_posts_ws_scheduled' }
);
db.posts.createIndex(
  { workspaceId: 1, clientId: 1, createdAt: -1 },
  { name: 'idx_posts_ws_client' }
);
db.posts.createIndex(
  { workspaceId: 1, createdBy: 1, createdAt: -1 },
  { name: 'idx_posts_ws_creator' }
);

// ── content_requests ─────────────────────────────────────────
db.content_requests.createIndex(
  { workspaceId: 1, status: 1, createdAt: -1 },
  { name: 'idx_cr_ws_status' }
);
db.content_requests.createIndex(
  { workspaceId: 1, clientId: 1, createdAt: -1 },
  { name: 'idx_cr_ws_client' }
);
db.content_requests.createIndex(
  { workspaceId: 1, assignedTo: 1, status: 1 },
  { name: 'idx_cr_ws_assigned' }
);

// ── knowledge_documents ──────────────────────────────────────
db.knowledge_documents.createIndex(
  { workspaceId: 1 },
  { name: 'idx_kd_workspace' }
);
db.knowledge_documents.createIndex(
  { workspaceId: 1, clientId: 1 },
  { name: 'idx_kd_ws_client' }
);

// ── notifications ────────────────────────────────────────────
db.notifications.createIndex(
  { userId: 1, isRead: 1, createdAt: -1 },
  { name: 'idx_notif_user_read' }
);
db.notifications.createIndex(
  { workspaceId: 1, userId: 1 },
  { name: 'idx_notif_ws_user' }
);
// TTL: auto-expire after 30 days
db.notifications.createIndex(
  { createdAt: 1 },
  { expireAfterSeconds: 2592000, name: 'idx_notif_ttl' }
);

// ── publish_logs ─────────────────────────────────────────────
db.publish_logs.createIndex(
  { postId: 1 },
  { name: 'idx_pl_post_id' }
);
db.publish_logs.createIndex(
  { workspaceId: 1, result: 1, createdAt: -1 },
  { name: 'idx_pl_ws_result' }
);

// ── ai_usage_logs ─────────────────────────────────────────────
db.ai_usage_logs.createIndex(
  { workspaceId: 1, feature: 1, createdAt: -1 },
  { name: 'idx_ai_ws_feature' }
);
db.ai_usage_logs.createIndex(
  { createdAt: -1 },
  { name: 'idx_ai_created' }
);

// ── report_jobs ───────────────────────────────────────────────
db.report_jobs.createIndex(
  { workspaceId: 1, status: 1 },
  { name: 'idx_rj_ws_status' }
);
db.report_jobs.createIndex(
  { workspaceId: 1, clientId: 1 },
  { name: 'idx_rj_ws_client' }
);

print('BrandHub MongoDB indexes created successfully.');
