# DA-E06-01 — Database Strategy V2: MongoDB vs PostgreSQL

> **STATUS: DESIGN — chưa áp dụng vào `scripts/init-postgres.sql` thật.** Tài liệu này thiết kế schema MỚI cho nghiệp vụ V2 (Agency → Workspace → Media Package → Media Campaign → Task), thay thế hoàn toàn model V1 (Workspace 1 tầng, `clients` đơn giản). DB thật hiện tại vẫn chạy schema V1 cho tới khi có migration chính thức.
> Nguồn nghiệp vụ: `docs/ba/11-data-entities-glossary.md`, `docs/ba/00-overview.md`.

---

## 1. Tổng quan kiến trúc lưu trữ

Giữ nguyên chiến lược 2-database của V1 — không đổi công nghệ, chỉ đổi entity:

| Storage | Role | Service sử dụng |
|---|---|---|
| **PostgreSQL** | Primary store cho identity, tổ chức (Agency/Workspace), thương mại (Package/Campaign/Billing), immutable audit | business-service |
| **MongoDB** | Primary store cho content thực thi (Task, Post, Material, Content Version), operational data | business-service, ai-service, publisher-service |
| **Redis** | Cache layer — không lưu primary data | Tất cả services |
| **ChromaDB** | Vector store cho RAG search | ai-service |

> **Nguyên tắc cốt lõi (không đổi):** Mỗi entity chỉ lưu tại **một** database duy nhất. Không sync, không duplicate.

### 1.1 Thay đổi lớn nhất so với V1

- Thêm tầng **Agency** phía trên Workspace — mọi FK chain giờ bắt đầu từ `agencies`, không phải `workspaces`.
- `clients` (bảng đơn giản V1) → tách thành `client_profiles` (PostgreSQL, tái sử dụng xuyên Agency) + quan hệ N-N với Workspace qua `workspace_members` (Client cũng là 1 dạng WorkspaceMember, role riêng biệt khỏi OWNER/MANAGER).
- Thêm chuỗi thương mại mới: `media_packages`, `workspace_media_packages`, `media_campaigns` — thay thế hoàn toàn `service_package` (jsonb tự do trong `clients` cũ).
- `posts` (MongoDB V1, đơn) → mở rộng thành `tasks` (MongoDB, generic 3 loại: post/livestream/survey) + `task_approvals` (lịch sử duyệt theo từng step, KHÔNG chỉ 1 status field — quyết định thiết kế quan trọng, xem mục 4.4).
- Thêm `third_party_collaborators` + `campaign_collaborators` (N-N) — module hoàn toàn mới, không tồn tại ở V1.
- `content_requests` giữ tên nhưng đổi state machine (`pending → in_progress → accepted/denied`, `denied` là terminal — khác 8-state cũ).

---

## 2. Tiêu chí phân chia (giữ nguyên rule V1, áp dụng lại cho entity mới)

### 2.1 Chọn MongoDB khi:

| Tiêu chí | Áp dụng cho entity V2 |
|---|---|
| Schema linh hoạt, field thêm/bớt không cần migration | `task.typeMetadata` khác nhau theo `type` (post/livestream/survey) |
| Dữ liệu nested, tránh JOIN nhiều bảng | Xem xét inline `approvalHistory[]` trong `tasks` — **quyết định: KHÔNG inline, tách collection riêng** (mục 4.4 — cần query/filter theo step độc lập khi giữ nguyên approval cũ sau reject) |
| High write throughput | `content_versions`, `ai_usage_logs`, `publish_logs` |
| Multi-tenant isolation đơn giản qua filter | Mọi Task/Content collection filter `{ workspaceId }` |

### 2.2 Chọn PostgreSQL khi:

| Tiêu chí | Áp dụng cho entity V2 |
|---|---|
| ACID transaction bắt buộc | Package/Campaign 2-bên-approve (mục 4.3), `transactions` |
| Foreign key constraint thật | `agencies.owner_id → users.id`, `workspaces.agency_id → agencies.id`, `workspace_members` unique(workspace_id, user_id) |
| Immutable audit trail | `audit_logs` (không đổi so với V1) |
| Referential integrity đa cấp | Agency → Workspace → Package → Campaign là chuỗi FK thật, cascade rules rõ ràng |

---

## 3. Hard Rules — Không có ngoại lệ (kế thừa V1 + bổ sung V2)

::: danger Hard Rule 1 — Financial data chỉ PostgreSQL
`subscription_plans`, `user_subscriptions` (plan gắn cấp **User/Owner**, không phải Workspace — xem `docs/ba/08-subscription-billing.md`), `transactions`, `ai_credit_ledgers` — **chỉ** PostgreSQL.
:::

::: danger Hard Rule 2 — Content thực thi chỉ MongoDB
`tasks`, `task_approvals`, `content_versions`, `material_repository`, `posts` (đã publish) — **chỉ** MongoDB. Không mirror sang PostgreSQL.
:::

::: danger Hard Rule 3 — workspaceId bắt buộc
Mọi MongoDB query bắt buộc filter `workspaceId`. Khi Owner truy vấn dữ liệu toàn Agency (nhiều Workspace), lấy danh sách `workspaceId` từ PostgreSQL trước rồi `$in` ở MongoDB — KHÔNG lưu `agencyId` trực tiếp trong content collection.
:::

::: danger Hard Rule 4 — MỚI: Package/Campaign approve phải atomic 2-cột
`workspace_media_packages.approved_by_agency_at` và `approved_by_client_at` chỉ set khi CẢ HAI đều non-null mới coi `negotiation_status = 'approved'`. Khi 1 bên sửa `final_terms`, transaction PHẢI reset cột approve của bên kia về `NULL` trong cùng 1 transaction. Xem `docs/ba/13_Confirmations_Round2_2026-09-15.md` mục 3.
:::

```js
// ❌ SAI
db.tasks.find({ status: 'COMPLETED' })
// ✅ ĐÚNG
db.tasks.find({ workspaceId: ctx.workspaceId, status: 'COMPLETED' })
```

---

## 4. Entity Mapping — Schema V2

### 4.1 PostgreSQL — 4 nhóm

#### Identity (4 bảng — không đổi từ V1)

| Table | Lý do PostgreSQL |
|---|---|
| `users` | `email` UNIQUE atomic, core identity không role/workspace |
| `user_oauth_providers` | 1NF split — array không index được |
| `user_refresh_tokens` | Cần index `jti`, `expires_at`, device tracking |
| `user_system_roles` | ADMIN/USER system-level, discriminated type |

#### Organization — Agency & Workspace (MỚI, thay nhóm "Workspace" V1)

| Table | Lý do PostgreSQL | Ghi chú V2 |
|---|---|---|
| `agencies` | `owner_id` FK thật → users, anchor mới của toàn bộ chain | **MỚI** — mỗi Agency đúng 1 Owner |
| `agency_members` | Junction User↔Agency, KHÔNG có cột role | **MỚI** — role chỉ tồn tại ở `workspace_members` |
| `agency_invitations` | Token single-use, hết hạn 3 ngày | **MỚI** |
| `workspaces` | `agency_id` FK thật → agencies (thay vì đứng độc lập như V1) | **ĐỔI** — Owner suy ra qua `agency.owner_id` |
| `workspace_members` | Role `OWNER`/`MANAGER`/`CREATOR`/`CLIENT` theo TỪNG Workspace | **ĐỔI** — `CLIENT` gộp vào cùng bảng thay vì bảng `clients` riêng |
| `workspace_invitations` | Giữ nguyên V1 | Không đổi |
| `workspace_templates` | Lưu cấu hình Workspace để tái sử dụng | **MỚI** |
| `client_profiles` | Profile riêng của Client, tái sử dụng xuyên nhiều Agency/Workspace | **MỚI**, thay `clients` (V1) — quyết định thiết kế xem mục 4.2 |

#### Commerce — Media Package & Campaign (MỚI hoàn toàn)

| Table | Lý do PostgreSQL |
|---|---|
| `media_packages` | Package template + custom gộp 1 bảng, cột `is_template` phân biệt (mục 4.3) |
| `workspace_media_packages` | Package đã áp dụng + đàm phán cho 1 Workspace, ACID 2-bên-approve |
| `media_campaigns` | Kế hoạch chi tiết sinh từ Package approved, immutable sau approve |

#### Billing (giữ cấu trúc V1, đổi phạm vi gắn Plan)

| Table | Lý do PostgreSQL | Ghi chú V2 |
|---|---|---|
| `subscription_plans` | Master data cố định | Không đổi |
| `user_subscriptions` | ACID upgrade/downgrade | **ĐỔI TÊN** từ `workspace_subscriptions` — Plan gắn cấp **User/Owner**, áp dụng toàn bộ Agency của họ |
| `transactions` | Atomic, PayOS, ACID | **ĐỔI TÊN** từ `payments`, gộp `invoices` |
| `ai_credit_ledgers` | Reset hàng tháng, không rollover | **MỚI** |
| `ai_credit_creator_limits` | Config hạn mức credit riêng từng Creator (Owner set) | **MỚI 2026-09-16** |
| `audit_logs` | Append-only, không đổi | Không đổi |

### 4.2 Quyết định thiết kế: `client_profiles` tách bảng riêng

**Quyết định (đóng câu hỏi mở #1 trong `docs/ba/11-data-entities-glossary.md`):** `client_profiles` là bảng **riêng biệt** khỏi `users`, KHÔNG dùng chung bảng User + cột phân loại.

**Lý do:**
- 1 User có thể vừa là Owner Agency A, vừa là Client ở Workspace của Agency B — dùng chung `users` + cột `type` sẽ phải xử lý 1 user "vừa Owner vừa Client" bằng row trùng email (vi phạm UNIQUE) hoặc 1 row nhiều persona lẫn lộn.
- `client_profiles.linked_user_id` là FK **nullable** → `users.id` — Client có thể được mời vào Workspace trước khi tự đăng ký tài khoản, profile tồn tại độc lập.
- Email trên `client_profiles` **cố định, không đổi được** (FR 3.3.4) — khác hẳn `users.email` (đổi được) → tách bảng tránh nhầm rule.

```
client_profiles.linked_user_id → users.id (nullable)
workspace_members.client_profile_id → client_profiles.id (nullable, chỉ set khi role = CLIENT)
```

### 4.3 Quyết định thiết kế: `media_packages` gộp 1 bảng, không polymorphic

**Quyết định (đóng câu hỏi mở #2):** 1 bảng `media_packages` với cột `is_template boolean`, KHÔNG tách `media_package_templates`/`media_package_customs` polymorphic.

**Lý do:** `workspace_media_packages.package_id` chỉ cần trỏ 1 bảng duy nhất — tránh polymorphic reference (`package_ref_type` + `package_ref_id`) vốn không enforce FK constraint thật. Khi Owner/Manager "custom" 1 Package, hệ thống **copy** row Template thành row mới `is_template = false`, không sửa Template gốc.

### 4.4 Quyết định thiết kế: `tasks` 1 bảng chung + `task_approvals` tách collection riêng

**Quyết định (đóng câu hỏi mở #3):** 1 collection MongoDB `tasks` chung, cột `type` (`post`/`livestream`/`survey`) phân biệt, field riêng nằm trong `typeMetadata` thay vì 3 collection riêng.

**Lý do:** cả 3 loại Task dùng chung 100% Approval Sequence — tách 3 collection sẽ trùng lặp toàn bộ logic transition.

**`task_approvals` tách collection riêng, KHÔNG inline** — lý do trực tiếp từ rule nghiệp vụ: khi Task reject quay về `ASSIGNED`, approval ở step TRƯỚC step bị reject phải **giữ nguyên** (`docs/ba/13_Confirmations_Round2_2026-09-15.md` mục 4). Tách collection cho phép query "approval còn hiệu lực của Task X" độc lập, không phải rebuild mảng inline mỗi lần reject.

### 4.5 MongoDB — Collections (đổi tên/mở rộng từ V1)

| Collection | Đổi so với V1 | Lý do |
|---|---|---|
| `tasks` | **THAY** `posts` — generic 3 loại | Post giờ chỉ là 1 `type` của Task |
| `task_approvals` | **MỚI**, tách từ `posts.approvalHistory[]` | Giữ lịch sử approve khi reject |
| `posts` | **GIỮ nhưng đổi nghĩa** — chỉ còn bài **đã publish thành công** | Tách "đang làm" (Task) khỏi "đã đăng" (Post) |
| `content_requests` | **ĐỔI state machine** — `pending → in_progress → accepted/denied`, `denied` terminal | `docs/ba/13` mục 5 |
| `material_repository` | **MỚI** — kho ảnh/video raw vs retouched | |
| `brand_collections` | **MỚI** — tài liệu Client cung cấp | |
| `hashtag_collections` | **MỚI** — kho hashtag theo Workspace | |
| `content_versions` | **MỚI** — lịch sử version nội dung | |
| `livestream_sessions` | **MỚI 2026-09-16** — con Task loại livestream (idea/script/status) | FR 3.6.22-24, trước đây gộp mơ hồ vào `tasks.typeMetadata` |
| `survey_forms` | **MỚI 2026-09-16** — con Task loại survey (form câu hỏi) | FR 3.6.25 |
| `survey_responses` | **MỚI 2026-09-16** — câu trả lời khảo sát | Tách riêng `survey_forms` vì high write throughput |
| `mail_templates` | **MỚI 2026-09-16** — mẫu email CRUD + gửi | FR 3.6.28-32, thiếu hoàn toàn ở thiết kế trước |
| `social_accounts` | Giữ nguyên V1, bỏ `ZALO_OA` khỏi enum platform | |
| `knowledge_documents`, `ai_usage_logs`, `publish_logs`, `notifications` | Giữ nguyên V1 | Không phụ thuộc Agency/Workspace model |

---

## 5. Cross-DB Reference Strategy (không đổi nguyên tắc, mở rộng phạm vi)

```
media_campaigns.id (PostgreSQL)
    ↕ application-level join
tasks.sourceRefId (MongoDB, khi sourceType = 'campaign')
```

### 5.1 Soft refs mới trong V2

| MongoDB field | Trỏ tới | Lưu ý |
|---|---|---|
| `tasks.workspaceId` | `workspaces.id` (PG) | Soft ref |
| `tasks.sourceRefId` | `media_campaigns.id` hoặc `content_requests._id` (tuỳ `sourceType`) | Soft ref, polymorphic ở tầng MongoDB — chấp nhận (không cần FK constraint) |
| `tasks.assigneeId`, `tasks.qcAssigneeId` | `users.id` (PG) | Soft ref |
| `task_approvals.taskId` | `tasks._id` | Cùng DB — dùng ref chuẩn Mongo |
| `content_requests.createdByClientProfileId` | `client_profiles.id` (PG) | Soft ref |
| `posts.taskId` | `tasks._id` | Link bài đã publish về Task gốc |

---

## 6. Redis, ChromaDB, Query Pattern, Security, Migration

Không đổi so với V1 — độc lập với model nghiệp vụ Agency/Workspace. Xem `docs/database/DA-E06-06-redis-key-patterns.md`, `DA-AI02-07-chromadb-collection-design.md` (không sửa trong đợt V2 này).

---

## 7. Sơ đồ tổng quan V2

```
┌──────────────────────────────────────────────────────────────────────────┐
│                          business-service                                 │
│                                                                           │
│  PostgreSQL                              MongoDB                          │
│  ── Identity ──                          ├── tasks              (NEW)     │
│  ├── users                               ├── task_approvals     (NEW)     │
│  ├── user_oauth_providers                ├── posts        (đổi nghĩa)     │
│  ├── user_refresh_tokens                 ├── content_requests (đổi FSM)   │
│  ├── user_system_roles                   ├── material_repository (NEW)    │
│  ── Organization (NEW) ──                ├── brand_collections   (NEW)    │
│  ├── agencies                   (NEW)    ├── hashtag_collections (NEW)    │
│  ├── agency_members              (NEW)    ├── content_versions    (NEW)    │
│  ├── agency_invitations          (NEW)    ├── livestream_sessions (NEW)    │
│  ├── workspaces               (đổi FK)    ├── survey_forms        (NEW)    │
│  ├── workspace_members          (đổi)     ├── survey_responses    (NEW)    │
│  ├── workspace_invitations                ├── mail_templates      (NEW)    │
│                                            ├── social_accounts             │
│                                            └── notifications               │
│                                                                            │
│                                            Redis (cache — không đổi)       │
│  ├── workspace_templates         (NEW)                                    │
│  ├── client_profiles          (đổi tên)                                   │
│  ── Commerce (NEW) ──                                                     │
│  ├── media_packages              (NEW)                                    │
│  ├── workspace_media_packages    (NEW)                                    │
│  ├── media_campaigns             (NEW)                                    │
│  ── Billing (đổi phạm vi) ──                                              │
│  ├── subscription_plans                                                   │
│  ├── user_subscriptions        (đổi tên, gắn User thay Workspace)         │
│  ├── transactions               (đổi tên, gộp invoices)                   │
│  ├── ai_credit_ledgers           (NEW)                                    │
│  ├── ai_credit_creator_limits    (NEW, per-Creator cap)                   │
│  └── audit_logs                                                           │
├──────────────────────────────────────────────────────────────────────────┤
│                            ai-service                                     │
│  MongoDB (không đổi)                  ChromaDB (không đổi)                │
│  ├── knowledge_documents              └── brand_embeddings_{wsId}        │
│  └── ai_usage_logs                    Redis                               │
│                                       └── trends:vn:{date}:{cat}         │
├──────────────────────────────────────────────────────────────────────────┤
│                    Third-party Collaborator (NEW, business-service)       │
│  PostgreSQL                                                               │
│  ├── third_party_collaborators   (danh bạ cấp Agency)                    │
│  └── campaign_collaborators      (N-N, trạng thái theo từng Campaign)     │
├──────────────────────────────────────────────────────────────────────────┤
│                         publisher-service                                 │
│  MongoDB (không đổi)                                                      │
│  └── publish_logs                                                         │
└──────────────────────────────────────────────────────────────────────────┘
```

---

## 8. Acceptance Criteria

- [x] Document liệt kê thay đổi entity V1 → V2, giữ nguyên rule phân chia MongoDB/PostgreSQL
- [x] Agency/Workspace/Package/Campaign/Task entity mapped với lý do PostgreSQL/MongoDB
- [x] 3/5 câu hỏi thiết kế mở trong `docs/ba/11-data-entities-glossary.md` đã được QUYẾT ĐỊNH ở đây (client_profiles tách bảng, media_packages gộp 1 bảng, tasks 1 bảng + task_approvals tách collection) — cần Trung xác nhận trước khi tạo migration thật
- [x] Cross-DB reference strategy mở rộng cho entity mới
- [x] Ghi rõ STATUS: DESIGN, chưa áp dụng `init-postgres.sql` thật
- [x] Third-party Collaborator module (N-N) được thiết kế
