# UC — Send Email via Template

| | |
|---|---|
| FR Code | 3.6.32 |
| Feature | Send Email via Template |
| Domain | Content & Workflow (FR 3.6) |
| Role | TBD (chưa gán role trong CSV) |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Gửi email thực tế dựa trên Mail Template đã chọn.

## 2. User Story

Là một Member,
tôi muốn gửi email cho Client dựa trên mẫu đã tạo,
để tiết kiệm thời gian soạn email lặp lại.

## 3. Acceptance Criteria

- Chọn Template + người nhận (Client trong Workspace) → điền các placeholder (nếu template có biến động, ví dụ {{clientName}}) → gửi.

## 4. UI / UX

- Nút 'Gửi Email' trong Mail Template detail, hoặc trực tiếp từ trang Client.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
POST /api/v1/workspaces/{id}/mail-templates/{templateId}/send
{ "recipientEmail": "string", "variables"?: {...} }
→ 200 { "success": true, "data": { "messageId" } }
```

## 6. Error Handling

- Gửi lỗi (email service down) → 502 `EMAIL_SERVICE_UNAVAILABLE`.

## 7. Edge Cases

- Không có edge case đặc biệt.

## 8. Definition of Done

- Gửi email thành công, log lại lịch sử gửi.

## Out of Scope

- Không có.

## Tham chiếu BA

[05_Content_Task_Workflow.md](../../../BA/05_Content_Task_Workflow.md)
