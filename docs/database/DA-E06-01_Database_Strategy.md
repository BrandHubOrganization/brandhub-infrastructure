# DA-E06-01 — Database Strategy: MongoDB vs PostgreSQL

> **Task:** Define which data goes into MongoDB, which into PostgreSQL, and why.  
> **Owner:** Trung (Leader) | **Priority:** 🔴 Critical  
> **Blocks:** DA-E06-02 (MongoDB collection design), DA-E06-03 (PostgreSQL table design), DA-E06-04 (indexing strategy)

---

## 1. Tổng quan kiến trúc lưu trữ

BrandHub sử dụng **hai primary database** với vai trò rõ ràng, không chồng lấn:

| Storage | Role | Service sử dụng |
|---|---|---|
| **MongoDB** | Primary store cho content, users, operational data | business-service, ai-service, publisher-service |
| **PostgreSQL** | Primary store cho financial, billing, immutable audit | business-service |
| **Redis** | Cache layer — không lưu primary data | Tất cả services |
| **ChromaDB** | Vector store cho RAG search | ai-service |

> **Nguyên tắc cốt lõi:** Mỗi entity chỉ được lưu tại **một** database duy nhất. Không sync, không duplicate, không partial mirror.

---

## 2. Tiêu chí phân chia (Decision Rules)

### 2.1 Chọn MongoDB khi:

| Tiêu chí | Giải thích chi tiết |
|---|---|
| **Schema linh hoạt** | Field có thể thêm bớt per workspace/client mà không cần migration. Ví dụ: `clients.metadata` là object tự do theo từng agency |
| **Dữ liệu dạng document/nested** | Tránh JOIN nhiều bảng — `posts` chứa `approval_history[]` inline thay vì bảng `post_approvals` riêng |
| **High write throughput** | `publish_logs`, `ai_usage_logs`, `notifications` — ghi hàng nghìn records/phút, MongoDB không block write bằng row-lock |
| **Multi-tenant isolation đơn giản** | Filter `{ workspaceId }` trên mọi query là đủ; không cần row-level security phức tạp |
| **Không yêu cầu cross-entity ACID** | Content entity có thể chấp nhận eventual consistency — mất 1 notification không phải lỗi nghiêm trọng |
| **TTL và auto-expire** | `notifications`, `report_jobs` — MongoDB TTL index tự xóa record cũ mà không cần scheduled job |

### 2.2 Chọn PostgreSQL khi:

| Tiêu chí | Giải thích chi tiết |
|---|---|
| **ACID transaction bắt buộc** | `payments` — debit ví + update invoice + tạo payment record phải atomic. Rollback nếu bất kỳ bước nào fail |
| **Foreign key constraint** | `invoices.subscription_id → workspace_subscriptions.id` — DB enforce, không để app tự kiểm |
| **Immutable audit trail** | `audit_logs` — append-only, không có UPDATE/DELETE, compliance yêu cầu |
| **Schema cố định** | `subscription_plans` không thay đổi structure — relational model phù hợp hơn |
| **Financial aggregate query** | `SUM(payments.amount) GROUP BY workspace_id` — PostgreSQL query planner tối ưu hơn MongoDB aggregation cho financial reporting |
| **Referential integrity** | Khi một subscription bị xóa, tất cả invoices phải được CASCADE hoặc SET NULL — PostgreSQL enforce tự động |

---

## 3. Hard Rules — Không có ngoại lệ

::: danger Hard Rule 1 — Financial data chỉ PostgreSQL
Toàn bộ dữ liệu tài chính (`subscription_plans`, `workspace_subscriptions`, `invoices`, `payments`) **chỉ** lưu PostgreSQL.

- Không cache vào MongoDB dù là partial
- Không đọc từ Redis thay cho PostgreSQL trừ read-through cache với TTL ngắn (≤ 60s)
- Không dùng MongoDB transaction để thay thế PostgreSQL ACID
:::

::: danger Hard Rule 2 — Content entity chỉ MongoDB
Toàn bộ content entity (`posts`, `content_requests`, `social_accounts`, ...) **chỉ** lưu MongoDB.

- Không tạo PostgreSQL table mirror cho bất kỳ MongoDB collection nào
- Nếu cần filter tài chính theo `workspaceId`, query MongoDB trước để lấy ID, sau đó query PostgreSQL riêng
:::

::: danger Hard Rule 3 — workspaceId bắt buộc
Mọi MongoDB query **bắt buộc** có filter `workspaceId`.

```js
// ❌ SAI — không có workspaceId
db.posts.find({ status: 'PUBLISHED' })

// ✅ ĐÚNG
db.posts.find({ workspaceId: ctx.workspaceId, status: 'PUBLISHED' })
```

`BRAND_CLIENT` role thêm filter `clientId` bên cạnh `workspaceId`:
```js
db.posts.find({ workspaceId: ctx.workspaceId, clientId: ctx.clientId, status: 'PUBLISHED' })
```
:::

---

## 4. Entity Mapping — 19 Entity vào đúng DB

> **Thay đổi thiết kế:** `users`, `workspaces`, `workspace_members`, `clients` chuyển từ MongoDB sang PostgreSQL để có FK thật, ACID transaction khi tạo user/workspace, và loại bỏ soft ref giữa financial chain với identity data.

### 4.1 PostgreSQL — 11 Tables (3 nhóm)

#### Identity

| Table | Lý do chọn PostgreSQL | Constraints quan trọng |
|---|---|---|
| `users` | `email` UNIQUE atomic; auth data cần ACID; `refresh_tokens` tách bảng riêng (1NF) | `UNIQUE(email)`, FK từ workspace_members |
| `user_oauth_providers` | 1NF: tách từ `users.oauth_providers[]` — array không thể query/index hiệu quả | `UNIQUE(provider, provider_id)`, FK → users |
| `user_refresh_tokens` | 1NF: tách từ `users.refresh_tokens[]` — cần index trên `jti`, `expires_at` | `UNIQUE(jti)`, FK → users ON DELETE CASCADE |

#### Workspace

| Table | Lý do chọn PostgreSQL | Constraints quan trọng |
|---|---|---|
| `workspaces` | `slug` UNIQUE atomic; `owner_id` FK thật → users; là anchor của toàn bộ financial chain | `UNIQUE(slug)`, FK → users |
| `workspace_members` | Junction user↔workspace với role — UNIQUE constraint atomic trên `(workspace_id, user_id)` | `UNIQUE(workspace_id, user_id)`, FK → users + workspaces |
| `clients` | `portal_user_id` FK thật → users; `workspace_id` FK thật → workspaces | FK → workspaces, FK → users (2 FK) |

#### Billing

| Table | Lý do chọn PostgreSQL | Constraints quan trọng |
|---|---|---|
| `subscription_plans` | Master data cố định, referential integrity | `UNIQUE(name)` |
| `workspace_subscriptions` | `workspace_id` FK thật → workspaces (không còn soft ref); ACID khi upgrade/downgrade | `UNIQUE(workspace_id)`, FK → workspaces + plans |
| `invoices` | Immutable sau `status = ISSUED` | FK → workspaces + workspace_subscriptions, `UNIQUE(invoice_number)` |
| `payments` | Atomic, không duplicate | FK → workspaces + invoices, `UNIQUE(transaction_id)` |
| `audit_logs` | Append-only — `user_id` giữ soft ref vì user có thể bị xóa nhưng log phải persist | `bigserial PK`, no UPDATE/DELETE |

### 4.2 MongoDB — 8 Collections

| Collection | Service | Lý do giữ MongoDB | Key pattern |
|---|---|---|---|
| `social_accounts` | business-service | AES-256-GCM encrypted token; metadata khác nhau per platform | Filter `{ workspaceId, platform }` |
| `posts` | business-service | Content core — high write, `approval_history[]` inline, schema thêm field per platform | Filter `{ workspaceId, status }`, `{ workspaceId, scheduledAt }` |
| `content_requests` | business-service | 8 states, nested `comments[]`, `attachments[]` | Filter `{ workspaceId, status }`, `{ workspaceId, assignedTo }` |
| `knowledge_documents` | ai-service | Brand knowledge cho RAG — document tự do, chunked text | Filter `{ workspaceId }`, `{ workspaceId, clientId }` |
| `notifications` | business-service | High volume, TTL 30 ngày tự expire, không cần JOIN | Filter `{ userId, isRead }` |
| `publish_logs` | publisher-service | Append-only, high write, retry tracking | Filter `{ postId }`, `{ workspaceId, result }` |
| `ai_usage_logs` | ai-service | Schema thay đổi per model/feature, append-only | Filter `{ workspaceId, feature }` |
| `report_jobs` | business-service | Transient job state, không cần financial integrity | Filter `{ workspaceId, status }` |

---

## 5. Cross-DB Reference Strategy

MongoDB và PostgreSQL chạy trên **hai connection pool riêng** — không thể JOIN ở DB engine level. Cross-DB reference dùng **Soft Reference pattern**:

### 5.1 Pattern chuẩn

```
workspace_subscriptions.workspace_id (PostgreSQL TEXT)
    ↕  application-level join (in-memory)
workspaces._id (MongoDB ObjectId → string)
```

**Flow thực tế:**
```
1. business-service nhận request với JWT chứa workspaceId
2. Query MongoDB: workspace = await db.workspaces.findOne({ _id: workspaceId })
3. Query PostgreSQL: sub = await pg.workspace_subscriptions.findOne({ workspace_id: workspaceId })
4. Merge trong application layer: { ...workspace, subscription: sub }
5. Không thực hiện DB-level JOIN
```

### 5.2 Các cross-DB soft refs còn lại

Sau khi chuyển `users`, `workspaces`, `workspace_members`, `clients` sang PostgreSQL, phần lớn internal refs đã trở thành **FK thật**. Chỉ còn soft ref theo chiều MongoDB → PostgreSQL:

| MongoDB field | Trỏ tới | Lưu ý |
|---|---|---|
| `social_accounts.workspace_id` | `workspaces.id` (PG) | Soft ref — UUID string |
| `social_accounts.client_id` | `clients.id` (PG) | Soft ref — UUID string |
| `posts.workspace_id` | `workspaces.id` (PG) | Soft ref |
| `posts.client_id` | `clients.id` (PG) | Soft ref |
| `posts.created_by` | `users.id` (PG) | Soft ref |
| `content_requests.workspace_id` | `workspaces.id` (PG) | Soft ref |
| `content_requests.client_id` | `clients.id` (PG) | Soft ref |
| `content_requests.requested_by` | `users.id` (PG) | Soft ref |
| `content_requests.assigned_to` | `users.id` (PG) | Soft ref |
| `notifications.workspace_id` | `workspaces.id` (PG) | Soft ref |
| `notifications.user_id` | `users.id` (PG) | Soft ref |
| `audit_logs.workspace_id` (PG) | `workspaces.id` (PG) | **UUID nullable** — ADMIN action không có workspace |
| `audit_logs.user_id` (PG) | `users.id` (PG) | **Soft ref** — user có thể bị xóa, log phải persist |

> **Lưu ý:** `audit_logs.user_id` giữ nguyên soft ref dù cả hai đều ở PostgreSQL — vì `audit_logs` là append-only, không thể có FK (DELETE user sẽ vi phạm constraint).

### 5.3 Khi nào KHÔNG dùng Soft Reference

- **Không** lưu financial amount trong MongoDB để tránh sync
- **Không** cache subscription status trong `workspaces` document — risk stale data
- **Không** join `audit_logs` với `users` ở DB level — query user info riêng nếu cần render

---

## 6. Redis — Cache Layer

Redis **không** lưu primary data. Chỉ dùng làm cache và distributed coordination:

| Key pattern | Mục đích | TTL | Ghi chú |
|---|---|---|---|
| `jwt:blacklist:{jti}` | Token đã logout/revoke — block replay attack | Remaining token lifetime | Xóa tự động khi token expire |
| `ratelimit:{userId}:{minute}` | Rate limiting per user per minute | 60s | Sliding window counter |
| `oauth:state:{state}` | CSRF protection cho OAuth flow | 10 phút | Xóa ngay sau dùng |
| `trends:vn:{date}:{category}` | Cache trending topics từ external AI/social API | 6 giờ | Refresh daily 2AM |
| `session:{sessionId}` | SSO session (nếu dùng) | 30 phút | Extend on activity |

**Không dùng Redis cho:**
- Primary storage bất kỳ entity nào
- Queue message (dùng dedicated queue: Bull/BullMQ hoặc RabbitMQ)
- Counter tài chính (dùng PostgreSQL)

---

## 7. ChromaDB — Vector Storage

ChromaDB chỉ thuộc phạm vi `ai-service`:

| Collection | Nội dung | Source |
|---|---|---|
| `brand_embeddings_{workspaceId}` | Brand knowledge vectors | Chunked từ `knowledge_documents` (MongoDB) |
| `post_history_{workspaceId}` | Vectors của posts đã publish — context cho AI generate | Chunked từ `posts` (MongoDB) |

**Relationship với MongoDB:**
```
knowledge_documents (MongoDB)
    → chunk text → embed → ChromaDB
    → chunk_ids[] stored back in knowledge_documents.chunk_ids
```

ChromaDB **không** thay thế MongoDB. Raw text lưu MongoDB; vector embedding lưu ChromaDB. Khi xóa document MongoDB, cần xóa chunk tương ứng trong ChromaDB (application layer responsibility).

---

## 8. Query Pattern Guidelines

### 8.1 MongoDB — Index-first query

Mọi query MongoDB phải dùng index. Không dùng `$where`, không scan full collection.

```js
// ✅ Dùng compound index { workspaceId, status }
db.posts.find({ workspaceId: id, status: 'PUBLISHED' })
    .sort({ scheduledAt: -1 })
    .limit(20)

// ❌ Tránh — không có index
db.posts.find({ content_text: /keyword/ })

// ✅ Full-text search → dùng MongoDB Atlas Search hoặc ElasticSearch
```

### 8.2 PostgreSQL — Transaction cho financial operations

```sql
-- Tạo payment + update invoice phải trong 1 transaction
BEGIN;
  INSERT INTO payments (workspace_id, invoice_id, amount, status, ...)
    VALUES ($1, $2, $3, 'COMPLETED', ...);
  UPDATE invoices SET status = 'PAID', paid_at = NOW()
    WHERE id = $2 AND status = 'ISSUED';
  -- Nếu UPDATE không affect row → invoice không hợp lệ → ROLLBACK
COMMIT;
```

### 8.3 Pagination

| Database | Pattern | Lý do |
|---|---|---|
| MongoDB | Cursor-based (`_id > lastId`) | Tránh skip cost trên large collection |
| PostgreSQL | Keyset (`id > lastId`) hoặc offset cho small result set | Consistent với MongoDB approach |

---

## 9. Security Considerations

### 9.1 MongoDB

- Mỗi service có **dedicated MongoDB user** với quyền tối thiểu:
  - `business-service`: read/write trên `users`, `workspaces`, `posts`, ... (không có `dropCollection`)
  - `ai-service`: read/write trên `knowledge_documents`, `ai_usage_logs`
  - `publisher-service`: read `posts`, write `publish_logs`
- `social_accounts` collection: `encrypted_token` và `encrypted_refresh_token` dùng AES-256-GCM. Key lưu trong Vault/Secret Manager — không trong env file
- Không log `oauth_providers[].accessToken` hay `refresh_tokens[].token` vào `audit_logs`

### 9.2 PostgreSQL

- `payments` và `invoices` table: chỉ service account có INSERT; không có UPDATE sau khi record completed
- `audit_logs`: chỉ có INSERT permission — không có UPDATE, DELETE dù là admin
- Row-level security (RLS) bật trên `workspace_subscriptions` — service chỉ đọc được record của workspace mình

### 9.3 Encryption at rest

| Storage | Encryption | Key management |
|---|---|---|
| MongoDB | Encrypted at rest (WiredTiger AES-256) | Managed key hoặc BYOK |
| PostgreSQL | Encrypted at rest (pgcrypto + disk encryption) | Managed key |
| Sensitive fields | App-level AES-256-GCM (`social_accounts`) | Vault / AWS KMS |

---

## 10. Sơ đồ tổng quan

```
┌──────────────────────────────────────────────────────────────────────┐
│                          business-service                             │
│                                                                       │
│  PostgreSQL (11 tables)                MongoDB (6 collections)        │
│  ── Identity ──                        ├── social_accounts            │
│  ├── users                             ├── posts                      │
│  ├── user_oauth_providers              ├── content_requests           │
│  ├── user_refresh_tokens               ├── notifications              │
│  ── Workspace ──                       └── report_jobs               │
│  ├── workspaces                                                       │
│  ├── workspace_members                 Redis (cache)                  │
│  ├── clients                           ├── jwt:blacklist:{jti}        │
│  ── Billing ──                         ├── ratelimit:{userId}:{min}   │
│  ├── subscription_plans                └── oauth:state:{state}        │
│  ├── workspace_subscriptions                                          │
│  ├── invoices                                                         │
│  ├── payments                                                         │
│  └── audit_logs                                                       │
├──────────────────────────────────────────────────────────────────────┤
│                            ai-service                                 │
│  MongoDB                              ChromaDB                        │
│  ├── knowledge_documents              └── brand_embeddings_{wsId}    │
│  └── ai_usage_logs                    Redis                           │
│                                       └── trends:vn:{date}:{cat}     │
├──────────────────────────────────────────────────────────────────────┤
│                         publisher-service                             │
│  MongoDB                                                              │
│  └── publish_logs                                                     │
└──────────────────────────────────────────────────────────────────────┘
```

---

## 11. Migration & Schema Evolution

### 11.1 MongoDB — không cần migration cho additive changes

```js
// Thêm field mới → không cần migration
// Old documents: không có field → app dùng default value
// New documents: có field
db.users.find({ newField: { $exists: false } }) // Backfill nếu cần
```

**Khi nào cần migration MongoDB:**
- Rename field (rename + backfill)
- Thay đổi kiểu dữ liệu (string → ObjectId)
- Xóa field bắt buộc

### 11.2 PostgreSQL — migration bắt buộc qua migration file

```sql
-- migrations/20260615_001_add_cancel_reason_to_subscriptions.sql
ALTER TABLE workspace_subscriptions
  ADD COLUMN cancel_reason TEXT;
```

- Dùng migration tool: **Flyway** hoặc **node-pg-migrate**
- Migration file đặt trong `business-service/src/migrations/`
- Không sửa trực tiếp production schema — mọi thay đổi qua migration file

---

## 12. Acceptance Criteria

- [x] Document liệt kê tiêu chí phân chia MongoDB vs PostgreSQL với giải thích chi tiết
- [x] 17 entity (12 MongoDB + 5 PostgreSQL) được map với lý do và key query pattern
- [x] Hard rules không ngoại lệ được ghi rõ với ví dụ code
- [x] Cross-DB reference strategy được định nghĩa với flow thực tế
- [x] Redis và ChromaDB được làm rõ scope và giới hạn
- [x] Security considerations cho từng storage layer
- [x] Query pattern guidelines (index-first, transaction, pagination)
- [x] Migration strategy cho cả MongoDB và PostgreSQL
- [x] Document lưu trong `brandhub-infrastructure/docs/database/`
