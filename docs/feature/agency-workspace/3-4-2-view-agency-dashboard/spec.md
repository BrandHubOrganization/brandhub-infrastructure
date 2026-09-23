# UC — View Agency Dashboard

| | |
|---|---|
| FR Code | 3.4.2 |
| Feature | View Agency Dashboard |
| Domain | Agency & Workspace (FR 3.4) |
| Role | OWNER |
| Version | 2.1 — Cập nhật 2026-09-23 — đồng bộ theo code thật |
| Trạng thái tài liệu | Draft — BA confirmed, **chưa code** (không có endpoint dashboard riêng trong `AgencyController`/`AgencyServiceImpl` hiện tại) |

## 1. Objective

Hiển thị thông tin tổng quan của 1 Agency cho Owner.

## 2. User Story

Là một Owner,
tôi muốn xem dashboard tổng quan của Agency,
để nắm được tình hình hoạt động chung.

## 3. Acceptance Criteria

- Hiển thị: số Workspace, số Member, số Client đang làm việc (đếm distinct qua các Workspace), hoạt động gần đây.
- Chỉ Owner của chính Agency đó xem được (kiểm tra `agency.ownerId === currentUser.id`) — pattern giống các method khác trong `AgencyServiceImpl` (ví dụ `updateAgency`, `removeAgency` đều so `agency.getOwnerId().equals(currentUser.getId())`, ném `ErrorCode.NOT_AGENCY_OWNER`).

## 4. UI / UX

- Trang `/agencies/:agencyId/dashboard`.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật — CHƯA CODE)

Chưa có endpoint dashboard riêng. Khi cài đặt, dùng `agencyId` (không phải `id`) để khớp path param thật của các endpoint Agency khác (`{agencyId}`), và cơ sở dữ liệu để tính số liệu là các bảng/field thật đã có:

```
GET /api/v1/agencies/{agencyId}/dashboard
→ 200 { "success": true, "data": { "workspaceCount", "memberCount", "clientCount", "recentActivity": [...] } }
```

- `memberCount`: đếm qua `AgencyMemberRepository.findByAgencyId` (bảng `agency_members`, role OWNER/MEMBER).
- `workspaceCount`, `clientCount`: chưa có repository method tổng hợp sẵn — cần bổ sung khi code (Workspace/ClientProfile theo agencyId).
- Agency cơ sở dùng field thật của `Agency` entity (xem bảng field tại FR 3.4.1/3.4.4), không phải field giả định cũ.

## 6. Error Handling

- Không phải Owner → 403 `FORBIDDEN`.
- Agency không tồn tại/đã soft-delete → 404 `AGENCY_NOT_FOUND`.

## 7. Edge Cases

- Agency vừa tạo, chưa có Workspace nào → dashboard hiển thị toàn 0, không lỗi.

## 8. Definition of Done

- Dashboard hiển thị đúng số liệu tổng hợp.

## Out of Scope

- Chart/biểu đồ chi tiết theo thời gian (có thể bổ sung sau, CSV chỉ yêu cầu overview).

## Tham chiếu BA

[01-organization-structure.md](../../../BA/01-organization-structure.md), [03-agency-workspace-management.md](../../../BA/03-agency-workspace-management.md)
