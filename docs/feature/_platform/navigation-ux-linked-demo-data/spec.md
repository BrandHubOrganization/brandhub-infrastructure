# Điều hướng, bố cục và data demo liên kết

> Trạng thái: đã duyệt. Ngày: 2026-11-04. Phạm vi: `brandhub-mobile-app`, `brandhub-web`, `brandhub-business-service`.

## 1. Objective

Người dùng phải luôn biết mình đang ở đâu, quay lại được, và thấy biểu đồ có số liệu khi đăng nhập bằng bất kỳ tài khoản demo nào. Hiện có bốn vấn đề:

1. 8 màn Admin trên mobile không có nút quay lại.
2. Mobile không có tab dưới; trang More có 22 mục; có hai lối "Cài đặt" dẫn tới hai màn khác nhau.
3. Client không có màn hồ sơ trên mobile, dù web có.
4. Tài khoản demo không cùng một tổ chức; biểu đồ gần như trống.

## 2. Hiện trạng đã xác minh

| Hạng mục | Bằng chứng |
| :--- | :--- |
| Thiếu back | Users, Moderation, Revenue, Notifications, MailTemplates, Reports, SystemHealth, CreditPrices dùng `showDrawerButton={false}` và không có `canGoBack` |
| Overview Admin | 9 chip là `Text` có `onPress`, đè lên thẻ số liệu; đăng xuất nằm cuối trang cuộn; không có biểu đồ |
| Web Admin | `AdminSidebar` đã đủ lối đi. Breadcrumb thiếu `crawl` và `trendPipeline` trong `Navbar.tsx` nên hai trang này hiện sai tên |
| Web, sidebar trong Workspace | Nhóm `create` có 13 mục trên một danh sách phẳng |
| Web quick login | `landingPath` của Client không bao giờ chạy vì nhánh `workspaceRole` được xét trước |
| Hồ sơ Client | Web: `/workspaces/:id/client-profile`. Mobile: không có màn; `clientProfileService` thiếu hàm đổi hồ sơ cho Workspace |
| Vai trò Owner | `WorkspaceServiceImpl` chỉ trả `OWNER` khi không có dòng `workspace_members`. Seed cho `user177` làm `MANAGER` ở 8 Workspace, nên Owner bị coi là Manager |
| Tài khoản | `user177` không sở hữu Circus Digital (chủ là `user11`). Nút Creator: web `user13`, mobile `user1` |
| Hồ sơ Client trong seed | `user59` có 15 hồ sơ; Workspace "TH True Milk" gắn hồ sơ "Vietjet Air" |
| Số liệu | 10 Workspace có tổng 1 task; 25 user cùng tạo ngày 2026-10-22; `billing_orders`, `billing_payments`, `content_moderation_reviews`, `admin_notifications` bằng 0; strike 0/0/0; MRR 0 và `activeSubscriptions` 0 dù có 4 subscription `ACTIVE` |
| Seed hiện có | `dev-quick-login.sql` chưa áp dụng trên DB local; `TaskSampleSeeder` chỉ seed cho Workspace của script đó và hardcode UUID user; cả hai còn Livestream |

## 3. User Story

- Là `Admin`, tôi chuyển nhanh giữa các khu vực và quay lại từ mọi màn con.
- Là `Owner`, `Manager`, `Creator`, `Client`, tôi có thanh tab đúng vai trò và tới các chức năng chính trong tối đa 2 lần bấm.
- Là `Client`, tôi xem, sửa hồ sơ thương hiệu và đổi hồ sơ đại diện cho Workspace ngay trên mobile.
- Là dev, tôi đăng nhập nhanh bằng 5 tài khoản trên web hoặc mobile và thấy cùng một tổ chức, cùng một bộ số liệu.

## 4. Acceptance Criteria

### 4.1 Mobile: Admin

- Thanh tab dưới: Tổng quan, Người dùng, Kiểm duyệt, Doanh thu, Thêm.
- "Thêm" chứa: Email/Thông báo, Mẫu email, Báo cáo, Giám sát hệ thống, Bảng giá Credit, Cài đặt, Đăng xuất.
- Mọi màn không phải gốc của tab có nút back trên header. Màn gốc của tab không hiện back.
- Bỏ khối chip và link "Người dùng →" ở Overview. Đăng xuất chỉ ở "Thêm".
- Overview và Doanh thu có biểu đồ tương đương web, dùng API `/admin/statistics` và `/admin/revenue` đã có.

### 4.2 Mobile: người dùng thường

- Tab dưới theo quyền trong `navAccess.ts`:
  - `Manager`, `Creator`, `Client`: Tổng quan, Task, Lịch, Chat, Thêm.
  - `Owner`: Tổng quan, Task, Thêm.
- Drawer chỉ còn nhiệm vụ đổi Agency/Workspace, tìm nhanh và chọn theme, ngôn ngữ.
- Trang "Thêm" chia nhóm, mỗi vai trò thấy tối đa 12 mục. Bỏ các mục trùng lối: "Mời thành viên mới" chuyển vào màn Thành viên; AI Video, AI Caption và Lịch sử video chuyển vào AI Hub.
- Chỉ còn một lối "Cài đặt". Đăng xuất nằm trong đó.
- `GlobalFab` không che tab dưới.

### 4.3 Mobile: chia lại nút trên màn quá tải

Xem từng màn rồi mới chia, theo quy tắc: mỗi màn một hành động chính, hành động phụ vào menu, hành động phá huỷ để riêng. Vùng chạm tối thiểu 44×44. Danh sách màn cần xem: AgencyDetail, TaskDetail, SecuritySettings, AccountSettings, MediaLibrary, AdminUserStrikes, ContentRequestDetail, CameraRecord. Không đổi logic nghiệp vụ.

### 4.4 Mobile: hồ sơ Client

- Màn `ClientProfile` chỉ cho `Client`, có trong "Thêm".
- Xem, sửa hồ sơ hiện tại của Workspace và đổi sang hồ sơ khác của mình, tương đương trang web.
- Có đủ trạng thái đang tải, lỗi, trống.

### 4.5 Web

- Sidebar trong Workspace: nhóm `create` chia thành các nhóm con thu gọn được. Không xoá route nào.
- Sửa breadcrumb Admin cho `crawl` và `trendPipeline`.
- Bỏ `landingPath` không có tác dụng trong `DevQuickLogin`.
- Audit bố cục và nút trên các trang web theo cùng quy tắc mục 4.3. Danh sách trang quá tải được liệt kê trong `plan.md`.

### 4.6 Data demo

- 5 tài khoản giữ nguyên email, dùng chung trên web và mobile: `admin@`, `user177@`, `user1@`, `user13@`, `user59@` thuộc `demo.brandhub.test`. Sửa nút Creator trên mobile thành `user13@`.
- `user177@` là `Owner` của agency demo và không có dòng `workspace_members` trong đó, để API trả `OWNER`.
- `user1@` là `Manager`, `user13@` là `Creator`, `user59@` là `Client` trong cùng Workspace "TH True Milk x Circus Digital". Hồ sơ Client của Workspace này là "TH True Milk".
- Mọi biểu đồ của Admin và của các vai trò có số liệu khác 0:
  - User đăng ký trải đều 120 ngày; có đủ trạng thái tài khoản; có strike và chế tài.
  - Đơn hàng và thanh toán SePay đã xác minh trong `billing_*`, có kỳ thuê bao hiện tại, MRR khác 0. Mọi dòng có `merchant_account='DEMO'`.
  - Hàng đợi kiểm duyệt, thông báo Admin, mức dùng AI credit.
  - Task đủ 4 trạng thái, có hạn trong 6 tháng qua, giao cho `user13@` và `user1@`.
  - Bài đăng đủ trạng thái, chỉ trên Facebook, Instagram, TikTok, Threads.
- Không có Livestream trong data mới; xoá Livestream khỏi `dev-quick-login.sql` và `TaskSampleSeeder`.
- `activeSubscriptions` bằng 0 không phải bug: `AdminRevenueService` chỉ tính kỳ `CURRENT` có đơn `FULFILLED` và thanh toán `VERIFIED`, trong khi DB không có các dòng này và subscription ở `REVIEW_REQUIRED`. Seed các dòng đó; subscription của agency demo chuyển sang `READY`. Không đổi logic tính doanh thu.
- Seed mặc định (`SubscriptionCreditSeeder`) vẫn không tạo đơn hàng giả; data doanh thu chỉ nằm trong profile tuỳ chọn `seed-linked-demo`.

### 4.7 An toàn khi seed

- Chạy lại nhiều lần không tạo trùng, không ghi đè data thật. ID cố định, gắn nhãn `seedTag` để xoá được đúng phần đã seed.
- Có lệnh gỡ data đã seed, xoá theo `seedTag`.
- Không chạy khi profile là `prod` hoặc `production`.
- Trước khi ghi Atlas, in ra số bản ghi sẽ thêm và ghi `seed_runs`.

### 4.8 Đa ngôn ngữ

- Mobile: chuỗi mới dùng `tr()`, thêm vào `locales/en.json`.
- Web: khoá mới thêm đồng thời vào `vi.json` và `en.json`, namespace `nav.*`, `admin.navigation.*`, `clientProfile.*`.

### 4.9 Light/Dark mode

Chỉ dùng token theme sẵn có (`palette`, biến CSS). Biểu đồ mới dùng màu từ `palette`, kiểm tra ở cả 2 theme.

## 5. UI/UX

Giữ nguyên ngôn ngữ thiết kế hiện có; đây là tinh chỉnh, không phải đổi giao diện. Kiểm theo `ui-ux-pro-max` (back dự đoán được, tối đa 5 tab, vùng chạm 44 px) và `impeccable` chế độ Operate.

## 6. API Contract

Không thêm API. Dùng lại `/api/v1/admin/statistics`, `/api/v1/admin/revenue`, `/api/v1/client-profile/*` và endpoint đổi hồ sơ mà `workspaceService.switchMyClientProfile` trên web đang gọi.

## 7. Error Handling và Edge Cases

- Link sâu từ thông báo vào màn con vẫn có back về màn gốc của tab.
- Đổi Workspace khi đang ở tab: về Tổng quan của Workspace mới.
- Đổi vai trò làm một tab biến mất: chuyển về Tổng quan.
- `Client` chưa có hồ sơ trong Workspace: hiện trạng thái trống và danh sách đổi hồ sơ.
- `Client` chỉ có một hồ sơ: ẩn khối đổi hồ sơ.
- Package chưa duyệt: web giữ nguyên hard gate hiện tại; mobile không nới quyền.
- Giữ nguyên `withAccess` khi vào thẳng màn không được phép.

## 8. UI States

Mỗi màn mới hoặc đổi đều có đang tải, lỗi kèm thử lại, trống, có dữ liệu. Biểu đồ không có dữ liệu hiện thông báo trống, không vẽ đường phẳng.

## 9. Test Cases sơ bộ

- Mở mỗi màn Admin từ tab và "Thêm", bấm back, về đúng màn trước.
- Đăng nhập nhanh từng vai trò trên mobile và web: thấy đúng tab, đúng vai trò, đúng Workspace.
- `Owner` thấy Gói cước và Hóa đơn; `Creator` không thấy.
- `Client` sửa hồ sơ, đổi hồ sơ; web thấy kết quả tương tự.
- Chạy seed 2 lần: số bản ghi không đổi. Chạy lệnh gỡ: data seed hết, data khác còn nguyên.
- Tất cả biểu đồ có số liệu. Đổi ngôn ngữ và theme không vỡ UI.
- Chạy jest, lint, tsc của mobile và web; test seed của business-service.

## 10. Definition of Done

Toàn bộ mục 4 đạt; test tự động qua; đã chạy thử 5 vai trò trên emulator và trình duyệt, có ảnh chụp; `plan.md`, `task.md`, `test.md` được cập nhật. Không commit khi chưa được yêu cầu.

## 11. Out of Scope

- Đổi nhận diện thương hiệu hoặc giao diện tổng thể.
- Thêm vào mobile các màn Admin chỉ có trên web: Trend, Crawler, Hóa đơn, Workspace Templates, Mail Batches, Mail Suppressions.
- Thay đổi quyền ở backend, thêm API, đổi quy tắc nghiệp vụ.
- Ghi data lên môi trường production.

## 12. Quyết định đã chốt

- Nơi seed: Postgres local và Mongo Atlas, DB `brandhub`. Chủ dự án xác nhận chỉ một mình dùng DB này.
- Data cũ: sửa tại chỗ phần liên quan (chuyển Circus Digital cho `user177@`, bỏ các dòng `MANAGER` của `user177@`, sửa hồ sơ TH True Milk); phần còn lại giữ nguyên, chỉ thêm mới.
- Phạm vi: cả mobile và web; mobile dùng tab dưới kết hợp drawer.
- Tối đa 12 mục trong "Thêm" cho mỗi vai trò.
- Biểu đồ Admin mobile chỉ gồm những loại web đang có, không thêm chỉ số mới.
