# Plan — Update Profile (FR 3.3.2)

> Liên kết: [spec.md](spec.md) — cập nhật profile cá nhân của User đang đăng nhập.

## 1. Phạm vi kỹ thuật

| Mục | Nội dung |
|---|---|
| Repo | `brandhub-business-service`, `brandhub-web-dashboard` |
| File implement | `UserServiceImpl.updateUserProfile()` |
| File đã có | `UserController` (`PUT /api/v1/users/me`), `UpdateProfileRequest` |

## 2. API Contract (final)

```
PUT /api/v1/users/me
Authorization: Bearer <access-token>
Body: { fullName, phone?, professionalTitle?, bio?, portfolioUrls?, workingLanguage?, timezone?, notificationPreferences? }
→ 200 ApiResponse<UserProfileResponse>
   data = { userId, email, fullName, avatarUrl, phone, role, workspaceId, professionalTitle, bio, portfolioUrls, workingLanguage, timezone, notificationPreferences, createdAt }
```

Khác so với spec.md (đề xuất `PATCH` + block email):

- Dùng `PUT` + upsert semantic (merge field không gửi) — giữ nguyên method hiện có, ít churn.
- Không có field email trong body → **bỏ** `EMAIL_UPDATE_NOT_ALLOWED`.
- `phone`, `professionalTitle`, `bio`, `portfolioUrls`, `workingLanguage`, `timezone`, `notificationPreferences` optional — hỗ trợ partial update + xử lý "chưa từng set" (null). `timezone`/`notificationPreferences` merge vào `preferences` jsonb; các field còn lại là cột riêng, set trực tiếp khi non-null.

## 3. Data Model

- `fullName`, `phone` lưu trực tiếp trên `users`. `timezone` + `notificationPreferences` merge vào `users.preferences` (jsonb). **Không migration.**

## 4. Luồng xử lý

1. `findById(userId)` → 404 `USER_NOT_FOUND`.
2. Set `fullName`; set `phone` nếu non-null.
3. Parse `preferences` hiện tại → merge `timezone`/`notificationPreferences` (chỉ field non-null).
4. Serialize lại → `save` → trả `toResponse`.

## 5. Dependencies

| Chiều | Mô tả |
|---|---|
| Chặn bởi | `User` entity, `UserRepository`, `View Profile` (3.3.1) |
| Bị chặn | — |
