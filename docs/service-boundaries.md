# Service Boundaries — BrandHub V2

> DA-1153 (DA-E05-02). Nguồn: `docs/database/schema-v2/brandhub-dbml.dbml` (header comment — ownership chuẩn), `docs/ba/00-overview.md`.
> Mô hình nghiệp vụ V2: `Agency → Workspace → Media Package → Media Campaign → Task`. Không còn Workspace phẳng như V1.

## 1. business-service (Java Spring Boot 3, port 8081)

### Owns
- **PostgreSQL — toàn bộ 23 bảng** (identity, organization, commerce, collaborator, billing):
  - Identity: `users`, `user_oauth_providers`, `user_refresh_tokens`, `user_system_roles`
  - Organization: `agencies`, `agency_members`, `agency_invitations`, `workspaces`, `workspace_members`, `workspace_invitations`, `workspace_templates`, `client_profiles`
  - Commerce: `media_packages`, `workspace_media_packages`, `media_campaigns`
  - Collaborator: `third_party_collaborators`, `campaign_collaborators`
  - Billing: `subscription_plans`, `user_subscriptions`, `transactions`, `ai_credit_ledgers`, `ai_credit_creator_limits`, `audit_logs`
- **MongoDB — 14 collections** (business domain, không phải AI/publish log):
  `tasks`, `task_approvals`, `posts`, `content_requests`, `material_repository`, `brand_collections`, `hashtag_collections`, `content_versions`, `livestream_sessions`, `survey_forms`, `survey_responses`, `mail_templates`, `social_accounts`, `notifications`
- **Redis** — JWT blacklist, rate limit, session cache.
- Toàn bộ RBAC (`RequireRoleAspect`): `SystemRole` (ADMIN/USER) + `MemberRole` (MANAGER/CREATOR/CLIENT theo Workspace) + Agency-level owner check.

### Does NOT own
- Không gọi trực tiếp Social Platform API (Facebook/Instagram/TikTok/Threads) — publisher-service làm việc đó.
- Không sinh nội dung AI (caption/image/video/ambassador) — chỉ gọi REST tới ai-service, không tự implement logic AI.
- Không kết nối ChromaDB hoặc AWS S3 (media gen output) — ai-service sở hữu.

### Trách nhiệm nghiệp vụ chính (V2)
- Toàn bộ vòng đời Agency → Workspace → Media Package → Media Campaign → Task backlog → Task Approval Sequence (Creator → [QC] → Manager → Client).
- Đẩy Task lên RabbitMQ cho publisher-service khi Post-type task hoàn tất Approval Sequence và tới lịch đăng.
- Là "orchestrator" duy nhất — publisher-service KHÔNG BAO GIỜ gọi Social API trực tiếp mà không qua message từ business-service.

---

## 2. ai-service (Python FastAPI, port 8082)

### Owns
- **ChromaDB** — brand knowledge vectors, RAG embeddings (collection naming: `agency_{agencyId}_brand_voice`, xem §DA-1158 khi hoàn tất — thay cho `workspace_{workspaceId}` cũ vì AI credit/brand voice giờ gắn cấp Agency, không phải Workspace lẻ).
- **AWS S3** — media output do AI generate (ảnh/video từ UC-77, UC-78).
- **MongoDB — 2 collections**: `knowledge_documents` (RAG source), `ai_usage_logs` (tracking credit usage per generation — nguồn cho FR 3.9.5 View AI Credit Tracking, dù bảng credit balance chính nằm ở PostgreSQL `ai_credit_ledgers` phía business-service).

### Does NOT own
- Không kết nối MongoDB business collections (`tasks`, `posts`...) hay PostgreSQL — lấy business context (Workspace/Campaign/brand info) qua REST API từ business-service khi cần.
- Không quản lý AI credit balance/limit (đó là PostgreSQL `ai_credit_ledgers`/`ai_credit_creator_limits`, business-service sở hữu) — ai-service chỉ ghi log usage, business-service là nguồn sự thật cho số dư.

### Trách nhiệm nghiệp vụ chính (V2)
- Generate: Caption, AI Brand Ambassador, Image, Video, Livestream Script (UC-74 → UC-82).
- Trend crawl (ADMIN-configured, FR 3.7.9) + hashtag/trending topic suggestion.
- Recommend Media Collaborator (UC-82) — chỉ gợi ý, không tự liên hệ/ký kết.

---

## 3. publisher-service (Java Spring Boot 3, stateless, port 8083)

### Owns
- **MongoDB — 1 collection**: `publish_logs` (lịch sử job publish, trạng thái từng lần gọi Social API).
- Không sở hữu bảng nào khác — hoàn toàn stateless ngoài log riêng.

### Does NOT own
- Zero access tới MongoDB business collections hay PostgreSQL của business-service.
- Không tự quyết định publish content nào/khi nào — chỉ nhận job qua RabbitMQ đã được business-service đóng gói đầy đủ (nội dung, media URL, OAuth token đã mã hóa, platform config).

### Trách nhiệm nghiệp vụ chính (V2)
- Consume RabbitMQ publish job → gọi đúng Social API (Facebook Post/Story/Reels, Instagram Post/Reels/Story, TikTok Video, Threads Post — UC-87/88/89).
- Retry với backoff (30s → 60s → 120s → DLQ) khi API lỗi.
- Gửi HTTP callback về business-service để cập nhật status Task/Post (`PENDING → IN_PROGRESS → DONE/FAIL`).
- Third-party Collaborator (báo/banner/TV — không có API) KHÔNG đi qua publisher-service — đó là tracking thủ công trong business-service, xem `docs/ba/07-publishing-social-collaborator.md` §2.

---

## 4. Nguyên tắc ranh giới chung

1. **1 DB — 1 owner duy nhất.** Không service nào kết nối trực tiếp vào DB không thuộc sở hữu của mình (xem DA-1154, database ownership diagram, cho chi tiết cross-DB reference strategy).
2. **business-service là orchestrator nghiệp vụ duy nhất.** ai-service và publisher-service là "worker" thực thi theo lệnh, không tự khởi tạo hành động nghiệp vụ (trừ crawl job theo lịch ADMIN cấu hình).
3. **RBAC 2 tầng (Agency-level + Workspace-level) chỉ tồn tại trong business-service.** ai-service/publisher-service tin tưởng request đã qua xác thực/phân quyền ở business-service (internal API key, không JWT) — không tự re-check quyền user.
4. **Third-party Collaborator (báo/banner/TV) là module tracking thủ công trong business-service** — không có service riêng, không tự động hóa như Social API publish.
