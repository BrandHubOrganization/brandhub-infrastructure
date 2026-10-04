# Test — 3-10-2-platform-statistics-overview

Các kỳ vọng chi tiết: Acceptance Criteria/Edge Cases trong [spec](spec.md) và mục 5 của [plan kỹ thuật](../plan.md).

- [x] Successful login trong 30 ngày (foundation)
- [x] Refresh không tính: dùng lastLoginAt; đã đối chiếu writer login/2FA/OAuth, refresh không cập nhật
- [ ] 3 ranking riêng
- [x] Biên UTC/VN cho biểu đồ đăng ký foundation
- [x] VI/EN và light/dark cho dashboard foundation

- [x] Chưa đăng nhập401; USER gọi Admin403; ADMIN hợp lệ mới đọc được endpoint statistics foundation.
- [ ] Lỗi server không báo thành công, không mất dữ liệu form; double click không ghi trùng.
- [ ] Không trả passwordHash/otpCode/totpSecret hoặc token trong danh sách/audit.

## Kết quả

### Dashboard foundation — 2026-10-02
- Backend: ADMIN200/USER403/anonymous401; days/timezone không hợp lệ400; aggregate không lẫn refresh với login, không đếm strike hết/gỡ/quy đổi; ngày thiếu được bù0; phân ngày UTC/VN đúng ở23:59/00:00; không trả PII.
- UI: `/admin` mặc định Tổng quan; số thực từDTO; lỗi không chuyển thành0; đổi kỳ/timezone gửi đúng query; refresh/retry; không sửa cache người khác; drill-down mở danh sách đúng trạng thái; back/refresh giữview; tab Người dùng giữ các thao tác strike.
- Visual: VI/EN, light/dark,1440px/390px; kiểm tra ảnh chụp, không tràn trang; keyboard/focus và nhãn biểu đồ; Admin không thấy ô chọn Agency. Mục chưa triển khai không có thao tác thành công giả.
- Regression: tests account/strike và stale-session hiện có; update URL vào tab users nếu trước đây mặc định users.

### Kết quả foundation ngày 2026-10-02

- Backend:13/13 pass (`AdminStatisticsTest`5 PostgreSQL thật + `AdminSecurityTest`8 MVC/security),0 skip. Bao gồm30d login window, biên ngàyVN/UTC, bù ngày0, future timestamp, strike gỡ/hết/quy đổi, Agency soft delete theo cả timestamp/status, tổng phân bố bằng tổng user;401/403/Admin200. Log `.tmp/dashboard-data-final.log`.
- Frontend:18/18 Playwright pass (9 overview,7 account,2 stale-login), gồm lỗi/retry,403 sau khi đã cache số liệu, search reset theo URL, mobile Admin navigation, trạng thái drill-down, VI/EN/light/dark. Log `.tmp/dashboard-ui-final.log`. Ảnh lưu ở `brandhub-web/test-results/admin-overview-*` và `admin-accounts-*`.
- RED đã tái hiện trước sửa: thiếu dashboard; mobile Admin dùng nhầm nav Workspace; cached số liệu còn hiển thị sau403; search cũ còn trong input sau xóa URL filter. Logs `.tmp/dashboard-ui-red.log`, `.tmp/dashboard-mobile-red.log`, `.tmp/dashboard-review-red.log`. Fixture ngày đã sửa để không bị Hibernate CreationTimestamp ghi đè; không sửa model production để chiều test.
- ESLint tất cả file frontend thay đổi và `npm run build`: pass; cảnh báo chunk lớn có sẵn vẫn còn. Logs `.tmp/dashboard-web-lint-final.log`, `.tmp/dashboard-web-build-final.log`.
- Browser/HTTP không mock qua Gateway8080: loginAdmin thành công; statistics200 ở cảUTC/VN,7/30 mẫu ngày; filter sai400, anonymous401; mở danh sách và dialog thẻ phạt; không lỗi JavaScript. DevDB hiện2users,1active30d,0agency. `.tmp/dashboard-live.log`, script `.tmp/dashboard-live.cjs`; ảnh `.tmp/admin-dashboard-live-vi.png`, `.tmp/admin-users-live-vi.png`.
- Review độc lập phát hiện2 lỗi UI nói trên, đã sửa và review lại không còn finding quan trọng trong phạm vi. Không chạy lại full suite có lỗi Workspace baseline vì không đổi Workspace business logic.

Chỉ nghiệm thu foundation. Ba bảng xếp hạng Agency, tài chính/MRR/ARR, custom range, cache Redis và PDF vẫn thuộc bước sau; checklist toàn bộ FR ở trên không được coi là hoàn thành.

## Kế hoạch kiểm chứng UI refinement — 2026-10-04

- Dữ liệu KPI/chart/status từ API; không Trust Score/Super Admin/x/2, mock notification hay số tiền mẫu. Có KPI pendingSanctions, nhãn active 30 ngày rõ; đổi 7/30/90 và UTC/VN gửi đúng query.
- Loading, lỗi/retry, refresh lỗi giữ chỉ báo stale; 403 bỏ toàn bộ số liệu đã cache. Tổng 0 không NaN, không tạo tỷ lệ giả.
- Link trạng thái mở đúng URL; search/filter/reload/pagination/dialog/quyền xử phạt giữ hành vi cũ. Email/Revenue/Reports/Moderation ghi rõ chưa sẵn sàng.
- VI/EN và light/dark; 375/768/1440px không tràn main, sidebar collapsed/mobile drawer; bảng cuộn bên trong; ảnh kiểm tra bằng mắt.
- Build và ESLint các file đổi; Playwright overview/accounts/stale-session; browser smoke đăng nhập Admin và đọc API thật. Không thử mutation chế tài trên dữ liệu người dùng để chụp giao diện.

Kết quả kiểm tra ngày 2026-10-04:

- Build frontend (`tsc -b` + `vite build`) thành công sau khi cài dependency của bản pull mới. ESLint các file thay đổi: 0 lỗi, 1 cảnh báo `react-hooks/set-state-in-effect` tại Sidebar trong logic hover/đóng Org Switcher có sẵn.
- Playwright overview/accounts: 17/17 pass. Kiểm tra shell Admin bỏ chuông notification mock đã RED (chuông vẫn tồn tại), sau sửa GREEN. Các nhánh refresh/retry/403, URL/search, dialog/idempotency khi lỗi, VI/EN và sáng/tối vẫn pass.
- Browser thật qua Gateway: đăng nhập Admin, statistics HTTP200, đổi UTC/VN, tìm tài khoản theo email và mở/đóng dialog thẻ phạt đều thành công; 0 lỗi JavaScript. Script `.tmp/dashboard-live.cjs`; ảnh `.tmp/admin-dashboard-live-vi.png`, `.tmp/admin-users-live-vi.png`.
- Dữ liệu DB hiện đã được seed thêm: 1.242 users, 795 active30d, 46 Agency; không giả định Admin nằm trong trang tài khoản đầu tiên. Smoke script tìm kiếm trước khi kiểm tra tài khoản Admin.
- Đã xem ảnh dashboard desktop thật và mobile dark từ Playwright. Web3000, Gateway8080, Business8081, AI8082, Publisher8083 đều phản hồi; Business health cần thời gian lâu hơn các dịch vụ khác nhưng trả UP.

Phạm vi bằng chứng này là dashboard/accounts và khởi chạy hệ thống; không dùng để nghiệm thu toàn bộ FR tài chính, email, xuất PDF hoặc Monitoring.

- Kiểm tra bổ sung trên code hiện tại sau pull: overview + accounts + finance + stale-session, 24/24 Playwright pass (19,8 giây). Bao gồm đăng nhập mật khẩu/Dev Quick Login thay phiên cũ, giao diện doanh thu mobile light/dark, validation lịch email và export không tạo PDF rỗng. Các bài kiểm tra finance dùng API fixture nên không chứng nhận đã gửi email hay thanh toán thật.

