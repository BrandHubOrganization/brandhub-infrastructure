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
   data = { id, name, ownerId, logoUrl, description, category, companySize,
            website, phone, location, brandColor, logoIcon, tagline,
            foundedYear, facebookUrl, linkedinUrl, instagramUrl,
            status, createdAt, updatedAt }
```

Khác so với spec.md (đề xuất `GET /api/v1/agencies/{id}/profile`):

- **Bỏ hậu tố `/profile`** — dùng thẳng `GET /{agencyId}` để thống nhất với `PUT /{agencyId}` (update) và `DELETE /{agencyId}` (remove), tránh 2 route cùng trả 1 Agency. Frontend gọi `/agency/:id` chung.
- Response không có `yearsActive`/portfolio — ngoài scope, chỉ trả field entity có sẵn.
- **Yêu cầu auth + quyền**: controller nhận `@AuthenticationPrincipal AuthenticatedUser currentUser`; service check OWNER (`agency.ownerId == currentUser.id`) hoặc có `AgencyMember` (`agencyMemberRepository.findByAgencyIdAndUserId`) → nếu không, `400 NOT_AGENCY_MEMBER`.

## 3. Data Model

- Đọc `agencies` qua `findById(agencyId)` + `agency_members` qua `findByAgencyIdAndUserId(agencyId, userId)`. Không migration.

## 4. Luồng xử lý

1. `findAgencyOrThrow(agencyId)` → nếu không có, throw `AGENCY_NOT_FOUND` (404).
2. `isOwner = agency.getOwnerId().equals(currentUser.getId())`.
3. `isMember = agencyMemberRepository.findByAgencyIdAndUserId(agencyId, currentUser.getId()).isPresent()`.
4. `!isOwner && !isMember` → throw `NOT_AGENCY_MEMBER` (400).
5. Map → `AgencyResponse`.

## 5. Dependencies

| Chiều | Mô tả |
|---|---|
| Chặn bởi | `Agency` entity + repository, `AgencyMember` repository (đã có) |
| Bị chặn | `Update` (3.4.5), `Remove` (3.4.6) — dùng chung `findAgencyOrThrow` |

## 6. Rủi ro kỹ thuật

- **Bỏ public view:** trước đây endpoint không check gì (public đọc). Nay đã siết còn OWNER/MEMBER — nếu BA cần trang giới thiệu công khai cho Client tiềm năng xem trước khi ký hợp đồng thì phải mở route public riêng (chưa có). Cần BA xác nhận lại yêu cầu public.
