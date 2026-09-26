# Plan — View Agency Invitation Status (FR 3.4.8)

> Liên kết: [spec.md](spec.md) — cho Owner xem invitation của Agency, User xem invitation của chính mình; hết hạn 1-30 ngày (mặc định 30, do 3.4.7 set khi tạo invitation).

## 1. Phạm vi kỹ thuật

| Mục | Nội dung |
|---|---|
| Repo | `brandhub-business-service` |
| File implement | `AgencyServiceImpl.listInvitations()`, `listMyPendingInvitations()`, `acceptInvitation()`, `declineInvitation()` |
| File đã có | `AgencyController` (GET `/{agencyId}/invitations`, GET `/invitations/my-pending`, POST `/invitations/accept`, POST `/invitations/decline`) |

## 2. API Contract (final)

```
GET /api/v1/agencies/{agencyId}/invitations      (Owner xem của Agency mình)
→ 200 ApiResponse<List<AgencyInvitationResponse>>

GET /api/v1/agencies/invitations/my-pending      (User xem của chính mình)
→ 200 ApiResponse<List<AgencyInvitationResponse>>

POST /api/v1/agencies/invitations/accept         Body: { "token": "string" }
→ 200 ApiResponse<AgencyMemberResponse>

POST /api/v1/agencies/invitations/decline        Body: { "token": "string" }
→ 200 ApiResponse<Void>
```

Khác so với spec.md (đề xuất `GET /api/v1/users/me/invitations`):

- **Dùng `GET /invitations/my-pending`** thay `GET /users/me/invitations` — route nằm chung trong `AgencyController` (không tạo thêm `UserController` route). Trả `agencyName` để hiển thị.
- **Hết hạn tính tại thời điểm query** (filter `expiresAt > now`), KHÔNG dùng scheduled job set `EXPIRED`. Lý do: đơn giản, chính xác hơn, không cần job. Accept/decline cũng check `expiresAt` trước khi xử lý.

## 3. Data Model

- Đọc `agency_invitations`, `agencies` (lấy `agencyName`), `users`.
- Accept: ghi `agency_members` (role `MEMBER`), cập nhật invitation `status = ACCEPTED`.
- Decline: `status = REVOKED` (V2 `InvitationStatus` không có `DECLINED`).

## 4. Luồng xử lý

`acceptInvitation`:
1. Tìm invitation theo token → 404/`INVALID_INVITATION`.
2. Check `status == PENDING` và `expiresAt` chưa qua → nếu sai `INVALID_INVITATION`.
3. Check `invitedEmail == user.email` (tránh accept nhầm) → `INVALID_INVITATION`.
4. Check chưa là member → `ALREADY_AGENCY_MEMBER`.
5. Save `AgencyMember(MEMBER)` + set invitation `ACCEPTED`.

## 5. Dependencies

| Chiều | Mô tả |
|---|---|
| Chặn bởi | `AgencyInvitation`, `AgencyMember` entity (đã có) |
| Bị chặn | luồng mời hoàn chỉnh (3.4.7) |

## 6. Rủi ro kỹ thuật

- **Accept đúng lúc hết hạn (spec mục 7):** check `expiresAt.isBefore(now)` ngay trước khi tạo member → chặn, không tạo member với invite hết hạn. Đã xử lý.
- **`DECLINED` vs `REVOKED`:** enum V2 thiếu `DECLINED`, dùng `REVOKED` làm terminal state. Ghi chú rõ để BA xác nhận tên.
