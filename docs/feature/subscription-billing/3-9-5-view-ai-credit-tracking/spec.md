# UC — View AI Credit Tracking

| | |
|---|---|
| FR Code | 3.9.5 |
| Feature | View AI Credit Tracking |
| Domain | Subscription (FR 3.9) |
| Role | CREATOR, OWNER |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Giám sát lượng credit Creator đã dùng cho tính năng AI trong tháng (tạo ảnh, content, video).

## 2. User Story

Là một Creator hoặc Owner,
tôi muốn xem credit AI đã dùng trong tháng,
để kiểm soát chi phí sử dụng AI.

## 3. Acceptance Criteria

- Creator xem credit CHÍNH MÌNH đã dùng.
- Owner xem tổng hợp credit toàn Agency, breakdown theo từng Creator.
- Breakdown theo loại tính năng: tạo ảnh, tạo content, tạo video (map với FR 3.7.2, 3.7.5, 3.7.7).

## 4. UI / UX

- Trang `/settings/ai-credit` (Creator xem của mình), `/agencies/:id/ai-credit` (Owner xem toàn Agency).

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
GET /api/v1/ai-credit/me?month=2026-09
→ 200 { "success": true, "data": { "used", "limit", "byFeature": {...} } }

GET /api/v1/agencies/{id}/ai-credit?month=2026-09
→ 200 { "success": true, "data": [{ "creatorId", "used", "limit" }] }
```

## 6. Error Handling

- Không có quyền xem credit của Creator khác (chỉ Owner mới xem toàn Agency) → 403 `FORBIDDEN`.

## 7. Edge Cases

- Tháng mới bắt đầu, credit reset — cần xác nhận cơ chế reset hàng tháng hay cộng dồn khi thiết kế kỹ thuật ([11-data-entities-glossary.md](../../../BA/11-data-entities-glossary.md) câu hỏi mở AICreditLedger).

## 8. Definition of Done

- Hiển thị đúng credit đã dùng, breakdown theo feature.

## Out of Scope

- Không có.

## Tham chiếu BA

[08-subscription-billing.md](../../../BA/08-subscription-billing.md)
