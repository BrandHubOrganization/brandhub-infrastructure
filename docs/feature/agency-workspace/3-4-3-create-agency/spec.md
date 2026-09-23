# UC — Create Agency

| | |
|---|---|
| FR Code | 3.4.3 |
| Feature | Create Agency |
| Domain | Agency & Workspace (FR 3.4) |
| Role | OWNER |
| Version | 2.1 — Cập nhật 2026-09-23 — đồng bộ theo code thật |
| Trạng thái tài liệu | Confirmed — đã code (xác nhận 2026-09-21, xem task.md/test.md đã update) |

## 1. Objective

Cho phép User tạo mới 1 Agency, tự động trở thành Owner — gắn 1-1 giữa Agency và user tạo ra nó.

## 2. User Story

Là một User,
tôi muốn tạo 1 Agency mới,
để bắt đầu quản lý công ty truyền thông của mình trên BrandHub.

## 3. Acceptance Criteria

- Form nhập `name` (bắt buộc), cùng các field branding tùy chọn (xem bảng field bên dưới).
- Submit → tạo `Agency` với `ownerId = currentUser.id`, đồng thời tạo `AgencyMember(role=OWNER)` cho chính user đó — quan hệ 1-1 cố định, không đổi được Owner qua FR khác trong phạm vi CSV hiện tại.
- Logo **không** truyền kèm lúc tạo qua field `logoUrl` trong form chính — upload logo là endpoint multipart riêng: `POST /{agencyId}/logo` (gọi sau khi đã có `agencyId`). `logoUrl` trong `AgencyRequest` vẫn tồn tại (có thể set text URL trực tiếp) nhưng luồng UI chuẩn là upload file riêng.
- Redirect vào Agency Dashboard vừa tạo.

## 4. UI / UX

- Trang `/agencies/create`, hoặc modal từ trang List Agency.

## 5. API Contract (khớp code thật)

```
POST /api/v1/agencies
{ AgencyRequest }
→ 201 { "success": true, "data": AgencyResponse }

POST /api/v1/agencies/{agencyId}/logo   (multipart/form-data, field "file")
→ 200 { "success": true, "data": AgencyResponse }   // logoUrl đã được cập nhật
```

`AgencyRequest` (request body):

| Field | Kiểu/Ghi chú |
|---|---|
| name | string, bắt buộc (`@NotBlank`) |
| logoUrl | string, optional |
| description | string, optional |
| category | enum AgencyCategory (MARKETING, FNB, FASHION, BEAUTY, TECHNOLOGY, REAL_ESTATE, EDUCATION, HEALTHCARE, RETAIL, FINANCE, ENTERTAINMENT, OTHER), optional |
| companySize | enum CompanySize (SIZE_1_10, SIZE_11_50, SIZE_51_200, SIZE_201_500, SIZE_500_PLUS), optional |
| website | string, optional |
| phone | string, optional |
| location | string, optional |
| brandColor | string (hex, ≤9 ký tự), optional |
| logoIcon | string, optional |
| tagline | string (≤140 ký tự), optional |
| foundedYear | integer, optional |
| facebookUrl | string, optional |
| linkedinUrl | string, optional |
| instagramUrl | string, optional |

Response: `AgencyResponse` — xem bảng đầy đủ tại spec FR 3.4.1 (bao gồm thêm `id`, `ownerId`, `status`, `createdAt`, `updatedAt`).

## 6. Error Handling

- `name` trống → 400 `VALIDATION_ERROR` (Bean Validation `@NotBlank`).

## 7. Edge Cases

- User đã là Owner của N Agency khác → không giới hạn số lượng Agency tạo mới trong CSV (có thể bị giới hạn theo Subscription Plan — xem FR 3.9, cần xác nhận liên kết khi thiết kế).

## 8. Definition of Done

- Tạo Agency thành công, `ownerId` gắn đúng user hiện tại, không đổi được sau khi tạo.

## Out of Scope

- Chuyển nhượng Owner (transfer ownership) — không có trong CSV hiện tại.

## Tham chiếu BA

[01-organization-structure.md](../../../BA/01-organization-structure.md), [03-agency-workspace-management.md](../../../BA/03-agency-workspace-management.md)
