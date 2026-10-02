# Plan — Update Client Profile (FR 3.3.4)

> Liên kết: [spec.md](spec.md) — tạo/sửa Client Profile của User đang đăng nhập.
>
> V2 (2026-10-02): **[SỬA]** Create/update không còn theo `agencyId` — xem [3.3.3/plan.md §6](../3-3-3-view-client-profile/plan.md#6-lịch-sử-thay-đổi).

## 1. Phạm vi kỹ thuật

| Mục | Nội dung |
|---|---|
| Repo | `brandhub-business-service`, `brandhub-web-dashboard` |
| File implement | `ClientProfileServiceImpl.createProfile()`, `updateById()`, `deleteById()` |
| File liên quan | `ClientProfileController` (`POST /api/v1/client-profile`, `PUT/DELETE /api/v1/client-profile/{profileId}`), `ClientProfileRequest` |

## 2. API Contract (final)

```
POST /api/v1/client-profile
Authorization: Bearer <access-token>
Body: { displayName, company?, phone?, note?, logoUrl?, website?, industry?, location?, description?,
        socialLinks?, contactName?, contactEmail?, companySize?, instagramUrl?, taxCode?, address?,
        tagline?, foundedYear?, budgetRange? }
→ 201 ApiResponse<ClientProfileResponse>

PUT /api/v1/client-profile/{profileId}
Body: <same shape>
→ 200 ApiResponse<ClientProfileResponse>
→ 403 CLIENT_PROFILE_NOT_OWNED (profileId không thuộc caller)

DELETE /api/v1/client-profile/{profileId}
→ 200 ApiResponse<Void>
→ 409 CLIENT_PROFILE_IN_USE (còn linked tới 1 workspace_members active)
```

Không có `agencyId` ở bất kỳ request/response nào. Không có `email` — lấy từ `User` (authStore).

- **Không còn upsert theo (userId, agencyId)** — create và update là 2 request riêng biệt, phân biệt bởi có/không có `profileId`.
- **Full-overwrite** vẫn giữ cho `PUT` — mỗi lần gửi đủ field, field thiếu bị ghi rỗng.

## 3. Data Model

`client_profiles` — không có migration nào thêm `agency_id` nữa (đã bị huỷ bỏ và revert, xem [2026-10-02-drop-client-profile-agency-id.sql](../../../database/migrations/2026-10-02-drop-client-profile-agency-id.sql)). Field list đầy đủ: xem [3.3.3/plan.md §3](../3-3-3-view-client-profile/plan.md#3-data-model).

## 4. Luồng xử lý

**Create:**
1. Build `ClientProfile.builder().userId(currentUser.getId())...` từ request.
2. `save` → trả `ClientProfileResponse`.

**Update:**
1. `findById(profileId)` → 404 nếu không có.
2. Check `profile.getUserId().equals(currentUser.getId())` → 403 `CLIENT_PROFILE_NOT_OWNED` nếu không khớp.
3. Ghi đè toàn bộ field từ request (full-overwrite), stamp `updatedAt`.
4. `save` → trả `ClientProfileResponse`.

**Delete:**
1. Check ownership như update.
2. Check `workspaceMemberRepository.findByClientProfileIdInAndIsActiveTrue([profileId])` rỗng → nếu không rỗng, 409 `CLIENT_PROFILE_IN_USE`.
3. `delete`.

## 5. Dependencies

| Chiều | Mô tả |
|---|---|
| Chặn bởi | `View Client Profile` (3.3.3) |
| Bị chặn | — |
