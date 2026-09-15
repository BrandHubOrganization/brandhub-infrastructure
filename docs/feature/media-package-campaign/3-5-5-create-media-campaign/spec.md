# UC — Create Media Campaign

| | |
|---|---|
| FR Code | 3.5.5 |
| Feature | Create Media Campaign |
| Domain | Media Package & Contract (FR 3.5) |
| Role | OWNER/MANAGER/CLIENT |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Tạo Media Campaign dựa trên Media Package đã approve — chi tiết hơn, bám sát brand cụ thể của Client. Campaign KHÔNG phải hợp đồng, là chiến lược thực hiện.

## 2. User Story

Là một Owner/Manager,
tôi muốn tạo Media Campaign dựa trên Package đã chốt,
để lên kế hoạch thực thi chi tiết phù hợp brand của Client.

## 3. Acceptance Criteria

- Chỉ tạo được Campaign khi `WorkspaceMediaPackage.negotiationStatus = APPROVED`.
- Nội dung Campaign: chiến lược thực hiện, brand guideline, timeline chi tiết — **KHÔNG phải văn bản hợp đồng**.
- Trạng thái ban đầu: `DRAFT`.

## 4. UI / UX

- Trang `/workspaces/:id/campaigns/create`, chỉ khả dụng sau khi Package approved.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
POST /api/v1/workspaces/{id}/campaigns
{ "name", "strategyDetail", "brandGuideline"?, "timeline"? }
→ 201 { "success": true, "data": { "id", "status": "DRAFT" } }
```

## 6. Error Handling

- Package chưa approved → 409 `PACKAGE_NOT_APPROVED`.

## 7. Edge Cases

- 1 Workspace có thể có nhiều Campaign theo thời gian (Campaign cũ COMPLETED, tạo Campaign mới tiếp theo cho giai đoạn sau) — không giới hạn 1 Campaign/Workspace.

## 8. Definition of Done

- Tạo Campaign thành công, đúng điều kiện tiên quyết Package approved.

## Out of Scope

- Không có.

## Tham chiếu BA

[04-media-package-campaign.md](../../../BA/04-media-package-campaign.md), [12-state-machines.md](../../../BA/12-state-machines.md)
