# Plan — Update Agency Profile (FR 3.4.5)

> Liên kết: [spec.md](spec.md) — cho Owner cập nhật name/description/logoUrl của Agency.

## 1. Phạm vi kỹ thuật

| Mục | Nội dung |
|---|---|
| Repo | `brandhub-business-service` |
| File implement | `AgencyServiceImpl.updateAgency()` |
| File đã có | `AgencyController` (`PUT /api/v1/agencies/{agencyId}`), `AgencyRequest`, `AgencyResponse` |

## 2. API Contract (final)

```
PUT /api/v1/agencies/{agencyId}
Authorization: Bearer <access-token>
Body: { "name": "string", "logoUrl"?: "string", "description"?: "string" }
→ 200 ApiResponse<AgencyResponse>
```

Khác so với spec.md (đề xuất `PATCH`):

- **Dùng `PUT` thay `PATCH`** — `AgencyRequest` yêu cầu `name` bắt buộc (`@NotBlank`), full-update; không có cơ chế merge từng field. Pattern PUT đã dùng thống nhất trong repo.
- `AgencyRequest` tái dùng từ create (3.4.3): `name` required, `logoUrl`/`description` optional.

## 3. Data Model

- Đọc/ghi `agencies`. Cập nhật `name` (trim), `logoUrl`, `description`, `updatedAt`. Không migration.

## 4. Luồng xử lý

1. `findAgencyOrThrow(agencyId)` → 404 nếu không có.
2. Check `agency.ownerId == currentUser.id` → nếu không, `NOT_AGENCY_OWNER` (403).
3. Set name (trim)/logoUrl/description, `updatedAt = now`, save.

## 5. Dependencies

| Chiều | Mô tả |
|---|---|
| Chặn bởi | `Agency` entity + repository, `AgencyRequest` (đã có) |
| Bị chặn | không |

## 6. Rủi ro kỹ thuật

- **`name` thiếu `@Size(max=255)`:** cột `name` dài 255. `@NotBlank` chỉ chặn rỗng. Để nguyên, bổ sung ở task validation riêng nếu cần.
- **Update qua `PUT` không phân biệt field nào thay đổi:** luôn ghi đủ 3 field — chấp nhận, vì form FE gửi đủ.
