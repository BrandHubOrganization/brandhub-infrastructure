# UC — Request Media Package

| | |
|---|---|
| FR Code | 3.5.3 |
| Feature | Request Media Package |
| Domain | Media Package & Contract (FR 3.5) |
| Role | OWNER/MANAGER/CLIENT |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Cho phép Client thảo luận lại với Agency về Package mẫu — đưa ra yêu cầu về giá, thời gian, hình thức; Agency phản hồi chấp nhận/từ chối/counter-offer, lặp lại đến khi 2 bên chốt.

## 2. User Story

Là một Client,
tôi muốn đề xuất thay đổi cho Media Package,
để gói truyền thông phù hợp hơn với nhu cầu và ngân sách của tôi.

## 3. Acceptance Criteria

- Client gửi yêu cầu thay đổi: giá, thời gian, sự kiện, hình thức...
- Owner/Manager phản hồi: chấp nhận, từ chối, hoặc counter-offer (đề xuất khác).
- Quá trình lặp lại nhiều vòng (`negotiationStatus` chuyển qua lại `CLIENT_REQUESTED_CHANGE ↔ AGENCY_COUNTERED`, xem [12-state-machines.md](../../../BA/12-state-machines.md) mục 2) — cho đến khi cả 2 bên chốt được gói cuối cùng.

## 4. UI / UX

- Trang `/workspaces/:id/media-package/negotiate` — dạng thread trao đổi (giống comment thread) + form đề xuất field cụ thể.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
POST /api/v1/workspaces/{id}/media-package/request-change
{ "requestedTerms": { "price"?, "duration"?, "format"? }, "note"? }
→ 201 { "success": true, "data": { "id", "negotiationStatus" } }

POST /api/v1/workspaces/{id}/media-package/counter-offer
{ "counterTerms": {...}, "note"? }
→ 201 { "success": true, "data": { "id", "negotiationStatus" } }
```

## 6. Error Handling

- Package đã ở trạng thái `APPROVED` → 409 `PACKAGE_ALREADY_APPROVED`, không cho request thay đổi nữa (phải làm việc trên Media Campaign, FR 3.5.5, thay vì sửa Package đã chốt).

## 7. Edge Cases

- Negotiate qua lại quá nhiều vòng không hồi kết → không có giới hạn số vòng trong CSV, để tự nhiên theo thực tế thương lượng.

## 8. Definition of Done

- Luồng negotiate hoạt động đúng nhiều vòng, lưu lại lịch sử trao đổi.

## Out of Scope

- Giới hạn số vòng negotiate tối đa (không có trong CSV).

## Tham chiếu BA

[04-media-package-campaign.md](../../../BA/04-media-package-campaign.md), [12-state-machines.md](../../../BA/12-state-machines.md)
