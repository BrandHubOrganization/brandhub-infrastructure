# UC — Check Copyright Infringement

| | |
|---|---|
| FR Code | 3.6.34 |
| Feature | Check Copyright Infringement |
| Domain | Content & Workflow (FR 3.6) |
| Role | CREATOR, CLIENT |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Check bản quyền hình ảnh, thương hiệu. CSV ghi 'phần này cần làm rõ hơn' — chưa có đặc tả kỹ thuật chi tiết.

## 2. User Story

Là một Creator hoặc Client,
tôi muốn kiểm tra ảnh/logo có vi phạm bản quyền không,
để tránh rủi ro pháp lý khi đăng bài.

## 3. Acceptance Criteria

- **[CÂU HỎI MỞ — CSV ghi rõ 'cần làm rõ hơn']** chưa xác định: check bản quyền dựa trên nguồn nào (reverse image search, database bản quyền cụ thể?), phạm vi check (chỉ ảnh hay cả logo/thương hiệu bên thứ 3 xuất hiện trong ảnh)?
- Tạm định nghĩa AC ở mức tối thiểu: chạy reverse-image-search qua API bên thứ 3, trả cảnh báo nếu tìm thấy ảnh giống ở nguồn có bản quyền công khai.
- Cần Trung làm rõ yêu cầu chi tiết trước khi thiết kế kỹ thuật chính thức.

## 4. UI / UX

- Nút 'Check Copyright' cạnh Check Compliance trong Task Detail.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
POST /api/v1/workspaces/{id}/tasks/{taskId}/copyright-check
→ 200 { "success": true, "data": { "matches": [{ "sourceUrl", "similarityScore" }] } }
```

## 6. Error Handling

- API bên thứ 3 lỗi → 502 `COPYRIGHT_SERVICE_UNAVAILABLE`.

## 7. Edge Cases

- Không tìm thấy match nào → trả `matches: []`.

## 8. Definition of Done

- **[Chưa thể coi Done — cần làm rõ yêu cầu trước]**.

## Out of Scope

- Chưa xác định phạm vi chính xác (xem câu hỏi mở AC).

## Tham chiếu BA

[05-content-task-workflow.md](../../../BA/05-content-task-workflow.md)
