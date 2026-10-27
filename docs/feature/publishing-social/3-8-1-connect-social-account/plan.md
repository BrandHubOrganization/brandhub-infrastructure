# Kế hoạch Kỹ thuật (Technical Plan): Connect Social Account — Meta OAuth (DA-E52-01)

## 1. Mục tiêu & Phạm vi
- Cung cấp luồng xác thực OAuth 2.0 chuẩn cho Meta (Facebook Pages và Instagram Professional/Business Accounts).
- Cho phép người dùng chuyển hướng an toàn đến Meta OAuth Dialog, cấp quyền và callback về hệ thống.
- Hệ thống trao đổi Authorization Code lấy Short-lived User Token, sau đó nâng cấp lên Long-lived User Token (60 ngày) và lấy Page Access Token vĩnh viễn (không hết hạn trừ khi đổi mật khẩu/hủy quyền).
- Tự động quét và liên kết các Facebook Pages và Instagram Business Accounts thuộc quyền quản lý của người dùng.
- Mã hóa Token bằng thuật toán AES-256 trước khi lưu trữ (`CryptoUtils`).
- Đồng bộ thông tin tài khoản xã hội vào `brandhub-business-service` thông qua endpoint internal bảo mật (`/api/v1/internal/social-accounts/sync`).

---

## 2. Kiến trúc & Luồng Dữ Liệu (Architecture & Data Flow)

### 2.1. Thành phần tham gia:
1. **Frontend (`brandhub-web`):**
   - Trang `/workspaces/:id/social-accounts`.
   - Nút "Kết nối" (Connect) kích hoạt điều hướng đến `${GATEWAY_URL}/api/v1/social/{platform}/connect?workspaceId={id}&clientId={clientId}`.
   - Nhận redirect callback sau khi hoàn tất kèm query params: `?status=success` hoặc `?status=error&error=...`.
2. **API Gateway (`brandhub-api-gateway`):**
   - Tuyến đường `/api/v1/social/**` được định tuyến trực tiếp vào `brandhub-publisher-service:8083` (bỏ qua JWT filter đối với OAuth connect/callback).
3. **Publisher Service (`brandhub-publisher-service`):**
   - `SocialOAuthController`: Tiếp nhận request `/connect`, sinh state chứa payload (workspaceId, clientId, timestamp, signature), redirect đến Meta OAuth Dialog.
   - Tiếp nhận `/callback`, xác thực state, gọi `MetaOAuthService`.
   - `MetaOAuthService`:
     - Gọi Meta Graph API `/oauth/access_token` để lấy short-lived user token.
     - Gọi `/oauth/access_token?grant_type=fb_exchange_token` lấy long-lived user token (60 days).
     - Gọi `/me/accounts?fields=id,name,access_token,instagram_business_account{id,username,profile_picture_url}`.
     - Mã hóa Access Token bằng `CryptoUtils.encrypt()`.
     - Gọi `BusinessServiceClient.syncSocialAccount()` đẩy thông tin sang Business Service.
4. **Business Service (`brandhub-business-service`):**
   - Nhận POST `/api/v1/internal/social-accounts/sync` với header `X-Internal-Service-Key`.
   - Tạo mới hoặc tái kích hoạt (Reactivate) bản ghi `SocialAccountDocument` cho Workspace/Client đó, bảo toàn liên kết lịch sử bài đăng cũ.

---

## 3. Danh sách Endpoint API

| Endpoint | Method | Service | Mô tả |
|---|---|---|---|
| `/api/v1/social/facebook/connect` | GET | `publisher-service` | Chuyển hướng sang Facebook OAuth Dialog |
| `/api/v1/social/instagram/connect` | GET | `publisher-service` | Chuyển hướng sang Instagram/Meta OAuth Dialog |
| `/api/v1/social/{platform}/callback` | GET | `publisher-service` | Tiếp nhận mã code từ Meta, xử lý trao đổi token và redirect về frontend |
| `/api/v1/internal/social-accounts/sync` | POST | `business-service` | Nhận dữ liệu account và encrypted token từ publisher |
| `/api/v1/social-accounts` | GET | `business-service` | Danh sách tài khoản social đã liên kết trong Workspace |
| `/api/v1/social-accounts/{id}` | DELETE | `business-service` | Ngắt kết nối (Disconnect) tài khoản |
