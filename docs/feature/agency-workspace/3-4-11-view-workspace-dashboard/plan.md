# Plan — View Workspace Dashboard (FR 3.4.11)

> Liên kết: [spec.md](spec.md) — Trạng thái tài liệu: **Draft — chưa code**. Plan này ở dạng đề xuất/dự kiến, cần xác nhận khi thiết kế kỹ thuật thật.

## 1. Phạm vi kỹ thuật (dự kiến)

| Mục | Nội dung |
|---|---|
| Repo | `brandhub-business-service` |
| File cần thêm | `WorkspaceServiceImpl.getDashboard()` (chưa tồn tại) |
| File đã có, dự kiến tái sử dụng | `WorkspaceController`, `WorkspaceRepository`, `WorkspaceMemberRepository` — chưa có repository tổng hợp Task/Client/Campaign theo workspace |

## 2. API Contract (đề xuất, chưa code)

```
GET /api/v1/workspaces/{id}/dashboard
→ 200 { "success": true, "data": { "taskStats": {...}, "activeClientCount", "activeCampaignCount" } }
```

Khác biệt tiềm năng so với spec.md khi thật sự cài đặt: cần xác nhận field `id` có khớp path param thật `{workspaceId}` như các endpoint Workspace khác hay không (pattern hiện tại trong `WorkspaceController` dùng `{workspaceId}`).

## 3. Data Model (dự kiến)

- Cần thống kê Task theo trạng thái (backlog/in progress/completed) theo `workspaceId` — hiện **chưa có** repository method tổng hợp (Task domain nằm ở service khác, cần xác nhận đã có bảng/entity `Task` liên kết `workspaceId` hay chưa).
- `activeClientCount`: đếm `WorkspaceMember` có `clientProfileId != null AND isActive = true` theo workspace — có thể tái dùng pattern từ `listMembers`.
- `activeCampaignCount`: cần xác nhận entity Campaign đã có field `workspaceId` + trạng thái active hay chưa.
- Không migration nào được đề xuất ở giai đoạn plan — phụ thuộc vào việc entity Task/Campaign đã có field liên kết Workspace hay chưa (cần thiết kế kỹ thuật xác nhận trước khi code).

## 4. Luồng xử lý (dự kiến)

1. `findWorkspaceOrThrow(id)` → 404 nếu không tồn tại.
2. `assertMember(id, currentUser.id)` — theo pattern `getWorkspace`/`listMembers` (check thủ công, không dùng `@RequireRole` vì aspect không resolve đúng workspace theo path) → 403 nếu không phải active member.
3. Query tổng hợp Task/Client/Campaign theo `workspaceId` (cần thiết kế thêm).
4. Trả về payload dashboard.

## 5. Dependencies

| Chiều | Mô tả |
|---|---|
| Chặn bởi | Cần xác nhận entity Task/Campaign đã liên kết `workspaceId` chưa (ngoài phạm vi Workspace domain) |
| Bị chặn | Không |

## 6. Rủi ro kỹ thuật

- **Chưa có endpoint, chưa có repository tổng hợp** — đây là điểm rủi ro lớn nhất, cần thiết kế kỹ thuật riêng trước khi ước lượng effort thật.
- **Phạm vi số liệu phụ thuộc domain khác** (Task, Campaign) chưa được xác nhận đã sẵn sàng liên kết `workspaceId` — cần BE lead xác nhận trước khi bắt đầu implement.
- Tương tự FR 3.4.2 (Agency Dashboard, cũng Draft) — có thể cân nhắc thiết kế chung 1 pattern dashboard cho cả 2 cấp Agency/Workspace nếu timeline cho phép.
