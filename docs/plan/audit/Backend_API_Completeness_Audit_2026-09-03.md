# BrandHub — Backend API Completeness Audit

> Phạm vi: các epic BACKEND còn task chưa Done trên Jira (theo snapshot phiên trước — không re-pull được Jira lần này, không có token khả dụng trong phiên audit này; dựa trên đối chiếu docs + code thực tế, coi code là nguồn sự thật).
> Nguồn đối chiếu: `docs/feature/*/spec.md` (business spec), `docs/api/endpoints/*.md` (API contract), source thực tế `brandhub-business-service`, `brandhub-ai-service`, `brandhub-publisher-service`.
> Ngày: 2026-09-03

> **⚠️ Cập nhật quan trọng (2026-09-03, verify lại có Jira token):** Đã kiểm tra lại toàn bộ 17 epic "Missing API" trên Jira thật — **task đã tồn tại đầy đủ và khớp đúng nghiệp vụ**, không thiếu task. Ví dụ: E16 Client có 4 task (DA-220, 236, 249, 266 — In review), E28-E31 Content Workflow có route thiết kế mới hơn cả doc cũ (`/my-tasks`, `/account-review`, `/client-approve`, `/client-reject` — không phải generic `/approve`/`/reject` như `05_post.md` mô tả, nghĩa là **doc API cũ đã lỗi thời so với task Jira**, không phải Jira thiếu). **Vấn đề thật sự là chưa ai code**, không phải thiếu task để giao việc. Không tạo task Jira mới — xem mục 5 để biết việc cần làm tiếp theo.

---

## 1. Tổng quan

| Epic | Business area | Spec found? | API doc found? | Code found? | Verdict |
|---|---|---|---|---|---|
| E12 | OAuth login (Facebook, GitHub) | Có (`auth/oauth-social-login`) | Có (`01_auth.md`) | GitHub/Google/LinkedIn/Microsoft **có** controller; **Facebook không có file nào** | **Missing API** |
| E15 | Workspace (create/settings/member) | Có (`workspace-management/spec.md`) | Có (`03_workspace.md`) | `WorkspaceController` đủ 14 endpoint khớp spec | **Complete** |
| E16 | Client API (agency-client) | Không tìm thấy spec riêng trong `docs/feature/` | Có, chi tiết (`04_client.md`, 8 endpoint) | **Không có** `ClientController`/`ClientService` — chỉ có entity `Client.java` | **Missing API** |
| E17 | Subscription plans (Admin CRUD) | Không tìm thấy spec riêng | Có, chi tiết (`10_subscription.md`, 6 endpoint + Stripe) | **Không có** controller/service — chỉ có entity `SubscriptionPlan.java`, `Invoice.java`, `Payment.java` | **Missing API** |
| E18 | Instagram OAuth connect | Không tìm thấy spec riêng | Có (`07_social_account.md`, generic `/social/connect/{platform}`) | **Không có** `SocialAccountController`, không có model MongoDB `social_accounts` | **Missing API** |
| E19 | Zalo OA OAuth | Không tìm thấy spec riêng | Không có mục riêng (gộp trong `07_social_account.md` generic) | **Không có** code | **Missing API** |
| E20 | Token refresh scheduled job | Không tìm thấy spec riêng | Có (`POST /social/accounts/{id}/refresh`) | **Không có** — phụ thuộc E18/E19 vốn cũng chưa có | **Missing API** |
| E21 | Publisher — Threads/TikTok adapter | Không có spec | Không có tài liệu API riêng publisher-service | `brandhub-publisher-service/src/main` chỉ có `BrandHubPublisherApplication.java` (bootstrap trống) — Jira nói "In Progress" nhưng repo chưa có code | **Missing API** (nghiêm trọng — service rỗng) |
| E22 | Publish callback → business-service | Không có spec | Không có | Không có endpoint nhận callback ở business-service, không có gì ở publisher-service | **Missing API** |
| E23 | AI internal API wiring | Không có spec riêng (nằm rải trong AI feature) | Có (`12_api-endpoint-ai-service.md`, 771 dòng) | `brandhub-ai-service` có router thật: content/image/video/ambassador/rag/trends — nhưng phía business-service **không có gì gọi sang** (không có `AiServiceClient`/proxy) | **Partial** |
| E24 | Business-service AI integration flow | Không có spec | — | Không tìm thấy client/controller nào ở business-service gọi ai-service | **Missing API** |
| E28 | Content request API | Không có spec riêng | Có (`06_content_request.md`, 6 endpoint) | **Không có** controller/model | **Missing API** |
| E29 | Assign content request | — | Nằm trong `06_content_request.md` (`PUT .../assign`) | Không có | **Missing API** |
| E30 | Calendar/posts API | Không có spec riêng | Có (`05_post.md`, đủ approve/submit flow) | **Không có** `PostController`/model | **Missing API** |
| E31 | Account review/approve API | — | Nằm trong `05_post.md` (`/submit`, `/approve`) | Không có | **Missing API** |
| E32 | Publisher — Facebook/social adapter | Không có spec | Không có | publisher-service rỗng (như E21) | **Missing API** |
| E33 | Retry logic publish | Không có spec | Không có | Không có gì để có retry logic — publisher-service rỗng | **Missing API** |
| E38 | Analytics aggregation API | Không có spec riêng | Có (`08_analytics.md`, 3 endpoint) | Không có `AnalyticsController`, không có `posts`/`ai_usage_logs` Mongo collection nào trong code | **Missing API** |
| E39 | Notification CRUD API | Không có spec riêng | Không tìm thấy file endpoint riêng cho notification | Không có model/controller Notification | **Missing API** |
| E41 | Firebase Cloud Messaging | — | — | Không có | **Missing API** |

**Đọc nhanh:** Trong 19 epic backend business-logic được audit, chỉ **1/19 (E15 – Workspace) là Complete**. Còn lại 17 epic Missing API hoàn toàn (chưa có 1 dòng code controller/service nào), và 1 epic (E23) Partial — AI service có endpoint thật nhưng chưa được business-service gọi tới nên chưa dùng được end-to-end. Điều này khác biệt lớn so với Jira status "In Review"/"In Progress" ở một số epic (VD: E16 "In review", E21 "In Progress") — trạng thái Jira không phản ánh đúng thực tế code.

---

## 2. Chi tiết theo epic (mọi epic khác "Complete")

### E12 — OAuth Facebook login (DA-613)
- Spec (`auth/oauth-social-login/spec.md`) mô tả multi-provider OAuth theo pattern chung.
- Code có đủ 4 provider: `GoogleOAuthController`, `GitHubOAuthController`, `LinkedInOAuthController`, `MicrosoftOAuthController` — mỗi controller có `/{provider}`, `/{provider}/link`, `/{provider}/callback`.
- **Thiếu:** không có `FacebookOAuthController` hay bất kỳ file nào chứa "facebook" trong toàn bộ `brandhub-business-service/src/main`. Jira nói task đang "In Progress" — khớp với thực tế chưa có code, không phải lỗi lệch trạng thái.
- Việc build sẽ nhanh vì pattern đã có sẵn 4 lần lặp lại (copy `GitHubOAuthController` + `GitHubOAuthService`, đổi endpoint Facebook Graph API).

### E16 — Client API
- API doc yêu cầu 8 endpoint: create, list (scoped theo role), get, update, delete, assign account manager, service-package, portal-access.
- Model `Client.java` tồn tại (fields khớp doc: name, brandName, industry, contactEmail...) nhưng **không có `ClientController`, `ClientService`, `ClientRepository`**.
- Thiếu toàn bộ: không chỉ CRUD cơ bản mà cả nghiệp vụ isolation (`ACCOUNT_MANAGER` chỉ thấy client được assign, `BRAND_CLIENT` chỉ thấy client của chính họ) — chưa có RBAC nào áp cho resource này vì chưa có controller.

### E17 — Subscription plans CRUD
- Doc mô tả rõ luồng Stripe: `/plans` (public), `/current`, `/subscribe` (tạo `clientSecret`), `/webhook` (Stripe HMAC), `/cancel`, `/invoices`.
- Model có `SubscriptionPlan`, `Invoice`, `Payment`, `WorkspaceSubscription`, enum `PaymentStatus`/`InvoiceStatus`/`SubscriptionStatus` — thiết kế DB đã sẵn sàng.
- **Thiếu 100% code tầng service/controller.** Đặc biệt nguy hiểm: `/webhook` cần raw-body signature validation (`STRIPE_WEBHOOK_SECRET`) — đây là điểm bảo mật quan trọng, chưa có gì để đánh giá được.

### E18/E19/E20 — Social OAuth connect (Instagram, Zalo) + token refresh job
- Doc gộp chung dưới `/api/v1/social/*` generic theo `{platform}` param, lưu MongoDB `social_accounts`.
- Không có `SocialAccountController`, không thấy MongoDB entity/config nào cho collection này trong business-service (business-service dùng JPA/Postgres cho các model khác — cần xác nhận có tích hợp Mongo driver chưa, có vẻ chưa vì không thấy dependency Mongo trong cấu trúc các model liệt kê).
- Token refresh job (E20) phụ thuộc hoàn toàn vào việc có OAuth token lưu trước — không thể build trước E18/E19.

### E21/E32/E33 — Publisher service (Threads/TikTok/Facebook adapter, retry logic)
- **Phát hiện nghiêm trọng nhất của audit này:** `brandhub-publisher-service/src/main/java/com/brandhub/publisher/` chỉ có đúng 1 file — `BrandHubPublisherApplication.java` (Spring Boot bootstrap trống, không route, không adapter, không retry, không queue).
- Jira ghi nhận DA-214 (Threads adapter) và DA-272 (TikTok adapter) đang **In Progress** — nhưng không có bất kỳ commit/class nào phản ánh việc đó trong repo hiện tại. Cần xác nhận trực tiếp với Phước — có thể code đang nằm ở branch riêng chưa merge, hoặc Jira status sai.
- Không có gì để đánh giá "exponential backoff", "dead-letter-queue", hay "per-platform rate limit" vì chưa có adapter nào tồn tại.

### E22 — Publish callback → business-service
- Không tìm thấy endpoint nào ở `business-service` để nhận callback trạng thái publish (VD: `POST /api/v1/posts/{id}/publish-status`). Vì publisher-service chưa có gì gọi ra ngoài, callback contract cũng chưa được định nghĩa ở cả hai phía.

### E23/E24 — AI service wiring
- `brandhub-ai-service` là service **duy nhất trong 3 backend service có code triển khai thật** — router FastAPI đủ 6 domain: content, image, video, ambassador, rag, trends (khớp `12_api-endpoint-ai-service.md`, 771 dòng doc — tài liệu dài nhất, phản ánh đây là phần được đầu tư nhiều nhất).
- **Thiếu (E24):** phía `business-service` không có `AiServiceClient`, `RestTemplate`/`WebClient` bean, hay controller nào forward request sang ai-service. Nghĩa là AI service hoạt động độc lập, nhưng chưa được business-service "wiring" vào — frontend không thể gọi AI qua business-service, phải gọi thẳng ai-service (nếu vậy thì thiếu auth/workspace-scoping ở tầng gateway).
- Verdict "Partial" cho E23 vì AI-side code tồn tại thật, nhưng "Missing API" cho E24 vì phần wiring hoàn toàn chưa có.

### E28/E29 — Content request API
- Doc yêu cầu 6 endpoint gồm workflow assign + comment thread.
- Không có `ContentRequest` model, controller, hay repository nào trong business-service. Đây là workflow cốt lõi kết nối Client → Account Manager → Creator — hiện không thể thực hiện được qua API dù đã có role model (`MemberRole` enum) sẵn sàng ở tầng Workspace.

### E30/E31 — Calendar/Posts + Approve
- Doc mô tả rõ approval chain: `POST /posts` (Creator/AM tạo) → `PUT .../submit` → `PUT .../approve`.
- Không có `Post` model/controller nào. Approval chain (Creator → Account Manager → Client) **hoàn toàn không thể đi qua được** vì chưa có transition endpoint nào tồn tại — không phải "thiếu 1 state" mà là thiếu toàn bộ luồng.

### E38 — Analytics aggregation
- Doc yêu cầu MongoDB aggregation trên `posts`/`ai_usage_logs`. Vì `posts` (E30) và social/AI usage tracking chưa tồn tại, analytics không có nguồn dữ liệu để tổng hợp dù có build controller cũng vô nghĩa — **phụ thuộc cứng vào E28-E31 xong trước.**

### E39/E41 — Notification + FCM
- Không tìm thấy file endpoint riêng cho Notification trong `docs/api/endpoints/` (không có `13_notification.md` hay tương đương) — nghĩa là ngay cả tài liệu hoá API cũng chưa có, không chỉ code. Cần làm rõ contract trước khi build.

---

## 3. Cross-cutting findings

1. **Role naming lệch giữa doc và code:** `docs/api/endpoints/*.md` dùng `AGENCY_OWNER / ACCOUNT_MANAGER / CONTENT_CREATOR / BRAND_CLIENT`, nhưng code thực tế (`MemberRole` enum, `workspace-management/spec.md`) dùng `OWNER / CREATOR / VIEWER / CLIENT / ACCOUNT`. Toàn bộ `docs/api/endpoints/04_client.md` đến `11_admin.md` có khả năng là tài liệu cũ/aspirational viết trước khi role model chốt lại — cần review lại toàn bộ trước khi dùng làm spec để code, không chỉ các epic liệt kê ở đây.
2. **Jira status không đáng tin cậy làm tín hiệu tiến độ code:** E16 "In review" và E21 "In Progress" nhưng repo tương ứng không có code phản ánh. Nên đối chiếu trực tiếp branch/PR thay vì chỉ tin Jira status khi ước lượng % hoàn thành.
3. **Publisher-service là điểm nghẽn lớn nhất:** toàn bộ nhóm E21/E22/E32/E33 (publish core) phụ thuộc vào 1 service hiện đang trống hoàn toàn. Đây là rủi ro capstone lớn nhất nếu deadline gần.
4. **Chuỗi phụ thuộc chưa được thứ tự hoá đúng trên Jira:** E38 (Analytics) phụ thuộc E30/E31 (Post); E20 (token refresh) phụ thuộc E18/E19 (social OAuth); E24 phụ thuộc E23. Nếu các epic phụ thuộc bị làm song song không đúng thứ tự sẽ phải làm lại.
5. **Workspace (E15) là chuẩn tốt để nhân bản:** có `@RequireRole` aspect, soft-delete pattern, business rule "last owner" đã implement đúng theo spec — nên dùng làm template khi build Client/Post/ContentRequest controller thay vì thiết kế lại từ đầu.
6. **Chưa thấy MongoDB config nào trong business-service** dù nhiều doc (Social Account, Analytics) giả định lưu Mongo — cần xác nhận dependency `spring-boot-starter-data-mongodb` đã có trong `pom.xml` chưa trước khi bắt đầu E18/E38.

---

## 4. Ưu tiên xây tiếp (theo mức độ tối quan trọng nghiệp vụ)

| # | Epic | Lý do ưu tiên |
|---|---|---|
| 1 | E30/E31 — Post + Approve API | Lõi nghiệp vụ nội dung, mọi thứ khác (Analytics, Content Request) phụ thuộc vào đây |
| 2 | E28/E29 — Content Request API | Điểm vào của luồng Client → AM → Creator, cần song song với E30 |
| 3 | E21/E32/E33 — Publisher service (adapter + retry) | Service đang hoàn toàn trống, publish là giá trị cốt lõi sản phẩm, rủi ro deadline cao nhất |
| 4 | E16 — Client API | Nền tảng multi-tenant agency-client, đã có model + doc sẵn, chỉ cần build (nhanh) |
| 5 | E24 — Wiring business-service ↔ ai-service | AI service đã có code thật, "chỉ" thiếu lớp gọi — effort thấp, giá trị cao |
| 6 | E18/E19/E20 — Social OAuth connect + refresh | Cần trước khi publisher-service (E32) có gì để publish tới |
| 7 | E12 — Facebook OAuth | Effort thấp (copy pattern GitHub/Google), nhưng không chặn epic khác |
| 8 | E17 — Subscription CRUD | Quan trọng cho monetization nhưng không chặn luồng demo core |
| 9 | E38 — Analytics | Phụ thuộc cứng vào E30/E31 xong trước, không nên bắt đầu sớm |
| 10 | E39/E41 — Notification + FCM | Chưa có cả doc, độ ưu tiên thấp nhất cho MVP capstone |

---

## 5. Verify lại với Jira thật (2026-09-03) — task đã đủ, KHÔNG tạo task mới

Sau khi có token Jira, đối chiếu lại toàn bộ 17 epic "Missing API" với task thật trên Jira. **Kết luận: task đã có sẵn, khớp đúng nghiệp vụ, không thiếu task để giao việc.** Vấn đề duy nhất là code chưa làm — đúng như audit gốc đã kết luận, nhưng khác ở chỗ **không cần tạo thêm task mới**, chỉ cần bắt tay vào code theo task đã có.

**Phát hiện quan trọng khác với audit gốc:**
- **E12 (OAuth) đã Done phần lớn** — 7/10 task Done (Register, Login, Refresh, Logout, Forgot/Reset Password, Change Password), chỉ 3 task chưa xong: Google (In review), Facebook + GitHub (In Progress). Audit gốc chỉ nói "thiếu Facebook" — thực tế đã có người đang làm cả Facebook lẫn GitHub.
- **E21 (Publisher Core) đã Done 3/6** — Init project, RabbitMQ consumer, Instagram adapter đều Done. Facebook adapter đang In review. Chỉ Threads + TikTok adapter còn thật sự chưa xong (In Progress). Audit gốc kết luận "service hoàn toàn trống" dựa trên việc chỉ thấy 1 file bootstrap trong repo — **có khả năng code đang nằm ở nhánh/PR chưa merge vào main**, cần Phước xác nhận trực tiếp thay vì tin theo audit code-scan.
- **E28-E31 (Content Workflow) có route thiết kế mới hơn doc cũ** — Jira dùng `/my-tasks`, `/account-review`, `/client-approve`, `/client-reject` thay vì generic `/approve`/`/reject` như `05_post.md` mô tả. Doc API cần cập nhật lại theo task Jira, không phải ngược lại.
- **Doc endpoint (`docs/api/endpoints/*.md`) đã lỗi thời ở nhiều chỗ** — số lượng endpoint trong doc không khớp số task Jira thực tế (VD E16 doc ghi 8 endpoint, Jira chỉ giao 4 task — có thể 4 endpoint còn lại đã được gộp/bỏ theo quyết định thiết kế mới chưa cập nhật lại doc).

**Bảng còn lại chính xác (theo task Jira thật, không phải audit code-scan cũ):**

| Epic | Epic key | Done | Còn lại | Người phụ trách chính |
|---|---|---|---|---|
| E12 Auth/OAuth | DA-92 | 7/10 | Google (review), Facebook + GitHub (In Progress) | Trung |
| E16 Client | DA-102 | 0/4 | Toàn bộ 4 task đang In review — chờ merge, không phải chưa code | Trung (assign) |
| E17 Subscription | DA-107 | 0/4 | Toàn bộ 4 task To Do | Ân |
| E18 Meta OAuth (FB+IG) | DA-103 | 0/4 | Toàn bộ 4 task To Do | Phước, Trung |
| E19 TikTok/Threads/Zalo OAuth | DA-108 | 0/4 | Toàn bộ 4 task To Do | Phước, Trung |
| E20 Token Lifecycle | DA-100 | 0/3 | Toàn bộ 3 task To Do | Trung, Phước |
| E21 Publisher Core | DA-105 | 3/6 | Threads + TikTok adapter (In Progress) | Phước |
| E22 Publish Callback | DA-95 | 0/3 | Toàn bộ 3 task To Do | Phước, Trung |
| E24 AI wiring | DA-101 | 0/3 | Toàn bộ 3 task **Unassigned** — cần giao gấp | Chưa có |
| E28 Content Request | DA-112 | 0/3 | Toàn bộ 3 task To Do | Phước |
| E29 Task Assignment | DA-120 | 0/3 | Toàn bộ 3 task To Do | Phước |
| E30 Content Calendar | DA-114 | 0/4 | Toàn bộ 4 task To Do (2 API + 2 FE component) | Phước |
| E31 Approval Workflow | DA-115 | 0/4 | Toàn bộ 4 task To Do | Phước |
| E32 Publishing System | DA-113 | 0/8 | Toàn bộ 8 task To Do (Facebook/IG/TikTok/Threads/Zalo adapter + Smart Ingestion + RabbitMQ consumer + callback) | Phước |
| E33 Publish Error Handling | DA-118 | 0/3 | Toàn bộ 3 task To Do | Phước, Trung |
| E38 Analytics | DA-125 | 0/4 | Toàn bộ 4 task To Do (2 API + 1 FE + 1 email) | — |
| E39 Notification | DA-121 | 0/3 | Toàn bộ 3 task To Do | Trung, Phước |
| E41 Mobile Notifications | DA-127 | 0/4 | Toàn bộ 4 task To Do | Phước, Trung |

**Việc cần làm ngay (không tạo task Jira mới):**
1. **Giao gấp 3 task E24 (Unassigned)** — DA-221, DA-238, DA-258 — đây là điểm nối AI service (đã chạy thật) vào business-service, effort thấp/giá trị cao nhất theo mục 4.
2. **Xác nhận với Phước về E21 Publisher** — code có tồn tại ở branch riêng chưa merge hay thật sự chưa bắt đầu Threads/TikTok adapter?
3. **Cập nhật `docs/api/endpoints/*.md`** cho khớp route thật đã thiết kế trong Jira (đặc biệt E28-E31, E16) — doc hiện dùng route cũ không khớp task đang code.
4. **Không cần tạo thêm Jira task** cho 17 epic này — toàn bộ đã có task đúng người đúng việc, chỉ cần đẩy code.

---

*Audit gốc thực hiện bằng cách đối chiếu trực tiếp source code 3 service (`business`, `ai`, `publisher`) với `docs/feature/*/spec.md` và `docs/api/endpoints/*.md`, không có Jira token khả dụng lúc đó. Mục 5 verify lại bằng Jira API thật (token Personal API Token, Basic Auth) ngày 2026-09-03 — số liệu mục 5 là nguồn chính xác nhất, ưu tiên hơn kết luận "Missing API" ở mục 1-4 vốn chỉ dựa trên code-scan.*
