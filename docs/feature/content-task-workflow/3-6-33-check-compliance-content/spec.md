# UC — Check Compliance Content

| | |
|---|---|
| FR Code | 3.6.33 |
| Feature | Check Compliance Content |
| Domain | Content & Workflow (FR 3.6) |
| Role | CREATOR, CLIENT |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Check đạo văn, bạo lực, hình ảnh dung tục qua API bên thứ 3 — trả bảng phân tích chi tiết để Creator tự sửa trước khi vi phạm chính sách nền tảng hoặc mất khả năng lên trending.

## 2. User Story

Là một Creator hoặc Client,
tôi muốn kiểm tra content có vi phạm chính sách không,
để chủ động sửa trước khi đăng lên social media.

## 3. Acceptance Criteria

- Chạy check trên nội dung Task (loại Post): text (đạo văn), hình ảnh (bạo lực, dung tục).
- Dùng API bên thứ 3 (moderation service) — trả về kết quả chuẩn nhất có thể.
- Hiển thị bảng phân tích: từ ngữ/đoạn vi phạm cụ thể, mức độ nghiêm trọng, gợi ý sửa.
- Nếu phát hiện vi phạm nghiêm trọng → có thể tự động đưa vào Content Moderation Queue để Admin review (xem [09_Admin_Management.md](../../../BA/09_Admin_Management.md) FR 3.10.4).

## 4. UI / UX

- Nút 'Check Compliance' trong Task Detail (loại Post), hiển thị kết quả dạng bảng highlight đoạn vi phạm.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
POST /api/v1/workspaces/{id}/tasks/{taskId}/compliance-check
→ 200 { "success": true, "data": { "violations": [{ "type", "excerpt", "severity", "suggestion" }] } }
```

## 6. Error Handling

- API bên thứ 3 timeout/lỗi → 502 `COMPLIANCE_SERVICE_UNAVAILABLE`, cho phép retry.

## 7. Edge Cases

- Content không có vi phạm nào → trả `violations: []`, hiển thị badge 'Đã qua kiểm duyệt'.

## 8. Definition of Done

- Check hoạt động, hiển thị đúng bảng phân tích vi phạm.

## Out of Scope

- Không có.

## Tham chiếu BA

[05_Content_Task_Workflow.md](../../../BA/05_Content_Task_Workflow.md)
