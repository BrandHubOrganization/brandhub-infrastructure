# Trạng thái triển khai Admin Management — 2026-10-02

## Đã triển khai và kiểm chứng

Giai đoạn nền tảng cho FR3.10.5/6/9 theo [plan](plan.md):

- Tab user từ API thật, DTO không chứa passwordHash/otpCode/totpSecret; tìm tên/email, lọc system role/trạng thái và phân trang.
- Strike YELLOW/ORANGE/RED, quy đổi đúng nhóm ba Vàng và liên kết nguồn, không dùng lại nguồn, gỡ nguồn không cascade sang Cam.
- Vi phạm mới reset hạn của thẻ đang hiệu lực, không hồi sinh thẻ đã hết/gỡ; xử lý cả biên thời gian trước khi worker chạy.
- Ba Cam hoặc Đỏ tạo review chờ; xác nhận có checkbox/lý do mới khóa30 ngày. Không tự phạt/ADMIN ngang hàng; không đổi quyền sở hữu hay đình chỉ Agency.
- Mở tự động khi đủ hạn, giữ generation phiên cũ vô hiệu, transactional email outbox có retry. Test SMTP dùng mock, không gửi email thử tới người dùng thật.
- UI Việt/Anh, light/dark, 390px/1440px; giữ bằng chứng khi mutation thất bại và retry cùng operationId.
- Đã backup database dev ở `F:/LEARN/DA/.tmp/brandhub-before-admin-20261002.dump`, áp dụng migration cộng thêm. Không thay dữ liệu SUSPENDED/DELETED cũ thành ACTIVE.

## Bằng chứng

- Lần kiểm chứng cuối:67/67 test liên quan pass, gồm auth/login/refresh/OAuth/2FA, security, strike/lifecycle và PostgreSQL integration. Log `.tmp/admin-verified-tests.log`.
- Unit RED→GREEN: StrikePolicy (4 test), AdminAccountService, AccountAccessPolicy, lifecycle; thêm regression cho expired flag, session generation và stale User save sau sanction.
- `AdminAccountDatabaseTest`: PostgreSQL17 thật, migration lặp an toàn; quy đổi/pardon/DTO/idempotency; xác nhận/mở lại/email retry; sáu writer đồng thời; stale profile/login save bị optimistic lock từ chối. Database test riêng `brandhub_admin_20261001_test`, không xử phạt user dev thật.
- `AdminSecurityTest`:401/403, role ADMIN cũ không vượt quyền hiện tại, DEACTIVATED, blacklist, refresh token không dùng như access, UUID/status không hợp lệ400.
- `JwtSessionVersionTest`: ký và parse RSA thật cho session generation trên cả access và refresh.
- Playwright `tests/e2e/admin/accounts.spec.ts`:6/6 pass, API response được mock cho kiểm tra UI. Đã xem4 ảnh VI/EN/light/dark.
- `npm run build` và ESLint các file đổi: pass.
- Smoke HTTP thật qua Gateway: login dev Admin thành công, profile roleADMIN, GET admin/users thành công, không có trường bí mật; không token→401. Business8081, Gateway8080 và web3000 đã khởi động trong phiên làm việc.

## Lỗi baseline, không che giấu
### Bổ sung sửa lỗi đăng nhập — 2026-10-02

Đã sửa stale bearer chặn login/Dev Quick Login: web bỏ Authorization ở các POST tự xác thực; backend chỉ bỏ lọc access token cho đúng tám endpoint, vẫn kiểm tra credentials và bảo vệ API cần đăng nhập. Chi tiết và bằng chứng ở [FR3.2.2 test](../authentication/3-2-2-sign-in-with-email/test.md#bằng-chứng-regression--2026-10-02):94 auth/security test và8 UI test pass; hai luồng đăng nhập thật vào Admin thành công sau restart Business. Không thay quy tắc sanction/session revocation.

### Baseline toàn bộ Business suite

Full Business suite sau thay đổi:278 test,1 failure,10 errors,9 skipped. Cùng11 lỗi đã có trước khi viết code (baseline243 test,1 failure,10 errors,9 skipped):

- `WorkspaceServiceTest.listMyWorkspaces_returnsWorkspacesForActiveMemberships` thất bại.
- Ba test `WorkspaceServiceTest.createWorkspace_*` lỗi do fixture không đáp ứng quyền Agency Owner.
- Bảy test `WorkspaceControllerIntegrationTest` không khởi tạo được context vì thiếu mock `ClientProfileRepository` của `RequireRoleAspect`.

Log: `.tmp/admin-baseline-tests.log`, `.tmp/admin-final-backend.log`, `.tmp/admin-verified-tests.log`, `.tmp/admin-web-qa.log`, `.tmp/admin-verified-web-build.log` trong workspace. Lần chạy khi Docker tắt có4 lỗi kết nối bổ sung; đã bật Docker và chạy lại,4 lỗi đó không còn.

## Review

Review độc lập phát hiện hai race ở login/refresh và một lỗi expired-flag. Đã thêm optimistic row version, session generation và reconcile trước vi phạm mới; lần review lại không còn finding quan trọng trong ba điểm này.

## Dashboard Tổng quan — cập nhật 2026-10-02

- `/admin` mở Tổng quan; `/admin?view=users` mở danh sách. Sidebar và menu điện thoại dành riêng Admin, không yêu cầu chọn Agency; link Monitoring giữ chức năng hiện có.
- 4 KPI thật, biểu đồ đăng ký 7/30/90 ngày, múi giờ VN/UTC, phân bố trạng thái, strike còn hiệu lực/review chờ và user mới. API `GET /api/v1/admin/statistics` chỉ dành cho Admin, snapshot PostgreSQL nhất quán; không lấy dữ liệu mock từ màn Admin cũ.
- Danh sách có avatar, toolbar, nhãn thẻ; bộ lọc theo URL và drill-down; giữ luồng phạt hiện có. VI/EN, light/dark, desktop/mobile; trạng thái lỗi/retry/forbidden có kiểm chứng.
- 13 backend test và 18 UI test pass; ESLint/build pass. Browser thật đã đăng nhập, đổi múi giờ, mở danh sách/dialog thành công. Chi tiết: [FR3.10.2 test](3-10-2-platform-statistics-overview/test.md). Ảnh `.tmp/admin-dashboard-live-vi.png` trong workspace.

## Phần còn lại

Không coi10 FR đã xong. FR3.10.7/8 (provisioning/activation/profile/paid next-cycle plan), FR3.10.4 (moderation và publisher), FR3.10.1 (broadcast email), FR3.10.11/12 (revenue/PDF) chưa triển khai đầy đủ. FR3.10.2 đã có dashboard foundation ở trên, còn rankingAgency, tài chính, custom range, cache vàPDF. Các mục chưa triển khai trong Admin mới hiển thị chưa sẵn sàng, không giả lập thao tác thành công. Metadata subscription của danh sách user vẫn còn ở giai đoạn2.

FLAGGED hiện được lưu và cho đăng nhập; yêu cầu ADMIN duyệt/giữ lịch bài tại luồng publish phải được nối ở giai đoạn3 trước khi nghiệm thu toàn bộ FR3.10.5/9. Email outbox hiện chỉ phục vụ mở khóa, không thay thế broadcast của FR3.10.1. Monitoring của Tuấn không sửa.

Chưa commit/push. Giữ nguyên các thay đổi auth/dev-login/AI có sẵn trong working tree trước phiên này.

## Doanh thu, thông báo email, PDF — cập nhật 2026-10-04

- FR 3.10.11: `GET /api/v1/admin/revenue?from&to&timezone&plan` trên bảng `transactions` PayOS hiện có; MRR/ARR, tiền thu gộp/hoàn/ròng, tách tiền tệ, MRR theo gói, giao dịch gần nhất; màn `/admin?view=revenue`.
- FR 3.10.1: `/api/v1/admin/notifications` (tạo, sửa, hủy, lịch sử, ước tính, catalog gói); worker xác định người nhận lúc gửi, giao qua `admin_email_outbox`; màn `/admin?view=email`.
- FR 3.10.12: `POST /api/v1/admin/reports` (REVENUE/USER/PLATFORM) + tải bằng token 24 giờ; trang `/admin?view=reports` và nút xuất ở Doanh thu/Người dùng.
- Migration [2026-10-04-admin-notifications-reports.sql](../../database/migrations/2026-10-04-admin-notifications-reports.sql); dependency `openpdf` + `openpdf-fonts-extra` 2.0.3.
- Dữ liệu demo: profile `seed-admin-demo` (`AdminDemoSeeder`), xem README seed.
- Chi tiết kiểm chứng và giới hạn: test.md của [3.10.1](3-10-1-push-notification/test.md), [3.10.11](3-10-11-view-revenue-dasboard/test.md), [3.10.12](3-10-12-export-report-file-pdf/test.md).
- Chưa làm: FR 3.10.4 Kiểm duyệt (thiếu nguồn vi phạm FR 3.6.33/34 và nối publisher), FR 3.10.7/8. Hai init SQL chưa gộp migration strikes 2026-10-01 và migration 2026-10-04.

## Kiểm duyệt nội dung — cập nhật 2026-10-04

- FR 3.10.4: PostgreSQL `content_moderation_reviews` (quyết định, thẻ phạt, audit) + Mongo `post_versions` (snapshot bất biến) + `posts.content_version`.
- Hook gửi duyệt trong `PostServiceImpl` (code của Lộc, người dùng đã đồng ý); API nội bộ cho Tuấn/Phước; màn `/admin?view=moderation`.
- Dev Business dùng Mongo local (`MONGODB_URI` trong `.env`, không commit), không ghi vào Atlas chung. Test dùng DB riêng `brandhub_moderation_test`.
- Hai init SQL (`docs/database/` và `scripts/`) đã gộp migration strikes 2026-10-01, notifications/reports và moderation 2026-10-04; dựng DB trắng từ mỗi file thành công.
- Chi tiết: [3.10.4 test](3-10-4-content-moderation-queue/test.md).

## Thông báo trong app — cập nhật 2026-10-04

- Theo quyết định mới của người dùng, FR 3.10.1 gửi cả email và in-app. Chi tiết: [quyết định](confirmed-decisions-2026-10-01.md), [test](3-10-1-push-notification/test.md).
- Sự cố đã xử lý: broadcast thử "test thử thôi" tới Tất cả người dùng có 5 địa chỉ seed mang domain thật; đã hoãn rồi đánh dấu `DEV_RECIPIENT_BLOCKED` trước khi SMTP gửi. Không có email nào tới người ngoài.
- Sidebar Admin dùng logo BrandHub thật (`BrandHubLogo`).

## Tạo và sửa người dùng — cập nhật 2026-10-04

- FR 3.10.7: `POST /api/v1/admin/users` tạo tài khoản `PENDING_VERIFICATION`, email kích hoạt bắt buộc (link 1 lần, 72h), trang `/activate-account` để người dùng tự đặt mật khẩu.
- FR 3.10.8: `GET/PATCH /api/v1/admin/users/{id}`; email bất biến, bảo vệ vai trò, đổi gói áp dụng kỳ sau và vẫn cần thanh toán.
- Migration `2026-10-05-admin-user-provisioning.sql`: chạy 2 lần DB test, backup, 2 lần DB dev; đã gộp vào 2 init SQL, dựng DB trắng từ mỗi file thành công.
- Chi tiết: [3.10.7 test](3-10-7-create-user/test.md), [3.10.8 test](3-10-8-update-user/test.md).
