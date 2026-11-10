# Admin Management — Implementation Plan

> Thực thi inline theo `superpowers:executing-plans`, kiểm thử nghiệp vụ theo `superpowers:test-driven-development`. Người dùng đã duyệt spec và yêu cầu bắt đầu plan/code ngày 2026-10-01. Không cần duyệt lại nghiệp vụ. Không commit hoặc triển khai production trong kế hoạch này.

**Goal:** triển khai 10 FR đã chốt bằng API/dữ liệu thật, bắt đầu từ nền tảng tài khoản và strike; không sửa FR 3.10.3 của Tuấn.

**Spec:** [quyết định đã duyệt](confirmed-decisions-2026-10-01.md), `spec.md` trong từng thư mục FR và Word FR 3.10.

**Architecture:** nghiệp vụ Admin nằm trong Business Service hiện có. PostgreSQL giữ tài khoản, strike, yêu cầu xử phạt, audit và email outbox; không tạo microservice mới. UI React dùng Axios/TanStack Query. Publisher kiểm tra lại quyền ở thời điểm dispatch khi luồng version bài viết được nối vào. Mọi thời điểm lưu UTC.

**Tech stack:** Java 21, Spring Boot 3.3.5, JPA/JDBC, PostgreSQL, Redis; React 19, TypeScript, Tailwind, i18next, TanStack Query.

## Global Constraints

- Giữ thay đổi đăng nhập/refresh đang có trong working tree. Làm tại workspace người dùng đang mở; không chuyển branch hay bỏ các thay đổi chưa commit.
- System role ADMIN/USER độc lập với quyền Owner/Manager/Creator/Client. Không tự chuyển Owner, không khóa Agency theo user.
- Không xóa tài khoản, không reset TOTP, không tự xác thực email bằng nút Admin, không tự ghi nhận doanh thu.
- Dùng response/error envelope hiện có. DTO whitelist, tuyệt đối không trả entity User chứa passwordHash/OTP/totpSecret.
- Kiểm tra quyền ADMIN tại service từ role hiện tại trong DB, không chỉ dựa vào giao diện hoặc claim cũ.
- Khóa hàng user trước mọi thay đổi strike/sanction; audit và outbox cùng transaction. Thao tác ghi có operationId để chống gửi lặp.
- Chỉ đánh dấu task hoàn tất khi có bằng chứng. Kế hoạch tổng thể không đồng nghĩa toàn bộ FR đã được implement.

## 0. Đối chiếu nền tảng (đã đọc code)

| Thành phần | Hiện trạng | Quyết định triển khai |
|---|---|---|
| AdminController | GET users trả entity User; PUT ban ghi SUSPENDED; chưa có kiểm tra ADMIN riêng | Thay bằng DTO whitelist và service có kiểm tra quyền. Bỏ route ban cũ để không vượt qua xác nhận mới. |
| JwtAuthenticationFilter | Xác thực chữ ký, chưa kiểm tra trạng thái user/blacklist ở Business | Bổ sung account/session policy; chỉ access token có role hợp lệ được dùng cho API. Chuẩn hóa authority ROLE_ADMIN/ROLE_USER. |
| AuthServiceImpl / OAuthService | Chỉ chấp nhận ACTIVE | Cho FLAGGED đăng nhập/refresh; khóa DEACTIVATED và kiểm tra mốc thu hồi token. Giữ luồng self-deactivate riêng. |
| DB | ddl-auto=validate, migration SQL thủ công | Migration cộng thêm, không rewrite dữ liệu SUSPENDED/DELETED; cần áp dụng trước khi chạy binary mới. |
| PostDocument | Chỉ read model Mongo cho thống kê, chưa có write path/version/scheduler trong Business | FR 3.10.4 cần xây đường ghi contentVersion và nối producer trước khi nghiệm thu dispatch. Không tạo moderation giả dựa trên seed. |
| SubscriptionServiceImpl | listPlans chưa làm; subscribe hiện cấp ACTIVE ngay; chưa có payment webhook/ledger | Không lấy thao tác subscribe làm tiền thu. FR 3.10.8/11 cần payment ledger và xác nhận thanh toán, trước khi thay gói tại kỳ mới. |
| AdminPage | users/moderation/stats/health đều từ mock | Thay tab users bằng API thật trước; các tab còn mock không được ghi nhận đã hoàn thành. Giữ monitoring hiện có. |

## 1. Tài khoản, strike, xử phạt — FR 3.10.5/6/9

### Files và hợp đồng

Business paths tương đối `brandhub-business-service/src/main/java/com/brandhub/business/`:

- `model/User.java`, `model/enums/UserStatus.java`: FLAGGED/PENDING_VERIFICATION, cleanPeriodEndsAt, tokensRevokedBefore, reactivateAt. Chỉ xử phạt Admin có reactivateAt; không mở tài khoản tự deactivated hoặc SUSPENDED cũ.
- `model/UserStrike.java`, `model/SanctionReview.java`: mức độ, lý do/category, nguồn quy đổi, operationId, người ghi/gỡ, thời gian hết hạn/gỡ và review PENDING/CONFIRMED/CLOSED.
- `repository/UserStrikeRepository.java`, `SanctionReviewRepository.java`, `UserRepository.java`: khóa user bằng PESSIMISTIC_WRITE; truy vấn lịch sử có phân trang; chọn batch user đến hạn.
- `service/admin/StrikePolicy.java`: tính thẻ hiệu lực, quy đổi ba Vàng chưa dùng, reset hạn khi vi phạm thật; Clock truyền vào policy để test biên ngày 30.
- `service/admin/AdminAccountService.java`, `AdminAccountQueryService.java`, `AdminAccountLifecycle.java`: guard ADMIN và đối tượng, ghi/gỡ, unflag, xác nhận review còn đủ chứng cứ, thu hồi session, mở lại và audit.
- `service/admin/AdminEmailOutbox.java`: lưu email mở khóa cùng transaction; worker gửi sau commit, retry có backoff. SMTP không bảo đảm exactly-once khi process chết sau gửi trước ghi nhận; ghi rõ giới hạn này.
- `security/AccountAccessPolicy.java`, `JwtAuthenticationFilter.java`, `service/impl/AuthServiceImpl.java`, `service/OAuthService.java`: chặn token trước thu hồi, FLAGGED vẫn đăng nhập. Thêm mốc thu hồi vào refresh; sau mở lại phải login mới.
- `controller/AdminController.java`, `dto/request/AdminStrikeRequest.java`, `AdminSanctionRequest.java`, `AdminUnflagRequest.java`, `dto/response/AdminUserResponse.java`, `AdminStrikeSummary.java`: DTO có validation, không rò bí mật.
- Migration: `brandhub-infrastructure/docs/database/migrations/2026-10-01-admin-account-strikes.sql`. Cập nhật hai init SQL sau khi migration được kiểm chứng. Enum PostgreSQL thêm bằng statement autocommit trước DDL dùng giá trị mới.
- Web: `src/services/adminAccountService.ts`, `src/pages/admin/components/AdminAccountsPanel.tsx`, `AdminStrikeDialog.tsx`, `src/pages/admin/index.tsx`. Không sử dụng callback verify/delete/toggle-disable từ mock cho tab users mới.
- Locale: `src/i18n/locales/{vi,en}/admin.json`, đăng ký trong `src/i18n/index.ts`. Keys `admin.accounts.{title,search,status,role,name,email,previous,next,empty,error,retry,manage}`, `admin.strikes.{title,reason,category,level,add,pardon,unflag,confirm,confirmLabel,ownerImpact,history,cleanUntil,reactivateAt,pendingReview,saved,error}`, `admin.status.*`, `admin.level.*`.

### API

- GET `/api/v1/admin/users?page=1&size=20&search=&status=&role=` → `{items,page,size,total}` (size 1–100).
- GET `/api/v1/admin/users/{id}/violations?page=1&size=20` → summary + lịch sử phân trang.
- POST cùng route → `{operationId,action:ADD|REMOVE,level?,category?,strikeId?,reason}`. Lặp cùng operationId/payload trả hiện trạng; cùng key khác payload trả 409.
- PATCH `/api/v1/admin/users/{id}/status` → `{action:UNFLAG,reason}`; không còn thẻ hiệu lực và không DEACTIVATED mới được bỏ cờ.
- POST `/api/v1/admin/users/{id}/sanction` → `{reviewId,confirmed:true,reason}`. Review đang chờ + RED hoặc >=3 ORANGE hiệu lực; tự phạt/ADMIN ngang hàng trả 403.
- Route PUT ban cũ bị loại bỏ, không còn đường bỏ qua review. FLAG từ ORANGE; thao tác FLAG thủ công phải ghi nhận ORANGE có lý do qua violations.

### Trình tự RED → GREEN

1. Test ba Vàng khác category→một Cam, Y4 không thêm Cam, Y6→Cam thứ hai; pardon nguồn giữ Cam; ngày 29 reset, đúng ngày 30 expire, không hồi sinh thẻ cũ.
2. Test ADMIN guard, DTO không lộ secret, idempotency, review chỉ một pending, evidence hết hạn không xác nhận được; confirm30 ngày và không tự mở sớm.
3. Implement migration, model/repository, policy, service/API; test transactions bằng PostgreSQL dev/integration trước nghiệm thu concurrency.
4. Test auth: FLAGGED được login/refresh; refresh/2FA token không dùng làm access; DEACTIVATED bị chặn; token cũ vẫn bị chặn sau auto-unlock; self-deactivated không bị worker mở.
5. UI real API: tìm/lọc/phân trang, lịch sử và ghi/gỡ thẻ, xác nhận khóa; giữ form khi lỗi và khóa nút trong mutation. Light/dark + VI/EN.
6. Chạy unit/MockMvc, compile/build web, migration trên DB test; ghi nhận các lỗi baseline riêng.

## 2. Kích hoạt và hồ sơ — FR 3.10.7/8

- Thêm `AdminProvisioningService`, DTO `CreateAdminUserRequest`/`UpdateAdminUserRequest`, `AccountActivationController/Service`, bảng `account_activation_tokens` lưu token hash/expiry/usedAt. GET catalog sử dụng SubscriptionPlanRepository thật.
- POST admin/users: chuẩn hóa unique email, fullname 2–100, mật khẩu min8 + số + ký tự đặc biệt, BCrypt12; PENDING_VERIFICATION + requirePasswordReset; enqueue email bắt buộc. Không đặt verifiedAt hoặc cấp paid entitlement.
- Token kích hoạt chỉ được dùng verify + đổi password; token dùng một lần, chống replay, không trả access trước hoàn tất hai điều kiện. UI `/activate-account`, lỗi giữ form, không lưu token trong log.
- PATCH admin/users/{id}: email bất biến; role hiện tại kiểm tra lại; không hạ ADMIN ngang hàng. Pending plan lưu `subscription_plan_changes` gắn currentPeriodEnd, paymentRequired=true; không ghi revenue.
- Test email trùng/normalization, mật khẩu yếu, replay/expiry, OAuth không bỏ qua password reset, Owner profile, kỳ sau chưa trả tiền không được tăng quota.

## 3. Nội dung và xuất bản — FR 3.10.4

- Xây `ContentVersionService` với Mongo immutable revision và PostgreSQL `content_moderation_reviews` (postId + versionId unique, snapshot/hash/reason/decision/adminId). Producer nội dung sở hữu việc enqueue; ADMIN không truyền arbitrary authorId.
- `AdminModerationController/Service`: APPROVE/BLOCK exact version, note >=10, block tạo strike qua cùng service transaction/idempotency key từ review. Approve giữ workflow/schedule hiện có.
- Nối scheduler đọc trạng thái tác giả khi đưa job vào queue; job chứa authorId, postId, contentVersionId. `publisher/core/consumer/PublishJobConsumer.java` gọi internal eligibility endpoint có credential service trước adapter; fail closed khi không xác minh được. Bài cũ đã schedule được giữ lại, không chỉ chặn UI.
- Test version mismatch, author bị flag sau enqueue, Manager approve không đủ, block sửa/resubmit mới, duplicate callback không ghi strike hai lần, Business unavailable không publish.

## 4. Email broadcasts — FR 3.10.1

- `AdminNotificationController/Service`, PostgreSQL `admin_notifications` + recipient deliveries. Các trạng thái DRAFT/SCHEDULED/SENDING/SENT/FAILED/CANCELLED; SENDING là trạng thái kỹ thuật khóa audience và quyền sửa.
- Scheduler claim due rows bằng `FOR UPDATE SKIP LOCKED`, resolve audience ALL/BY_PLAN/BY_ROLE tại send time. Delivery unique(notificationId,userId), không retry delivered. SMTP retry có backoff và giới hạn log không lộ nội dung nhạy cảm.
- Validate title5–200/body10–5000; future schedule ISO timestamp có offset; timezone hiển thị. PATCH/cancel chỉ trước gửi; zero recipients SENT/0. UI composer/list với lịch và cancel confirmation.
- Test chuyển plan trước gửi, cancel/send race, duplicate worker, SMTP fail/partial, đúng offset và zero audience.

## 5. Thống kê, doanh thu — FR 3.10.2/11

- `AdminStatisticsService` đọc user.lastLoginAt (successful login) và audit LOGIN; audit TOKEN_REFRESH không là activity. Ba rankings riêng: Mongo posts workspace→agency, audit sự kiện nghiệp vụ agencyId (CREATE/UPDATE/DELETE/ROLE_CHANGE/PERMISSION_CHANGE), payment ledger agencyId.
- Xây payment ledger nguồn sự kiện xác nhận giao dịch: unique provider/eventId, type SUBSCRIPTION/AI_CREDIT/REFUND, amount/currency/paidAt/refundOf/agencyId. Cần đầu nối payment provider trước nghiệm thu thu thực tế; không suy đoán giao dịch từ subscription ACTIVE hoặc seed.
- `AdminRevenueService`: BigDecimal, paid active subscription net recurring price/cycleMonths; MRR sum/ARR*12; receipts/partial refunds theo ngày sự kiện; đồng tiền phải nhóm riêng, không cộng VND với USD.
- `ReportPeriod` chỉ UTC/Asia/Ho_Chi_Minh, interval [from,to), daily buckets trong zone; cùng cache key/filter/asOf cho màn và export. Cache 15 phút có asOf.
- UI `AdminStatisticsPanel`/`AdminRevenuePanel`; dữ liệu unavailable phải hiển thị rõ, không tráo số mock. Test gói năm1200000→100000MRR, giảm giá, AIcredit, hoàn kỳ khác, timezone midnight, inactive/failedpayment, ba ranking độc lập.

## 6. PDF — FR 3.10.12

- `AdminReportController/Service` dùng snapshot dataset từ mục5; A4, embedded font có tiếng Việt, filters/zone/asOf và pagination. Không đưa field bí mật user vào report.
- API trả metadata JSON + link download có token hash, expires24h; authorization ADMIN ở cả create/download. File private storage và cleanup TTL; audit export có filter/count, không nội dung cá nhân.
- Không có dữ liệu→MSG122 không tạo file. Test expired link, unauthorized download, dataset/formula parity, tiếng Việt và overflow bảng bằng render PDF.

## Verification / baseline

- Business: Maven 3.9.11 từ wrapper cache, `mvn -B test`; trước sửa 243 tests, 1 failure,10 errors,9 skipped (log `.tmp/admin-baseline-tests.log`). Phân tích cụ thể trước kết luận regression.
- Web: `npm run build`, eslint các file đổi; Playwright smoke nếu server chạy. Không có script unit test hiện tại.
- Gateway/Publisher: `mvn -B test` khi sửa tương ứng.
- Migration: apply DB test, run twice, verify FK/unique indexes, concurrency same-user; backup trước khi apply dev DB. Không tự migrate production.

## Review Focus

Kiểm tra mọi đường cấp/quay vòng JWT, không lộ secret từ DTO, race ghi/gỡ/quy đổi/confirm, không mở self-deactivated hoặc SUSPENDED cũ, không tác động agency members, rollback DB/outbox, SMTP ambiguity; actor authorization lấy từ DB. Review độc lập sau khi hoàn thành slice triển khai, không coi unit mocks chứng minh được khóa DB.

## Quyết định kỹ thuật sau review — 2026-10-02

- Thêm `users.row_version` (JPA optimistic lock) để thao tác hồ sơ/login cũ không ghi đè xử phạt vừa commit. Xung đột trả `409 CONCURRENT_UPDATE`.
- Thêm `users.session_version`; xác nhận xử phạt tăng generation. Access/refresh token đều mang generation của user tại lúc bắt đầu cấp phiên; kiểm tra generation hiện tại ở access và refresh. Token legacy thiếu claim được coi là generation0. Cách này chặn cả refresh đang chạy đồng thời, dù JWT được ký sau mốc thu hồi; mở lại không reset generation.
- Nếu hạn sạch đã qua nhưng worker chưa chạy, reconciliate flag và review dưới khóa user trước khi ghi vi phạm mới. Một Vàng mới không kéo dài cờ Cam đã hết hạn.
- POST/PATCH mutation trả `ApiResponse<Void>` với data=null; UI invalidate/refetch danh sách và lịch sử sau thành công. Dùng enum `ADD/REMOVE/UNFLAG`, khác cách viết thường trong API đề xuất ban đầu.
- Bộ DTO hoàn toàn tách entity User. Đọc danh sách giới hạn100; roles/strike/review được lấy theo batch cho cả page.
- SMTP timeout cấu hình tại `application.yml`; retry outbox không rollback việc mở tài khoản. Không hứa exactly-once SMTP sau crash giữa gửi và commit.
- Thực thi giai đoạn nền tảng: xem [trạng thái và bằng chứng](implementation-status-2026-10-02.md). Những mục2–6 vẫn là kế hoạch, chưa nghiệm thu.
