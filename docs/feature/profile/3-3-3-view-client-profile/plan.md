# Plan — View Client Profile (FR 3.3.3)

> Liên kết: [spec.md](spec.md) — hiển thị hồ sơ Client của User đang đăng nhập.

## 1. Phạm vi kỹ thuật

| Mục | Nội dung |
|---|---|
| Repo | `brandhub-business-service`, `brandhub-web-dashboard` |
| File implement | `ClientProfileServiceImpl.getMyProfile()` |
| File đã có | `ClientProfileController` (`GET /api/v1/client-profile/me`), `ClientProfileResponse` |

## 2. API Contract (final)

```
GET /api/v1/client-profile/me
Authorization: Bearer <access-token>
→ 200 ApiResponse<ClientProfileResponse>
   data = { id, userId, displayName, company, phone, note, logoUrl, website, industry, location, description, socialLinks, createdAt, updatedAt }
→ 404 CLIENT_PROFILE_NOT_FOUND (chưa có hồ sơ)
```

Khác so với spec.md (đề xuất thêm `email`):

- **Bỏ `email`** — align theo BA confirmed (glossary 11-data-entities): ClientProfile = `{ id, userId, displayName, company, phone, note, createdAt, updatedAt }`. Email lấy từ `User` (authStore), không lưu trên ClientProfile.

## 3. Data Model

`client_profile` sau align BA:

| Field | Type | Note |
|---|---|---|
| id | UUID | PK |
| user_id | UUID | FK `users`, **không unique** (1 User → nhiều ClientProfile theo Agency) |
| display_name | varchar | not null |
| company | varchar | null |
| phone | varchar | null |
| note | text | null |
| logo_url | varchar | null — logo công ty |
| website | varchar | null — website công ty |
| industry | varchar | null — ngành nghề |
| location | varchar | null — địa điểm |
| description | text | null — mô tả công ty |
| social_links | jsonb | null — `{ "linkedin", "facebook" }` |
| created_at / updated_at | timestamptz | |

## 4. Luồng xử lý

1. `findByUserId(currentUser.getId())` → `CLIENT_PROFILE_NOT_FOUND` nếu không có.
2. Map → `ClientProfileResponse`.

## 5. Dependencies

| Chiều | Mô tả |
|---|---|
| Chặn bởi | `ClientProfile` entity, `ClientProfileRepository` |
| Bị chặn | `Update Client Profile` (3.3.4) |
