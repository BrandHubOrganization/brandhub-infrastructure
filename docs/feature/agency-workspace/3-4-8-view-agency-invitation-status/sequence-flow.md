# Sequence Flow — View Agency Invitation Status

> Bổ sung cho `spec.md` (FR 3.4.8). File này liệt kê từng bước actor → action → hệ thống, đủ chi tiết để vẽ sequence diagram trực tiếp — không diễn giải nghiệp vụ (xem spec.md cho phần đó).
>
> Cập nhật: 2026-09-23. Khớp code thật tại thời điểm này (`AgencyController.listInvitations`, `listMyPendingInvitations`, `cancelInvitation`, `declineInvitation`).

## Actors

- **Owner** — chủ Agency.
- **Invitee** — người được mời.
- **FE** — brandhub-web-dashboard (React).
- **BE** — brandhub-business-service (Spring Boot).
- **DB** — PostgreSQL (`agency_invitations`).

---

## Flow A — Owner xem toàn bộ invitation của Agency

1. Owner → FE: mở tab "Lời mời đang chờ" trong `/agencies/:agencyId/members`.
2. FE → BE: `GET /api/v1/agencies/{agencyId}/invitations`.
3. BE (`AgencyServiceImpl.listInvitations`):
   a. Check Owner — sai → `403 NOT_AGENCY_OWNER`.
   b. Query toàn bộ `agency_invitations` theo `agencyId` (mọi status: PENDING/ACCEPTED/REVOKED, kể cả PENDING đã quá `expiresAt`).
   c. **Lazy-expire khi map response**: với mỗi bản ghi `status == PENDING` mà `expiresAt` đã qua → derive trả `status = EXPIRED` trong `AgencyInvitationResponse`, **không ghi lại DB**.
4. BE → FE: `200 { data: [ AgencyInvitationResponse, ... ] }`.
5. FE: render list, hiển thị status đã derive (PENDING/EXPIRED/ACCEPTED/REVOKED).

## Flow B — Owner hủy 1 invitation đang PENDING

1. Owner → FE: bấm "Hủy lời mời" trên 1 dòng invitation.
2. FE → BE: `DELETE /api/v1/agencies/{agencyId}/invitations/{invitationId}`.
3. BE (`AgencyServiceImpl.cancelInvitation`):
   a. Check Owner — sai → `403 NOT_AGENCY_OWNER`.
   b. Tìm invitation theo id + thuộc agency — không có → `404 INVITATION_NOT_FOUND`.
   c. Check `status == PENDING` (chưa hết hạn logic hay đã hết hạn đều tính, miễn DB status còn PENDING) — không phải PENDING (đã ACCEPTED/REVOKED, hoặc EXPIRED theo lazy-check) → `400 INVALID_INVITATION`.
   d. `UPDATE agency_invitations SET status = REVOKED`.
4. BE → FE: `200 { data: null }`.
5. FE: xóa dòng khỏi list PENDING (hoặc chuyển badge sang "Đã hủy").

## Flow C — Invitee xem invitation pending của chính mình

1. Invitee → FE: mở mục "Lời mời của tôi" trong notification/dashboard cá nhân.
2. FE → BE: `GET /api/v1/agencies/invitations/my-pending`.
3. BE (`AgencyServiceImpl.listMyPendingInvitations`):
   a. Query `agency_invitations` theo `email == currentUser.email`.
   b. Lọc bỏ hẳn (không trả về) các invitation không còn `PENDING` hoặc đã qua `expiresAt` — khác Flow A (Owner thấy cả EXPIRED derive, Invitee không thấy gì ngoài invitation còn hiệu lực thật).
4. BE → FE: `200 { data: [ AgencyInvitationResponse, ... ] }` (chỉ PENDING còn hiệu lực).
5. FE: render list, mỗi item có nút Accept (FR 3.4.7) / Decline.

## Flow D — Invitee từ chối lời mời (Decline)

1. Invitee → FE: bấm "Từ chối" trên 1 invitation.
2. FE → BE: `POST /api/v1/agencies/invitations/decline` `{ token }`.
3. BE (`AgencyServiceImpl.declineInvitation`): tìm theo token, `UPDATE status = REVOKED` (V2 không có `DECLINED` riêng, dùng chung `REVOKED`).
4. BE → FE: `200 { data: null }`.
5. FE: xóa item khỏi list "Lời mời của tôi".

---

## Error paths tổng hợp

| Bước | Điều kiện lỗi | HTTP | ErrorCode |
|---|---|---|---|
| List (Owner) | Không phải Owner | 403 | `NOT_AGENCY_OWNER` |
| Cancel | Không phải Owner | 403 | `NOT_AGENCY_OWNER` |
| Cancel | Invitation không tồn tại/không thuộc agency | 404 | `INVITATION_NOT_FOUND` |
| Cancel | Invitation không còn PENDING | 400 | `INVALID_INVITATION` |

## Ghi chú khác biệt so với spec.md gốc

Không có drift — spec.md đã mô tả đúng cơ chế lazy-expire (không phải scheduled job), hạn mặc định 30 ngày (tùy chỉnh 1-30), và route thật `/agencies/invitations/my-pending` (không phải `/users/me/invitations`). Sequence-flow.md bổ sung thêm chi tiết cho `declineInvitation` (đã có route trong controller nhưng spec.md mục 5 liệt kê ở phần API Contract mà chưa tách thành flow riêng) — đây là bổ sung chi tiết hóa, không phải sửa sai.
