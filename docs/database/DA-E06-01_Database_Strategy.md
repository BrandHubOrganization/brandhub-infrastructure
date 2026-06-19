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

## 4. Entity Mapping — 17 Entity vào đúng DB

### 4.1 MongoDB — 12 Collections

| Collection | Service | Lý do chọn MongoDB | Key pattern |
|---|---|---|---|
| `users` | business-service | Schema mở rộng được (OAuth providers, preferences per user); không cần FK tới payment | Filter `{ _id }` hoặc `{ email }` |
| `workspaces` | business-service | Flexible config per workspace (branding, settings object lồng nhau) | Filter `{ _id }` hoặc `{ slug }` |
| `workspace_members` | business-service | Quan hệ user↔workspace thay đổi thường, soft delete cần audit nhẹ | Filter `{ workspaceId, userId }` |
| `clients` | business-service | Profile client linh hoạt per agency; `service_package` dạng object thay đổi theo deal | Filter `{ workspaceId }` |
| `social_accounts` | business-service | AES-256-GCM encrypted token; metadata khác nhau per platform (FB Page vs Zalo OA) | Filter `{ workspaceId, platform }` |
| `posts` | business-service | Content entity core — high write, `approval_history[]` inline, schema thêm field per platform | Filter `{ workspaceId, status }`, `{ workspaceId, scheduledAt }` |
| `content_requests` | business-service | Request flow nhiều state (8 states), nested `comments[]`, `attachments[]` | Filter `{ workspaceId, status }`, `{ workspaceId, assignedTo }` |
| `knowledge_documents` | ai-service | Brand knowledge base cho RAG — document dạng tự do, chunked text | Filter `{ workspaceId }`, `{ workspaceId, clientId }` |
| `notifications` | business-service | Event-driven, high volume, TTL tự expire sau 30 ngày, không cần JOIN | Filter `{ userId, isRead }` |
| `publish_logs` | publisher-service | Append-only log mỗi lần publish — high write, retry tracking, không cần ACID | Filter `{ postId }`, `{ workspaceId, result }` |
| `ai_usage_logs` | ai-service | Token count, model used, cost estimate — schema thay đổi per model/feature | Filter `{ workspaceId, feature }`, `{ createdAt }` |
| `report_jobs` | business-service | Background report job status — transient state, không cần financial integrity | Filter `{ workspaceId, status }` |

### 4.2 PostgreSQL — 5 Tables

| Table | Service | Lý do chọn PostgreSQL | Constraints quan trọng |
|---|---|---|---|
| `subscription_plans` | business-service | Master data cố định (FREE/BASIC/PRO/ENTERPRISE), cần referential integrity | `UNIQUE(name)`, không xóa plan đang dùng |
| `workspace_subscriptions` | business-service | FK tới `subscription_plans`, billing state — cần ACID khi upgrade/downgrade | `FK → subscription_plans.id`, `UNIQUE(workspaceId)` |
| `invoices` | business-service | Hóa đơn tài chính — immutable sau khi `status = ISSUED`, audit bắt buộc | `FK → workspace_subscriptions.id`, `UNIQUE(invoiceNumber)` |
| `payments` | business-service | Transaction thanh toán — atomic, không được duplicate | `FK → invoices.id`, `UNIQUE(transactionId)` |
| `audit_logs` | business-service | Append-only security log (login, role change, delete) — không có UPDATE/DELETE | `bigserial PK`, no FK (soft refs), no DELETE permission |

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

### 5.2 Các cross-DB soft refs hiện tại

| MongoDB field | Trỏ tới | Lưu ý |
|---|---|---|
| `workspaces.subscription_id` | `workspace_subscriptions.id` (PG) | Dùng để lookup nhanh, không enforce FK |
| `workspace_subscriptions.workspace_id` (PG) | `workspaces._id` (Mongo) | String, không có FK constraint |
| `invoices.workspace_id` (PG) | `workspaces._id` (Mongo) | Soft ref — tên workspace lấy từ app layer |
| `payments.workspace_id` (PG) | `workspaces._id` (Mongo) | Tương tự invoices |
| `audit_logs.workspace_id` (PG) | `workspaces._id` (Mongo) | Nullable (ADMIN action có thể không có workspace) |
| `audit_logs.user_id` (PG) | `users._id` (Mongo) | Soft ref — user info lấy từ app layer khi cần |

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
┌─────────────────────────────────────────────────────────────────┐
│                        business-service                          │
│                                                                  │
│  MongoDB (9 collections)          PostgreSQL (5 tables)          │
│  ├── users                        ├── subscription_plans         │
│  ├── workspaces                   ├── workspace_subscriptions    │
│  ├── workspace_members            ├── invoices                   │
│  ├── clients                      ├── payments                   │
│  ├── social_accounts              └── audit_logs                 │
│  ├── posts                                                       │
│  ├── content_requests             Redis (cache)                  │
│  ├── notifications                ├── jwt:blacklist:{jti}        │
│  └── report_jobs                  ├── ratelimit:{userId}:{min}   │
│                                   └── oauth:state:{state}        │
├─────────────────────────────────────────────────────────────────┤
│                          ai-service                              │
│  MongoDB                          ChromaDB                       │
│  ├── knowledge_documents          └── brand_embeddings_{wsId}   │
│  └── ai_usage_logs                Redis                          │
│                                   └── trends:vn:{date}:{cat}    │
├─────────────────────────────────────────────────────────────────┤
│                       publisher-service                          │
│  MongoDB                                                         │
│  └── publish_logs                                                │
└─────────────────────────────────────────────────────────────────┘
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
