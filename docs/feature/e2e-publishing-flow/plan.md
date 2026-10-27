# Kế hoạch Kỹ thuật: E2E Publishing Flow Test trên Sandbox Accounts (DA-E42-05)

## 1. Kiến trúc & Vị trí Triển khai
- **Repo mục tiêu:** `brandhub-business-service` (quản trị toàn bộ quy trình vòng đời nội dung: ContentRequest → Task → Post → Review/Approve → Trigger Publishing).
- **Package test:** `src/test/java/com/brandhub/business/e2e/`
- **Công nghệ sử dụng:**
  - **JUnit 5 Jupiter:** `@Tag("E2E")`, `@Test`, `@Order(n)`, `@TestMethodOrder`.
  - **Spring Boot Test:** `@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)`.
  - **RestTestClient / WebTestClient / RestClient:** Giao tiếp API nội bộ & kiểm tra API bên thứ 3.
  - **AssertJ & Awaitility:** Kiểm tra bất đồng bộ khi chờ Publisher Service / RabbitMQ trả callback cập nhật DB.

---

## 2. Các Thành phần Kỹ thuật Cần Xây dựng

### 2.1. Cấu hình Credentials Sandbox (`E2ESandboxProperties.java`)
- Đọc các biến cấu hình từ môi trường (`System.getenv` hoặc `@ConfigurationProperties(prefix = "e2e.sandbox")`):
  - `meta.pageId`, `meta.pageAccessToken` (dùng chung cho Facebook Page & Instagram Graph).
  - `threads.userId`, `threads.accessToken`.
  - `tiktok.openId`, `tiktok.accessToken`.
- Cung cấp method `isMetaConfigured()`, `isTikTokConfigured()`, `isThreadsConfigured()` để hỗ trợ `Assumptions.assumeTrue(...)`.

### 2.2. Bộ Kiểm chứng Nền tảng Thực tế (`PlatformReadVerifier.java`)
- Cung cấp các hàm kiểm tra trạng thái bài đăng trên sandbox API thực:
  - `verifyFacebookPost(String pagePostId, String pageAccessToken)`: Gọi `GET https://graph.facebook.com/v21.0/{pagePostId}?access_token={token}` xác nhận HTTP 200 và ID khớp.
  - `verifyInstagramPost(String mediaId, String accessToken)`: Gọi `GET https://graph.facebook.com/v21.0/{mediaId}?fields=id,media_type,status_code`.
  - `verifyThreadsPost(String threadsMediaId, String accessToken)`: Gọi `GET https://graph.threads.net/v1.0/{threadsMediaId}?fields=id,text`.
  - `verifyTikTokPost(String publishId, String accessToken)`: Gọi TikTok Sandbox Query Endpoint xác nhận trạng thái `SUCCESS`.

### 2.3. Lớp Kịch bản Test E2E (`PublishingFlowE2ETest.java`)
- Chứa các kịch bản kiểm thử:
  - `testCompletePublishingFlow_Facebook()`: Luồng từ Request → Draft → Review → Publish → Verify FB Page Sandbox.
  - `testCompletePublishingFlow_Instagram()`: Luồng đầy đủ ảnh/media → Verify Instagram Sandbox.
  - `testCompletePublishingFlow_Threads()`: Luồng văn bản & ảnh → Verify Threads Sandbox.
  - `testCompletePublishingFlow_TikTok()`: Luồng video/post → Verify TikTok Sandbox.
- Sử dụng transaction rollback hoặc test workspace riêng biệt để cô lập dữ liệu.

### 2.4. Cấu hình Maven Surefire (`pom.xml`)
- Khai báo `<excludedGroups>E2E</excludedGroups>` trong maven-surefire-plugin mặc định.
- Khi cần chạy E2E sandbox: `mvn test -Dgroups=E2E`.

---

## 3. Thứ tự Triển khai (Build Sequence)
1. Thêm cấu hình Maven Surefire để phân tách `@Tag("E2E")`.
2. Tạo lớp cấu hình `E2ESandboxProperties`.
3. Xây dựng tiện ích xác minh read API `PlatformReadVerifier`.
4. Viết kịch bản kiểm thử tích hợp `PublishingFlowE2ETest`.
5. Chạy xác thực và kiểm tra biên (Edge cases: token hết hạn, mock fallback).
