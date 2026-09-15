# UC — View Status Tracking

| | |
|---|---|
| FR Code | 3.8.8 |
| Feature | View Status Tracking |
| Domain | Publishing & Social (FR 3.8) |
| Role | MEMBER |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Theo dõi tiến độ bài làm: Pending, In Progress, Done, Fail.

## 2. User Story

Là một Member,
tôi muốn xem trạng thái publish của bài đăng,
để biết bài đã lên thành công hay gặp lỗi.

## 3. Acceptance Criteria

- 4 trạng thái: `PENDING → IN_PROGRESS → DONE` hoặc `FAIL`.
- Xem transition chi tiết tại [12-state-machines.md](../../../BA/12-state-machines.md) mục 7.

## 4. UI / UX

- Badge trạng thái trong list Post/Dashboard.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
GET /api/v1/workspaces/{id}/posts/{postId}/status
→ 200 { "success": true, "data": { "status", "failReason"? } }
```

## 6. Error Handling

- Không có lỗi đặc biệt.

## 7. Edge Cases

- `FAIL` không tự động retry trong phạm vi CSV hiện tại — cần xác nhận retry-policy khi thiết kế publisher-service kỹ thuật (đã có tiền lệ retry 3 lần exponential backoff ở hệ thống cũ).

## 8. Definition of Done

- Trạng thái hiển thị đúng thời điểm thực tế.

## Out of Scope

- Auto-retry chi tiết (chưa xác nhận chính sách).

## Tham chiếu BA

[07-publishing-social-collaborator.md](../../../BA/07-publishing-social-collaborator.md), [12-state-machines.md](../../../BA/12-state-machines.md)
