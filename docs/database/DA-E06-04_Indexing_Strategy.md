# DA-E06-04 — Indexing Strategy

**Sprint:** 3 | **Owner:** Trung (Leader) | **Priority:** 🟡 High  
**Blocked by:** DA-E06-02 (MongoDB schema), DA-E06-03 (PG schema)  
**Blocks:** DA-E06-07 (init scripts)

---

## 1. Mục tiêu

Xác định toàn bộ indexes cần thiết cho 15 bảng PostgreSQL và 8 collection MongoDB để đảm bảo API performance từ ngày đầu, không phải optimize sau launch.

**Nguyên tắc chung:**
- Index theo query pattern thực tế, không index thừa
- Compound index: cột selective nhất đứng đầu
- MongoDB: mọi time-series query bắt buộc có `workspaceId` đứng đầu compound index
- PostgreSQL: PK tự động có index — chỉ liệt kê indexes bổ sung

---

## 2. PostgreSQL Indexes

### 2.1 Identity Group

#### `users`

| Index | Columns | Type | Query Pattern |
|-------|---------|------|---------------|
| `idx_users_email` | `email` | Unique | Login, forgot-password lookup |

#### `user_oauth_providers`

| Index | Columns | Type | Query Pattern |
|-------|---------|------|---------------|
| `idx_oauth_user_id` | `user_id` | B-tree | List OAuth providers của 1 user |
| `idx_oauth_provider_unique` | `(provider, provider_id)` | Unique | OAuth callback: tìm user theo provider + external ID |

#### `user_refresh_tokens`

| Index | Columns | Type | Query Pattern |
|-------|---------|------|---------------|
| `idx_rt_user_id` | `user_id` | B-tree | List all sessions của 1 user (session manager UI) |
| `idx_rt_jti` | `jti` | Unique | Token validation — JWT ID lookup |
| `idx_rt_expires_at` | `expires_at` | B-tree | Cleanup job: xóa expired tokens |

#### `user_system_roles`

| Index | Columns | Type | Query Pattern |
|-------|---------|------|---------------|
| `idx_system_roles_user_id` | `user_id` | Unique | Check xem user có phải ADMIN không |

#### `password_reset_tokens`

| Index | Columns | Type | Query Pattern |
|-------|---------|------|---------------|
| `idx_pwd_reset_user_id` | `user_id` | B-tree | List reset attempts của 1 user (audit) |
| `idx_pwd_reset_token` | `token_hash` | Unique | Reset password: validate token |

---

### 2.2 Workspace Group

#### `workspaces`

| Index | Columns | Type | Query Pattern |
|-------|---------|------|---------------|
| `idx_workspaces_slug` | `slug` | Unique | Subdomain/URL routing: `brandname.brandhub.io` |
| `idx_workspaces_owner_id` | `owner_id` | B-tree | "Workspaces tôi sở hữu" |

#### `workspace_members`

| Index | Columns | Type | Query Pattern |
|-------|---------|------|---------------|
| `idx_wm_workspace_id` | `workspace_id` | B-tree | List tất cả members trong 1 workspace |
| `idx_wm_user_id` | `user_id` | B-tree | "Tôi là member của workspace nào" (user dashboard) |
| `idx_wm_unique` | `(workspace_id, user_id)` | Unique | Ngăn duplicate membership |

> **Lý do tách 2 index riêng** thay vì chỉ có composite: cả hai query pattern đều phổ biến và độc lập. Composite `(workspace_id, user_id)` chỉ tối ưu query theo workspace_id-first, không dùng được cho user_id-only scan.

#### `workspace_invitations`

| Index | Columns | Type | Query Pattern |
|-------|---------|------|---------------|
| `idx_inv_workspace_id` | `workspace_id` | B-tree | List pending invitations của workspace |
| `idx_inv_token` | `token` | Unique | Accept invitation: validate email link token |
| `idx_inv_email` | `invited_email` | B-tree | Check xem email đã được invite chưa |
| `idx_inv_unique` | `(workspace_id, invited_email)` | Unique | Ngăn invite cùng email 2 lần |

#### `workspace_member_permissions`

| Index | Columns | Type | Query Pattern |
|-------|---------|------|---------------|
| `idx_perms_member_id` | `workspace_member_id` | B-tree | Load all permission overrides của 1 member |
| `idx_perms_unique` | `(workspace_member_id, permission)` | Unique | Ngăn duplicate permission entry |

#### `clients`

| Index | Columns | Type | Query Pattern |
|-------|---------|------|---------------|
| `idx_clients_workspace_id` | `workspace_id` | B-tree | List clients trong workspace |
| `idx_clients_manager_id` | `assigned_manager_id` | B-tree | "Clients tôi phụ trách" (ACCOUNT_MANAGER view) |

---

### 2.3 Billing Group

#### `subscription_plans`

| Index | Columns | Type | Query Pattern |
|-------|---------|------|---------------|
| `idx_plans_name` | `name` | Unique | Lookup plan theo enum name (seeding, admin) |

> Bảng nhỏ (4 rows), full scan đủ dùng. Index duy nhất cần thiết là unique constraint trên `name`.

#### `workspace_subscriptions`

| Index | Columns | Type | Query Pattern |
|-------|---------|------|---------------|
| `idx_ws_sub_workspace_id` | `workspace_id` | Unique | Load subscription hiện tại của workspace |
| `idx_ws_sub_status_period` | `(status, current_period_end)` | B-tree | Cron job: tìm subscriptions sắp hết hạn |

#### `invoices`

| Index | Columns | Type | Query Pattern |
|-------|---------|------|---------------|
| `idx_inv_workspace_id` | `workspace_id` | B-tree | Invoice history của workspace |
| `idx_inv_subscription_id` | `subscription_id` | B-tree | Invoice theo subscription |
| `idx_inv_number` | `invoice_number` | Unique | Lookup hóa đơn theo số |

#### `payments`

| Index | Columns | Type | Query Pattern |
|-------|---------|------|---------------|
| `idx_pay_workspace_id` | `workspace_id` | B-tree | Payment history của workspace |
| `idx_pay_invoice_id` | `invoice_id` | B-tree | Payments cho 1 invoice |
| `idx_pay_tx_id` | `transaction_id` | Unique | Webhook idempotency: ngăn duplicate payment |

#### `audit_logs`

| Index | Columns | Type | Query Pattern |
|-------|---------|------|---------------|
| `idx_audit_user_time` | `(user_id, created_at DESC)` | B-tree | "Hoạt động của user X" — security audit |
| `idx_audit_workspace_time` | `(workspace_id, created_at DESC)` | B-tree | Activity log của workspace |
| `idx_audit_resource` | `(resource_type, resource_id)` | B-tree | "Ai đã đụng đến Post #123?" |

> `created_at DESC` trong compound index giúp ORDER BY DESC không cần extra sort.

---

## 3. MongoDB Indexes

> **Quy tắc bắt buộc:** Mọi compound index trên time-series collection đều bắt đầu bằng `workspaceId: 1`, sau đó mới đến field phân loại, cuối là `createdAt: -1`. Lý do: mọi query trong hệ thống đều filter theo workspaceId trước tiên (multi-tenant isolation).

### 3.1 `social_accounts`

| Index | Fields | Type | Query Pattern |
|-------|--------|------|---------------|
| `idx_sa_workspace` | `{ workspaceId: 1 }` | Single | List accounts của workspace |
| `idx_sa_workspace_platform_account` | `{ workspaceId: 1, platform: 1, accountId: 1 }` | Unique | OAuth callback: tìm account để refresh token |
| `idx_sa_workspace_status` | `{ workspaceId: 1, tokenStatus: 1 }` | Compound | Token refresh job: tìm EXPIRING_SOON accounts |

### 3.2 `posts`

| Index | Fields | Type | Query Pattern |
|-------|--------|------|---------------|
| `idx_posts_ws_status` | `{ workspaceId: 1, status: 1, createdAt: -1 }` | Compound | Content calendar: filter theo trạng thái |
| `idx_posts_ws_scheduled` | `{ workspaceId: 1, scheduledAt: 1 }` | Compound | Publisher scheduler: lấy posts SCHEDULED sắp đến |
| `idx_posts_ws_client` | `{ workspaceId: 1, clientId: 1, createdAt: -1 }` | Compound | BRAND_CLIENT view: posts của client X |
| `idx_posts_ws_creator` | `{ workspaceId: 1, createdBy: 1, createdAt: -1 }` | Compound | "Posts tôi tạo" (CONTENT_CREATOR view) |

> `scheduledAt` dùng ascending `1` vì scheduler cần lấy posts gần nhất trước (ORDER BY ASC).

### 3.3 `content_requests`

| Index | Fields | Type | Query Pattern |
|-------|--------|------|---------------|
| `idx_cr_ws_status` | `{ workspaceId: 1, status: 1, createdAt: -1 }` | Compound | List requests theo workflow state |
| `idx_cr_ws_client` | `{ workspaceId: 1, clientId: 1, createdAt: -1 }` | Compound | Requests của client X |
| `idx_cr_ws_assigned` | `{ workspaceId: 1, assignedTo: 1, status: 1 }` | Compound | "Requests được giao cho tôi" + filter by status |

### 3.4 `knowledge_documents`

| Index | Fields | Type | Query Pattern |
|-------|--------|------|---------------|
| `idx_kd_workspace` | `{ workspaceId: 1 }` | Single | List documents của workspace |
| `idx_kd_ws_client` | `{ workspaceId: 1, clientId: 1 }` | Compound | Documents của client X (RAG context filter) |

> Full-text search được xử lý bởi ChromaDB (vector search), không cần MongoDB text index ở đây.

### 3.5 `notifications`

| Index | Fields | Type | Query Pattern |
|-------|--------|------|---------------|
| `idx_notif_user_read` | `{ userId: 1, isRead: 1, createdAt: -1 }` | Compound | Unread notifications count + list |
| `idx_notif_ws_user` | `{ workspaceId: 1, userId: 1 }` | Compound | Notifications trong workspace của user |
| `idx_notif_ttl` | `{ createdAt: 1 }` | **TTL** | Auto-expire sau **30 ngày** |

> TTL index: `expireAfterSeconds: 2592000` (30 × 24 × 3600). MongoDB background job tự xóa, không cần cron.

### 3.6 `publish_logs`

| Index | Fields | Type | Query Pattern |
|-------|--------|------|---------------|
| `idx_pl_post_id` | `{ postId: 1 }` | Single | Lịch sử publish của 1 post |
| `idx_pl_ws_result` | `{ workspaceId: 1, result: 1, createdAt: -1 }` | Compound | Failed publish report: filter FAILED logs |

### 3.7 `ai_usage_logs`

| Index | Fields | Type | Query Pattern |
|-------|--------|------|---------------|
| `idx_ai_ws_feature` | `{ workspaceId: 1, feature: 1, createdAt: -1 }` | Compound | AI credit usage per feature per workspace |
| `idx_ai_created` | `{ createdAt: -1 }` | Single | Global AI usage dashboard (ADMIN) |

> `createdAt: -1` standalone cho admin query không filter theo workspace.

### 3.8 `report_jobs`

| Index | Fields | Type | Query Pattern |
|-------|--------|------|---------------|
| `idx_rj_ws_status` | `{ workspaceId: 1, status: 1 }` | Compound | List running/pending jobs của workspace |
| `idx_rj_ws_client` | `{ workspaceId: 1, clientId: 1 }` | Compound | Report history của client X |

---

## 4. TTL Indexes Summary

| Collection | Index Field | TTL | Lý do |
|-----------|------------|-----|-------|
| `notifications` | `createdAt` | 30 ngày | Thông báo cũ không cần thiết |

> Redis TTL keys (không phải MongoDB):
> - `refresh:{jti}` → 7 ngày (đồng bộ với `user_refresh_tokens.expires_at`)
> - `pwd:reset:{token}` → 1 giờ (đồng bộ với `password_reset_tokens.expires_at`)
> - `oauth:state:{state}` → 10 phút (CSRF protection cho OAuth flow)

---

## 5. Indexes Không Tạo (và lý do)

| Table/Collection | Field bỏ qua | Lý do |
|-----------------|-------------|-------|
| `subscription_plans` | `is_active` | Bảng 4 rows, full scan đủ |
| `users` | `status` | Login query dùng email index trước, status check sau |
| `audit_logs` | `action` | Không có query filter by action duy nhất |
| `knowledge_documents` | `tags` | Array field — text search dùng ChromaDB |
| `posts` | `platform` | Luôn đi kèm workspaceId, covered bởi compound |
| `workspace_members` | `role` | Thường query all members rồi filter in-memory (set nhỏ) |

---

## 6. Init Script Reference

Tất cả indexes PostgreSQL đã được khai báo trong:  
`brandhub-infrastructure/scripts/init-postgres.sql`

MongoDB indexes cần khai báo trong:  
`brandhub-infrastructure/scripts/init-mongo.js`

```js
// Ví dụ — posts collection
db.posts.createIndex({ workspaceId: 1, status: 1, createdAt: -1 });
db.posts.createIndex({ workspaceId: 1, scheduledAt: 1 });
db.posts.createIndex({ workspaceId: 1, clientId: 1, createdAt: -1 });
db.posts.createIndex({ workspaceId: 1, createdBy: 1, createdAt: -1 });

// Ví dụ — notifications TTL
db.notifications.createIndex({ createdAt: 1 }, { expireAfterSeconds: 2592000 });
```

Xem full init script tại [init-mongo.js](../../scripts/init-mongo.js).
