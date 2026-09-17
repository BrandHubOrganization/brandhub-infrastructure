# UC — Write Livestream Script

| | |
|---|---|
| FR Code | 3.6.23 |
| Feature | Write Livestream Script |
| Domain | Content & Workflow (FR 3.6) |
| Role | CREATOR |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Viết kịch bản đầy đủ cho 1 phiên livestream.

## 2. User Story

Là một Creator,
tôi muốn viết kịch bản chi tiết cho buổi livestream,
để có nội dung dẫn dắt xuyên suốt buổi live.

## 3. Acceptance Criteria

- Editor soạn script — có thể dùng chung Content Writing View (FR 3.6.10) hoặc form riêng theo timeline (segment theo mốc thời gian, giống mẫu Form Creator trong sơ đồ: 0:10, 15:20, 21:30...).
- Có thể dùng AI hỗ trợ (Generate Livestream Script, xem [06-ai-features.md](../../../BA/06-ai-features.md) FR 3.7.11) làm bản gợi ý trước khi tự viết/chỉnh sửa.
- Checklist thực tế kèm theo (từ sơ đồ Flow diagram): ý tưởng/chiến lược target, kịch bản, tính toán rủi ro, quay phim/chụp/setup chuẩn bị, BTS quay bằng camera, người đảm sát/diễn viên, retouch source cắt cam + video edit để chạy hook.

## 4. UI / UX

- Tab 'Script' trong Task Detail (loại Livestream), timeline segment editor.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
PATCH /api/v1/workspaces/{id}/tasks/{taskId}/livestream/script
{ "segments": [{ "timeMark": "string", "content": "string" }] }
→ 200 { "success": true, "data": { ...updated script... } }
```

## 6. Error Handling

- Task không phải loại `livestream` → 400 `INVALID_TASK_TYPE`.

## 7. Edge Cases

- Không có edge case đặc biệt.

## 8. Definition of Done

- Script lưu đúng theo timeline segment.

## Out of Scope

- Không có.

## Tham chiếu BA

[05-content-task-workflow.md](../../../BA/05-content-task-workflow.md)
