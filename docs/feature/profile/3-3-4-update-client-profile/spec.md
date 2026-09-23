# UC — Update Client Profile

| | |
|---|---|
| FR Code | 3.3.4 |
| Feature | Update Client Profile |
| Domain | Profile (FR 3.3) |
| Role | USER |
| Version | 2.1 (sync với code thật, 2026-09-23) |
| Trạng thái tài liệu | Đã code — spec khớp `ClientProfileController`/`ClientProfileServiceImpl` |

## 1. Objective

Cho phép cập nhật Client Profile, nhưng KHÔNG cho đổi email — email là khóa định danh cố định, lấy từ `User`/authStore, không lưu trên ClientProfile.

## 2. User Story

Là một User đóng vai trò Client,
tôi muốn cập nhật thông tin Client Profile của mình (trong phạm vi 1 Agency cụ thể),
nhưng email của tôi phải giữ cố định để Agency luôn nhận diện đúng tôi.

## 3. Acceptance Criteria

- Form cho sửa: `displayName` (bắt buộc), `company`, `phone`, `note`, `logoUrl`, `website`, `industry`, `location`, `description`, `socialLinks`.
- **KHÔNG có field email trong form/DTO** — `ClientProfileRequest` không có field này nên không thể gửi email qua FR này (không phải BE chặn bằng error code riêng, mà DTO không có chỗ chứa).
- Mỗi lần cập nhật gắn với 1 `agencyId` cụ thể (khoá theo cặp `userId` + `agencyId`) — sửa Client Profile ở Agency A không ảnh hưởng bản ghi ở Agency B.
- Lưu thành công → cập nhật đồng bộ hiển thị ở TẤT CẢ Workspace **cùng 1 Agency** đang dùng chung bản ghi `ClientProfile(userId, agencyId)` đó.
- Endpoint là **upsert**: nếu chưa có `ClientProfile` cho cặp `(userId, agencyId)` này, BE tự tạo mới thay vì trả lỗi 404. ClientProfile được tạo lần đầu qua accept-invitation HOẶC qua lần đầu gọi update (upsert) — cả 2 đường đều hợp lệ.
- Full-overwrite: mỗi lần gọi phải gửi đủ field cần giữ, field không gửi bị ghi `null` (không phải partial-patch).

## 4. UI / UX

- Form edit trong trang Client Profile (FR 3.3.3), FE lấy `agencyId` hiện tại từ URL query.

## 5. API Contract

```
PUT /api/v1/client-profile/me?agencyId={agencyId}
Authorization: Bearer <access-token>
{
  "displayName": "string",
  "company"?: "string", "phone"?: "string", "note"?: "string",
  "logoUrl"?: "string", "website"?: "string", "industry"?: "string",
  "location"?: "string", "description"?: "string",
  "socialLinks"?: { "linkedin"?: "string", "facebook"?: "string", ... }
}
→ 200 { "success": true, "data": {
    "id", "userId", "agencyId", "displayName", "company", "phone", "note",
    "logoUrl", "website", "industry", "location", "description", "socialLinks",
    "createdAt", "updatedAt"
  } }
```

`agencyId` là query param bắt buộc.

## 6. Error Handling

- `displayName` trống/blank → 400 `VALIDATION_ERROR`.
- Thiếu query param `agencyId` → 400 `VALIDATION_ERROR`.
- Token hết hạn/không hợp lệ → 401 `UNAUTHORIZED`.
- **Ghi chú:** DTO (`ClientProfileRequest`) không có field `email` nên không thể gửi email qua endpoint này — không có `ErrorCode` riêng cho trường hợp này (`EMAIL_UPDATE_NOT_ALLOWED` không tồn tại trong `ErrorCode.java`).

## 7. Edge Cases

- Client cập nhật `displayName` khi đang có task đang chờ duyệt ở nhiều Workspace cùng Agency → tên hiển thị mới áp dụng ngay cho tất cả Workspace cùng Agency đó, không cần đồng bộ thủ công từng nơi.
- Gọi update lần đầu cho 1 `agencyId` chưa từng có ClientProfile → tự tạo mới (upsert), không lỗi 404.

## 8. Definition of Done

- Update thành công mọi field trừ email (verify: DTO không có field email nên không thể gửi).
- Upsert hoạt động đúng: tạo mới khi chưa có, update khi đã có, đều qua cùng `PUT /me?agencyId=...`.

## Out of Scope

- Đổi email Client Profile (không có field email trong DTO, không nằm trong phạm vi FR này).

## Tham chiếu BA

[02-authentication-profile.md](../../../BA/02-authentication-profile.md)
