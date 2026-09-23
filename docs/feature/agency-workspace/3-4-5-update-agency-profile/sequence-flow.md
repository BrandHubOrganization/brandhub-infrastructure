# Sequence Flow — Update Agency Profile

> Bổ sung cho `spec.md` (FR 3.4.5). File này liệt kê từng bước actor → action → hệ thống, đủ chi tiết để vẽ sequence diagram trực tiếp — không diễn giải nghiệp vụ (xem spec.md cho phần đó).
>
> Cập nhật: 2026-09-23. Khớp code thật tại thời điểm này (`AgencyController.updateAgency`/`uploadLogo`, `AgencyServiceImpl.updateAgency`).

## Actors

- **Owner**
- **FE** — brandhub-web-dashboard (React).
- **BE** — brandhub-business-service (Spring Boot).
- **DB** — PostgreSQL (`agencies`).

---

## Flow A — Update thông tin Agency (PUT full-replace)

1. Owner → FE: mở `/agencies/:agencyId/profile/edit`, form load sẵn toàn bộ field hiện có (`GET /{agencyId}` — FR 3.4.4).
2. Owner sửa field, giữ nguyên field không đổi (bắt buộc vì là PUT full-replace, không phải PATCH).
3. FE → BE: `PUT /api/v1/agencies/{agencyId}` `{ AgencyRequest }` (đầy đủ field).
4. BE (`AgencyServiceImpl.updateAgency`):
   a. `findAgencyOrThrow(agencyId)` — không tồn tại → `404 AGENCY_NOT_FOUND`.
   b. Check `agency.getOwnerId().equals(currentUser.getId())` — sai → `403 NOT_AGENCY_OWNER`.
   c. Validate `@NotBlank name` — trống → `400 VALIDATION_ERROR`.
   d. Set lại toàn bộ field từ request (field nào request không có sẽ bị set null — full replace).
   e. `UPDATE agencies`.
5. BE → FE: `200 { data: AgencyResponse }`.
6. FE: hiện toast thành công, cập nhật lại form/preview.

## Flow B — Đổi logo (multipart riêng)

1. Owner → FE: chọn file logo mới trên trang edit.
2. FE → BE: `POST /api/v1/agencies/{agencyId}/logo` (multipart/form-data, field `file`).
3. BE (`AgencyServiceImpl.updateLogo`):
   a. `findAgencyOrThrow(agencyId)` — không tồn tại → `404 AGENCY_NOT_FOUND`.
   b. Check `agency.getOwnerId().equals(currentUser.getId())` — sai → `403 NOT_AGENCY_OWNER`.
   c. `fileStorageService.uploadAgencyLogo(agencyId, file.getBytes(), file.getContentType())` — nếu `file.getBytes()` ném `IOException` → catch, ném `BusinessException(FILE_READ_ERROR)` → `400 FILE_READ_ERROR`.
   d. Set `agency.logoUrl` = url mới, `updatedAt = now`, save.
4. BE → FE: `200 { data: AgencyResponse }`.
5. FE: cập nhật preview logo.

---

## Error paths tổng hợp

| Bước | Điều kiện lỗi | HTTP | ErrorCode |
|---|---|---|---|
| Update | Agency không tồn tại | 404 | `AGENCY_NOT_FOUND` |
| Update | Không phải Owner | 403 | `NOT_AGENCY_OWNER` |
| Update | `name` trống | 400 | `VALIDATION_ERROR` |
| Logo upload | Agency không tồn tại | 404 | `AGENCY_NOT_FOUND` |
| Logo upload | Không phải Owner | 403 | `NOT_AGENCY_OWNER` |
| Logo upload | Đọc file lỗi (`IOException`) | 400 | `FILE_READ_ERROR` |

## Ghi chú khác biệt so với spec.md gốc

Không có drift. Logo upload error case (`FILE_READ_ERROR`, 400 thay vì 500 generic) đã khớp code `AgencyServiceImpl.updateLogo` — trước đây IOException ném RuntimeException/500, nay bắt và trả `BusinessException(FILE_READ_ERROR)`.
