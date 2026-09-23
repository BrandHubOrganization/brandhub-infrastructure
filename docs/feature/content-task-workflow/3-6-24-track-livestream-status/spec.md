# UC — Track Livestream Status

| | |
|---|---|
| FR Code | 3.6.24 |
| Feature | Track Livestream Status |
| Domain | Content & Workflow (FR 3.6) |
| Role | CREATOR |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Hiển thị tiến độ Livestream theo các trạng thái Pre-live → Live → Post-live → Done/Cancel.

## 2. User Story

Là một Creator,
tôi muốn cập nhật trạng thái buổi livestream,
để team theo dõi tiến độ thực tế của buổi live.

## 3. Acceptance Criteria

- 4 trạng thái chính: `PRE_LIVE → LIVE → POST_LIVE → DONE`, có thể `CANCEL` ở PRE_LIVE hoặc LIVE.
- Xem chi tiết transition tại [12-state-machines.md](../../../BA/12-state-machines.md) mục 5.
- State này lồng bên trong Task cha — Task cha vẫn đi qua Approval Sequence (FR 3.6.9) sau khi Livestream state đạt DONE.

## 4. UI / UX

- Progress stepper hiển thị 4 trạng thái trong Task Detail (loại Livestream).

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
PATCH /api/v1/workspaces/{id}/tasks/{taskId}/livestream/status
{ "status": "pre_live|live|post_live|done|cancel" }
→ 200 { "success": true, "data": { ...updated livestream status... } }
```

## 6. Error Handling

- Chuyển trạng thái không hợp lệ (ví dụ từ DONE quay lại LIVE) → 409 `INVALID_LIVESTREAM_TRANSITION`.

## 7. Edge Cases

- Cancel ở POST_LIVE (đã live xong, đang xử lý hậu kỳ) → KHÔNG hợp lệ, chỉ Cancel được ở PRE_LIVE hoặc LIVE theo state machine đã xác nhận.

## 8. Definition of Done

- Chuyển trạng thái đúng theo state machine, chặn transition không hợp lệ.

## Out of Scope

- Không có.

## Tham chiếu BA

[05-content-task-workflow.md](../../../BA/05-content-task-workflow.md), [12-state-machines.md](../../../BA/12-state-machines.md)
