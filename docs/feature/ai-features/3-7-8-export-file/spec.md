# UC — Export File

| | |
|---|---|
| FR Code | 3.7.8 |
| Feature | Export File |
| Domain | AI Features (FR 3.7) |
| Role | CREATOR |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Export file về máy người dùng sau khi generate, nhiều định dạng — chủ yếu mp4/webM để upload social.

## 2. User Story

Là một Creator,
tôi muốn export file đã generate về máy,
để lưu trữ hoặc upload thủ công lên social media khác.

## 3. Acceptance Criteria

- Chọn định dạng export (ảnh: PNG/JPG; video: mp4/webM).
- Download file trực tiếp, không watermark (trừ khi đã apply watermark trước — FR 3.6.15).

## 4. UI / UX

- Nút 'Export' cạnh kết quả generate (Image/Video).

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
GET /api/v1/ai/assets/{assetId}/export?format=mp4
→ 200 (binary file stream)
```

## 6. Error Handling

- Định dạng không hỗ trợ cho loại asset đó (ví dụ xin export ảnh dưới dạng mp4) → 400 `UNSUPPORTED_EXPORT_FORMAT`.

## 7. Edge Cases

- Không có edge case đặc biệt.

## 8. Definition of Done

- Export đúng định dạng yêu cầu.

## Out of Scope

- Không có.

## Tham chiếu BA

[06_AI_Features.md](../../../BA/06_AI_Features.md)
