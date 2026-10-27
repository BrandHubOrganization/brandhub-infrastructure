# Đặc tả Nghiệp vụ: E2E Publishing Flow Test trên Sandbox Accounts (DA-E42-05)

## 1. Mục tiêu (Objective)
Xây dựng bộ kiểm thử đầu-cuối (End-to-End - `@Tag("E2E")`) bằng Java/JUnit 5 để xác minh toàn bộ chu trình xử lý nội dung từ lúc tạo yêu cầu (`ContentRequest`), sinh nội dung AI, chỉnh sửa bản nháp (`save draft`), nộp bài (`submit`), Quản lý duyệt (`MANAGER approve`), Khách hàng duyệt (`client approve`), cho tới khi bài viết được xuất bản thành công sang các tài khoản Sandbox thực tế trên 4 nền tảng mạng xã hội: Facebook, Instagram, TikTok, Threads.

---

## 2. User Story
- **Là một** Kỹ sư Đảm bảo Chất lượng (QA) / Backend Developer,
- **Tôi muốn** có bộ test E2E tự động kích hoạt luồng xuất bản thực tế qua sandbox APIs của các nền tảng xã hội,
- **Để** đảm bảo tính toàn vẹn của dữ liệu trong DB (lưu đúng `platformPostId`, trạng thái `PUBLISHED`) và xác nhận bài đăng thực sự hiển thị trên nền tảng mà không làm ảnh hưởng đến các lần build CI mặc định.

---

## 3. Tiêu chí Chấp nhận (Acceptance Criteria)

### AC-1: Trình tự luồng E2E chuẩn
Kịch bản test thực thi tuần tự các bước:
1. **Tạo Content Request (`ContentRequest`):** Khách hàng/Quản lý tạo yêu cầu nội dung với tiêu đề, mô tả và chỉ định nền tảng (Facebook, Instagram, TikTok, Threads).
2. **AI Sinh nội dung & Lưu bản nháp (`AI generate & save draft`):** Kích hoạt sinh nội dung từ AI (hoặc nạp payload nội dung đáp ứng schema nền tảng) và lưu draft vào bảng `Post`.
3. **Nộp bài duyệt (`submit`):** Creator nộp bài chuyển trạng thái task/post sang chờ duyệt nội bộ (`PENDING_INTERNAL_REVIEW`).
4. **Quản lý duyệt (`MANAGER approve`):** Quản lý workspace kiểm duyệt và phê duyệt bài viết (`APPROVED` / chuyển sang `PENDING_CLIENT_APPROVAL` nếu yêu cầu duyệt khách hàng).
5. **Khách hàng duyệt (`Client approve`):** Đại diện khách hàng phê duyệt bài viết cuối cùng, chuyển bài viết sang trạng thái sẵn sàng đăng (`READY_TO_PUBLISH`).
6. **Kích hoạt xuất bản (`Publishing flow`):** Kích hoạt tác vụ xuất bản bài viết qua Publisher Service (đồng bộ hoặc qua hàng đợi RabbitMQ).
7. **Xác nhận DB:** Truy vấn DB xác nhận bài viết cập nhật trạng thái `PUBLISHED` và `platformPostId` không rỗng.

### AC-2: Bao phủ 4 nền tảng chính qua Sandbox
Test bao phủ xuất bản lên các nền tảng:
- **Facebook:** Đăng Post lên Facebook Test Page thông qua Meta Graph API Sandbox / Test Page Access Token.
- **Instagram:** Đăng Image/Carousel Post lên Instagram Sandbox Test Account liên kết Page.
- **TikTok:** Đăng Video thông qua TikTok Content Posting API Sandbox.
- **Threads:** Đăng Text/Media Post lên Threads Sandbox/Test Account.

### AC-3: Lưu vết mã bài đăng (`platformPostId`)
Sau khi xuất bản thành công:
- Record `Post` (hoặc `post_platforms`) trong cơ sở dữ liệu phải lưu trữ `platformPostId` phản hồi từ từng nền tảng tương ứng.
- Ghi nhận `published_at` chính xác thời điểm hoàn tất.

### AC-4: Kiểm chứng bài đăng tồn tại bằng Platform Read API
- Gọi trực tiếp Read API của nền tảng tương ứng (ví dụ: `GET /{page-post-id}` trên Graph API, `GET /v2/post/publish/status/fetch/` trên TikTok) với sandbox token để xác thực bài đăng thực sự tồn tại trên hệ thống mạng xã hội.

### AC-5: Phân tách và Gắn Tag `@Tag("E2E")`
- Bộ test E2E được gắn `@Tag("E2E")`.
- Được cấu hình loại trừ (excluded) khỏi lệnh chạy test thường nhật (`mvn test`) của CI/CD cục bộ.
- Chỉ chạy khi được chỉ định rõ ràng qua profile hoặc maven flag (`mvn test -Dgroups=E2E`).

---

## 4. Quản lý Cấu hình & Sandbox Credentials
- Toàn bộ token, app secret, test page ID được đọc từ biến môi trường hoặc file `.env.test` (tuyệt đối không hardcode trong mã nguồn):
  - `E2E_META_TEST_PAGE_ID`
  - `E2E_META_TEST_PAGE_ACCESS_TOKEN`
  - `E2E_INSTAGRAM_TEST_ACCOUNT_ID`
  - `E2E_TIKTOK_SANDBOX_ACCESS_TOKEN`
  - `E2E_THREADS_TEST_ACCESS_TOKEN`
- Khi thiếu biến môi trường sandbox thực tế trên máy dev, test runner có cơ chế ghi log cảnh báo và `Assumptions.assumeTrue(...)` để bỏ qua các bài test phụ thuộc credential ngoài, tránh làm gãy build tổng thể.

---

## 5. Phạm vi ngoài (Out of Scope)
- Không kiểm thử giao diện người dùng frontend (UI/Browser test) trong task này.
- Không đăng bài lên tài khoản production thực tế của khách hàng (chỉ sử dụng developer sandbox/test user).
