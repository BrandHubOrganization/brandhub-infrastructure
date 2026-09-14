# UC — Generate Meeting Link

| | |
|---|---|
| FR Code | 3.6.27 |
| Feature | Generate Meeting Link |
| Domain | Content & Workflow (FR 3.6) |
| Role | CREATOR |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Tự động tạo link Google Meet cho buổi workshop/họp liên quan Task.

## 2. User Story

Là một Creator,
tôi muốn tự động tạo link Google Meet,
để tổ chức buổi họp/workshop online liên quan đến Task.

## 3. Acceptance Criteria

- Bấm 'Tạo link Meet' → gọi Google Calendar/Meet API tạo link, gắn vào Task.

## 4. UI / UX

- Nút trong Task Detail (loại Survey hoặc bất kỳ Task cần họp).

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
POST /api/v1/workspaces/{id}/tasks/{taskId}/meeting-link
→ 201 { "success": true, "data": { "meetingUrl": "string" } }
```

## 6. Error Handling

- Lỗi kết nối Google API → 502 `GOOGLE_MEET_UNAVAILABLE`.

## 7. Edge Cases

- Tạo link nhiều lần cho cùng 1 Task → mỗi lần tạo 1 link mới, không tái sử dụng link cũ (trừ khi cache trong session hiện tại).

## 8. Definition of Done

- Tạo link Meet thành công, gắn đúng vào Task.

## Out of Scope

- Không có.

## Tham chiếu BA

[05_Content_Task_Workflow.md](../../../BA/05_Content_Task_Workflow.md)
