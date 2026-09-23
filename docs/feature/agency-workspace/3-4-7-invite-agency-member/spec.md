# UC — Invite Agency Member

| | |
|---|---|
| FR Code | 3.4.7 |
| Feature | Invite Agency Member |
| Domain | Agency & Workspace (FR 3.4) |
| Role | OWNER |
| Version | 2.1 — Cập nhật 2026-09-23 — đồng bộ theo code thật |
| Trạng thái tài liệu | Confirmed — đã code (xác nhận 2026-09-21, khớp task.md/test.md) — **GAP**: xem mục 7 |

## 1. Objective

Cho phép Owner mời người dùng khác vào Agency qua email + token link. Có thể gán sẵn 1 Workspace + role ngay từ lúc mời (tùy chọn); riêng role CLIENT bắt buộc phải kèm workspace.

## 2. User Story

Là một Owner,
tôi muốn mời thêm người vào Agency (và tùy chọn gán sẵn vào 1 Workspace với role cụ thể),
để họ có thể tham gia làm việc trong Agency/Workspace ngay sau khi accept.

## 3. Acceptance Criteria

- Form nhập `email` (bắt buộc), và tùy chọn: `inviteeName`, `note`, `workspaceId`, `role`, `expiryDays`.
- Gửi lời mời qua email kèm token link (`MailService.sendAgencyInvitationEmail`) — **không có notification in-app** (xem GAP mục 7, giữ nguyên như bản cũ).
- Nếu `workspaceId` được truyền: workspace đó phải thuộc đúng agency (else `WORKSPACE_NOT_IN_AGENCY`); nếu `role = MANAGER`, workspace đó chưa được có manager active nào khác (else `MANAGER_ALREADY_ASSIGNED` — mỗi workspace chỉ 1 manager).
- Nếu `role = CLIENT`: **bắt buộc** phải kèm `workspaceId` ngay từ lúc mời (else 400 `WORKSPACE_REQUIRED_FOR_CLIENT_INVITE`) — vì CLIENT không tạo `AgencyMember`, phải có workspace để accept gán `ClientProfile` + `WorkspaceMember`.
- Hạn lời mời (`expiryDays`) tùy chỉnh 1–30 ngày, **mặc định 30 ngày** nếu không truyền hoặc truyền ngoài khoảng (server tự kẹp `Math.max(1, Math.min(30, expiryDays))`).
- Giới hạn tối đa **20 invitation đang PENDING** (chưa hết hạn) cho 1 Agency — vượt quá → 409 `TOO_MANY_PENDING_INVITATIONS`.
- Không cho tạo invitation trùng: nếu email đã pending cho agency này → 409 `INVITATION_ALREADY_PENDING`; nếu email đã là `AgencyMember` → 409 `ALREADY_AGENCY_MEMBER`.
- **Người được mời sau khi accept với role rỗng/không phải CLIENT** trở thành `AgencyMember(role=MEMBER)` — không có role Agency-level đặc biệt nào khác ngoài OWNER/MEMBER. Nếu invitation có kèm `workspaceId`+`role` (MANAGER/CREATOR), sau khi accept sẽ tự động thêm luôn `WorkspaceMember` tương ứng vào workspace đó.
- **Không có auto-accept khi user đăng ký đúng email được mời** — người dùng phải chủ động bấm link/gọi `POST /invitations/accept` với token để accept, kể cả khi email trùng khớp.

## 4. UI / UX

- Trang `/agencies/:agencyId/members`, nút 'Mời thành viên'.

## 5. API Contract (khớp code thật)

```
POST /api/v1/agencies/{agencyId}/invitations
{ InviteAgencyMemberRequest }
→ 200 { "success": true, "data": AgencyInvitationResponse }
```

Lưu ý response HTTP status thật là **200** (controller không set `@ResponseStatus(CREATED)` cho endpoint này), khác với Create Agency (201).

`InviteAgencyMemberRequest`:

| Field | Kiểu/Ghi chú |
|---|---|
| email | string, bắt buộc (`@NotBlank @Email`) |
| inviteeName | string, optional — tên hiển thị trong email mời |
| note | string, optional — lời nhắn kèm invitation |
| workspaceId | UUID, optional — gán sẵn workspace; bắt buộc nếu `role = CLIENT` |
| role | enum MemberRole: MANAGER, CREATOR, CLIENT — optional |
| expiryDays | integer, optional, 1-30, mặc định 30 nếu bỏ trống/ngoài khoảng |

`AgencyInvitationResponse`:

| Field | Kiểu/Ghi chú |
|---|---|
| id | UUID |
| agencyId | UUID |
| agencyName | string |
| invitedEmail | string |
| invitedBy | UUID |
| token | string (dùng cho accept link) |
| note | string |
| workspaceId | UUID (nullable) |
| workspaceName | string (nullable) |
| role | enum MemberRole (nullable) |
| status | enum InvitationStatus: PENDING, ACCEPTED, EXPIRED, REVOKED |
| expiresAt | OffsetDateTime |
| acceptedAt | OffsetDateTime (nullable) |
| createdAt | OffsetDateTime |

Accept (không thuộc FR 3.4.7 nhưng liên quan trực tiếp luồng invite):

```
POST /api/v1/agencies/invitations/accept
{ "token": "string" }
→ 200 { "success": true, "data": AgencyMemberResponse }
```

## 6. Error Handling

- Email đã là Member của Agency → 409 `ALREADY_AGENCY_MEMBER`.
- Đã có invitation PENDING cho email này trong agency → 409 `INVITATION_ALREADY_PENDING`.
- Đã đạt 20 invitation PENDING của agency → 409 `TOO_MANY_PENDING_INVITATIONS`.
- Không phải Owner → 403 `NOT_AGENCY_OWNER`.
- `workspaceId` không tồn tại → 404 `WORKSPACE_NOT_FOUND`.
- `workspaceId` không thuộc agency này → 400 `WORKSPACE_NOT_IN_AGENCY`.
- `role = MANAGER` nhưng workspace đã có manager active → 409 `MANAGER_ALREADY_ASSIGNED`.
- `role = CLIENT` mà không kèm `workspaceId` → 400 `WORKSPACE_REQUIRED_FOR_CLIENT_INVITE`.

## 7. Edge Cases

- Email được mời chưa có User account trên hệ thống → vẫn gửi được lời mời qua email; **không tự động accept** khi họ đăng ký (đã sửa so với bản cũ) — họ phải chủ động bấm link/gọi API accept với token.
- **[GAP xác nhận 2026-09-21, đã chốt với team]** AC bản cũ ghi "gửi email + tạo notification trong app" — code hiện tại (`AgencyServiceImpl.inviteMember`, `MailService.sendAgencyInvitationEmail`) **chỉ gửi email, không có notification in-app nào**. Đã xác nhận: hệ thống **chưa có module notification chung nào** — không code phần này trong đợt hiện tại, giữ nguyên chỉ-email cho tới khi module notification được xây (task riêng, ngoài phạm vi FR 3.4.7).

## 8. Definition of Done

- Mời thành công; nếu không kèm workspace/role, người được mời sau khi accept chỉ có `AgencyMember(role=MEMBER)`, không có role Agency-level khác.

## Out of Scope

- Notification in-app (chưa có module chung — xem GAP).
- Resend/gia hạn invitation cũ (tạo mới invitation là hướng hiện tại, không sửa invitation cũ ngoài revoke qua `cancelInvitation`).

## Tham chiếu BA

[01-organization-structure.md](../../../BA/01-organization-structure.md), [03-agency-workspace-management.md](../../../BA/03-agency-workspace-management.md)
