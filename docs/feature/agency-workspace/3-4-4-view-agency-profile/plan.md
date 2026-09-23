# Plan — View Agency Profile (FR 3.4.4)

> Liên kết: [spec.md](spec.md) — hiển thị Profile công khai của Agency (name, logo, description).

## 1. Phạm vi kỹ thuật

| Mục | Nội dung |
|---|---|
| Repo | `brandhub-business-service` |
| File implement | `AgencyServiceImpl.getAgency()` |
| File đã có | `AgencyController` (`GET /api/v1/agencies/{agencyId}`), `AgencyRepository`, `AgencyResponse` |

## 2. API Contract (final)

```
GET /api/v1/agencies/{agencyId}
Authorization: Bearer <access-token>
→ 200 ApiResponse<AgencyResponse>
   data = { id, name, ownerId, logoUrl, description, status, createdAt, updatedAt }
```

Khác so với spec.md (đề xuất `GET /api/v1/agencies/{id}/profile`):

- **Bỏ hậu tố `/profile`** — dùng thẳng `GET /{agencyId}` để thống nhất với `PUT /{agencyId}` (update) và `DELETE /{agencyId}` (remove), tránh 2 route cùng trả 1 Agency. Frontend gọi `/agency/:id` chung.
- Response không có `yearsActive`/portfolio — ngoài scope, chỉ trả field entity có sẵn.

## 3. Data Model

- Đọc `agencies` qua `findById(agencyId)`. Không migration.

## 4. Luồng xử lý

1. `findAgencyOrThrow(agencyId)` → nếu không có, throw `AGENCY_NOT_FOUND` (404).
2. Map → `AgencyResponse`.

## 5. Dependencies

| Chiều | Mô tả |
|---|---|
| Chặn bởi | `Agency` entity + repository (đã có) |
| Bị chặn | `Update` (3.4.5), `Remove` (3.4.6) — dùng chung `findAgencyOrThrow` |

## 6. Rủi ro kỹ thuật

- **Public view không login (spec mục 7):** endpoint đang yêu cầu auth (Bearer). Nếu cần public, phải tách route riêng + đảm bảo không lộ thông tin nội bộ. Chưa làm — để BA quyết.
