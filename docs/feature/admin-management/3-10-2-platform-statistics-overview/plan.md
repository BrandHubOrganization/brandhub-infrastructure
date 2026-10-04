# Plan — 3-10-2-platform-statistics-overview

Nguồn: [spec](spec.md), [quyết định đã duyệt](../confirmed-decisions-2026-10-01.md).

Thiết kế, file paths, API, migration, thứ tự và rủi ro: **mục 5** của [plan tổng thể](../plan.md). Các global constraints và Review Focus trong plan tổng thể áp dụng đầy đủ.

Thành phần: AdminStatisticsService; ReportPeriod; AdminStatisticsPanel.

## Dashboard foundation — 2026-10-02

- Design: giữ font Inter và palette BrandHub (cam `#f05a28`, trắng `#ffffff`, canvas `#fafafa`, xám `#71717a`, sidebar `#09090b`); màu lấy qua theme token. Header căn trái; vùng nội dung tối đa khoảng1440px;4 KPI; biểu đồ đăng ký chiếm2/3, phân bố tài khoản1/3; hàng dưới là các việc cần xử lý và tài khoản mới. Không trang trí gradient hoặc số tăng trưởng chưa có căn cứ.
- URL `/admin` là Tổng quan, `?view=users` là danh sách; filter status trong URL dùng cho drill-down. Giữ query state khi refresh/back. Sidebar Admin riêng trong component hiện có, không đổi nghiệp vụ Monitoring hoặc quyền người dùng thường.
- API đọc riêng `GET /api/v1/admin/statistics?days=30&timezone=Asia/Ho_Chi_Minh`. ChỉADMIN; days∈7,30,90; timezone∈UTC,Asia/Ho_Chi_Minh; sai→400. Không mutation hoặc migration.
- DTO: `generatedAt`, `timezone`, `days`, `periodStart`, `periodEnd` (ISO timestamps; cuối kỳ là now), `totalUsers`, `activeUsers30d`, `totalAgencies`, `flaggedUsers`, `pendingVerificationUsers`, `deactivatedUsers`, `pendingSanctions`, `newUsersInPeriod`; `strikes:{yellow,orange,red}`; `accountStatuses:[{status,count}]`; `registrations:[{date,count}]` đủ ngày theo timezone. Không trường riêng tư.
- Backend dùng Clock, SQL/JPA tổng hợp có tham số và transaction read-only REPEATABLE_READ để giữ snapshot nhất quán. Đã xác minh lastLoginAt chỉ được cập nhật tại completeLogin (password/2FA) và OAuth login; refresh không gọi completeLogin. Strike chỉ removed_at IS NULL, converted_to_id IS NULL, expires_at > now, created_at <= now. Pending review trạng tháiPENDING. Agency loại deleted_at khácnull hoặc statusSOFT_DELETED theo enum hiện có.
- Frontend: `adminStatisticsService.ts`, `AdminOverviewPanel.tsx`, các component biểu đồ/summary cần thiết, `admin/index.tsx`, AccountsPanel và Sidebar. Overview loading/empty/error/forbidden, retry/refresh; query key gồm actor+days+timezone; sau đổi tài khoản không dùng dữ liệu người cũ. Dữ liệu cũ có chỉ báo nếu refresh thất bại.
- Giữ chức năng strike đang chạy; cải thiện avatar/tên/email, toolbar, trạng thái và bố cục bảng. Các FR chưa triển khai hiển thị chưa sẵn sàng, không giả lập approve/send/export.
- Ruling: thực hiện trong working tree hiện tại để giữ các thay đổi Admin/auth chưa commit và tiếp tục localhost người dùng đang xem; không reset/checkout hoặc commit các thay đổi ngoài phạm vi.
- Ruling: không thêm tài chính/ranking Agency ở bước thiết kế dashboard này vì phải hoàn tất ánh xạ nguồn thu/bài/hoạt động của giai đoạn sau; dùng trạng thái chưa có dữ liệu thay số giả.

Trình tự: test nghiệp vụ RED → backend/data GREEN → API/security → UI/locale → build/integration. Locale thêm trong brandhub-web/src/i18n/locales/vi/admin.json và en/admin.json; theme dùng token hiện có. Không sửa monitoring.

## UI refinement — 2026-10-04

1. Dùng working tree hiện tại vì đây là tiếp tục dashboard/auth đang được người dùng xem; giữ mọi thay đổi có sẵn, không commit/push.
2. Tách `AdminOverviewPanel` thành orchestration và component summary/charts/recent users trong `src/pages/admin/components/`, chỉ dùng `adminStatisticsService`/`adminAccountService` hiện hữu. Không thêm endpoint/migration.
3. Cập nhật `AdminSidebar`, phần Admin của `Navbar`, `admin/index.tsx`, bảng người dùng/dialog: bố cục mẫu, navigation grouping, role thật, bỏ notification mock cho ADMIN, làm rõ strike. Tôn trọng phạm vi người dùng thường và Monitoring.
4. Bổ sung song song `src/i18n/locales/{vi,en}/admin.json`: `navigation.utilities`, `.planned`, `overview.pendingHint`, `.attentionHint`, `.verificationHint`, `.flaggedReviewHint`, `.sanctionHint`, `.noPending`, `.periodTotal`, `.snapshot`, `accounts.rulesTitle`, `.rulesHint`, `.clearFilters`, `.page`, `.reviewPending`. Không đổi định nghĩa activeUsers30d.
5. Chạy Playwright Admin/auth hiện có, thêm kiểm tra nội dung sai của HTML không lọt vào UI, các mục chưa sẵn sàng, trường hợp tổng user=0 và viewport tablet. Build, lint các file đổi; xem ảnh VI/EN sáng/tối và browser smoke API thật.
6. Ghi bằng chứng tại test.md/task.md. File HTML là tài liệu tham khảo, không phải hợp đồng dữ liệu; ghi rõ các khác biệt đã sửa trong ứng dụng.

