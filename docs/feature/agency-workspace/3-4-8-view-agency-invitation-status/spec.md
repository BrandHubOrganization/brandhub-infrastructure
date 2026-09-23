# UC — View Agency Invitation Status

| | |
|---|---|
| FR Code | 3.4.8 |
| Feature | View Agency Invitation Status |
| Domain | Agency & Workspace (FR 3.4) |
| Role | OWNER/USER (invited) |
| Version | 2.1 — Cập nhật 2026-09-23 — đồng bộ theo code thật |
| Trạng thái tài liệu | Confirmed — đã code (`AgencyController.listInvitations`, `listMyPendingInvitations`, `cancelInvitation`) |

## 1. Objective

Cho cả người mời và người được mời xem trạng thái lời mời vào Agency, tự động hết hạn theo `expiryDays` đã đặt lúc mời (mặc định 30 ngày).

## 2. User Story

Là một Owner hoặc User được mời,
tôi muốn xem trạng thái lời mời vào Agency,
để biết lời mời còn hiệu lực hay đã hết hạn/được xử lý.

## 3. Acceptance Criteria

- Owner xem list toàn bộ invitation đang pending/expired/accepted/revoked của Agency mình (`GET /{agencyId}/invitations`).
- User được mời xem invitation pending của chính họ qua `GET /invitations/my-pending` (lọc theo email, chỉ trả các invitation còn `PENDING` và chưa hết hạn).
- **Hạn mặc định 30 ngày**, tùy chỉnh 1-30 ngày qua `expiryDays` lúc invite (FR 3.4.7) — không phải cố định 3 ngày.
- **Cơ chế hết hạn là lazy-expire lúc query**, không phải scheduled job: bản ghi DB vẫn giữ `status=PENDING` sau khi qua `expiresAt`; khi `listInvitations` đọc ra, nếu `status=PENDING` và `expiresAt` đã qua thì derive trả về `status=EXPIRED` trong response (không ghi lại DB). `listMyPendingInvitations` lọc bỏ hẳn các invitation đã hết hạn (chỉ trả những cái còn hiệu lực).
- Owner có thể **hủy invitation đang PENDING** qua `DELETE /{agencyId}/invitations/{invitationId}` (chỉ Owner, chỉ khi status còn PENDING) — chuyển `status=REVOKED`.

## 4. UI / UX

- Owner: tab 'Lời mời đang chờ' trong `/agencies/:agencyId/members`.
- User được mời: mục 'Lời mời của tôi' trong notification/dashboard cá nhân.

## 5. API Contract (khớp code thật)

```
GET /api/v1/agencies/{agencyId}/invitations
→ 200 { "success": true, "data": [ AgencyInvitationResponse, ... ] }   // toàn bộ, kể cả EXPIRED/ACCEPTED/REVOKED

GET /api/v1/agencies/invitations/my-pending
→ 200 { "success": true, "data": [ AgencyInvitationResponse, ... ] }   // chỉ PENDING còn hiệu lực, theo email user hiện tại

DELETE /api/v1/agencies/{agencyId}/invitations/{invitationId}
→ 200 { "success": true, "data": null }   // hủy invitation — chỉ Owner, chỉ khi PENDING

POST /api/v1/agencies/invitations/decline
{ "token": "string" }
→ 200 { "success": true, "data": null }   // user được mời từ chối — set status=REVOKED (V2 không có DECLINED riêng)
```

`AgencyInvitationResponse` — xem bảng field đầy đủ tại FR 3.4.7.

Route thật không có `/users/me/invitations` — dùng `/agencies/invitations/my-pending` (nằm trong `AgencyController`).

## 6. Error Handling

- Owner chỉ xem/hủy invitation của Agency mình (`listInvitations`/`cancelInvitation` đều check `NOT_AGENCY_OWNER`).
- Hủy invitation không tồn tại hoặc không thuộc agency → 404 `INVITATION_NOT_FOUND`.
- Hủy invitation không còn PENDING (đã accepted/expired/revoked) → 400 `INVALID_INVITATION`.

## 7. Edge Cases

- Invitation hết hạn đúng lúc user bấm accept → `acceptInvitation` kiểm tra lại `status == PENDING && expiresAt` chưa qua tại thời điểm accept, nếu không thỏa → 400 `INVALID_INVITATION`, không tạo AgencyMember.
- Vì lazy-expire, 2 lần gọi `listInvitations` cách nhau qua mốc `expiresAt` có thể trả `status` khác nhau cho cùng 1 bản ghi dù DB chưa đổi — đúng thiết kế (derive tại thời điểm đọc).

## 8. Definition of Done

- Trạng thái hiển thị đúng, tự derive EXPIRED chính xác theo `expiresAt` (mặc định 30 ngày, tùy chỉnh 1-30) khi query — test với clock giả lập.

## Out of Scope

- Gia hạn lời mời (resend) — có thể coi là tạo invitation mới, không sửa invitation cũ.
- ~~Hủy invitation~~ — **đã có trong code** (`cancelInvitation`), không còn Out of Scope, xem mục 5.

## Tham chiếu BA

[01-organization-structure.md](../../../BA/01-organization-structure.md), [03-agency-workspace-management.md](../../../BA/03-agency-workspace-management.md)
