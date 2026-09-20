# Plan — Update Client Profile (FR 3.3.4)

> Liên kết: [spec.md](spec.md) — cập nhật hồ sơ Client của User đang đăng nhập.

## 1. Phạm vi kỹ thuật

| Mục | Nội dung |
|---|---|
| Repo | `brandhub-business-service`, `brandhub-web-dashboard` |
| File implement | `ClientProfileServiceImpl.upsertMyProfile()` |
| File đã có | `ClientProfileController` (`PUT /api/v1/client-profile/me`), `ClientProfileRequest` |

## 2. API Contract (final)

```
PUT /api/v1/client-profile/me
Authorization: Bearer <access-token>
Body: { displayName, company?, phone?, note?, logoUrl?, website?, industry?, location?, description?, socialLinks? }
→ 200 ApiResponse<ClientProfileResponse>
   data = { id, userId, displayName, company, phone, note, logoUrl, website, industry, location, description, socialLinks, createdAt, updatedAt }
```

Khác so với spec.md (đề xuất thêm `email`):

- **Bỏ `email`** — align theo BA (email lấy từ `User`). Request chỉ còn `displayName` (required) + `company`/`phone`/`note` (optional).
- Upsert: nếu chưa có → tạo mới; có rồi → update. Giữ `PUT` + upsert thay vì `PATCH`.

## 3. Data Model + Migration

`ddl-auto: validate` → cần migration SQL thủ công. Rename + drop cột cũ, thêm cột standout:

```sql
ALTER TABLE client_profile RENAME COLUMN linked_user_id TO user_id;
ALTER TABLE client_profile DROP COLUMN IF EXISTS email;
ALTER TABLE client_profile DROP COLUMN IF EXISTS brand_name;
ALTER TABLE client_profile ADD COLUMN IF NOT EXISTS logo_url varchar(500);
ALTER TABLE client_profile ADD COLUMN IF NOT EXISTS website varchar(255);
ALTER TABLE client_profile ADD COLUMN IF NOT EXISTS industry varchar(100);
ALTER TABLE client_profile ADD COLUMN IF NOT EXISTS location varchar(255);
ALTER TABLE client_profile ADD COLUMN IF NOT EXISTS description text;
ALTER TABLE client_profile ADD COLUMN IF NOT EXISTS social_links jsonb;
```

## 4. Luồng xử lý

1. `findByUserId(currentUser.getId())` → upsert (create/update).
2. Set `displayName`, `company`, `phone`, `note` (không đổi `userId`).
3. `save` → trả `ClientProfileResponse`.

## 5. Dependencies

| Chiều | Mô tả |
|---|---|
| Chặn bởi | `View Client Profile` (3.3.3), migration SQL |
| Bị chặn | — |
