# UC — Create Survey

| | |
|---|---|
| FR Code | 3.6.25 |
| Feature | Create Survey |
| Domain | Content & Workflow (FR 3.6) |
| Role | CREATOR |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Tạo khảo sát (form) cho workshop.

## 2. User Story

Là một Creator,
tôi muốn tạo khảo sát cho workshop,
để thu thập phản hồi/thông tin từ người tham gia.

## 3. Acceptance Criteria

- Form builder: thêm câu hỏi (text, multiple choice, rating...), sắp xếp theo time slot (giống Form Creator trong sơ đồ: 0:10, 15:20, 21:30...).
- Chỉ áp dụng cho Task có `type=survey`.

## 4. UI / UX

- Trang Task Detail (loại Survey), form builder kéo thả câu hỏi.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
POST /api/v1/workspaces/{id}/tasks/{taskId}/survey
{ "questions": [{ "type", "label", "timeSlot"? }] }
→ 201 { "success": true, "data": { "surveyId", "publicLink" } }
```

## 6. Error Handling

- Task không phải loại `survey` → 400 `INVALID_TASK_TYPE`.

## 7. Edge Cases

- Không có câu hỏi nào khi publish → 400 `SURVEY_MUST_HAVE_QUESTIONS`.

## 8. Definition of Done

- Tạo Survey thành công, có link public để người tham gia điền.

## Out of Scope

- Không có.

## Tham chiếu BA

[05_Content_Task_Workflow.md](../../../BA/05_Content_Task_Workflow.md)
