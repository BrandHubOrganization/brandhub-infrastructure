# Plan — View User Profile (FR 3.3.1)

> Liên kết: [spec.md](spec.md) — hiển thị profile cá nhân của User đang đăng nhập.

## 1. Phạm vi kỹ thuật

| Mục | Nội dung |
|---|---|
| Repo | `brandhub-business-service`, `brandhub-web-dashboard` |
| File implement | `UserServiceImpl.getUserProfile()` |
| File đã có | `UserController` (`GET /api/v1/users/me`), `UserProfileResponse` |

## 2. API Contract (final)

```
GET /api/v1/users/me
Authorization: Bearer <access-token>
→ 200 ApiResponse<UserProfileResponse>
   data = { userId, email, fullName, avatarUrl, phone, role, workspaceId, professionalTitle, bio, portfolioUrls, workingLanguage, timezone, notificationPreferences, createdAt }
```

Khác so với spec.md (đề xuất `{ id, fullName, email, avatarUrl, phone, createdAt }`):

- Thêm `role`, `workspaceId`, `professionalTitle`, `bio`, `portfolioUrls`, `workingLanguage`, `timezone`, `notificationPreferences` — field đã có sẵn, trả về để FE hiển thị + echo lại cho luồng update.
- `userId` thay vì `id` — thống nhất với `UserProfileResponse` hiện tại.

## 3. Data Model

- `phone` có sẵn trên `users` (unique, length 20). `timezone` + `notificationPreferences` nằm trong `users.preferences` (jsonb). **Không migration.**

## 4. Luồng xử lý

1. `findById(userId)` → 404 `USER_NOT_FOUND` nếu không có.
2. Resolve `role` (UserSystemRole, default `USER`), `workspaceId` (currentUser → fallback WorkspaceMember).
3. Parse `preferences` jsonb → `timezone`, `notificationPreferences`.
4. Map → `UserProfileResponse`.

## 5. Dependencies

| Chiều | Mô tả |
|---|---|
| Chặn bởi | `User` entity + `UserRepository` (đã có) |
| Bị chặn | `Update Profile` (3.3.2) — dùng chung `toResponse` |
