# Kịch bản Kiểm chứng (Test Cases): E2E Publishing Flow Test (DA-E42-05)

## Bảng Kịch bản Kiểm thử Đầu-Cuối

| Mã Test Case | Tên Kịch Bản | Dữ liệu Đầu vào (Input) | Kết quả Kỳ vọng (Expected Output) |
|---|---|---|---|
| **TC-E2E-01** | Trình tự luồng vòng đời đầy đủ | Request tạo ContentRequest, bản nháp nội dung, tài khoản Manager và Client | Toàn bộ trạng thái chuyển tiếp đúng thứ tự: PENDING → REVIEW → APPROVED → PUBLISHED. Không phát sinh lỗi xung đột trạng thái. |
| **TC-E2E-02** | Xác nhận dữ liệu trong DB | Post ID sau khi Publisher hoàn tất callback | Record trong bảng `posts` có `status = 'PUBLISHED'`, cột `platform_post_id` khác null, `published_at` có giá trị thời gian hợp lệ. |
| **TC-E2E-03** | Xác minh bài đăng Facebook Sandbox | `platformPostId` nhận được từ Meta + `E2E_META_TEST_PAGE_ACCESS_TOKEN` | HTTP 200 từ `https://graph.facebook.com/v21.0/{platformPostId}`, JSON trả về chứa ID trùng khớp. |
| **TC-E2E-04** | Xác minh bài đăng Instagram Sandbox | `platformPostId` của Instagram media + Page Access Token | HTTP 200 từ Graph API Instagram, trường `status_code` là `FINISHED` hoặc `id` tồn tại. |
| **TC-E2E-05** | Xác minh bài đăng Threads Sandbox | `threadsMediaId` + `E2E_THREADS_TEST_ACCESS_TOKEN` | HTTP 200 từ `https://graph.threads.net/v1.0/{threadsMediaId}`, nội dung text hiển thị khớp bài viết. |
| **TC-E2E-06** | Xác minh bài đăng TikTok Sandbox | `publishId` + `E2E_TIKTOK_SANDBOX_ACCESS_TOKEN` | HTTP 200 từ TikTok endpoint, trạng thái bài đăng là `SUCCESS`. |
| **TC-E2E-07** | Phân lập Tag `@Tag("E2E")` | Chạy lệnh `mvn test` thông thường | Toàn bộ các class/method có `@Tag("E2E")` đều bị bỏ qua (0 runs hoặc excluded), không gây lỗi build khi thiếu credentials ngoài. |
| **TC-E2E-08** | Cơ chế Bỏ qua An toàn (Assumption Skip) | Chạy `mvn test -Dgroups=E2E` trong môi trường thiếu cấu hình sandbox env | Các test case tự động được đánh dấu là SKIPPED (qua `Assumptions.assumeTrue`), không bị báo FAILED hoặc ERROR. |
