# UC — View Agency Invitation Status

| | |
|---|---|
| FR Code | 3.4.8 |
| Feature | View Agency Invitation Status |
| Domain | Agency & Workspace (FR 3.4) |
| Role | OWNER/USER (invited) |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Cho cả người mời và người được mời xem trạng thái lời mời vào Agency, tự động hết hạn sau 3 ngày.

## 2. User Story

Là một Owner hoặc User được mời,
tôi muốn xem trạng thái lời mời vào Agency,
để biết lời mời còn hiệu lực hay đã hết hạn/được xử lý.

## 3. Acceptance Criteria

- Owner xem list toàn bộ invitation đang pending/expired/accepted của Agency mình.
- User được mời xem invitation của chính họ (trong notification hoặc trang riêng).
- **Invitation tự động hết hạn sau 3 ngày** kể từ lúc tạo — hệ thống set `status=EXPIRED` tự động (qua scheduled job hoặc tính toán tại thời điểm query).

## 4. UI / UX

- Owner: tab 'Lời mời đang chờ' trong `/agencies/:id/members`.
- User được mời: mục 'Lời mời của tôi' trong notification/dashboard cá nhân.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
GET /api/v1/agencies/{id}/invitations
→ 200 { "success": true, "data": [{ "id", "email", "status", "createdAt", "expiresAt" }] }

GET /api/v1/users/me/invitations
→ 200 { "success": true, "data": [{ "id", "agencyName", "status", "expiresAt" }] }
```

## 6. Error Handling

- Không có lỗi đặc biệt ngoài phân quyền xem (Owner chỉ xem của Agency mình).

## 7. Edge Cases

- Invitation hết hạn đúng lúc user bấm accept → phải chặn accept, trả lỗi rõ ràng thay vì tạo AgencyMember với invitation đã hết hạn.

## 8. Definition of Done

- Trạng thái hiển thị đúng, tự hết hạn sau 3 ngày chính xác (test với clock giả lập).

## Out of Scope

- Gia hạn lời mời (resend) — có thể coi là tạo invitation mới, không sửa invitation cũ.

## Tham chiếu BA

[01-organization-structure.md](../../../BA/01-organization-structure.md), [03-agency-workspace-management.md](../../../BA/03-agency-workspace-management.md)
