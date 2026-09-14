# UC — Approve Media Campaign

| | |
|---|---|
| FR Code | 3.5.6 |
| Feature | Approve Media Campaign |
| Domain | Media Package & Contract (FR 3.5) |
| Role | OWNER/MANAGER/CLIENT |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Cả 2 bên đồng ý Media Campaign → nhấn triển khai, toàn bộ công việc trong Campaign tự động đẩy vào Workspace thành backlog Task.

## 2. User Story

Là một Owner/Manager hoặc Client,
tôi muốn xác nhận đồng ý với Media Campaign,
để chính thức triển khai và sinh ra công việc cụ thể.

## 3. Acceptance Criteria

- Cần cả 2 phía approve (giống cơ chế Package, FR 3.5.4).
- Khi `APPROVED` → **tự động sinh N Task vào backlog** của Workspace (mỗi đầu việc trong Campaign = 1 Task, xem [05_Content_Task_Workflow.md](../../../BA/05_Content_Task_Workflow.md)).
- Task sinh ra ở mức độ thô: chỉ có tên + deadline, CHƯA có người thực hiện hay yêu cầu chi tiết — cần Identify Task Detail (FR 3.6.1) sau đó.
- Campaign chuyển trạng thái `IN_PROGRESS` ngay sau khi sinh Task.

## 4. UI / UX

- Nút 'Triển khai' xuất hiện khi cả 2 phía đã approve.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
POST /api/v1/workspaces/{id}/campaigns/{campaignId}/approve
→ 200 { "success": true, "data": { "status", "approvedByAgencyAt", "approvedByClientAt" } }

POST /api/v1/workspaces/{id}/campaigns/{campaignId}/deploy
→ 200 { "success": true, "data": { "tasksCreated": number, "taskIds": [...] } }
```

## 6. Error Handling

- Deploy khi chưa đủ 2 phía approve → 409 `CAMPAIGN_NOT_APPROVED`.

## 7. Edge Cases

- Deploy 2 lần liên tiếp do double-click → cần idempotency (chặn tạo trùng Task nếu đã deploy trước đó).

## 8. Definition of Done

- Approve + Deploy hoạt động đúng, Task sinh ra đúng số lượng và nội dung thô từ Campaign.

## Out of Scope

- Không có.

## Tham chiếu BA

[04_Media_Package_Campaign.md](../../../BA/04_Media_Package_Campaign.md), [12_State_Machines.md](../../../BA/12_State_Machines.md)
