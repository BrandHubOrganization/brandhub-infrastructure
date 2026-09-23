# Sequence Flow — Create Agency

> Bổ sung cho `spec.md` (FR 3.4.3). File này liệt kê từng bước actor → action → hệ thống, đủ chi tiết để vẽ sequence diagram trực tiếp — không diễn giải nghiệp vụ (xem spec.md cho phần đó).
>
> Cập nhật: 2026-09-23. Khớp code thật tại thời điểm này (`AgencyController.createAgency`/`uploadLogo`, `AgencyServiceImpl.createAgency`).

## Actors

- **User** — chưa có Agency hoặc muốn tạo thêm.
- **FE** — brandhub-web-dashboard (React).
- **BE** — brandhub-business-service (Spring Boot).
- **DB** — PostgreSQL (`agencies`, `agency_members`).

---

## Flow A — Tạo Agency (không kèm logo)

1. User → FE: mở `/agencies/create` (hoặc modal), điền form `name` (bắt buộc) + field branding tuỳ chọn (`description`, `category`, `companySize`, `website`, `phone`, `location`, `brandColor`, `logoIcon`, `tagline`, `foundedYear`, `facebookUrl`, `linkedinUrl`, `instagramUrl`).
2. FE → BE: `POST /api/v1/agencies` `{ AgencyRequest }`.
3. BE (`AgencyServiceImpl.createAgency`):
   a. Validate `@NotBlank name` — trống → `400 VALIDATION_ERROR`.
   b. Validate `brandColor` ≤9 ký tự, `tagline` ≤140 ký tự (Bean Validation) — sai → `400 VALIDATION_ERROR`.
   c. `INSERT agencies` (`ownerId = currentUser.id`, `status = ACTIVE`).
   d. `INSERT agency_members` (`agencyId`, `userId = currentUser.id`, `role = OWNER`).
4. BE → FE: `201 { data: AgencyResponse }` (kèm `id` vừa tạo).
5. FE: redirect sang Agency Dashboard vừa tạo (`/agencies/:agencyId/dashboard` — theo FR 3.4.2, hiện chưa có route thật, tạm dùng trang chi tiết FR 3.4.4).

## Flow B — Upload logo sau khi đã có agencyId

1. Tiếp theo Flow A bước 5 (hoặc từ trang edit sau này).
2. User → FE: chọn file ảnh logo.
3. FE → BE: `POST /api/v1/agencies/{agencyId}/logo` (multipart/form-data, field `file`).
4. BE (`AgencyController.uploadLogo`): lưu file, update `agency.logoUrl`.
5. BE → FE: `200 { data: AgencyResponse }` (đã có `logoUrl` mới).
6. FE: cập nhật preview logo.

---

## Error paths tổng hợp

| Bước | Điều kiện lỗi | HTTP | ErrorCode |
|---|---|---|---|
| Create | `name` trống | 400 | `VALIDATION_ERROR` |
| Create | Field vượt giới hạn (`brandColor` >9 ký tự, `tagline` >140 ký tự) | 400 | `VALIDATION_ERROR` |

## Ghi chú khác biệt so với spec.md gốc

Không có drift — spec.md đã ghi rõ logo là endpoint multipart riêng (không qua field `logoUrl` của form chính), khớp đúng code (`uploadLogo` là action riêng biệt với `createAgency`).
