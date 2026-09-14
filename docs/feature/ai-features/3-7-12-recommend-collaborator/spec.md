# UC — Recommend Collaborator

| | |
|---|---|
| FR Code | 3.7.12 |
| Feature | Recommend Collaborator |
| Domain | AI Features (FR 3.7) |
| Role | CREATOR |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Gợi ý bên thứ 3 (báo điện tử, trang chạy banner, kênh TV) để Client chọn làm đối tác truyền thông cho chiến dịch — hỗ trợ module Third-party Collaborator.

## 2. User Story

Là một Creator hoặc Manager,
tôi muốn AI gợi ý đối tác truyền thông phù hợp,
để mở rộng chiến dịch ra ngoài social media.

## 3. Acceptance Criteria

- Input: ngành hàng, đối tượng target, ngân sách dự kiến → AI trả về list gợi ý đối tác (báo, banner, TV), có phân cấp option (ưu tiên theo mức độ phù hợp).
- AI chỉ **gợi ý** — không tự động liên hệ hay ký kết. Kết quả gợi ý có thể được **thêm mới vào danh bạ `ThirdPartyCollaborator` cấp Agency**, hoặc **link vào Campaign hiện tại** nếu đối tác đó đã có sẵn trong danh bạ (record `CampaignCollaborator`) — xem [11_Data_Entities_Glossary.md](../../../BA/11_Data_Entities_Glossary.md).

## 4. UI / UX

- Trang `/workspaces/:id/campaigns/:campaignId/recommend-collaborator`.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
POST /api/v1/ai/recommend-collaborator
{ "industry", "targetAudience", "budgetRange" }
→ 200 { "success": true, "data": { "recommendations": [{ "name", "type", "tier", "reason" }] } }

POST /api/v1/workspaces/{id}/campaigns/{campaignId}/collaborators
{ "collaboratorId" (nếu chọn từ danh bạ có sẵn) hoặc "newCollaborator": { "name", "type", "contactInfo" } }
→ 200 { "success": true, "data": { "campaignCollaboratorId", "collaboratorId", "cooperationStatus": "contacted" } }
```

## 6. Error Handling

- Không có lỗi đặc biệt.

## 7. Edge Cases

- Không tìm thấy đối tác phù hợp với ngân sách quá thấp → trả gợi ý ở tier thấp nhất kèm cảnh báo, không trả rỗng hoàn toàn.

## 8. Definition of Done

- Gợi ý đúng, có thể chuyển thành Third-party Collaborator record để theo dõi tiếp.

## Out of Scope

- Tự động liên hệ/ký kết với đối tác (chỉ gợi ý, xem [07_Publishing_Social_Collaborator.md](../../../BA/07_Publishing_Social_Collaborator.md)).

## Tham chiếu BA

[06_AI_Features.md](../../../BA/06_AI_Features.md)
