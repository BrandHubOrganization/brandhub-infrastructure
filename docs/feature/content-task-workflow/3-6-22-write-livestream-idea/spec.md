# UC — Write Livestream Idea

| | |
|---|---|
| FR Code | 3.6.22 |
| Feature | Write Livestream Idea |
| Domain | Content & Workflow (FR 3.6) |
| Role | MANAGER, CREATOR |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Điền ý tưởng và mục tiêu hướng tới cho 1 Task loại Livestream.

## 2. User Story

Là một Manager hoặc Creator,
tôi muốn điền ý tưởng cho buổi livestream,
để định hướng nội dung trước khi viết script chi tiết.

## 3. Acceptance Criteria

- Form nhập `idea` (mô tả ý tưởng), `goal` (mục tiêu hướng tới — ví dụ: tăng nhận diện thương hiệu, ra mắt sản phẩm).
- Chỉ áp dụng cho Task có `type=livestream`.

## 4. UI / UX

- Trang Task Detail (loại Livestream), tab 'Idea'.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
PATCH /api/v1/workspaces/{id}/tasks/{taskId}/livestream/idea
{ "idea": "string", "goal": "string" }
→ 200 { "success": true, "data": { ...updated livestream session... } }
```

## 6. Error Handling

- Task không phải loại `livestream` → 400 `INVALID_TASK_TYPE`.

## 7. Edge Cases

- Không có edge case đặc biệt.

## 8. Definition of Done

- Lưu idea/goal thành công.

## Out of Scope

- Không có.

## Tham chiếu BA

[05-content-task-workflow.md](../../../BA/05-content-task-workflow.md)
