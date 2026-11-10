# Plan — View Agency Dashboard (FR 3.4.2)

> Liên kết: [spec.md](spec.md) — Trạng thái tài liệu: **Draft — chưa code**. Plan này ở dạng đề xuất/dự kiến, cần xác nhận khi thiết kế kỹ thuật thật.

## 1. Phạm vi kỹ thuật (dự kiến)

| Mục | Nội dung |
|---|---|
| Repo | `brandhub-business-service` |
| File cần thêm | `AgencyServiceImpl.getDashboard()` (chưa tồn tại) |
| File đã có, dự kiến tái sử dụng | `AgencyController`, `AgencyRepository`, `AgencyMemberRepository.findByAgencyId` — chưa có repository tổng hợp Workspace/ClientProfile theo agencyId |

## 2. API Contract (đề xuất, chưa code)

```
GET /api/v1/agencies/{agencyId}/dashboard
→ 200 { "success": true, "data": { "workspaceCount", "memberCount", "clientCount", "recentActivity": [...] } }
```

Dùng `{agencyId}` (không phải `id`) để khớp path param thật của các endpoint Agency khác.

## 3. Data Model (dự kiến)

- `memberCount`: `AgencyMemberRepository.findByAgencyId` (bảng `agency_members`).
- `workspaceCount`, `clientCount`: chưa có repository method — cần bổ sung khi code (đếm Workspace/ClientProfile theo agencyId).
- `recentActivity`: chưa xác định nguồn dữ liệu — cần thiết kế (AuditLog? Activity riêng?).
- Không migration đề xuất ở giai đoạn plan.

## 4. Luồng xử lý (dự kiến)

1. `findAgencyOrThrow(agencyId)` → 404 `AGENCY_NOT_FOUND` nếu không tồn tại/soft-delete.
2. Check `agency.ownerId == currentUser.id` → 403 `NOT_AGENCY_OWNER` nếu không phải Owner.
3. Query tổng hợp member/workspace/client theo agencyId.
4. Trả payload dashboard.

## 5. Dependencies

| Chiều | Mô tả |
|---|---|
| Chặn bởi | Cần repository method tổng hợp Workspace/ClientProfile theo agencyId (chưa có) |
| Bị chặn | Không |

## 6. Rủi ro kỹ thuật

- **Chưa có endpoint, chưa có repository tổng hợp** — cần thiết kế kỹ thuật riêng trước khi ước lượng effort.
- **`recentActivity` nguồn dữ liệu chưa rõ** — cần BA/BE lead chốt dùng nguồn nào.
- Tương tự FR 3.4.11 (Workspace Dashboard, cũng Draft) — cân nhắc thiết kế chung 1 pattern dashboard cho cả 2 cấp Agency/Workspace.
