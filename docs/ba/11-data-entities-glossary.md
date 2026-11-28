# 11 — Từ Điển Thực Thể Dữ Liệu & Kiến Trúc Lưu Trữ Đa Cơ Sở Dữ Liệu (Data Entities & Glossary)

> Navigation: [← BA Index](./README.md) · [← 10 - Roles & Permissions Matrix](./10-roles-permissions-matrix.md) · [Tiếp: 12 - State Machines →](./12-state-machines.md)
>
> Tài liệu này tổng hợp toàn bộ các thực thể nghiệp vụ (Domain Entities) của hệ thống **BrandHub**, phân bổ trên hệ lưu trữ đa cơ sở dữ liệu (**PostgreSQL — 97 bảng**, **MongoDB — 52 collections**, **ChromaDB**, **Neo4j**, **Redis**) và đối chiếu trực tiếp với **141 Yêu cầu Chức năng (`3.2.1` – `3.10.14`)** (danh mục chi tiết từng bảng xem tại [ERD Entity Descriptions](../database/schema/erd-entity-descriptions.md)).

---

## 1. Kiến trúc Phân tầng Lưu trữ Đa Cơ sở Dữ liệu (Polyglot Persistence)

| Hệ quản trị CSDL | Vai trò trong Kiến trúc | Các Thực thể Chính được Lưu trữ |
| :--- | :--- | :--- |
| **PostgreSQL** (`Relational & Financial DB`) | Lưu trữ dữ liệu định danh, tổ chức đa tầng, hợp đồng gói dịch vụ, chiến dịch, tài chính, hóa đơn SePay, ví AI Credit và hàng đợi gửi email cần tính toàn vẹn giao dịch ACID (`@Transactional`). | `users`, `agencies`, `agency_members`, `agency_invitations`, `workspaces`, `workspace_members`, `workspace_templates`, `client_profiles`, `media_packages`, `workspace_media_packages`, `media_campaigns`, `content_requests`, `subscription_plans`, `user_subscriptions`, `invoices`, `agency_credit_wallets`, `workspace_credit_limits`, `credit_reservations`, `ai_credit_prices`, `mail_batches`, `mail_deliveries`, `mail_suppressions`, `newsletter_usage`, `share_links`. |
| **MongoDB** (`Content & Workflow Document Store`) | Lưu trữ dữ liệu công việc đa định dạng (8 loại `TaskType`), trình soạn chia phần (`TaskSection`), lịch sử phiên bản, bài đăng mạng xã hội, khảo sát, thư viện tư liệu, mẫu email, danh bạ KOL và tin nhắn chat thời gian thực. | `tasks` (`TaskDocument` + embedded `Subtask`), `task_sections`, `task_section_versions`, `task_section_events`, `task_approvals`, `posts` (`PostDocument`), `surveys`, `survey_responses`, `materials`, `hashtag_collections`, `mail_templates`, `mail_recipient_groups`, `brand_knowledge_docs`, `collaborators`, `chat_channels`, `chat_messages`, `moderation_items`. |
| **Neo4j** (`AI Trend Knowledge Graph`) | Lưu trữ đồ thị tri thức xu hướng phục vụ khám phá xu hướng (`3.7.1`, `3.7.2`) và cung cấp ngữ cảnh đồ thị cho AI sinh nội dung (`3.7.6`). | Nút (`Nodes`): `TrendTopic`, `Keyword`, `Hashtag`, `Platform`, `Industry`, `ContentAngle`. Cạnh (`Relationships`): `RELATES_TO`, `TRENDING_ON`, `HAS_HASHTAG`, `SUGGESTS_ANGLE`. |
| **Redis** (`Cache, Session, Rate-Limit & Pub/Sub`) | Lưu mã OTP xác thực, danh sách thu hồi/phiên JWT, khóa phân tán, bộ giới hạn tốc độ (`ChatRateLimiter`, `NewsletterTestRateLimiter`) và hàng đợi đệm. | `otp:*`, `auth:refresh:*`, `ratelimit:*`, `ws:presence:*`. |

---

## 2. Danh mục Thực thể Chi tiết theo Miền Nghiệp vụ

### 2.1. Nhóm Định danh, Tổ chức & Không gian Lai (`3.2`, `3.3`, `3.4`)

| Thực thể (Bảng / Collection) | CSDL | Các Trường Cốt lõi (Key Attributes) | Quan hệ & Quy tắc Nghiệp vụ (Business Invariants) |
| :--- | :-: | :--- | :--- |
| **`User`** (`users`) | Postgres | `id (UUID)`, `email (UNIQUE)`, `password_hash`, `display_name`, `avatar_url`, `system_role (USER \| ADMIN)`, `two_factor_enabled`, `working_language (vi \| en)`, `violation_status`, `status (ACTIVE \| BANNED \| DELETED)` | Liên kết `1-N` với `Agency` (vai trò `Owner`), `1-N` với `AgencyMember` và `WorkspaceMember`. |
| **`Agency`** (`agencies`) | Postgres | `id (UUID)`, `owner_id (FK users)`, `name`, `logo_icon`, `tagline`, `company_size`, `category`, `status (ACTIVE \| DELETED)` | Đại diện cho một Công ty truyền thông B2B hoặc một **`Personal Hub`** cá nhân (`logo_icon = "personal-studio"`). Mỗi `Agency` có đúng 1 `Owner` và 1 ví `AgencyCreditWallet`. |
| **`AgencyMember`** (`agency_members`) | Postgres | `id`, `agency_id`, `user_id`, `status (ACTIVE \| REMOVED)`, `joined_at` | Danh sách nhân sự thuộc `Agency` (`3.4.6`–`3.4.11`). |
| **`AgencyInvitation`** (`agency_invitations`) | Postgres | `id`, `agency_id`, `email`, `invited_by`, `target_workspace_id`, `target_workspace_role`, `language (vi \| en)`, `personal_message`, `status (PENDING \| ACCEPTED \| DECLINED \| EXPIRED)`, `expires_at` | Lời mời tham gia `Agency` kèm xem trước bản mẫu email song ngữ (`3.4.8`–`3.4.10`). |
| **`Workspace`** (`workspaces`) | Postgres | `id (UUID)`, `agency_id (FK agencies)`, `name`, `brand_name`, `timezone_config`, `status (ACTIVE \| ARCHIVED \| DELETED)`, `workspace_media_package_id`, **`settings (JSONB)`** | Cột JSONB `settings` lưu **`"workspaceMode": "AGENCY" \| "PERSONAL"`** và `"isPersonalDefault": true \| false`. Các bản ghi cũ không có khóa này mặc định là `"AGENCY"`. |
| **`WorkspaceMember`** (`workspace_members`) | Postgres | `id`, `workspace_id`, `user_id`, `workspace_role (MANAGER \| CREATOR \| CLIENT)`, `client_profile_id`, `status (ACTIVE \| REMOVED)` | Ràng buộc `UNIQUE (workspace_id, user_id)`. Mỗi Workspace đang `ACTIVE` luôn có ít nhất 1 `MANAGER`. Trong Workspace `PERSONAL`, không có thành viên `CLIENT`. |
| **`ClientProfile`** (`client_profiles`) | Postgres | `id (UUID)`, `workspace_id`, `display_name`, `logo_url`, `industry`, `website`, `contact_email`, `brand_guidelines` | Hồ sơ thương hiệu của khách hàng (`3.3.3`–`3.3.4`). `display_name` được dùng làm tên người gửi Newsletter; `logo_url` được in vào file PDF/DOCX xuất ra. |
| **`WorkspaceTemplate`** (`workspace_templates`) | Postgres | `id`, `agency_id`, `name`, `description`, `template_config (JSONB)`, `created_by` | Mẫu cấu hình Workspace tái sử dụng (`3.4.19`–`3.4.22`). |

### 2.2. Nhóm Gói Truyền thông, Chiến dịch & Yêu cầu Nội dung (`3.5`)

| Thực thể (Bảng / Collection) | CSDL | Các Trường Cốt lõi (Key Attributes) | Quan hệ & Quy tắc Nghiệp vụ |
| :--- | :-: | :--- | :--- |
| **`MediaPackage`** (`media_packages`) | Postgres | `id`, `agency_id`, `name`, `description`, `offerings (JSONB: serviceType, quantity, unit, price)`, `total_price`, `is_template` | Danh mục gói dịch vụ mẫu của `Agency` (`3.5.1`, `3.5.2`). Hỗ trợ đủ 8 loại `PackageServiceType` (`CONTENT_POST`, `SHORT_VIDEO`, `SURVEY`, `EVENT_PLAN`, `PRESS_RECOMMENDATION`, `KOL_BOOKING`, `WORKSHOP_SUPPORT`, `EMAIL_NEWSLETTER`). |
| **`WorkspaceMediaPackage`** (`workspace_media_packages`) | Postgres | `id`, `workspace_id`, `source_package_id`, `custom_name`, `offerings (JSONB)`, `status (DRAFT \| REQUESTED \| APPROVED)` | Gói dịch vụ áp dụng cho một Workspace (`3.5.3`, `3.5.4`). Ở chế độ `PERSONAL`, hệ thống tự cấp ngầm gói khung không giới hạn để người dùng lập Chiến dịch cá nhân ngay. |
| **`MediaCampaign`** (`media_campaigns`) | Postgres | `id`, `workspace_id`, `workspace_media_package_id`, `name`, `objective`, `start_date`, `end_date`, `work_items (JSONB)`, `status (DRAFT \| ACTIVE \| COMPLETED)` | Chiến dịch truyền thông (`3.5.5`–`3.5.9`). Khi `deploy`, sinh ra các `TaskDocument` cha và bộ `Subtask` theo vai trò chuẩn. |
| **`ContentRequest`** (`content_requests`) | Postgres | `id`, `workspace_id`, `client_user_id`, `title`, `type`, `description`, `desired_due_date`, `status (PENDING \| APPROVED \| REJECTED \| CANCELLED)`, `linked_task_id` | Yêu cầu nội dung do `Client` gửi từ `Client Portal` (`3.5.10`–`3.5.13`). |

### 2.3. Nhóm Công việc Đa định dạng, Trình soạn Chia phần & Cộng tác (`3.6`)

| Thực thể (Bảng / Collection) | CSDL | Các Trường Cốt lõi (Key Attributes) | Quan hệ & Quy tắc Nghiệp vụ |
| :--- | :-: | :--- | :--- |
| **`TaskDocument`** (`tasks`) | Mongo | `id`, `workspaceId`, `campaignId`, **`type (8 TaskTypes)`**, `title`, `description`, `status (TODO \| IN_PROGRESS \| IN_REVIEW \| FINISHED \| CANCELLED)`, `priority`, `assigneeId`, `dueDate`, **`requiresClientApproval`**, `sourceType`, `workflowRevision`, `lastSubmission`, **`subtasks: List<Subtask>`** | Hỗ trợ 8 loại `TaskType` chuẩn (`POST`, `SHORT_VIDEO`, `SURVEY`, `EVENT_PLAN`, `PRESS_RECOMMENDATION`, `KOL_BOOKING`, `WORKSHOP`, `EMAIL_NEWSLETTER`). Trong `Subtask` có trường **`subtaskRole`** gắn với `TaskCatalog`. Trong chế độ `PERSONAL`, `requiresClientApproval = false` và hỗ trợ `self-approve` 1 chạm. |
| **`TaskSectionDocument`** (`task_sections`) | Mongo | `id (taskId\|sectionKey)`, `workspaceId`, `taskId`, **`sectionKey`**, **`visibility (OUTPUT \| INTERNAL)`**, **`status (DRAFT \| SUBMITTED \| INTERNAL_APPROVED \| CLIENT_APPROVED \| RETURNED)`**, `revision`, `content (Map)`, `returnNote`, `clientPendingSince` | Lưu trữ trạng thái, revision CAS và nội dung của từng phần trong trình soạn thảo chia phần. Phần `INTERNAL` bị lọc bỏ hoàn toàn khi `Client` truy vấn. |
| **`TaskSectionVersionDocument`** (`task_section_versions`) | Mongo | `id (taskId\|sectionKey\|versionNo)`, `taskId`, `sectionKey`, `versionNo`, `content (Snapshot)`, `submittedBy`, `submittedAt` | Bản chụp lịch sử bất biến mỗi khi chủ phần bấm `Submit` (`3.6.34`); cho phép xem diff từng dòng và khôi phục (`Restore`). |
| **`TaskSectionEventDocument`** (`task_section_events`) | Mongo | `id`, `taskId`, `sectionKey`, `action (SUBMIT \| APPROVE \| RETURN \| REOPEN \| CLIENT_APPROVE \| CLIENT_RETURN \| SELF_APPROVE)`, `actorId`, `note`, `at` | Nhật ký kiểm toán đầy đủ cho mọi thao tác duyệt/trả/mở lại phần. |
| **`PostDocument`** (`posts`) | Mongo | `id`, `workspaceId`, `taskId`, `contentText`, `hashtags`, `media (List<PostMedia>)`, `targetPlatforms (FB \| IG \| TIKTOK \| THREADS)`, `scheduledAt`, `status (DRAFT \| APPROVED \| SCHEDULED \| PUBLISHING \| PUBLISHED \| FAILED)` | Lưu nội dung xuất bản của công việc `POST` và `SHORT_VIDEO` (`3.6.1`–`3.6.9`, `3.8.5`–`3.8.15`). |
| **`Material`** (`materials`) | Mongo | `id`, `workspaceId`, `folderId`, `name`, `mimeType`, `sizeBytes`, `storageUrl`, `watermarkedUrl`, `driveFileId`, `clientVisible`, `tags` | Thư viện tư liệu số của Workspace, hỗ trợ đóng dấu `Watermark` (`3.6.18`), đồng bộ `Google Drive` (`3.6.15`–`3.6.17`) và chia sẻ thư mục cho `Client` / `Guest`. |
| **`MailBatch` & `MailDelivery`** (`mail_batches`, `mail_deliveries`, `newsletter_usage`) | Postgres | `id`, `workspace_id`, `agency_id`, **`kind (SEND \| TEST \| NEWSLETTER)`**, `status`, `scheduled_at`, `total_count`, `sent_count`, `failed_count` | Hạ tầng gửi email mẫu (`3.6.28`–`3.6.32`) và gửi bản tin `EMAIL_NEWSLETTER` thật với bộ đếm hạn mức tháng theo `Agency` (`newsletter_usage`: `1.000` / `10.000` / `50.000`). |
| **`ShareLink`** (`share_links`) | Postgres | `id`, `token (UNIQUE)`, `workspace_id`, `resource_type (MEDIA_PACKAGE \| POST \| DOCUMENT \| FOLDER)`, `resource_id`, `expires_at`, `revoked_at` | Đường dẫn chia sẻ công khai chỉ-đọc cho `Guest` (`/s/:token`). |

### 2.4. Nhóm AI, Mạng xã hội, Tài chính & Quản trị (`3.7`, `3.8`, `3.9`, `3.10`)

| Thực thể (Bảng / Collection) | CSDL | Các Trường Cốt lõi (Key Attributes) | Quan hệ & Quy tắc Nghiệp vụ |
| :--- | :-: | :--- | :--- |
| **`BrandKnowledgeDoc`** (`brand_knowledge_docs`) | Mongo + Vector | `id`, `workspaceId`, `fileName`, `fileUrl`, `chunkCount`, `status (PROCESSING \| INDEXED \| FAILED)` | Tài liệu tri thức thương hiệu phục vụ RAG khi sinh nội dung AI (`3.7.3`–`3.7.5`). |
| **`Collaborator`** (`collaborators`) | Mongo | `id`, `agencyId`, `name`, `platforms`, `niche`, `followerCount`, `engagementRate`, `rateCardVnd`, `contactInfo` | Hồ sơ KOL / Influencer / Cộng tác viên trong danh bạ Agency (`3.7.15`–`3.7.19`). |
| **`SocialAccount`** (`social_accounts`) | Postgres | `id`, `workspace_id`, **`platform (FACEBOOK \| INSTAGRAM \| TIKTOK \| THREADS)`**, `account_id`, `account_name`, `access_token_enc`, `status (CONNECTED \| EXPIRED \| DISCONNECTED)` | Tài khoản mạng xã hội kết nối vào Workspace (`3.8.1`, `3.8.2`). Chỉ hỗ trợ đúng 4 nền tảng chuẩn. |
| **`AgencyCreditWallet` & `WorkspaceCreditLimit`** (`agency_credit_wallets`, `workspace_credit_limits`) | Postgres | `agency_id`, `plan_balance`, `purchased_balance`, `held_balance`; `workspace_id`, **`cap (BIGINT NULLABLE)`**, `used_in_period`, `held_in_period`, `revision` | Kiến trúc Ví tổng cấp Agency + Trần ngân sách cấp Workspace (`3.9.4`–`3.9.6`). `cap = NULL` là không giới hạn riêng; `cap = 0` là chặn tác vụ tính phí. |
| **`SubscriptionPlan`, `AgencySubscription` & `BillingOrder`** | Postgres | `plan_code (STUDIO_FREE \| STUDIO_PLUS \| STUDIO_PRO \| BASIC \| PLUS \| ENTERPRISE)`, `price_vnd`, `credit_grant`; `sepay_reference`, `amount_vnd`, `status (PENDING \| PAID \| EXPIRED \| CANCELLED)` | Quản lý 6 gói cước thuộc 2 dòng sản phẩm, thanh toán **SePay (VietQR)** nâng cấp gói / nạp thêm credit và đối soát doanh thu (`3.9.1`–`3.9.6`, `3.10.10`–`3.10.14`). |

---

## 3. Các Thực thể Đã Loại bỏ Khỏi Phạm vi (De-scoped Entities — `AGENTS.md`)

- **`LivestreamSession` / `LivestreamScript`**: Đã loại bỏ hoàn toàn theo quy tắc không làm tính năng Livestream.
- **`CopyrightCheckResult`**: Đã loại bỏ; chỉ sử dụng `ComplianceCheck` (`3.6.33`) và `ModerationItem` (`3.10.4`).
- **`MemberCreditLimit` (Hạn mức AI Credit theo từng cá nhân)**: Đã được thay thế hoàn toàn bởi `WorkspaceCreditLimit` (`CREDIT_PERSONAL_LIMIT_RETIRED`).
