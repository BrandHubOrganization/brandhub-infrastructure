# UC — Create Media Package

| | |
|---|---|
| FR Code | 3.5.1 |
| Feature | Create Media Package |
| Domain | Media Package & Contract (FR 3.5) |
| Role | OWNER/MANAGER |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Cho phép Owner/Manager chọn Package mẫu có sẵn (do Admin tạo) hoặc custom Package mới riêng cho Agency.

## 2. User Story

Là một Owner hoặc Manager,
tôi muốn tạo/chọn Media Package cho Workspace,
để có cơ sở đàm phán với Client về gói truyền thông.

## 3. Acceptance Criteria

- Admin đã tạo sẵn các Package mẫu (2 tuần, 3 tuần...) — Owner/Manager chọn 1 trong số đó, hoặc custom Package mới riêng cho Agency.
- **Thứ tự nghiệp vụ đã confirm**: Workspace được tạo TRƯỚC (FR 3.4.12), Manager chọn Package template NGAY SAU khi tạo Workspace, trước khi mời Client vào (xem [04-media-package-campaign.md](../../../BA/04-media-package-campaign.md) mục 1).
- Nếu Owner/Manager chưa chọn Package khi tạo Workspace → hệ thống gửi thông báo nhắc Manager hoàn thành bước này.
- Template cần dễ tùy chỉnh theo ý Client (không cứng nhắc).
- **Thiết kế DB đề xuất**: tách 2 bảng `MediaPackageTemplate` (Admin tạo) và `MediaPackageCustom` (Owner/Manager tạo) — Workspace chỉ lưu `packageRefId` + `packageRefType` tham chiếu tới 1 trong 2 (xem [11-data-entities-glossary.md](../../../BA/11-data-entities-glossary.md)).

## 4. UI / UX

- Sau khi tạo Workspace, redirect vào bước chọn Package: `/workspaces/:id/media-package/select`.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
GET /api/v1/media-package-templates
→ 200 { "success": true, "data": [{ "id", "name", "type", "durationWeeks", "budgetAmount" }] }

POST /api/v1/workspaces/{id}/media-package
{ "packageRefId": "string", "packageRefType": "template|custom" }
→ 201 { "success": true, "data": { "workspaceMediaPackageId" } }

POST /api/v1/agencies/{id}/media-package-custom
{ "name", "type", "scopeDescription" }
→ 201 { "success": true, "data": { "id" } }
```

## 6. Error Handling

- Chưa chọn Package sau X ngày tạo Workspace → nhắc nhở lặp lại (không block truy cập Workspace, chỉ cảnh báo).

## 7. Edge Cases

- Owner/Manager đổi Package đã chọn TRƯỚC khi mời Client vào (chưa bắt đầu đàm phán) → cho phép đổi tự do; SAU khi Client đã bắt đầu Request thay đổi (FR 3.5.3) → không cho đổi hẳn sang Package khác, chỉ tiếp tục negotiate trên Package hiện tại.

## 8. Definition of Done

- Chọn/tạo Package thành công, thông báo nhắc nhở hoạt động đúng.

## Out of Scope

- Admin tạo Package mẫu — thuộc phạm vi FR khác (Admin Management), FR này chỉ là phía Owner/Manager sử dụng.

## Tham chiếu BA

[04-media-package-campaign.md](../../../BA/04-media-package-campaign.md), [12-state-machines.md](../../../BA/12-state-machines.md)
