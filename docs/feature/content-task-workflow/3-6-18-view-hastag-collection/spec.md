# UC — View Hastag Collection

| | |
|---|---|
| FR Code | 3.6.18 |
| Feature | View Hastag Collection |
| Domain | Content & Workflow (FR 3.6) |
| Role | CREATOR, CLIENT |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Kho hashtag riêng cho từng Workspace — Creator tự thêm tự do, Client thêm mang tính đặc thù bắt buộc dùng, AI recommend thêm.

## 2. User Story

Là một Creator hoặc Client,
tôi muốn xem kho hashtag của Workspace,
để tái sử dụng hashtag phù hợp cho bài đăng mới.

## 3. Acceptance Criteria

- List hashtag theo Workspace, phân loại theo mục đích sử dụng (xem FR 3.6.19).
- Hashtag do Client thêm được đánh dấu **bắt buộc dùng** cho sự kiện tương ứng — khác hashtag Creator tự thêm (tùy chọn).
- Có tích hợp gợi ý từ AI (xem [06_AI_Features.md](../../../BA/06_AI_Features.md) FR 3.7.10 Suggest Hashtag Trend).

## 4. UI / UX

- Trang `/workspaces/:id/hashtags`.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
GET /api/v1/workspaces/{id}/hashtags
→ 200 { "success": true, "data": [{ "id", "tag", "purpose", "addedBy", "isRequired" }] }
```

## 6. Error Handling

- Không có quyền truy cập → 403 `FORBIDDEN`.

## 7. Edge Cases

- Không có edge case đặc biệt.

## 8. Definition of Done

- List hiển thị đúng phân loại required/optional.

## Out of Scope

- Không có.

## Tham chiếu BA

[05_Content_Task_Workflow.md](../../../BA/05_Content_Task_Workflow.md)
