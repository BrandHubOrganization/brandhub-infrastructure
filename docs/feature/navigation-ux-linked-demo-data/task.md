# Điều hướng, bố cục và data demo liên kết: công việc

## 1. Data demo

- [x] Viết `linked-demo.sql` và `linked-demo-remove.sql`
- [x] Viết `LinkedDemoSeeder` với profile `seed-linked-demo`, cờ gỡ và chặn production
- [x] Test seeder: chạy 2 lần không đổi số bản ghi; gỡ xong còn nguyên data khác
- [x] Bỏ Livestream khỏi `dev-quick-login.sql` và `TaskSampleSeeder`
- [x] Chạy `seed-admin-demo` rồi `seed-linked-demo` trên Postgres local và Mongo Atlas
- [x] Xác minh qua API: 5 tài khoản đúng vai trò, biểu đồ có số liệu

## 2. Mobile: tab dưới

- [x] Thanh tab tự viết trong `screenLayout`, không thêm thư viện
- [x] `WorkspaceTabBar` và `tabs.ts` theo vai trò, test quyền
- [x] Drawer chỉ đổi Workspace; xử lý tab biến mất khi đổi vai trò
- [x] `GlobalFab` không che tab

## 3. Mobile: Admin

- [x] Thanh tab trong `AdminStackNavigator` và `AdminMoreScreen`
- [x] Back cho mọi màn không phải gốc tab
- [x] Bỏ chip và link trùng ở Overview
- [x] `AdminCharts` cho Overview và Doanh thu

## 4. Mobile: hồ sơ Client và trang Thêm

- [x] `workspaceService.switchMyClientProfile`, test service
- [x] `ClientProfileScreen` với đủ trạng thái
- [x] Gọn `MoreScreen`, một lối Cài đặt, tối đa 12 mục mỗi vai trò
- [x] `LoginScreen`: Creator là `user13@`

## 5. Mobile: chia lại nút

- [x] Sửa AgencyDetail, TaskDetail; SecuritySettings, AccountSettings đã xem, giữ nguyên
- [x] MediaLibrary, AdminUserStrikes, ContentRequestDetail, CameraRecord: đã xem, giữ nguyên

## 6. Web

- [x] Nhóm con cho `create` trong sidebar
- [x] Breadcrumb `crawl`, `trendPipeline`
- [x] Bỏ `landingPath` trong `DevQuickLogin`
- [x] Audit trang web: dashboard và dashboard Workspace đã gọn; các trang khác chưa đọc hết

## 7. Hoàn tất

- [x] Cập nhật `vi.json` + `en.json` (web) và `en.json` (mobile)
- [ ] Kiểm tra light/dark mode trên mobile và web (mới xem mobile sáng, web tối)
- [x] Chạy jest, lint, tsc, build, test seed
- [ ] Chạy thử 5 vai trò trên trình duyệt (emulator đã đủ 5; web mới Manager)
- [x] Đánh dấu kết quả trong `test.md`

## 8. Sửa sau khi kiểm thật trên emulator (2026-11-04)

- [x] FAB che nút Gửi ở Chat: ẩn FAB ở tab Chat
- [x] FAB đè lên drawer đang mở: ẩn khi drawer mở
- [x] FAB che dòng cuối ở Mở rộng, Task, Lịch: thêm khoảng đệm dưới
- [x] `Client` thấy "Dời lịch" dù API từ chối; post đã đăng cũng có nút: chỉ hiện cho `Manager`, `Creator` với post chưa đăng
- [x] Đổi ngôn ngữ ở màn con bị đẩy về gốc mục: bỏ tham số điều hướng cũ khi khôi phục
- [x] Hàng đợi kiểm duyệt "(Không có nội dung)": seeder thiếu `post_versions`; đã seed lại local và Atlas
- [x] `Owner` thấy "Chưa có Task": hiện Task đang mở của Workspace
- [x] Biểu đồ đường lệch nhãn tháng; donut cùng tông cam: canh theo cột, dùng màu trạng thái
- [x] Header màn con vỡ breadcrumb: điện thoại chỉ giữ 2 cấp cuối, bỏ hẳn khi có nút hành động
- [x] Drawer đè thanh gesture; nút menu 40dp; hàng drawer 40dp; nút Chỉnh sửa, Quên mật khẩu nhỏ
- [x] Nhãn lệch: tab Dashboard/Thêm thành Tổng quan/Mở rộng; "Expand" thành "More"; `ACTIVE` thô ở kiểm duyệt
