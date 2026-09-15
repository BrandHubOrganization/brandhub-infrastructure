# UC — View the Template Media Package

| | |
|---|---|
| FR Code | 3.5.2 |
| Feature | View the Template Media Package |
| Domain | Media Package & Contract (FR 3.5) |
| Role | OWNER/MANAGER/CLIENT |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Cho Client xem các Package mẫu (chiến lược dài/ngắn) để hiểu quy mô triển khai, nhân sự, thời gian book Agency.

## 2. User Story

Là một Client,
tôi muốn xem các gói Media Package mẫu,
để hiểu Agency sẽ triển khai truyền thông cho tôi như thế nào.

## 3. Acceptance Criteria

- Hiển thị chi tiết Package đã chọn cho Workspace này: loại (theo thời gian / theo ngân sách / phó mặc toàn bộ), nội dung mô tả phạm vi công việc.
- 3 kiểu Package:
  - **Theo thời gian**: "Trong X tuần sẽ làm những gì".
  - **Theo ngân sách**: "Với số tiền Y sẽ làm được những gì".
  - **Phó mặc toàn bộ**: Agency tự quyết cách làm, miễn đạt KPI thỏa thuận.

## 4. UI / UX

- Trang `/workspaces/:id/media-package` — Client xem sau khi được Manager invite vào Workspace.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
GET /api/v1/workspaces/{id}/media-package
→ 200 { "success": true, "data": { "id", "type", "scopeDescription", "negotiationStatus" } }
```

## 6. Error Handling

- Client chưa được invite vào Workspace này → 403 `FORBIDDEN`.

## 7. Edge Cases

- Package thuộc loại 'phó mặc toàn bộ' → UI cần làm rõ KPI cam kết cụ thể là gì (field riêng, không chỉ mô tả chung).

## 8. Definition of Done

- Hiển thị đúng loại Package và nội dung mô tả cho Client.

## Out of Scope

- Không có.

## Tham chiếu BA

[04-media-package-campaign.md](../../../BA/04-media-package-campaign.md)
