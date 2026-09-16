# UC — Apply Watermark

| | |
|---|---|
| FR Code | 3.6.15 |
| Feature | Apply Watermark |
| Domain | Content & Workflow (FR 3.6) |
| Role | CREATOR |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Thêm watermark thương hiệu (logo do Client cung cấp) vào ảnh/ấn phẩm đã chỉnh sửa xong, tương tự công cụ img2go.

## 2. User Story

Là một Creator,
tôi muốn thêm watermark thương hiệu vào ảnh,
để đánh dấu bản quyền ấn phẩm trước khi công bố.

## 3. Acceptance Criteria

- Chọn ảnh đã retouched + chọn logo (từ Brand Collection của Client) → apply watermark với vị trí/độ mờ tùy chọn.
- Xuất ra file mới (không overwrite ảnh gốc).

## 4. UI / UX

- Tool nhúng trong Task Detail (loại Post), preview watermark trước khi apply.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
POST /api/v1/workspaces/{id}/materials/{materialId}/watermark
{ "logoAssetId": "string", "position": "string", "opacity": number }
→ 201 { "success": true, "data": { "id", "url" } }
```

## 6. Error Handling

- `logoAssetId` không tồn tại trong Brand Collection → 400 `LOGO_NOT_FOUND`.

## 7. Edge Cases

- Client chưa cung cấp logo nào trong Brand Collection → tool báo rõ cần Client upload logo trước, không cho apply watermark rỗng.

## 8. Definition of Done

- Apply watermark thành công, tạo file mới không phá ảnh gốc.

## Out of Scope

- Watermark cho video (CSV chỉ đề cập ảnh, tương tự img2go — công cụ ảnh).

## Tham chiếu BA

[05-content-task-workflow.md](../../../BA/05-content-task-workflow.md)
