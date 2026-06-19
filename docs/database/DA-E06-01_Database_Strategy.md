# DA-E06-01 — Database Strategy: MongoDB vs PostgreSQL

> **Task:** Define which data goes into MongoDB, which into PostgreSQL, and why.  
> **Owner:** Trung (Leader) | **Priority:** 🔴 Critical  
> **Blocks:** DA-E06-02 (MongoDB design), DA-E06-03 (PostgreSQL design)

---

## 1. Nguyên tắc phân chia (Decision Rules)

### MongoDB — dùng khi:

| Tiêu chí | Lý do |
|---|---|
| Schema linh hoạt, thay đổi theo từng workspace/client | Document model không cần migration khi thêm field |
| High write throughput, ghi nhiều liên tục | MongoDB tối ưu cho write-heavy workload |
| Dữ liệu dạng document/nested object | Tránh JOIN nhiều bảng — query gọn hơn |
| Không cần ACID transaction toàn cục | Các entity content không yêu cầu tính nhất quán tài chính |
| Multi-tenant isolation theo `workspaceId` | Mỗi collection filter theo `workspaceId` là đủ |

### PostgreSQL — dùng khi:

| Tiêu chí | Lý do |
|---|---|
| Dữ liệu tài chính, thanh toán, billing | Bắt buộc ACID — sai 1 đồng là lỗi nghiêm trọng |
| Cần foreign key constraint giữa các bảng | PostgreSQL enforce referential integrity |
| Cần audit trail bất biến | Append-only log, không xóa, không sửa |
| Schema cố định, ít thay đổi | Relational model phù hợp khi structure ổn định |
| Cần aggregate tài chính (SUM, GROUP BY) | PostgreSQL query optimizer tốt hơn cho analytics tài chính |

---

## 2. Hard Rules — Không ngoại lệ

> **Hard rule 1:** Toàn bộ dữ liệu tài chính (`subscriptions`, `invoices`, `payments`) **chỉ** lưu PostgreSQL — không exception, không cache MongoDB.

> **Hard rule 2:** Toàn bộ content entity (`posts`, `content_requests`, `analytics events`) **chỉ** lưu MongoDB — không lưu PostgreSQL dù schema nhỏ.

> **Hard rule 3:** Mọi collection MongoDB **bắt buộc** có field `workspaceId` và filter theo nó trong mọi query. `BRAND_CLIENT` role thêm filter `clientId`.

---

## 3. Mapping — 17 Entity vào đúng DB

### MongoDB — 12 Collections

| Collection | Service owner | Lý do chọn MongoDB |
|---|---|---|
| `users` | business-service | Schema mở rộng được (thêm OAuth providers, preferences); không cần FK tới payment |
| `workspaces` | business-service | Flexible config per workspace (branding, settings dạng object lồng nhau) |
| `workspace_members` | business-service | Quan hệ user↔workspace, thay đổi thường, không cần ACID |
| `clients` | business-service | Profile client do agency quản lý, schema linh hoạt theo từng agency |
| `social_accounts` | business-service | Lưu encrypted OAuth token + platform metadata — cấu trúc khác nhau per platform |
| `posts` | business-service | Content entity core — high write, schema có thể thêm field per platform |
| `content_requests` | business-service | Request từ client/AI, trạng thái thay đổi nhiều, nested approval history |
| `knowledge_documents` | ai-service | Brand knowledge base cho RAG — document dạng tự do, chunked text |
| `notifications` | business-service | Event-driven, high volume, TTL tự expire, không cần JOIN |
| `publish_logs` | publisher-service | Log mỗi lần publish lên social — append-only, high write, không cần ACID |
| `ai_usage_logs` | ai-service | Token count, model used, cost estimate — high volume, schema thay đổi per model |
| `report_jobs` | business-service | Background report generation status — transient, không cần tài chính integrity |

### PostgreSQL — 5 Tables

| Table | Service owner | Lý do chọn PostgreSQL |
|---|---|---|
| `subscription_plans` | business-service | Master data plan (FREE/BASIC/PRO/ENTERPRISE) — cố định, cần referential integrity |
| `workspace_subscriptions` | business-service | FK tới `subscription_plans`, trạng thái billing của từng workspace — cần ACID |
| `invoices` | business-service | Hóa đơn tài chính — immutable sau khi issued, cần audit |
| `payments` | business-service | Transaction thanh toán — ACID bắt buộc, không được mất hay duplicate |
| `audit_logs` | business-service | Append-only security log (login, role change, delete) — bất biến theo compliance |

---

## 4. Cross-DB Reference Strategy

Các service **không** thực hiện JOIN trực tiếp giữa MongoDB và PostgreSQL.

**Pattern được dùng — Soft Reference:**

```
workspace_subscriptions.workspace_id (PostgreSQL)
    ↓ string — không có FK constraint
workspaces._id (MongoDB)
```

- Business-service query MongoDB lấy workspace → lấy `workspaceId`
- Dùng `workspaceId` để query PostgreSQL riêng
- Join trong application memory (in-memory sau 2 query)
- **Không** thực hiện DB-level JOIN

**Lý do:** MongoDB và PostgreSQL chạy trên 2 connection pool riêng — không thể JOIN ở DB engine level.

---

## 5. Redis — Cache Layer (không phải primary storage)

Redis **không** lưu primary data. Chỉ dùng cho:

| Key pattern | Mục đích | TTL |
|---|---|---|
| `jwt:blacklist:{jti}` | Token đã logout/revoke | Remaining token lifetime |
| `ratelimit:{userId}:{minute}` | Rate limiting per user | 60s |
| `oauth:state:{state}` | CSRF protection cho OAuth flow | 10 phút |
| `trends:vn:{date}:{category}` | Cache trending topics từ AI | 6 giờ |

---

## 6. ChromaDB — Vector Storage (ai-service only)

| Dữ liệu | Mục đích |
|---|---|
| Brand embeddings | RAG — tìm kiếm semantic cho brand knowledge |
| Document chunks | Chunked `knowledge_documents` từ MongoDB, indexed as vectors |

ChromaDB **không** thay thế MongoDB. `knowledge_documents` raw text lưu MongoDB; vector embedding lưu ChromaDB.

---

## 7. Sơ đồ tổng quan

```
┌─────────────────────────────────────────────────────────┐
│                    business-service                      │
│                                                          │
│  MongoDB (12 collections)    PostgreSQL (5 tables)       │
│  ├── users                   ├── subscription_plans      │
│  ├── workspaces              ├── workspace_subscriptions │
│  ├── workspace_members       ├── invoices                │
│  ├── clients                 ├── payments                │
│  ├── social_accounts         └── audit_logs              │
│  ├── posts                                               │
│  ├── content_requests        Redis (cache only)          │
│  ├── notifications           ├── jwt:blacklist           │
│  └── report_jobs             ├── ratelimit               │
│                              ├── oauth:state             │
├─────────────────────────────────────────────────────────┤
│                      ai-service                          │
│  MongoDB                     ChromaDB                    │
│  ├── knowledge_documents     └── brand embeddings        │
│  └── ai_usage_logs           Redis                       │
│                              └── trends cache            │
├─────────────────────────────────────────────────────────┤
│                   publisher-service                      │
│  MongoDB                                                 │
│  └── publish_logs                                        │
└─────────────────────────────────────────────────────────┘
```

---

## 8. Acceptance Criteria

- [x] Document liệt kê tiêu chí phân chia MongoDB vs PostgreSQL rõ ràng
- [x] 17 entity (12 MongoDB + 5 PostgreSQL) được map với lý do cụ thể
- [x] Hard rules không ngoại lệ được ghi rõ
- [x] Cross-DB reference strategy được định nghĩa
- [x] Document lưu trong `brandhub-infrastructure/docs/database/`
