# Plan — Create Agency (FR 3.4.3)

> Liên kết: [spec.md](spec.md) — cho User tạo Agency mới, tự trở thành Owner (ownerId = currentUser.id).

## 1. Phạm vi kỹ thuật

| Mục | Nội dung |
|---|---|
| Repo | `brandhub-business-service` |
| File đã scaffold sẵn | `model/Agency.java`, `controller/AgencyController.java`, `service/AgencyService.java`, `service/impl/AgencyServiceImpl.java`, `dto/request/AgencyRequest.java`, `dto/response/AgencyResponse.java`, `repository/AgencyRepository.java` |
| File cần implement | `AgencyServiceImpl.createAgency()` (hiện throw `UnsupportedOperationException`) |
| File cần chỉnh | `AgencyController.createAgency()` — thêm `@ResponseStatus(HttpStatus.CREATED)` |
| File mới | `src/test/java/com/brandhub/business/service/AgencyServiceImplTest.java` (test `createAgency`) |
| Frontend | Chưa trong phạm vi task này — route `/agencies/create` thuộc task FE riêng |

Entity, controller, interface, DTO, repository đã có đầy đủ — **không tạo mới**, chỉ implement logic service.

## 2. API Contract (final)

```
POST /api/v1/agencies
Authorization: Bearer <access-token>          (bất kỳ user đã đăng nhập)
Body:   { "name": "string", "logoUrl"?: "string", "description"?: "string" }
→ 201   ApiResponse<AgencyResponse>
        data = { id, name, ownerId, logoUrl, description, status, createdAt, updatedAt }
```

Khác so với spec.md (đề xuất ghi 201 kèm `{success:true,data:{...}}`):

- **Status code 201** — giữ nguyên đề xuất spec, KHÔNG đổi sang 200. Lý do: `rule.md` §3.2 quy định `POST /create → 201 Created`. Controller scaffold hiện chưa gắn `@ResponseStatus`, cần bổ sung để khớp contract.
- **Response dùng envelope `ApiResponse<T>`** chuẩn của repo (kèm `requestId`, `version`, `timestamp`), không trả raw object như ví dụ rút gọn trong spec.

## 3. Data Model

- Đọc/ghi: bảng `agencies` (entity `Agency` đã map đủ).
- **Không cần migration** — cột đã đủ: `name`, `owner_id`, `logo_url`, `description`, `status`, `deleted_at`, `created_at`, `updated_at`.
- `status` mặc định `EntityStatus.ACTIVE` (đã set `@Builder.Default`).
- `createdAt`/`updatedAt` đã có `@Builder.Default = now()`.

**Làm rõ quan hệ owner:** BA ghi "1-1" nhưng nghĩa là *1 Agency → đúng 1 Owner*, không phải *1 User → 1 Agency*. Đã confirm tại `docs/ba/01-organization-structure.md`: "1 User có thể là Owner của nhiều Agency". ⇒ **KHÔNG** đặt unique constraint trên `owner_id`. `AgencyRepository.findByOwnerId()` trả `List<Agency>` (đã đúng).

## 4. Luồng xử lý

`AgencyServiceImpl.createAgency(currentUser, request)`:

1. Build `Agency` từ request: `name = request.name().trim()`, `logoUrl`, `description`.
2. Gán `ownerId = currentUser.getId()`.
3. `status` = `ACTIVE` (mặc định builder, không set thủ công).
4. `agencyRepository.save(agency)` → sinh `id` (UUID) + timestamp.
5. Map entity → `AgencyResponse` (helper `toResponse`, copy pattern `ClientProfileServiceImpl`).
6. Trả `AgencyResponse` cho controller wrap vào `ApiResponse.ok`.

**Không có bước nào khác** (không gửi email, không tạo Workspace kèm theo, không kiểm tra duplicate name — BA/spec không yêu cầu).

## 5. Dependencies

| Chiều | Mô tả |
|---|---|
| Chặn bởi | `Agency` entity + repository (đã có sẵn) — không còn gì chặn |
| Bị chặn bởi task này | `List Agency` (3.4.1), `View Agency Profile` (3.4.4)… đều là implement `AgencyServiceImpl` các method khác, cùng repo |

## 6. Rủi ro kỹ thuật

- **Nhầm `1-1` → đặt unique `owner_id`:** sẽ chặn user tạo Agency thứ 2. Đã làm rõ ở mục 3, KHÔNG thêm unique.
- **Trim name:** `AgencyRequest` chỉ có `@NotBlank` (chặn null/blank), không chặn khoảng trắng thừa 2 đầu ⇒ service tự `.trim()` trước khi lưu (theo pattern `ClientProfileServiceImpl`).
- **Status code:** nếu quên `@ResponseStatus(CREATED)`, API trả 200 thay vì 201 → lệch contract. Đã đưa vào task checklist.
- **`name` thiếu `@Size(max=...)`:** cột `name` dài 255; spec không yêu cầu giới hạn ký tự. Để nguyên, không mở rộng scope (nếu cần sẽ bổ sung ở task validation riêng).
