# DA-E06-01 — Database Strategy V2: MongoDB vs PostgreSQL

> Navigation: [← Knowledge Base Hub](../../index.md) · [← Database Hub](../README.md) · [ERD Entity Descriptions](./erd-entity-descriptions.md)
>
> **STATUS: IMPLEMENTED IN V2/V3 BASELINE** — Áp dụng chính thức trong `database/init/init-postgres-v2.sql` (**97 bảng PostgreSQL**) và `database/init/init-mongo.js` (**52 collections MongoDB**) theo mô hình `Agency → Workspace → Media Package → Media Campaign → Task → Post`.
> Nguồn nghiệp vụ: [11-data-entities-glossary.md](../../ba/11-data-entities-glossary.md), [BA Overview](../../ba/README.md).

---

## 1. Tổng quan kiến trúc lưu trữ

Hệ thống vận hành trên kiến trúc đa cơ sở dữ liệu (5-engine polyglot persistence), phân tách rõ theo đặc tính ACID, cấu trúc linh hoạt và truy vấn ngữ nghĩa/đồ thị:

| Storage | Role | Service sử dụng |
|---|---|---|
| **PostgreSQL 17** | Primary ACID store (**97 tables**) cho identity, tổ chức (`Agency`/`Workspace`/`Client`), thương mại (`Package`/`Campaign`), Billing V3 (**SePay VietQR**), AI Credit Wallets, Product Video Production, Storage Quota/Drive Sync, Mail Delivery & immutable audit | `brandhub-business-service` |
| **MongoDB 7.0** | Primary document store (**52 collections**) cho thực thi nội dung (`Task`, `TaskSection`, `Post`, `Material`, `Survey`, `Chat`, `VideoProject`), monitoring & operational logs | `brandhub-business-service`, `brandhub-ai-service`, `brandhub-publisher-service` |
| **Redis 7** | Ephemeral coordination & cache layer (JWT blacklist, Gateway rate-limit, OAuth state, trend ZSET, publisher lock) — không lưu primary data | Tất cả 4 backend services |
| **ChromaDB** | HNSW 384-d vector store cho Brand RAG (`client_{clientId}`) & trend chunks | `brandhub-ai-service` |
| **Neo4j 5** | Knowledge Graph cho Trend Centrality (`:Trend`, `:User`) & GraphRAG 1–2 hop traversal | `brandhub-ai-service` |

> **Nguyên tắc cốt lõi (không đổi):** Mỗi entity chỉ lưu tại **một** database duy nhất. Không sync, không duplicate.

### 1.1 Thay đổi lớn nhất so với V1

- Thêm tầng **Agency** phía trên Workspace — mọi FK chain giờ bắt đầu từ `agencies`, không phải `workspaces`.
- `clients` (bảng đơn giản V1) → tách thành `client_profiles` (PostgreSQL, tái sử dụng xuyên Agency) + quan hệ N-N với Workspace qua `workspace_members` (Client cũng là 1 dạng WorkspaceMember, role riêng biệt khỏi OWNER/MANAGER).
- Thêm chuỗi thương mại mới: `media_packages`, `workspace_media_packages`, `media_campaigns` — thay thế hoàn toàn `service_package` (jsonb tự do trong `clients` cũ).
- `posts` (MongoDB V1, đơn) → mở rộng thành `tasks` (MongoDB, đa loại công việc: `POST`, `SURVEY`, `SHORT_VIDEO`, `EVENT_PLAN`, `PRESS_RECOMMENDATION`) + `task_approvals` (lịch sử duyệt theo từng step, KHÔNG chỉ 1 status field — xem mục 4.4).
- Thêm `third_party_collaborators` + `campaign_collaborators` (N-N) — module hoàn toàn mới, không tồn tại ở V1.
- `content_requests` giữ tên nhưng đổi state machine (`pending → in_progress → accepted/denied`, `denied` là terminal — khác 8-state cũ).

---

## 2. Tiêu chí phân chia (giữ nguyên rule V1, áp dụng lại cho entity mới)

### 2.1 Chọn MongoDB khi:

| Tiêu chí | Áp dụng cho entity V2 |
|---|---|
| Schema linh hoạt, field thêm/bớt không cần migration | `task.typeMetadata` khác nhau theo `type` (`POST`/`SURVEY`/`SHORT_VIDEO`/`EVENT_PLAN`/`PRESS_RECOMMENDATION`) |
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
`subscription_plans`, `user_subscriptions`, `agency_subscriptions` (xem [08-subscription-billing.md](../../ba/08-subscription-billing.md)), `billing_orders`, `billing_payments`, `transactions` (**SePay VietQR**), `agency_credit_wallets`, `ai_credit_reservations` — **chỉ** PostgreSQL.
:::

::: danger Hard Rule 2 — Content thực thi chỉ MongoDB
`tasks`, `task_approvals`, `content_versions`, `materials`, `posts` (đã publish) — **chỉ** MongoDB. Không mirror sang PostgreSQL.
:::

::: danger Hard Rule 3 — workspaceId bắt buộc
Mọi MongoDB query bắt buộc filter `workspaceId`. Khi `Owner` truy vấn dữ liệu toàn Agency (nhiều Workspace), lấy danh sách `workspaceId` từ PostgreSQL trước rồi `$in` ở MongoDB — KHÔNG lưu `agencyId` trực tiếp trong content collection.
:::

::: danger Hard Rule 4 — MỚI: Package/Campaign approve phải atomic 2-cột
`workspace_media_packages.approved_by_agency_at` và `approved_by_client_at` chỉ set khi CẢ HAI đều non-null mới coi `negotiation_status = 'approved'`. Khi 1 bên sửa `final_terms`, transaction PHẢI reset cột approve của bên kia về `NULL` trong cùng 1 transaction (`FR 3.5.3`–`FR 3.5.4`).
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
| `agencies` | `owner_id` FK thật → users, anchor mới của toàn bộ chain | **MỚI** — mỗi Agency đúng 1 `Owner` |
| `agency_members` | Junction User↔Agency | **MỚI** — quyền vận hành chi tiết nằm ở `workspace_members` |
| `agency_invitations` | Token single-use, hết hạn 30 ngày (`BR-17`) | **MỚI** |
| `workspaces` | `agency_id` FK thật → agencies (thay vì đứng độc lập như V1) | **ĐỔI** — `Owner` suy ra qua `agencies.owner_id` |
| `workspace_members` | Role `MANAGER`/`CREATOR`/`CLIENT` theo TỪNG Workspace | **ĐỔI** — `CLIENT` gộp vào cùng bảng thay vì bảng `clients` riêng (`Owner` không lưu trùng ở enum này mà xác định qua `agencies.owner_id`) |
| `workspace_invitations` | Giữ nguyên V1 | Không đổi |
| `workspace_templates` | Lưu cấu hình Workspace để tái sử dụng | **MỚI** |
| `client_profiles` | Profile riêng của Client, tái sử dụng xuyên nhiều Agency/Workspace | **MỚI**, thay `clients` (V1) — quyết định thiết kế xem mục 4.2 |

#### Commerce — Media Package & Campaign (MỚI hoàn toàn)

| Table | Lý do PostgreSQL |
|---|---|
| `media_packages` | Package template + custom gộp 1 bảng, cột `is_template` phân biệt (mục 4.3) |
| `workspace_media_packages` | Package đã áp dụng + đàm phán cho 1 Workspace, ACID 2-bên-approve |
| `media_campaigns` | Kế hoạch chi tiết sinh từ Package approved, immutable sau approve |

#### Billing & AI Credit Wallets (SePay VietQR, Upgrade-Only)

| Table | Lý do PostgreSQL | Ghi chú V2 / V3 |
|---|---|---|
| `subscription_plans` | Master data 6 gói (`STUDIO_FREE/PLUS/PRO`, `BASIC/PLUS/ENTERPRISE`) | Mở rộng 2 dòng sản phẩm |
| `user_subscriptions` / `agency_subscriptions` | ACID upgrade-only (`FR 3.9.1`, không hỗ trợ hạ cấp trực tiếp) | Gắn cấp `Owner` / `Agency` |
| `billing_orders` / `billing_payments` / `transactions` | Atomic, **SePay (VietQR)** webhook idempotent, ACID (`FR 3.9.2`) | Chuẩn hóa cổng SePay |
| `agency_credit_wallets` / `credit_grants` / `ai_credit_reservations` | Sổ cái giữ chỗ, khấu trừ và hoàn trả AI Credit nguyên tử | Thay thế bản nháp `ai_credit_ledgers` cũ |
| `workspace_credit_limits` | Hạn mức AI Credit tháng cho từng Workspace (`FR 3.9.6 Set Credit`) | Thay thế bản nháp `ai_credit_creator_limits` cũ |
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

**Quyết định (đóng câu hỏi mở #3):** 1 collection MongoDB `tasks` chung, cột `type` phân biệt `POST`/`SURVEY`/`SHORT_VIDEO` và hai loại mở rộng `EVENT_PLAN`/`PRESS_RECOMMENDATION`. Nội dung chuyên biệt của hai loại mở rộng nằm trong `event_plans`/`press_recommendations`; identity và workflow vẫn ở `tasks`.

**Lý do:** các Task type dùng chung Approval Sequence — tách collection workflow theo loại sẽ trùng lặp logic transition.

**`task_approvals` tách collection riêng, KHÔNG inline** — lý do trực tiếp từ rule nghiệp vụ (`FR 3.6.9`): khi Task bị reject sẽ quay về bước `Creator` đầu tiên, nhưng toàn bộ nhật ký duyệt và nhận xét của các vòng trước phải **giữ nguyên**. Collection là append-only; `tasks.approvalRound` tăng mỗi lần resubmit, và mỗi approval lưu round tương ứng.

### 4.5 MongoDB — Collections cốt lõi (đổi tên/mở rộng từ V1; danh mục đủ 52 collections xem [erd-entity-descriptions.md](./erd-entity-descriptions.md))

| Collection | Đổi so với V1 | Lý do |
|---|---|---|
| `tasks` | **THAY** `posts` — đa loại công việc | Post giờ chỉ là 1 `type` của Task; Campaign work item được chống trùng bằng partial unique index |
| `event_plans` / `press_recommendations` | **MỚI**, nội dung chuyên biệt của Task | Không tạo module vận hành sự kiện hoặc booking báo chí |
| `task_approvals` | **MỚI**, tách từ `posts.approvalHistory[]` | Giữ lịch sử approve khi reject (`FR 3.6.9`) |
| `posts` | **GIỮ nhưng đổi nghĩa** — bài gắn Task lên lịch / đã publish | Tách "đang sản xuất" (`tasks`) khỏi "xuất bản mạng xã hội" (`posts`) |
| `content_requests` | **ĐỔI state machine** — `PENDING → IN_PROGRESS → ACCEPTED / DENIED / CANCELLED` | `FR 3.5.10`–`3.5.13` |
| `materials` / `material_folders` / `material_versions` | **MỚI** — kho tư liệu RAW vs Retouched & Brand Reference (`FR 3.6.11`–`3.6.19`) | |
| `watermark_presets` | **MỚI** — cấu hình đóng dấu bản quyền (`FR 3.6.18`) | |
| `surveys` | **MỚI** — biểu mẫu khảo sát (`FR 3.6.25`) | |
| `survey_responses` | **MỚI** — câu trả lời khảo sát (`FR 3.6.26`) | Tách riêng vì high write throughput |
| `mail_templates` | **MỚI** — mẫu email CRUD + gửi (`FR 3.6.28`–`3.6.32`) | |
| `social_accounts` | 4 nền tảng chuẩn: `FACEBOOK`, `INSTAGRAM`, `TIKTOK`, `THREADS` (`FR 3.8.1`) | |
| `knowledge_documents`, `ai_usage_logs`, `publish_logs`, `notifications` | Giữ nguyên phân tách theo service | Xem [Service Boundaries](../../architecture/service-boundaries.md) |

---

## 5. Cross-DB Reference Strategy (không đổi nguyên tắc, mở rộng phạm vi)

```
media_campaigns.id (PostgreSQL)
    ↕ application-level join
tasks.campaignId (MongoDB, nullable khi Task sinh từ Content Request)
```

### 5.1 Soft refs mới trong V2

| MongoDB field | Trỏ tới | Lưu ý |
|---|---|---|
| `tasks.workspaceId` | `workspaces.id` (PG) | Soft ref |
| `tasks.campaignId` | `media_campaigns.id` | Soft ref; `null` khi Task sinh từ Content Request hoặc không thuộc Campaign |
| `tasks.assigneeId`, `tasks.qcAssigneeId` | `users.id` (PG) | Soft ref |
| `task_approvals.taskId` | `tasks._id` | Cùng DB — dùng ref chuẩn Mongo |
| `content_requests.createdByClientProfileId` | `client_profiles.id` (PG) | Soft ref |
| `posts.taskId` | `tasks._id` | Link bài đã publish về Task gốc |

---

## 6. Redis, ChromaDB, Query Pattern, Security, Migration

Xem chi tiết tại [DA-E06-06 — Redis Key Patterns](../redis-cache/redis-key-patterns.md), [DA-E06-08 — Database Access Rules](../redis-cache/database-access-rules.md), và [DA-AI02-07 — ChromaDB Collection Design](../ai-vector/chromadb-collection-design.md).

---

## 7. Sơ đồ tổng quan cốt lõi V2 (Danh mục đầy đủ 97 PG + 52 Mongo xem `erd-entity-descriptions.md`)

```text
┌──────────────────────────────────────────────────────────────────────────┐
│                          business-service                                │
│                                                                          │
│  PostgreSQL (97 tables)                  MongoDB (49 collections)        │
│  ── Identity ──                          ├── tasks                       │
│  ├── users                               ├── task_approvals              │
│  ├── user_oauth_providers                ├── task_sections / versions    │
│  ├── user_refresh_tokens                 ├── posts / post_versions       │
│  ├── user_system_roles                   ├── content_requests            │
│  ── Organization ──                      ├── materials / folders         │
│  ├── agencies                            ├── watermark_presets           │
│  ├── agency_members                      ├── surveys / survey_responses  │
│  ├── agency_invitations                  ├── mail_templates              │
│  ├── workspaces                          ├── social_accounts             │
│  ├── workspace_members                   ├── chat_channels / messages    │
│  ├── workspace_invitations               ├── video_projects              │
│  ├── workspace_templates                 └── notifications               │
│  ├── client_profiles                                                     │
│  ── Commerce & Collaborators ──          Redis (auth & session state)    │
│  ├── media_packages                                                      │
│  ├── workspace_media_packages                                            │
│  ├── media_campaigns                                                     │
│  ├── third_party_collaborators                                           │
│  ├── campaign_collaborators                                              │
│  ── Billing (SePay) & AI Credits ──                                      │
│  ├── subscription_plans                                                  │
│  ├── agency_subscriptions / billing_orders / billing_payments            │
│  ├── transactions (SePay VietQR)                                         │
│  ├── agency_credit_wallets / credit_grants                               │
│  ├── workspace_credit_limits / ai_credit_reservations                    │
│  └── audit_logs                                                          │
├──────────────────────────────────────────────────────────────────────────┤
│                            ai-service                                    │
│  MongoDB (2 collections)              ChromaDB + Neo4j + Redis           │
│  ├── knowledge_documents              ├── client_{clientId} (384d HNSW)  │
│  └── ai_usage_logs                    ├── Neo4j Trend Knowledge Graph    │
│                                       └── trends:vn:{date}:{cat}         │
├──────────────────────────────────────────────────────────────────────────┤
│                         publisher-service                                │
│  MongoDB (1 collection)                                                  │
│  └── publish_logs                                                        │
└──────────────────────────────────────────────────────────────────────────┘
```

---

## 8. Mở rộng V3 trong Production Baseline (97 PG Tables + 52 Mongo Collections)

Ngoài 4 nhóm cốt lõi ở mục 4, baseline hiện hành trong `database/init/init-postgres-v2.sql` và `database/init/init-mongo.js` đã hoàn thiện thêm 5 phân hệ mở rộng:

1. **Billing V3 — 6 Gói Studio/Agency & Chu kỳ giá (`29 bảng PG`)**:
   - Mở rộng `subscription_plans` thành 2 dòng sản phẩm: **Studio** (`STUDIO_FREE`, `STUDIO_PLUS`, `STUDIO_PRO`) và **Agency** (`BASIC`, `PLUS`, `ENTERPRISE`), quản lý giá theo chu kỳ tháng/năm tại `billing_plan_cycle_prices` và lịch sử chỉnh sửa cấu hình gói của `Admin` tại `billing_plan_change_log`.
   - Cổng thanh toán chuẩn hóa duy nhất qua **SePay (VietQR)** (`billing_orders` → `billing_payment_attempts` → `billing_payment_events` → `billing_payments` → `billing_order_fulfillments`), chỉ hỗ trợ nâng cấp gói (`FR 3.9.1`, không có luồng hạ cấp).
2. **Product Video Production & Studio (`7 bảng PG` + `4 collections Mongo`)**:
   - Trạng thái điều phối render, storyboard JSONB, báo giá credit và khóa thuê bao worker nằm trên PostgreSQL (`product_video_productions`, `product_video_plans`, `product_video_quotes`, `product_video_attempts`, `product_video_requests`) gắn trực tiếp FK `reservation_id → ai_credit_reservations`.
   - Timeline dự án dựng phim và AI Auto-Edit nằm trên MongoDB (`video_projects`, `video_project_assets`, `video_project_upload_sessions`, `video_auto_edits`), liên kết qua soft-ref `product_video_productions.project_id`.
3. **Storage Quota, Client Vault, Envelope Encryption & Google Drive Sync (`17 bảng PG` + `8 collections Mongo`)**:
   - Tách bạch dung lượng của Agency (`agency_storage_usage`, `agency_storage_reservations`) và kho tư liệu riêng của `Client` (`client_vault_storage_usage`, `client_vault_quota_releases`, `client_vault_shares`), hỗ trợ mua thêm gói dung lượng qua `storage_addon_plans` / `storage_addon_subscriptions`.
   - Đồng bộ dung lượng bất đồng bộ an toàn từ MongoDB `material_audit_outbox` sang PostgreSQL `material_audit_receipts`, kết hợp đồng bộ 2 chiều Google Drive (`agency_drive_connections`, `workspace_drive_folders`, `repository_drive_*`).
   - Toàn bộ khóa bọc dữ liệu S3/Vault sử dụng mã hóa phong bì KMS `RepositoryEnvelopeCrypto` (`ALG_AES_256_GCM_HKDF_SHA512_COMMIT_KEY`) lưu metadata cipher trên `materials` và `material_folders`.
4. **Mail Batches, Newsletter Quota & Engagement Reminders (`7 bảng PG` + `2 collections Mongo`)**:
   - Mẫu thiết kế HTML nằm ở MongoDB (`mail_templates`, `mail_recipient_groups`), trong khi hàng đợi phát tán hàng loạt dùng `FOR UPDATE SKIP LOCKED` trên PostgreSQL (`mail_batches`, `mail_deliveries`, `mail_send_quota`, `mail_suppressions`, `newsletter_usage`) kèm lịch nhắc tương tác chiến dịch tại `engagement_reminders`.
5. **Realtime In-App Notifications (`LISTEN/NOTIFY`) & Infrastructure Monitoring**:
   - Bảng `user_notifications` gắn PostgreSQL trigger `trg_user_notifications_Insert` phát sự kiện `pg_notify('user_notifications_channel', ...)` để đẩy thông báo thời gian thực qua WebSocket STOMP tới đúng người dùng mà không cần polling.
   - Bốn collection `monitoring_servers`, `monitoring_collectors`, `monitoring_enrollments`, `monitoring_health_targets` phục vụ trang giám sát sức khỏe hạ tầng của `Admin` (`FR 3.10.3`).

---

## 9. Acceptance Criteria

- [x] Document liệt kê thay đổi entity V1 → V2/V3, giữ nguyên rule phân chia PostgreSQL / MongoDB / Redis / ChromaDB / Neo4j
- [x] Agency/Workspace/Package/Campaign/Task entity mapped với lý do PostgreSQL/MongoDB
- [x] Chốt 3 quyết định thiết kế cốt lõi (`client_profiles` tách bảng, `media_packages` gộp 1 bảng, `tasks` chung + `task_approvals` append-only)
- [x] Cross-DB reference strategy mở rộng cho entity V2/V3 (bao gồm `product_video_productions` ↔ `video_projects` và `material_audit_outbox` ↔ `material_audit_receipts`)
- [x] Đồng bộ thực thi trực tiếp trong `database/init/init-postgres-v2.sql` (97 bảng) và `database/init/init-mongo.js` (52 collections)
- [x] Third-party Collaborator module (N-N), SePay Billing V3, Client Vault & `LISTEN/NOTIFY` được tài liệu hóa đầy đủ
