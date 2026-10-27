# Danh sách Công việc (Task Checklist): Connect Social Account — Meta OAuth (DA-E52-01)

| Task ID | Thành phần | Mô tả công việc | Trạng thái |
|---|---|---|---|
| **TASK-01** | `brandhub-publisher-service` | Cấu hình `MetaOAuthConfig.java` đọc `client-id`, `client-secret`, `redirect-uri`, `frontend-base-url` và `scopes` từ environment | [x] DONE |
| **TASK-02** | `brandhub-publisher-service` | Hiện thực `MetaOAuthService.java` (`buildAuthorizationUrl`, `processCallback`, `exchangeTokens`, mã hóa `CryptoUtils.encrypt`) | [x] DONE |
| **TASK-03** | `brandhub-publisher-service` | Tạo `SocialOAuthController.java` với các endpoint `/facebook/connect`, `/instagram/connect`, và callback handler redirect frontend | [x] DONE |
| **TASK-04** | `brandhub-publisher-service` | Hiện thực `BusinessServiceClient.java` gọi sync tài khoản sang business-service với header `X-Internal-Service-Key` | [x] DONE |
| **TASK-05** | `brandhub-business-service` | Tạo `SocialAccountController.java` (`POST /api/v1/internal/social-accounts/sync`, `GET /api/v1/social-accounts`, `DELETE /api/v1/social-accounts/{id}`) | [x] DONE |
| **TASK-06** | `brandhub-business-service` | Hiện thực `SocialAccountServiceImpl.java` xử lý logic sync, reactivate tài khoản cũ tránh tạo trùng lặp | [x] DONE |
| **TASK-07** | `brandhub-api-gateway` | Cấu hình Route Gateway `/api/v1/social/**` chuyển tiếp sang `publisher-service:8083` bỏ qua JWT filter | [x] DONE |
| **TASK-08** | `brandhub-web` | Xây dựng UI `SocialAccountsPage`, `SocialAccountCard`, `useSocialAccounts` hook xử lý callback toast và build URL connect | [x] DONE |
| **TASK-09** | Testing & Verification | Viết Unit Test bao phủ `MetaOAuthServiceTest` (14/14 pass) và `SocialOAuthControllerTest` (9/9 pass) | [x] DONE |
