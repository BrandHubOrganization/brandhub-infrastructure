# Điều hướng, bố cục và data demo liên kết: kế hoạch

**Goal:** Thực hiện [spec.md](spec.md): tab dưới trên mobile, màn hồ sơ Client, gọn nút, nhóm sidebar web, 5 tài khoản demo cùng tổ chức và biểu đồ có số liệu.

**Architecture:** Mobile thêm một lớp tab bên trong drawer hiện có; stack cũ giữ nguyên làm nội dung từng tab. Web chỉ đổi cấu hình sidebar. Data dùng một seeder tuỳ chọn mới, chạy sau `seed-admin-demo` có sẵn.

**Tech Stack:** Expo 56, React Navigation 7, `react-native-svg`; React, Vite, recharts; Spring Boot, Postgres local, Mongo Atlas DB `brandhub`.

## Global Constraints

- Tên vai trò chỉ dùng `Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`.
- Không Livestream trong data hoặc UI mới. Nền tảng chỉ Facebook, Instagram, TikTok, Threads. Thanh toán SePay/VietQR.
- Không thêm API, không đổi quyền backend, không xoá route.
- Chuỗi mới có i18n; màu lấy từ token theme.
- Vùng chạm mới tối thiểu 44×44; tối đa 5 tab.
- Không commit khi chưa được yêu cầu.

## Review Focus

1. Vai trò đổi giữa hai Workspace làm tab hiện tại biến mất: phải về Tổng quan, không màn trắng.
2. Link sâu vào màn con: back phải về đúng gốc tab, không thoát app.
3. Seed chạy lại hoặc thất bại giữa chừng: không nhân đôi, không để data nửa vời, gỡ được.
4. `Client` một hồ sơ hoặc chưa có hồ sơ: màn vẫn dùng được.
5. Đổi ngôn ngữ làm app remount: giữ đúng tab và màn đang mở.

## Cấu trúc file

| Khu vực | File | Thay đổi |
| :--- | :--- | :--- |
| Seed | `resources/seed/linked-demo.sql` | Mới: sửa liên kết tài khoản, thêm billing, kiểm duyệt, thông báo |
| Seed | `seed/LinkedDemoSeeder.java` | Mới: profile `seed-linked-demo`, chạy SQL và seed task, post vào Mongo |
| Seed | `resources/seed/linked-demo-remove.sql`, cờ `--remove` | Mới: gỡ theo `seedTag` và `merchant_account='DEMO'` |
| Seed | `dev-quick-login.sql`, `TaskSampleSeeder.java` | Bỏ Livestream |
| Mobile | `navigation/WorkspaceTabBar.tsx`, `navigation/tabs.ts`, `components/common/AppTabBar.tsx` | Mới: tab theo vai trò, gắn vào `screenLayout` của drawer; không thêm thư viện |
| Mobile | `navigation/AdminStackNavigator.tsx` | 5 tab Admin trong `layout` của stack |
| Mobile | `navigation/AdminStackNavigator.tsx`, `MainDrawerNavigator.tsx`, `AppNavigator.tsx` | Nối lớp tab |
| Mobile | `components/sidebar/SidebarContent.tsx`, `components/common/GlobalFab.tsx` | Drawer chỉ đổi Workspace; FAB tránh tab |
| Mobile | `screens/admin/AdminMoreScreen.tsx` | Mới: trang Thêm của Admin |
| Mobile | `components/admin/AdminCharts.tsx` | Mới: biểu đồ tăng trưởng, trạng thái, doanh thu |
| Mobile | `screens/more/ClientProfileScreen.tsx` | Mới: màn hồ sơ Client |
| Mobile | `services/workspaceService.ts`, `utils/navAccess.ts`, `screens/more/MoreScreen.tsx` | Đổi hồ sơ, quyền màn mới, gọn nhóm |
| Mobile | `screens/auth/LoginScreen.tsx` | Creator là `user13@` |
| Mobile | Màn trong spec 4.3 | Chia lại nút |
| Mobile | `i18n/locales/en.json` | Chuỗi mới |
| Web | `sidebarNavConfig.ts`, `Sidebar.tsx` | Nhóm con cho `create` |
| Web | `Navbar.tsx`, `DevQuickLogin.tsx` | Breadcrumb, bỏ `landingPath` |
| Web | `i18n/locales/vi.json`, `en.json` | Khoá nhóm con |

## Luồng data

1. `seed-postgres` và `seed-mongo` đã chạy (hiện trạng).
2. Chạy `seed-admin-demo`: 1.240 user, 48 agency, strike, chế tài; ghi thêm post `seed_tag=admin-demo` vào Mongo.
3. Chạy `seed-linked-demo`: sửa liên kết 5 tài khoản, billing cho Circus Digital và các agency của `user177@`, task và post cho TH True Milk.

`seed_runs` ngăn chạy lại. Sửa tại chỗ chỉ đụng: chủ sở hữu Circus Digital, các dòng `MANAGER` của `user177@`, hồ sơ Client của TH True Milk.

## Thứ tự

Seed trước để có data thật khi kiểm tra UI. Sau đó tab mobile, Admin, hồ sơ Client, trang Thêm, chia nút, web, kiểm thử cuối.

## Rủi ro

| Rủi ro | Cách xử lý |
| :--- | :--- |
| Ghi nhầm môi trường Atlas | Từ chối khi profile `prod`/`production`; in host, DB và số bản ghi trước khi ghi |
| Backend đổi cấu trúc billing | Seed qua constraint và trigger thật của DB, có test tích hợp |
| Mobile đang có nhiều thay đổi chưa commit | Chỉ sửa đúng file trong kế hoạch, không dọn thay đổi khác |
