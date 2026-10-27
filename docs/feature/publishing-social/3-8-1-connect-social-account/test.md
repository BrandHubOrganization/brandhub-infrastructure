# Kịch bản Kiểm chứng (Test Cases): Connect Social Account — Meta OAuth (DA-E52-01)

## 1. Mục tiêu kiểm chứng
Đảm bảo toàn bộ luồng OAuth của Facebook và Instagram hoạt động trơn tru:
1. Sinh URL ủy quyền với đúng App ID, Scopes, và State payload hợp lệ.
2. Trao đổi Authorization Code lấy Token ngắn hạn và Token dài hạn (60 ngày).
3. Lấy thông tin Page / Instagram Account và mã hóa Token trước khi lưu trữ.
4. Xử lý trường hợp người dùng từ chối / hủy ủy quyền (User Denied).
5. Xử lý trường hợp không tìm thấy Fanpage hoặc Instagram Business Account liên kết.
6. Đồng bộ an toàn sang `brandhub-business-service`.

---

## 2. Danh sách Test Cases (Unit & Integration Tests)

| Test ID | Class kiểm thử | Phương thức | Kết quả kỳ vọng | Trạng thái |
|---|---|---|---|---|
| **TC-01** | `MetaOAuthServiceTest` | `testBuildAuthorizationUrl_Facebook` | Trả về URL `https://www.facebook.com/v19.0/dialog/oauth` kèm scopes `pages_manage_posts`, `pages_read_engagement` | PASSED |
| **TC-02** | `MetaOAuthServiceTest` | `testBuildAuthorizationUrl_Instagram` | Trả về URL dialog kèm scope `instagram_basic`, `instagram_content_publish` | PASSED |
| **TC-03** | `MetaOAuthServiceTest` | `testProcessCallback_SuccessFacebook` | Trao đổi code -> long-lived token -> fetch accounts -> encrypt token -> sync business service | PASSED |
| **TC-04** | `MetaOAuthServiceTest` | `testProcessCallback_SuccessInstagram` | Quét linked Instagram Business Account từ Page -> encrypt token -> sync sang business-service | PASSED |
| **TC-05** | `MetaOAuthServiceTest` | `testProcessCallback_NoPagesFound` | Ném ngoại lệ hợp lệ hoặc log warning khi user không quản lý trang nào | PASSED |
| **TC-06** | `MetaOAuthServiceTest` | `testProcessCallback_PageWithoutInstagram` | Bỏ qua trang không có Instagram Business Account liên kết | PASSED |
| **TC-07** | `MetaOAuthServiceTest` | `testRevokeToken_Success` | Gọi DELETE `/me/permissions` hủy token thành công | PASSED |
| **TC-08** | `SocialOAuthControllerTest` | `testConnectFacebook_Redirect` | HTTP 302 Redirect sang Facebook OAuth dialog | PASSED |
| **TC-09** | `SocialOAuthControllerTest` | `testConnectInstagram_Redirect` | HTTP 302 Redirect sang Instagram OAuth dialog | PASSED |
| **TC-10** | `SocialOAuthControllerTest` | `testHandleCallback_UserDenied` | Redirect về frontend URL kèm `status=error&error=access_denied` | PASSED |
| **TC-11** | `SocialOAuthControllerTest` | `testHandleCallback_Success` | Redirect về frontend URL kèm `status=success&platform=facebook` | PASSED |

---

## 3. Kết quả chạy tự động (Maven Surefire)
```text
[INFO] Running com.brandhub.publisher.platform.meta.MetaOAuthServiceTest
[INFO] Tests run: 14, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 8.997 s -- in com.brandhub.publisher.platform.meta.MetaOAuthServiceTest
[INFO] Running com.brandhub.publisher.platform.meta.SocialOAuthControllerTest
[INFO] Tests run: 9, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 10.05 s -- in com.brandhub.publisher.platform.meta.SocialOAuthControllerTest
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] Total time:  33.702 s
[INFO] ------------------------------------------------------------------------
```
**Tổng kết:** 23/23 tests ĐẠT 100%.
