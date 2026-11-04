# Điều hướng, bố cục và data demo liên kết: kiểm thử

Trạng thái: `[ ]` chưa chạy, `[x]` đã chạy và đạt. Ghi rõ nếu một mục chỉ kiểm bằng test tự động.

## Data demo

- [x] `user177@` có vai trò `OWNER` tại TH True Milk qua API
- [x] `user1@` `MANAGER`, `user13@` `CREATOR`, `user59@` `CLIENT` trong TH True Milk
- [x] Hồ sơ Client của TH True Milk là "TH True Milk"
- [x] Task đủ 4 trạng thái; post đủ trạng thái; chỉ 4 nền tảng
- [x] Không có Livestream trong data mới
- [x] `/admin/revenue`: MRR khác 0, `activeSubscriptions` khác 0
- [x] `/admin/statistics`: đăng ký trải nhiều ngày; có strike, chế tài
- [x] Hàng đợi kiểm duyệt có mục
- [x] Chạy seed lần 2: số bản ghi không đổi
- [x] Gỡ seed: data seed hết, data khác còn nguyên
- [x] Profile `prod`: seeder từ chối chạy

## Mobile

- [x] Mỗi vai trò thấy đúng tab: `Manager`, `Creator`, `Client` 5 tab; `Owner` 3 tab; `Admin` 5 tab
- [x] Đổi Workspace làm mất tab đang mở: về Tổng quan (bấm thật: đang ở Chat đổi sang vai `Owner`, về Tổng quan, 3 tab)
- [x] 8 màn Admin có back hoặc là gốc tab (bấm thật: Báo cáo; các màn còn lại kiểm qua code)
- [x] Đăng xuất từ Thêm của Admin và từ Cài đặt
- [x] `Owner` thấy Gói cước, Hóa đơn; `Creator` không thấy (bấm thật)
- [x] `Client` xem, sửa, đổi hồ sơ (bấm thật, đối chiếu DB); màn trống khi chưa có hồ sơ và ẩn khối đổi khi có một hồ sơ (chỉ test tự động)
- [x] Trang Thêm tối đa 12 mục mỗi vai trò; một lối Cài đặt
- [x] FAB không che tab, không che nút Gửi, không đè drawer; vùng chạm mới tối thiểu 44×44 (Android; chip lọc cũ ở Chat và Lịch vẫn 30-32dp)
- [x] Đổi VI/EN: giữ màn, không vỡ chữ (bấm thật ở Dashboard và Cài đặt)
- [x] Chuyển sáng/tối: biểu đồ và tab đủ tương phản (xem bằng mắt, không đo tỉ lệ tương phản)

## Web

- [x] Sidebar `create` chia nhóm, thu gọn được, mọi route còn truy cập được
- [ ] Breadcrumb `crawl`, `trendPipeline` đúng tên
- [ ] Quick login 5 vai trò vào đúng Workspace TH True Milk
- [ ] Đổi VI/EN và sáng/tối không vỡ UI

## Tự động

- [x] Mobile: `npx jest` 378/378, `npx tsc --noEmit` (repo không có script lint)
- [x] Web: `vitest` 104/104, `tsc -b`, build; eslint chỉ chạy trên file đã đổi
- [x] Business: test seed

## Ghi chú kết quả (2026-11-04)

- Chạy thật trên emulator: tab Admin, back từ Báo cáo, Doanh thu; tab Owner, Manager, Creator, Client; màn hồ sơ Client hiển thị đúng TH True Milk.
- Chạy thật trên trình duyệt: quick login Manager, sidebar chia nhóm, số liệu dashboard.
- Chỉ kiểm bằng test tự động: ẩn khối đổi hồ sơ, profile `prod`, chặn của Admin (chỉ bấm thật Duyệt).
- Web lint: còn lỗi `react-hooks/set-state-in-effect` có từ trước ở `pages/dashboard/index.tsx`.
- Chưa chạy: mọi thứ trên iOS, web (quick login Client, Creator, Owner, Admin; breadcrumb `crawl`/`trendPipeline`; VI/EN và sáng/tối).
- Lỗi tìm ra và đã sửa khi kiểm thật: xem danh sách ở `task.md`, mục 8.

## Cách chạy seed

Từ `brandhub-business-service`, sau khi nạp biến trong `.env`:

```bash
mvn spring-boot:run -Dspring-boot.run.arguments="--seed-only --spring.profiles.active=seed-admin-demo"
mvn spring-boot:run -Dspring-boot.run.arguments="--seed-only --spring.profiles.active=seed-linked-demo"
# Gỡ: thêm --seed.linked-demo.remove=true vào lệnh thứ hai
```
