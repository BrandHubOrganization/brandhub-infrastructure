# BA — Mục lục nghiệp vụ (Business Analysis)

Thư mục này chứa tài liệu nghiệp vụ thực tế (business process), viết theo **đúng code đang triển khai** — không viết theo spec/FR mong muốn còn chưa có code. Format: BPMN-style (Actor / Trigger / Pre-condition / Main Flow / Exception Flow / Business Rules), giống style `Document_Plan.md`.

Nguồn đối chiếu: `brandhub-business-service/src/main/java/com/brandhub/business/{controller,service,model}/`. Mỗi file phải trích dẫn rõ file Java nào đã đọc để viết.

## Trạng thái

- ✅ Đã viết
- 🔲 Chưa viết — có code, cần viết
- ⛔ Chưa có code — chỉ có spec/endpoint-doc (`docs/api/endpoints/`), KHÔNG viết BA cho tới khi code xong

## Danh sách file

| # | File | Domain | Trạng thái | Nguồn code chính |
|---|---|---|---|---|
| 1 | `authentication.md` | Đăng ký, đăng nhập (email/phone/OAuth), OTP, refresh/logout, quên/đổi mật khẩu, link/unlink phone & OAuth | ✅ | `AuthController`, `GoogleOAuthController`, `GitHubOAuthController`, `LinkedInOAuthController`, `MicrosoftOAuthController`, `AuthServiceImpl` |
| 2 | `workspace-management.md` | Tạo/sửa workspace, upload logo, audit log workspace | 🔲 | `WorkspaceController`, `WorkspaceServiceImpl` |
| 3 | `workspace-member-rbac.md` | Mời/xoá thành viên, gán role (OWNER/MANAGER/ACCOUNT/CREATOR/CLIENT), permission theo role | 🔲 | `WorkspaceController` (invite/remove member), `WorkspaceMember`, `WorkspaceMemberPermission`, `MemberRole` |
| 4 | `client-management.md` | Quản lý Client (khách hàng của agency) trong workspace | ⛔ | `Client.java` chỉ là entity, KHÔNG có `ClientRepository`/`ClientService`/`ClientController` |
| 5 | `subscription-billing.md` | Gói subscription, thanh toán, invoice, trạng thái subscription workspace | ⛔ | `SubscriptionPlan`/`WorkspaceSubscription`/`Invoice`/`Payment.java` chỉ là entity, KHÔNG có repository/service/controller |
| 6 | `user-profile.md` | Xem/sửa profile, user status | 🔲 | `UserController`, `UserService`, `User`, `UserStatus` |
| 7 | `admin.md` | Chức năng ADMIN (system role), quản trị toàn hệ thống | 🔲 | `AdminController` |
| 8 | `file-upload.md` | Upload file lên S3 (logo, avatar, media...) | 🔲 | `UploadS3Controller`, `FileStorageService`, `S3FileStorageServiceImpl` |
| 9 | `email-notification.md` | Gửi email (OTP, reset password, mời thành viên...) | 🔲 | `EmailService`, `MailService` |
| 10 | `audit-log.md` | Ghi log hành động (login/logout/role change/permission change...) trên workspace | 🔲 | `AuditLogRepository`, `AuditLog.java`, enum `AuditAction`, `WorkspaceController.listAuditLogs` |
| 11 | `content-request.md` | Content request giữa Account và Client | ⛔ | chỉ có `docs/api/endpoints/06_content_request.md`, chưa có entity/controller |
| 12 | `post-publishing.md` | Tạo/lên lịch/xuất bản post đa kênh | ⛔ | chỉ có `docs/api/endpoints/05_post.md`, chưa có entity/controller |
| 13 | `social-account.md` | Kết nối social account (Facebook/Instagram/TikTok...) | ⛔ | chỉ có `docs/api/endpoints/07_social_account.md`, chưa có entity/controller |
| 14 | `analytics-report.md` | Dashboard analytics, report định kỳ | ⛔ | chỉ có `docs/api/endpoints/08_analytics.md`, `09_report.md`, chưa có entity/controller |

## Quy tắc viết tiếp

1. Chỉ viết file mới khi domain đã **có code chạy được** (controller + service, không chỉ DTO rỗng) — nếu chưa, giữ nguyên ⛔, không suy diễn nghiệp vụ.
2. Đọc hết controller + serviceImpl + entity liên quan trước khi viết, trích rõ tên file đã đọc ở đầu doc (như `authentication.md`).
3. Gap/lỗi phát hiện khi đọc code (thiếu validate, thiếu rate-limit, dùng sai enum...) → ghi thành mục riêng cuối file, không sửa code.
4. Xong 1 file → cập nhật trạng thái ở bảng này (🔲 → ✅).
