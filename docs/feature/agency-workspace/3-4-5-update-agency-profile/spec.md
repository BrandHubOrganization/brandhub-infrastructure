# UC — Update Agency Profile

| | |
|---|---|
| FR Code | 3.4.5 |
| Feature | Update Agency Profile |
| Domain | Agency & Workspace (FR 3.4) |
| Role | OWNER |
| Version | 2.2 — Cập nhật 2026-09-23 — bổ sung error case `FILE_READ_ERROR` (logo upload) |
| Trạng thái tài liệu | Confirmed — đã code (xác nhận 2026-09-21, khớp task.md/test.md) |

## 1. Objective

Cho phép Owner cập nhật thông tin Agency Profile.

## 2. User Story

Là một Owner,
tôi muốn cập nhật thông tin Agency Profile,
để giữ thông tin công ty luôn mới nhất.

## 3. Acceptance Criteria

- Form sửa: **toàn bộ field của `AgencyRequest`** — `name` (bắt buộc), `logoUrl`, `description`, `category`, `companySize`, `website`, `phone`, `location`, `brandColor`, `logoIcon`, `tagline`, `foundedYear`, `facebookUrl`, `linkedinUrl`, `instagramUrl` (xem bảng field tại FR 3.4.3). Đây là PUT toàn bộ (full replace), không phải PATCH từng phần — request body cần truyền đủ field, field nào không truyền sẽ bị set null.
- Chỉ Owner của chính Agency đó được sửa (`agency.getOwnerId().equals(currentUser.getId())`, else `NOT_AGENCY_OWNER`).
- Logo cập nhật qua endpoint multipart riêng `POST /{agencyId}/logo` (AC3), không qua field `logoUrl` của form chính (tương tự FR 3.4.3). Lỗi đọc file → 400 `FILE_READ_ERROR` (xem mục 6).

## 4. UI / UX

- Trang `/agencies/:agencyId/profile/edit`.

## 5. API Contract (khớp code thật)

```
PUT /api/v1/agencies/{agencyId}
{ AgencyRequest }
→ 200 { "success": true, "data": AgencyResponse }

POST /api/v1/agencies/{agencyId}/logo   (multipart/form-data, field "file")
→ 200 { "success": true, "data": AgencyResponse }
```

Method thật là **PUT**, không phải PATCH. `AgencyRequest`/`AgencyResponse` — xem bảng field đầy đủ tại FR 3.4.3 / FR 3.4.1.

## 6. Error Handling

- Không phải Owner → 403 `NOT_AGENCY_OWNER`.
- `name` trống → 400 `VALIDATION_ERROR`.
- Agency không tồn tại → 404 `AGENCY_NOT_FOUND`.
- Upload logo (`POST /{agencyId}/logo`) lỗi đọc file (`IOException` khi `file.getBytes()`) → 400 `FILE_READ_ERROR` (không phải 500 — `AgencyServiceImpl.updateLogo` bắt `IOException` và ném `BusinessException(FILE_READ_ERROR)`).
- Upload logo không phải Owner → 403 `NOT_AGENCY_OWNER` (check giống Flow A, cùng field `agency.getOwnerId()`).

## 7. Edge Cases

- Vì là PUT full-replace, FE cần truyền lại toàn bộ field hiện có (kể cả field không đổi) để tránh vô tình xóa dữ liệu branding đã nhập trước đó.

## 8. Definition of Done

- Update thành công, chỉ Owner sửa được.

## Out of Scope

- Không có.

## Tham chiếu BA

[01-organization-structure.md](../../../BA/01-organization-structure.md), [03-agency-workspace-management.md](../../../BA/03-agency-workspace-management.md)
