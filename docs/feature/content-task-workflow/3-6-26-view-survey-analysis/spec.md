# UC — View Survey Analysis

| | |
|---|---|
| FR Code | 3.6.26 |
| Feature | View Survey Analysis |
| Domain | Content & Workflow (FR 3.6) |
| Role | MANAGER, CREATOR |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Xem kết quả tổng quát của khảo sát.

## 2. User Story

Là một Manager hoặc Creator,
tôi muốn xem kết quả khảo sát,
để đánh giá hiệu quả workshop.

## 3. Acceptance Criteria

- Hiển thị số lượng phản hồi, breakdown theo từng câu hỏi (chart cho multiple choice, list cho text).

## 4. UI / UX

- Tab 'Kết quả' trong Task Detail (loại Survey).

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
GET /api/v1/workspaces/{id}/tasks/{taskId}/survey/analysis
→ 200 { "success": true, "data": { "responseCount", "questionBreakdown": [...] } }
```

## 6. Error Handling

- Survey chưa có phản hồi nào → trả data rỗng, không lỗi.

## 7. Edge Cases

- Không có edge case đặc biệt.

## 8. Definition of Done

- Hiển thị đúng kết quả tổng hợp.

## Out of Scope

- Export kết quả (có thể bổ sung sau, không có trong CSV).

## Tham chiếu BA

[05-content-task-workflow.md](../../../BA/05-content-task-workflow.md)
