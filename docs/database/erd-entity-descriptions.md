# DA-D12-03 — [R3 §3.1.5] ERD Entity Descriptions V2

> **STATUS: DESIGN** — schema mới cho nghiệp vụ V2 (Agency → Workspace → Media Package → Media Campaign → Task), chưa áp dụng vào `scripts/init-postgres.sql` thật.
> **Owner:** Trung | **Priority:** 🟡 Medium
> **Nguồn:** `docs/ba/11-data-entities-glossary.md`, `docs/database/database-strategy.md`
> **Source ERD:** [`brandhub-erd.puml`](./brandhub-erd.puml) · [`brandhub-dbml.dbml`](./brandhub-dbml.dbml) · [`brandhub-schema-diagram.html`](./brandhub-schema-diagram.html)

---

## 1. ERD Figure

> Render `brandhub-erd.puml` (PlantUML) hoặc mở `brandhub-schema-diagram.html` cho interactive schema diagram.

---

## 2. Entity Descriptions

BrandHub V2's ERD chứa **31 entity**: **21 PostgreSQL** tables (identity, tổ chức Agency/Workspace, thương mại Package/Campaign, Third-party Collaborator, billing) và **10 MongoDB** collections (Task/content thực thi, operational data). Xem [`database-strategy.md`](./database-strategy.md) cho storage-split rationale và các quyết định thiết kế.

### 2.1 PostgreSQL — Identity Group (4 tables, không đổi so với V1)

| # | Entity | Description |
|---|---|---|
| 1 | `users` | Core user account: credentials, profile, status. Anchor cho mọi identity FK. |
| 2 | `user_oauth_providers` | Liên kết user với OAuth identity ngoài (Google, Facebook). |
| 3 | `user_refresh_tokens` | Refresh token active theo device/session. |
| 4 | `user_system_roles` | Role hệ thống (`ADMIN`/`USER`), tách biệt khỏi role theo Workspace. |

### 2.2 PostgreSQL — Organization Group (8 tables, MỚI/ĐỔI V2)

| # | Entity | Trạng thái | Description |
|---|---|---|---|
| 5 | `agencies` | **MỚI** | Công ty truyền thông, anchor mới của toàn bộ chain. Mỗi Agency đúng 1 Owner. |
| 6 | `agency_members` | **MỚI** | Junction User↔Agency, KHÔNG có cột role. |
| 7 | `agency_invitations` | **MỚI** | Lời mời vào Agency, hết hạn 3 ngày. |
| 8 | `workspaces` | **ĐỔI** | Thuộc 1 Agency (FK thật), phục vụ nhiều Client. Owner suy ra qua `agency.owner_id`. |
| 9 | `workspace_members` | **ĐỔI** | Role theo TỪNG Workspace (`OWNER`/`MANAGER`/`CREATOR`/`CLIENT`) — gộp Client vào đây, thay bảng `clients` V1. |
| 10 | `workspace_invitations` | Không đổi | Lời mời vào Workspace. |
| 11 | `workspace_templates` | **MỚI** | Lưu cấu hình Workspace để tái sử dụng khi tạo Workspace mới. |
| 12 | `client_profiles` | **MỚI** | Profile riêng của Client, tái sử dụng xuyên nhiều Agency/Workspace. Email cố định (FR 3.3.4). |

### 2.3 PostgreSQL — Commerce Group (3 tables, MỚI hoàn toàn V2)

| # | Entity | Description |
|---|---|---|
| 13 | `media_packages` | Package mẫu (Admin tạo) hoặc custom (Owner/Manager tạo), gộp 1 bảng qua cột `is_template`. |
| 14 | `workspace_media_packages` | Package đã áp dụng + đàm phán cho 1 Workspace cụ thể — ACID 2-bên-approve. |
| 15 | `media_campaigns` | Kế hoạch thực thi chi tiết, sinh từ Package đã approve. Immutable sau approve. |

### 2.4 PostgreSQL — Third-party Collaborator Group (2 tables, MỚI hoàn toàn V2)

| # | Entity | Description |
|---|---|---|
| 16 | `third_party_collaborators` | Danh bạ đối tác truyền thông ngoài (báo/banner/TV) cấp Agency, tái sử dụng qua nhiều Campaign. |
| 17 | `campaign_collaborators` | Bảng liên kết N-N — trạng thái hợp tác (`contacted`/`negotiating`/`confirmed`/`live`) theo TỪNG Campaign. |

### 2.5 PostgreSQL — Billing Group (5 tables, đổi phạm vi gắn Plan)

| # | Entity | Trạng thái | Description |
|---|---|---|---|
| 18 | `subscription_plans` | Không đổi | Catalog gói (Basic/Pro/Enterprise). |
| 19 | `user_subscriptions` | **ĐỔI TÊN** | Từ `workspace_subscriptions` — Plan gắn cấp **User/Owner**, áp dụng toàn bộ Agency của họ. |
| 20 | `transactions` | **ĐỔI TÊN** | Từ `payments`, gộp `invoices` — giao dịch PayOS, ACID. |
| 21 | `ai_credit_ledgers` | **MỚI** | Sổ credit AI theo tháng, reset hàng tháng, KHÔNG rollover. |
| — | `audit_logs` | Không đổi | Append-only, log hành động nhạy cảm. |

### 2.6 MongoDB Collections (10 collections)

| # | Entity | Trạng thái | Description |
|---|---|---|---|
| 22 | `tasks` | **MỚI**, thay `posts` V1 | Đơn vị công việc chung 3 loại (post/livestream/survey), dùng chung Approval Sequence. |
| 23 | `task_approvals` | **MỚI**, tách khỏi `tasks` | Lịch sử duyệt theo từng step — giữ nguyên approval cũ khi step sau bị reject. |
| 24 | `posts` | **ĐỔI NGHĨA** | Chỉ còn bài ĐÃ PUBLISH thành công lên social (kết quả Task type=post hoàn thành). |
| 25 | `content_requests` | **ĐỔI FSM** | `pending → in_progress → accepted/denied`, `denied` là trạng thái terminal. |
| 26 | `material_repository` | **MỚI** | Kho ảnh/video, phân biệt raw vs đã retouch. |
| 27 | `brand_collections` | **MỚI** | Tài liệu Client cung cấp làm tham khảo. |
| 28 | `hashtag_collections` | **MỚI** | Kho hashtag theo Workspace. |
| 29 | `content_versions` | **MỚI** | Lịch sử version nội dung (Content History). |
| 30 | `social_accounts` | Giữ nguyên, bỏ `ZALO_OA` | Tài khoản social đã connect (Facebook/Instagram/TikTok/Threads). |
| 31 | `notifications` | Giữ nguyên, thêm type mới | Thông báo, thêm loại cho Package/Campaign/Task approval. |

---

## 3. Relationship Notes

Full FK relationship diagram nằm ở [`brandhub-erd.puml`](./brandhub-erd.puml). Tóm tắt:

- **Identity chain**: `users` toả FK tới `user_oauth_providers`, `user_refresh_tokens`, `user_system_roles`, và giờ còn là anchor của `agencies.owner_id`.
- **Organization chain (MỚI)**: `agencies` → `workspaces` → `workspace_members`/`workspace_invitations`/`ws_media_packages`. `client_profiles` liên kết N-N tới `workspace_members` (chỉ khi `role = CLIENT`).
- **Commerce chain (MỚI)**: `media_packages` → `workspace_media_packages` → `media_campaigns` → `campaign_collaborators` → `third_party_collaborators`.
- **Billing chain**: `user_subscriptions → subscription_plans`, `transactions → users` (không còn qua `invoices` riêng như V1).
- **MongoDB collections** dùng **soft reference** (string ID, không FK enforce) về `workspaceId`/`userId`/`clientProfileId` PostgreSQL — nhất quán với chiến lược đa DB, referential integrity thực thi ở application layer.

::: warning Ghi chú thay đổi lớn nhất
So với V1 (17 entity theo mô tả gốc cũ, thực tế tăng lên 23 entity trước khi V2), schema V2 tăng lên **31 entity** — chủ yếu do 3 nhóm hoàn toàn mới: Organization (Agency layer, 8 bảng), Commerce (Media Package/Campaign, 3 bảng), Third-party Collaborator (2 bảng). Đây là thiết kế **DESIGN**, chưa migrate vào DB thật.
:::
