# UC — Approve Media Package

| | |
|---|---|
| FR Code | 3.5.4 |
| Feature | Approve Media Package |
| Domain | Media Package & Contract (FR 3.5) |
| Role | OWNER/MANAGER/CLIENT |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Khi Package đã đúng thỏa thuận của cả 2 bên, cả Agency và Client cùng đồng ý — chốt thành 'hợp đồng khung'.

## 2. User Story

Là một Owner/Manager hoặc Client,
tôi muốn xác nhận đồng ý với Media Package đã thương lượng,
để chính thức bắt đầu triển khai.

## 3. Acceptance Criteria

- Cần **CẢ 2 PHÍA xác nhận approve** — `approvedByAgencyAt` VÀ `approvedByClientAt` đều phải có giá trị mới coi Package là `APPROVED` (xem [12-state-machines.md](../../../BA/12-state-machines.md) mục 2).
- 1 bên approve trước, chờ bên còn lại — không tự động approve khi chỉ có 1 phía xác nhận.
- Sau khi `APPROVED` → Package trở thành cơ sở để tạo Media Campaign (FR 3.5.5).

## 4. UI / UX

- Nút 'Đồng ý' riêng cho từng phía trong trang negotiate; hiển thị rõ trạng thái bên nào đã approve, bên nào chưa.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
POST /api/v1/workspaces/{id}/media-package/approve
→ 200 { "success": true, "data": { "negotiationStatus", "approvedByAgencyAt", "approvedByClientAt" } }
```

## 6. Error Handling

- Gọi approve khi Package đang ở trạng thái không hợp lệ để approve (ví dụ chưa có đề xuất nào) → 409 `INVALID_STATE_FOR_APPROVAL`.

## 7. Edge Cases

- 1 bên approve rồi đổi ý muốn negotiate lại trước khi bên kia approve → cho phép hủy approve của chính mình, quay lại trạng thái negotiate.

## 8. Definition of Done

- Approve 2 phía hoạt động đúng, chỉ chuyển `APPROVED` khi đủ cả 2.

## Out of Scope

- Không có.

## Tham chiếu BA

[04-media-package-campaign.md](../../../BA/04-media-package-campaign.md), [12-state-machines.md](../../../BA/12-state-machines.md)
