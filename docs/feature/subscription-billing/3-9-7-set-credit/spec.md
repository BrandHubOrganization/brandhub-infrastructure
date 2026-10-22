# UC — Set Credit

> **BA hiện hành 2026-10-19:** Owner cấu hình mức mặc định Agency và hạn mức từng thành viên Manager/Creator; Owner không có hạn mức cá nhân. Đây là trần chi tiêu, không phân bổ ví: tổng trần được vượt quỹ chung, nhưng tổng thực chi không được vượt số dư. Giữ cấu hình qua kỳ subscription, reset usage theo kỳ. Quyết định này thay giới hạn tổng hạn mức/soft warning trong các mục lịch sử dưới đây. Xem [đặc tả hiện hành](../member-credit/spec.md).

| | |
|---|---|
| FR Code | 3.9.7 |
| Feature | Set Credit |
| Domain | Subscription (FR 3.9) |
| Role | OWNER |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Owner đặt hạn mức tiêu credit cho Creator — cơ chế kiểm soát chi phí AI nội bộ Agency.

## 2. User Story

Là một Owner,
tôi muốn đặt hạn mức credit AI cho từng Creator,
để kiểm soát chi phí sử dụng AI trong Agency.

## 3. Acceptance Criteria

- Set `monthlyLimit` cho 1 Creator cụ thể (trong phạm vi tổng credit Agency đang có).
- Creator vượt hạn mức → không generate AI được nữa cho đến tháng sau hoặc được Owner tăng hạn mức.

## 4. UI / UX

- Trang `/agencies/:id/ai-credit`, nút 'Đặt hạn mức' cạnh mỗi Creator.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
PATCH /api/v1/agencies/{id}/ai-credit/{creatorId}/limit
{ "monthlyLimit": number }
→ 200 { "success": true, "data": { "creatorId", "monthlyLimit" } }
```

## 6. Error Handling

- Không phải Owner → 403 `FORBIDDEN`.
- `monthlyLimit` vượt tổng credit Agency hiện có → 400 `LIMIT_EXCEEDS_AGENCY_CREDIT` (cảnh báo, không chặn cứng nếu Owner muốn cho phép vượt tạm thời — quyết định khi thiết kế).

## 7. Edge Cases

- Creator đã dùng vượt hạn mức mới đặt (do trước đó chưa có hạn mức) → không rollback usage cũ, hạn mức mới chỉ áp dụng cho phần dùng tiếp theo.

## 8. Definition of Done

- Đặt hạn mức thành công, Creator bị chặn đúng khi vượt.

## Out of Scope

- Không có.

## Tham chiếu BA

[08-subscription-billing.md](../../../BA/08-subscription-billing.md)
