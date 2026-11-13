# DA-D12-03 — [R3 §3.1.5] ERD Entity Descriptions (Current Sync)

> **STATUS: ACTIVE / SYNCED** — Đồng bộ trực tiếp từ codebase `brandhub-business-service` (`@Entity` + SQL repositories + `@Document` + Mongo stores), [`init-postgres-v2.sql`](../init-postgres-v2.sql), và [`init-mongo.js`](../init-mongo.js).
> **Owner:** Trung | **Updated:** 2026-11-12
> **Source ERD:** [`brandhub-erd.puml`](./brandhub-erd.puml) · [`brandhub-dbml.dbml`](./brandhub-dbml.dbml) · [`brandhub-schema-diagram.html`](./brandhub-schema-diagram.html)

---

## 1. Tổng quan số lượng Entity

Hệ thống BrandHub hiện tại gồm **147 entities** (không tính Redis cache, ChromaDB vector collections, Neo4j graph):
- **PostgreSQL: 95 tables** (**93** domain/application tables + **2** infrastructure/seed tables `brandhub_schema_migrations`, `seed_runs`)
  - Trong đó có **31** JPA `@Entity` tables và **64** SQL/JDBC tables (62 domain + 2 infra/seed).
- **MongoDB: 52 collections** (**51** domain/application collections + **1** seed marker `seed_runs`; bao gồm 4 collection V1/seed-compat `users`, `workspaces`, `workspace_members`, `clients`)
  - Trong đó có **31** Spring Data `@Document` classes và **21** `MongoTemplate`/schema-managed collections.

---

## 2. PostgreSQL Entities (95 tables)

### 2.1 Identity & Auth (5 tables)

| # | Entity | Source | Description |
|---|---|---|---|
| 1 | `users` | `@Entity User` | Core user account: credentials, profile, status. Anchor cho mọi identity FK. |
| 2 | `user_oauth_providers` | `@Entity UserOAuthProvider` | Liên kết user với OAuth identity ngoài (Google, Facebook). |
| 3 | `user_refresh_tokens` | `@Entity UserRefreshToken` | Refresh token active theo device/session. |
| 4 | `user_system_roles` | `@Entity UserSystemRole` | Role hệ thống (`ADMIN`/`USER`), tách biệt khỏi role theo Workspace. |
| 5 | `account_activation_tokens` | SQL | Token kích hoạt tài khoản một lần (Admin tạo user / invite). |

### 2.2 Organization: Agency, Workspace & Client (8 tables)

| # | Entity | Source | Description |
|---|---|---|---|
| 6 | `agencies` | `@Entity Agency` | Công ty truyền thông, anchor của toàn bộ chain. Mỗi Agency có 1 `owner_id`. |
| 7 | `agency_members` | `@Entity AgencyMember` | Junction User↔Agency (không lưu role; role nằm ở `workspace_members`). |
| 8 | `agency_invitations` | `@Entity AgencyInvitation` | Lời mời gia nhập Agency. |
| 9 | `client_profiles` | `@Entity ClientProfile` | Profile riêng của Client, tái sử dụng xuyên nhiều Agency/Workspace. |
| 10 | `workspaces` | `@Entity Workspace` | Không gian làm việc thuộc 1 `agency_id` (FK thật), phục vụ Client. |
| 11 | `workspace_members` | `@Entity WorkspaceMember` | Role theo Workspace (`OWNER`/`MANAGER`/`CREATOR`/`CLIENT`), liên kết `client_profiles` khi `role = CLIENT`. |
| 12 | `workspace_invitations` | `@Entity WorkspaceInvitation` | Lời mời vào Workspace. |
| 13 | `workspace_templates` | `@Entity WorkspaceTemplate` | Lưu cấu hình Workspace để tái sử dụng khi tạo Workspace mới. |

### 2.3 Commerce: Media Package & Campaign (8 tables)

| # | Entity | Source | Description |
|---|---|---|---|
| 14 | `media_packages` | `@Entity MediaPackage` | Gói mẫu (Admin) hoặc gói custom theo `custom_workspace_id`, hỗ trợ `share_token`/`share_enabled`. |
| 15 | `workspace_media_packages` | `@Entity WorkspaceMediaPackage` | Package đã áp dụng + đàm phán 2 bên (`approved_by_agency_at`, `approved_by_client_at`), hỗ trợ `manager_led` & `preparation_status`. |
| 16 | `package_negotiation_events` | `@Entity PackageNegotiationEvent` | Lịch sử đàm phán package (`BASELINE`, `REQUEST_CHANGE`, `COUNTER_OFFER`, `MANAGER_SAVE`). |
| 17 | `media_campaigns` | `@Entity MediaCampaign` | Kế hoạch thực thi chi tiết sinh từ `workspace_media_packages` đã approve. |
| 18 | `campaign_versions` | `@Entity CampaignVersion` | Snapshot version của kế hoạch chiến dịch (`version_number`). |
| 19 | `campaign_review_events` | `@Entity CampaignReviewEvent` | Lịch sử duyệt/phản hồi chiến dịch. |
| 20 | `campaign_deployments` | `@Entity CampaignDeployment` | Theo dõi triển khai campaign work items thành `tasks` trong MongoDB. |
| 21 | `content_request_completion_jobs` | SQL | Outbox durable đồng bộ hoàn thành Content Request khi campaign hoàn tất. |

### 2.4 Third-party Collaborators & Hashtags (3 tables)

| # | Entity | Source | Description |
|---|---|---|---|
| 22 | `third_party_collaborators` | `@Entity ThirdPartyCollaborator` | Danh bạ đối tác truyền thông ngoài (báo/KOL/banner/TV) cấp Agency. |
| 23 | `campaign_collaborators` | `@Entity CampaignCollaborator` | Liên kết N-N giữa `media_campaigns` và `third_party_collaborators` kèm trạng thái hợp tác. |
| 24 | `workspace_hashtags` | `@Entity Hashtag` | Kho hashtag theo Workspace. |

### 2.5 Task Content Sync & Legacy Task (3 tables)

| # | Entity | Source | Description |
|---|---|---|---|
| 25 | `tasks` | `@Entity Task` | Bảng task phía PostgreSQL (legacy/sync reference cho collaborative editing). |
| 26 | `task_content_operations` | `@Entity TaskContentOperation` | Log operation chỉnh sửa nội dung cộng tác (CRDT/OT). |
| 27 | `task_content_snapshots` | `@Entity TaskContentSnapshot` | Snapshot trạng thái nội dung cộng tác theo revision. |

### 2.6 Billing, Subscription & AI Credits (25 tables)

| # | Entity | Source | Description |
|---|---|---|---|
| 28 | `subscription_plans` | `@Entity SubscriptionPlan` | Catalog gói subscription (`BASIC`/`PRO`/`ENTERPRISE`). |
| 29 | `user_subscriptions` | `@Entity UserSubscription` | Subscription gắn cấp User/Owner. |
| 30 | `subscription_plan_changes` | SQL | Lịch sử yêu cầu đổi/nâng cấp gói subscription. |
| 31 | `transactions` | `@Entity Transaction` | Giao dịch thanh toán PayOS/VietQR, ACID. |
| 32 | `billing_plan_versions` | SQL | Phiên bản giá & quyền lợi gói billing theo thời điểm. |
| 33 | `agency_subscriptions` | SQL | Trạng thái subscription cấp Agency (Billing V3). |
| 34 | `agency_subscription_periods` | SQL | Chu kỳ hiệu lực subscription của Agency. |
| 35 | `billing_orders` | SQL | Đơn hàng thanh toán/gia hạn/addon. |
| 36 | `billing_payment_attempts` | SQL | Lần thử thanh toán qua cổng PayOS. |
| 37 | `billing_payments` | SQL | Giao dịch thanh toán đã xác nhận. |
| 38 | `billing_payment_events` | SQL | Webhook/event thanh toán thô từ provider (idempotent). |
| 39 | `billing_order_fulfillments` | SQL | Trạng thái cấp quyền lợi sau khi đơn hàng thanh toán thành công. |
| 40 | `agency_credit_wallets` | SQL | Ví AI credit cấp Agency. |
| 41 | `credit_grants` | SQL | Lô credit được cấp (theo gói hoặc mua thêm), có `expires_at` và `available`/`reserved`/`consumed`. |
| 42 | `workspace_credit_limits` | SQL | Hạn mức sử dụng AI credit theo từng Workspace. |
| 43 | `credit_usage_periods` | SQL | Kỳ tính mức dùng credit cấp Agency. |
| 44 | `workspace_credit_usage` | SQL | Mức dùng/đặt trước credit theo Workspace trong kỳ. |
| 45 | `ai_credit_operation_prices` | SQL | Bảng đơn giá credit theo loại thao tác AI (`VIDEO_GENERATE`, v.v.). |
| 46 | `ai_credit_reservations` | SQL | Giữ chỗ (reserve) credit trước khi chạy AI job. |
| 47 | `credit_reservation_allocations` | SQL | Phân bổ reservation vào từng `credit_grants` cụ thể. |
| 48 | `credit_operations` | SQL | Nghiệp vụ trừ/hoàn/giải phóng credit (idempotent `operation_key`). |
| 49 | `credit_entries` | SQL | Bút toán sổ cái chi tiết (`credit_operations` → `credit_grants`). |
| 50 | `billing_outbox_events` | SQL | Outbox event của module billing. |
| 51 | `billing_audit_events` | SQL | Audit log bất biến cho thay đổi billing/subscription. |
| 52 | `subscription_operational_issues` | SQL | Sự cố vận hành phát hiện bởi subscription reconciler. |
| 53 | `subscription_observation_jobs` | SQL | Lease/cursor job giám sát đồng bộ subscription. |
| 54 | `subscription_provider_checks` | SQL | Lịch sử kiểm tra đối soát đơn hàng với PayOS. |

### 2.7 AI Jobs & Product Video Production (7 tables)

| # | Entity | Source | Description |
|---|---|---|---|
| 55 | `ai_caption_generations` | SQL | Lịch sử sinh caption AI và liên kết reservation credit. |
| 56 | `ai_video_jobs` | SQL | Job sinh video AI ngắn. |
| 57 | `product_video_productions` | SQL (`ProductVideoStore`) | Phiên sản xuất video sản phẩm (soft-ref `project_id` tới Mongo `video_projects`), quản lý state & worker lease. |
| 58 | `product_video_plans` | SQL (`ProductVideoStore`) | Storyboard/plan JSONB theo `revision` cho mỗi production. |
| 59 | `product_video_quotes` | SQL (`ProductVideoStore`) | Báo giá credit theo scene hoặc toàn production (`price_id` → `ai_credit_operation_prices`). |
| 60 | `product_video_attempts` | SQL (`ProductVideoStore`) | Từng lần render/generate scene gắn `reservation_id` → `ai_credit_reservations`. |
| 61 | `product_video_requests` | SQL (`ProductVideoStore`) | Idempotency request key cho thao tác sản xuất video sản phẩm. |

### 2.8 Storage, Quota & Google Drive Sync (17 tables)

| # | Entity | Source | Description |
|---|---|---|---|
| 62 | `system_storage_pools` | SQL | Pool dung lượng lưu trữ hệ thống. |
| 63 | `agency_storage_usage` | SQL | Dung lượng lưu trữ đã dùng/đang giữ chỗ của Agency. |
| 64 | `agency_storage_reservations` | SQL | Giữ chỗ dung lượng trước khi upload file lên S3. |
| 65 | `storage_usage_entries` | SQL | Bút toán tăng/giảm dung lượng lưu trữ. |
| 66 | `material_quota_releases` | SQL | Biên lai giải phóng quota khi xóa material vĩnh viễn. |
| 67 | `material_audit_receipts` | SQL | Biên nhận xử lý audit event từ `material_audit_outbox`. |
| 68 | `agency_drive_connections` | SQL | Kết nối Google Drive OAuth của Agency. |
| 69 | `workspace_drive_folders` | SQL | Ánh xạ thư mục Google Drive vào Workspace. |
| 70 | `repository_drive_objects` | SQL | Metadata file đồng bộ giữa Repository và Google Drive. |
| 71 | `repository_drive_states` | SQL | Trạng thái đồng bộ Drive theo scope. |
| 72 | `repository_drive_generations` | SQL | Thế hệ đồng bộ (generation counter) Drive. |
| 73 | `repository_drive_operations` | SQL | Hàng đợi thao tác đồng bộ Drive. |
| 74 | `storage_addon_plans` | SQL | Gói mua thêm dung lượng lưu trữ (Agency / Client Vault). |
| 75 | `storage_addon_subscriptions` | SQL | Gói addon dung lượng đang kích hoạt. |
| 76 | `client_vault_storage_usage` | SQL | Dung lượng đã dùng/giữ chỗ của Client Vault (`user_id`). |
| 77 | `client_vault_quota_releases` | SQL | Biên lai giải phóng quota của Client Vault. |
| 78 | `repository_vault_migration_receipts` | SQL | Biên nhận chuyển dung lượng khi chia sẻ/migrate giữa Agency Repository và Client Vault. |

### 2.9 Mail Sending & Newsletter (6 tables)

| # | Entity | Source | Description |
|---|---|---|---|
| 79 | `mail_attachments` | SQL | Tệp/ảnh đính kèm email template (S3 key). |
| 80 | `mail_batches` | SQL | Lô gửi mail (`SEND`, `TEST`, `NEWSLETTER`), soft-ref `template_id` tới Mongo `mail_templates`. |
| 81 | `mail_deliveries` | SQL | Từng người nhận trong một `mail_batches` (`FOR UPDATE SKIP LOCKED`). |
| 82 | `mail_send_quota` | SQL | Bộ đếm gửi mail hàng ngày (`SYSTEM` / `WORKSPACE`). |
| 83 | `mail_suppressions` | SQL | Danh sách hủy đăng ký theo `workspace_id` / `client_profile_id` + `email_lower`. |
| 84 | `newsletter_usage` | SQL | Bộ đếm gửi Newsletter theo tháng/ngày cho từng `agency_id`. |

### 2.10 Admin, Moderation, Notifications & Audit (9 tables)

| # | Entity | Source | Description |
|---|---|---|---|
| 85 | `audit_logs` | `@Entity AuditLog` | Nhật ký kiểm toán hành động nhạy cảm (append-only). |
| 86 | `user_strikes` | `@Entity UserStrike` | Lịch sử gậy/cảnh cáo vi phạm của user. |
| 87 | `sanction_reviews` | `@Entity SanctionReview` | Hồ sơ khiếu nại/xem xét gỡ gậy. |
| 88 | `admin_account_operations` | SQL | Nhật ký idempotent cho thao tác quản trị tài khoản. |
| 89 | `admin_email_outbox` | SQL | Outbox gửi email hệ thống/thông báo từ Admin. |
| 90 | `admin_notifications` | SQL | Chiến dịch thông báo toàn hệ thống/theo gói từ Admin. |
| 91 | `admin_report_exports` | SQL | Lưu file xuất báo cáo Admin (tạm thời kèm token tải). |
| 92 | `content_moderation_reviews` | SQL | Hàng đợi & kết quả kiểm duyệt nội dung (Admin). |
| 93 | `user_notifications` | SQL | Hộp thư thông báo in-app của từng User. |

### 2.11 Infrastructure & Seed Metadata (2 tables)

| # | Entity | Source | Description |
|---|---|---|---|
| 94 | `brandhub_schema_migrations` | SQL | Theo dõi các bản migration SQL đã chạy. |
| 95 | `seed_runs` | SQL (`PostgresSeedRunStore`) | Đánh dấu trạng thái chạy demo seed (opt-in CLI). |

---

## 3. MongoDB Collections (52 collections)

### 3.1 Tasks, Workflow, Sections & Surveys (13 collections)

| # | Collection | Source | Description |
|---|---|---|---|
| 1 | `tasks` | `@Document TaskDocument` | Đơn vị công việc chung (`POST`, `LIVESTREAM`, `SURVEY`, `EVENT_PLAN`, `PRESS_RECOMMENDATION`, `SHORT_VIDEO`, `KOL_BOOKING`, `WORKSHOP`, `EMAIL_NEWSLETTER`). |
| 2 | `task_approvals` | MongoStore | Lịch sử duyệt theo từng step/round (`MANAGER` / `CLIENT`). |
| 3 | `task_comments` | MongoStore (`TaskCommentStore`) | Bình luận trong Task kèm mentions & attachments. |
| 4 | `task_comment_uploads` | MongoStore (`TaskCommentStore`) | Ảnh upload nháp/đính kèm cho bình luận Task. |
| 5 | `task_notification_outbox` | MongoStore (`TaskAssignmentOutbox`) | Outbox durable phát thông báo khi giao việc, comment, duyệt bài. |
| 6 | `task_sections` | `@Document TaskSectionDocument` | Trạng thái từng section theo vai trò trong Task (`DRAFT`, `SUBMITTED`, `INTERNAL_APPROVED`, `CLIENT_APPROVED`, `RETURNED`). |
| 7 | `task_section_versions` | `@Document TaskSectionVersionDocument` | Snapshot bất biến mỗi lần submit section. |
| 8 | `task_section_events` | `@Document TaskSectionEventDocument` | Nhật ký thao tác trên section (`SUBMIT`, `APPROVE`, `CLIENT_APPROVE`, `RETURN`, `CLIENT_RETURN`, `REOPEN`, `RESTORE`). |
| 9 | `content_requests` | `@Document ContentRequestDocument` | Yêu cầu nội dung từ Client (`PENDING → IN_PROGRESS → ACCEPTED / DENIED / CANCELLED`). |
| 10 | `surveys` | `@Document SurveyDocument` | Form khảo sát gắn với Task loại `SURVEY`. |
| 11 | `survey_responses` | `@Document SurveyResponseDocument` | Câu trả lời khảo sát công khai (high write throughput). |
| 12 | `event_plans` | Schema/Store | Nội dung kế hoạch sự kiện của Task `EVENT_PLAN`. |
| 13 | `press_recommendations` | Schema/Store | Gợi ý đơn vị báo chí của Task `PRESS_RECOMMENDATION`. |

### 3.2 Social Publishing & Accounts (4 collections)

| # | Collection | Source | Description |
|---|---|---|---|
| 14 | `social_accounts` | `@Document SocialAccountDocument` | Tài khoản MXH đã kết nối (Facebook, Instagram, TikTok, Threads). |
| 15 | `posts` | `@Document PostDocument` | Bài viết gắn Task đã lên lịch hoặc đã publish lên MXH. |
| 16 | `post_versions` | Schema/Seeder | Lịch sử phiên bản nội dung bài viết. |
| 17 | `publish_logs` | Schema/Seeder | Nhật ký kết quả publish lên từng nền tảng MXH. |

### 3.3 Chat & Realtime Calls (8 collections)

| # | Collection | Source | Description |
|---|---|---|---|
| 18 | `chat_channels` | `@Document ChatChannelDocument` | Kênh chat trong Workspace (direct/group/context). |
| 19 | `chat_channel_reads` | `@Document ChatChannelReadDocument` | Con trỏ đã đọc theo kênh chat. |
| 20 | `chat_messages` | `@Document ChatMessageDocument` | Tin nhắn chat trong kênh/thread, hỗ trợ `attachmentIds`. |
| 21 | `chat_read_states` | `@Document ChatReadStateDocument` | Trạng thái đã đọc theo context chat. |
| 22 | `chat_notification_preferences` | MongoStore | Cấu hình tắt/bật thông báo chat theo user & channel. |
| 23 | `chat_calls` | `@Document ChatCallDocument` | Phiên gọi thoại/video (Agora) trong kênh chat. |
| 24 | `chat_scheduled_messages` | `@Document ChatScheduledMessageDocument` | Tin nhắn hẹn giờ gửi trong kênh chat. |
| 25 | `chat_attachments` | `@Document ChatAttachmentDocument` | Tệp đính kèm tin nhắn chat (upload trực tiếp hoặc tham chiếu Repository). |

### 3.4 Material Repository, Client Vault & Watermark (8 collections)

| # | Collection | Source | Description |
|---|---|---|---|
| 26 | `materials` | `@Document MaterialDocument` | Kho tư liệu ảnh/video/file thuộc Workspace hoặc Client Vault. |
| 27 | `material_folders` | `@Document MaterialFolderDocument` | Cây thư mục trong Workspace Repository và Client Vault. |
| 28 | `material_versions` | `@Document MaterialVersionDocument` | Lịch sử các phiên bản tệp của mỗi `materials` document. |
| 29 | `material_upload_sessions` | MongoStore | Phiên upload multipart/staging lên S3 cho Repository. |
| 30 | `material_references` | MongoStore | Theo dõi tham chiếu từ Post/Task/Chat tới Material để chặn xóa nhầm. |
| 31 | `material_audit_outbox` | MongoStore | Outbox đồng bộ biến động dung lượng về PostgreSQL. |
| 32 | `client_vault_shares` | `@Document ClientVaultShareDocument` | Chia sẻ tài nguyên giữa Client Vault và Workspace. |
| 33 | `watermark_presets` | `@Document WatermarkPresetDocument` | Cấu hình mẫu watermark theo Workspace / Client Profile. |

### 3.5 Video Studio & Auto-Edit (4 collections)

| # | Collection | Source | Description |
|---|---|---|---|
| 34 | `video_projects` | `@Document VideoProjectDocument` | Dự án dựng/chỉnh sửa video (`snapshotJson`, `manifestJson`, `revision`). |
| 35 | `video_project_assets` | `@Document VideoProjectAssetDocument` | Tài nguyên media (clip, audio, image) thuộc Video Project. |
| 36 | `video_project_upload_sessions` | `@Document VideoUploadSessionDocument` | Phiên upload asset cho Video Project. |
| 37 | `video_auto_edits` | `@Document VideoAutoEditDocument` | Job AI Auto-Edit video (plan, progress, lease, output). |

### 3.6 Mail Templates & Recipient Groups (2 collections)

| # | Collection | Source | Description |
|---|---|---|---|
| 38 | `mail_templates` | `@Document MailTemplateDocument` | Mẫu email theo Workspace hoặc mẫu hệ thống (`workspaceId = null`). |
| 39 | `mail_recipient_groups` | `@Document MailRecipientGroupDocument` | Nhóm danh sách người nhận email lưu sẵn theo Workspace. |

### 3.7 Infrastructure Monitoring (4 collections)

| # | Collection | Source | Description |
|---|---|---|---|
| 40 | `monitoring_servers` | `@Document MongoMonitoringServer` | Máy chủ hạ tầng được đăng ký giám sát. |
| 41 | `monitoring_collectors` | `@Document MongoMonitoringCollector` | Agent thu thập metric gắn với server. |
| 42 | `monitoring_enrollments` | `@Document MongoMonitoringEnrollment` | Token đăng ký collector (có TTL `expiresAt`). |
| 43 | `monitoring_health_targets` | `@Document MongoMonitoringHealthTarget` | Endpoint/service health check mục tiêu. |

### 3.8 AI, Knowledge, Notifications & Reports (4 collections)

| # | Collection | Source | Description |
|---|---|---|---|
| 44 | `knowledge_documents` | Schema/Seeder | Tài liệu kiến thức thương hiệu (sync metadata với ChromaDB). |
| 45 | `notifications` | Schema/Seeder | Thông báo legacy/operational phía MongoDB. |
| 46 | `ai_usage_logs` | Schema/Seeder | Nhật ký sử dụng tính năng AI. |
| 47 | `report_jobs` | Schema/Seeder | Job xuất báo cáo bất đồng bộ. |

### 3.9 Legacy V1 / Seed Compatibility (5 collections)

| # | Collection | Source | Description |
|---|---|---|---|
| 48 | `users` | Schema/Seeder | Bản ghi user tương thích V1 cho demo seeder. |
| 49 | `workspaces` | Schema/Seeder | Bản ghi workspace tương thích V1 cho demo seeder. |
| 50 | `workspace_members` | Schema/Seeder | Bản ghi workspace_member tương thích V1 cho demo seeder. |
| 51 | `clients` | Schema/Seeder | Bản ghi client tương thích V1 cho demo seeder. |
| 52 | `seed_runs` | Schema/Seeder | Đánh dấu trạng thái chạy Mongo demo seed. |

---

## 4. Relationship Notes

- **Identity & Organization (PostgreSQL)**: `users` là root của `user_oauth_providers`, `user_refresh_tokens`, `user_system_roles`, `account_activation_tokens`, `agencies.owner_id`, `user_subscriptions`, `user_strikes`, `user_notifications`. `agencies` → `workspaces` → `workspace_members` (kết nối `client_profiles` khi `role = CLIENT`).
- **Commerce & Collaborator (PostgreSQL)**: `media_packages` → `workspace_media_packages` → `package_negotiation_events` & `media_campaigns` → `campaign_versions`, `campaign_review_events`, `campaign_deployments`, `campaign_collaborators` → `third_party_collaborators`.
- **Billing V3 & Credit Ledger (PostgreSQL)**: `billing_plan_versions` → `agency_subscriptions` → `agency_subscription_periods`; `billing_orders` → `billing_payment_attempts` / `billing_payments` / `billing_order_fulfillments`; `agency_credit_wallets` → `credit_grants` / `credit_operations` / `credit_entries`; `ai_credit_reservations` → `credit_reservation_allocations` & `product_video_attempts`.
- **Product Video Production (PostgreSQL ↔ MongoDB)**: `product_video_productions` (FK tới `workspaces`, `users`, `agencies`; soft-ref `project_id` tới Mongo `video_projects`) → `product_video_plans`, `product_video_quotes` (FK `ai_credit_operation_prices`), `product_video_attempts` (FK `ai_credit_reservations`), `product_video_requests`.
- **Storage & Drive Sync (PostgreSQL ↔ MongoDB)**: `agency_storage_usage` / `client_vault_storage_usage` đồng bộ với `materials` / `material_versions` / `material_folders` qua `material_audit_outbox` (Mongo) → `material_audit_receipts` (PostgreSQL). `agency_drive_connections` → `workspace_drive_folders` → `repository_drive_objects` / `states` / `generations` / `operations`.
- **Mail & Newsletter (PostgreSQL ↔ MongoDB)**: `mail_batches` (PostgreSQL, soft-ref `template_id` tới Mongo `mail_templates`) → `mail_deliveries`; `newsletter_usage` gắn `agency_id`; `mail_suppressions` gắn `workspace_id` và `client_profile_id`.
- **Tasks & Sections (MongoDB)**: `tasks` là trung tâm liên kết `task_approvals`, `task_comments` (→ `task_comment_uploads`), `task_notification_outbox`, `task_sections` (→ `task_section_versions`, `task_section_events`), `surveys` (→ `survey_responses`), `event_plans`, `press_recommendations`, `posts` (→ `post_versions`, `publish_logs`).
