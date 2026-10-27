# Danh sách Công việc (Task Checklist): E2E Publishing Flow Test (DA-E42-05)

## Checklist Phân rã Thực thi

### Phase 1: Cấu hình Môi trường & Test Runner
- [x] **TASK-1:** Cập nhật `pom.xml` của `brandhub-business-service` để cấu hình Maven Surefire Plugin:
  - Mặc định exclude các test có `@Tag("E2E")`.
  - Hỗ trợ chạy riêng biệt qua tham số `-Dgroups=E2E`.
- [x] **TASK-2:** Tạo `src/test/java/com/brandhub/business/e2e/E2ESandboxProperties.java`:
  - Khai báo mapping các biến môi trường sandbox (`META`, `TIKTOK`, `THREADS`).
  - Cung cấp các method kiểm tra sẵn sàng cấu hình (`isConfigured`).

---

### Phase 2: Công cụ Kiểm chứng Nền tảng (Read API Verifier)
- [x] **TASK-3:** Xây dựng `src/test/java/com/brandhub/business/e2e/PlatformReadVerifier.java`:
  - Hiện thực `verifyFacebookPost(String pagePostId, String accessToken)`.
  - Hiện thực `verifyInstagramPost(String mediaId, String accessToken)`.
  - Hiện thực `verifyThreadsPost(String threadsMediaId, String accessToken)`.
  - Hiện thực `verifyTikTokPost(String publishId, String accessToken)`.

---

### Phase 3: Hiện thực Kịch bản Kiểm thử Đầu-Cuối (E2E Test Suite)
- [x] **TASK-4:** Tạo `src/test/java/com/brandhub/business/e2e/PublishingFlowE2ETest.java` với tag `@Tag("E2E")`:
  - Khởi tạo dữ liệu mẫu (Workspace, Creator, Manager, Client).
  - Bước 1: Tạo `ContentRequest`.
  - Bước 2: AI Generate / Lưu bản nháp `Post`.
  - Bước 3: Nộp bài duyệt (`SUBMIT`).
  - Bước 4: Manager duyệt bài (`MANAGER_APPROVED`).
  - Bước 5: Client duyệt bài (`CLIENT_APPROVED`).
  - Bước 6: Kích hoạt xuất bản (`READY_TO_PUBLISH` → `PUBLISHING`).
  - Bước 7: Xác nhận DB record cập nhật `status = PUBLISHED` và lưu trữ `platformPostId`.
  - Bước 8: Gọi `PlatformReadVerifier` kiểm tra thực tế trên Sandbox.
- [x] **TASK-5:** Bao phủ kịch bản đa nền tảng (Facebook, Instagram, TikTok, Threads).

---

### Phase 4: Kiểm thử & Hoàn thiện
- [x] **TASK-6:** Kiểm chứng lệnh chạy mặc định `mvn test` bỏ qua `@Tag("E2E")`.
- [x] **TASK-7:** Kiểm chứng lệnh chạy chỉ định `mvn test -Pe2e` hoặc `-DexcludedGroups=none` hoạt động chuẩn xác với cơ chế fallback khi thiếu credentials.
