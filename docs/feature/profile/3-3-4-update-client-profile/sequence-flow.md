# Sequence Flow — Update Client Profile

> Bổ sung cho `spec.md` (FR 3.3.4). File này liệt kê từng bước actor → action → hệ thống, đủ chi tiết để vẽ sequence diagram trực tiếp — không diễn giải nghiệp vụ (xem spec.md cho phần đó).
>
> Cập nhật: 2026-09-23. Khớp code thật tại thời điểm này (`ClientProfileController`, `ClientProfileServiceImpl`).

## Actors

- **User** — người dùng đóng vai trò Client ở 1 Workspace của 1 Agency.
- **FE** — brandhub-web-dashboard (React), form edit trong trang Client Profile (FR 3.3.3).
- **BE** — brandhub-business-service (Spring Boot).
- **DB** — PostgreSQL (bảng `client_profiles`).

## Nhắc lại — khoá theo (userId, agencyId)

Giống FR 3.3.3: mọi thao tác update đều gắn với 1 `agencyId` cụ thể — sửa Client Profile ở Agency A **không ảnh hưởng** tới bản ghi ở Agency B (nếu User cũng là Client ở đó). "Đồng bộ tất cả Workspace" trong AC chỉ đúng trong phạm vi **các Workspace cùng 1 Agency**, vì chúng cùng trỏ về 1 bản ghi `ClientProfile(userId, agencyId)`.

---

## Flow A — Update Client Profile đã tồn tại

1. User → FE: sửa form (`displayName`, `company`, `phone`, `note`, và các field khác nếu UI có: `logoUrl`, `website`, `industry`, `location`, `description`, `socialLinks`), bấm Save. FE biết `agencyId` hiện tại từ ngữ cảnh trang.
2. FE → BE: `PUT /api/v1/client-profile/me?agencyId={agencyId}` `{displayName, company?, phone?, note?, logoUrl?, website?, industry?, location?, description?, socialLinks?}`.
   - `displayName` trống/blank → validation `@NotBlank` chặn ở controller → `400 VALIDATION_ERROR`.
   - Request DTO (`ClientProfileRequest`) **không có field `email`** — không thể gửi email qua endpoint này (không phải BE chặn bằng error code riêng, mà DTO không có chỗ chứa).
3. BE (`ClientProfileController.upsertMyProfile` → `ClientProfileServiceImpl.upsertMyProfile`):
   a. BE → DB: `findByUserIdAndAgencyId(userId, agencyId)` — có bản ghi → dùng bản ghi đó để update (tiếp bước b).
   b. Set lại toàn bộ field: `displayName.trim()`, `company`, `phone`, `note`, `logoUrl`, `website`, `industry`, `location`, `description`, `socialLinks` (serialize JSON), `updatedAt = now`.
4. BE → DB: `save(profile)`.
5. BE → FE: `200 { id, userId, agencyId, displayName, company, phone, note, logoUrl, website, industry, location, description, socialLinks, createdAt, updatedAt }`.
6. FE: toast thành công, cập nhật UI ngay. Vì mọi Workspace cùng Agency đều query cùng bản ghi này, thay đổi hiển thị ngay lập tức ở mọi nơi dùng chung Agency đó (không cần đồng bộ thủ công).

## Flow B — Gọi update khi CHƯA có Client Profile cho Agency này (upsert tạo mới)

Cùng endpoint `PUT /api/v1/client-profile/me?agencyId={agencyId}`, khác ở bước 3a:

3a'. BE → DB: `findByUserIdAndAgencyId(userId, agencyId)` — **không có** → BE tạo mới object `ClientProfile.builder().userId(userId).agencyId(agencyId).build()` (chưa lưu DB), rồi set field như Flow A bước b và save — `INSERT` thay vì `UPDATE`.

- Đây là hành vi "upsert" thật của endpoint (tên method là `upsertMyProfile`), khác với mô tả ở FR 3.3.3 rằng Client Profile "chỉ được tạo lần đầu khi accept lời mời Client". Trên thực tế endpoint update này **tự tạo mới nếu chưa có**, không throw `404`.

---

## Error paths tổng hợp

| Bước | Điều kiện lỗi | HTTP | ErrorCode |
|---|---|---|---|
| Update (Flow A/B) | `displayName` trống | 400 | `VALIDATION_ERROR` |
| Update (Flow A/B) | Token hết hạn/không hợp lệ | 401 | `UNAUTHORIZED` |

## Ghi chú

- Hành vi upsert (Flow B) là chủ đích, đã được Trung xác nhận giữ nguyên (không tách riêng luồng tạo mới khỏi luồng update). `spec.md` (mục 3, 8) đã mô tả rõ: ClientProfile được tạo lần đầu qua accept-invitation HOẶC qua lần đầu gọi update.
- Không có `ErrorCode` riêng để chặn field `email` — `ClientProfileRequest` không có field này ở tầng DTO nên không thể gửi được, đã ghi rõ trong `spec.md` mục 6.
