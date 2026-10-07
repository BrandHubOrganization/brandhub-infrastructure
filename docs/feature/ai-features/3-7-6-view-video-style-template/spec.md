# UC — View Video Style Template

| | |
|---|---|
| FR Code | 3.7.6 |
| Feature | View Video Style Template |
| Domain | AI Features (FR 3.7) |
| Role | CREATOR |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Tương tự FR 3.7.4 nhưng áp dụng cho LLM gen Video.

## 2. User Story

Là một Creator,
tôi muốn chọn 1 style template video có sẵn,
để tạo video theo phong cách mong muốn nhanh hơn.

## 3. Acceptance Criteria

- List style template cho video (thumbnail/preview clip ngắn), chọn 1 → áp dụng cho Generate Video (FR 3.7.7).

## 4. UI / UX

- Gallery chọn style trong màn Generate Video.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
GET /api/v1/ai/video-style-templates
→ 200 { "success": true, "data": [{ "id", "name", "previewUrl" }] }
```

## 6. Error Handling

- Không có lỗi đặc biệt.

## 7. Edge Cases

- Không có edge case đặc biệt.

## 8. Definition of Done

- Hiển thị đúng danh sách style video.

## Out of Scope

- Không có.

## Tham chiếu BA

[06-ai-features.md](../../../BA/06-ai-features.md)

## Bổ sung khi thiết kế kỹ thuật (2026-10-08)

- Danh mục cố định trong AI service (`app/services/video_styles.py`, chốt 2026-10-04): 8 style (giới thiệu sản phẩm, vlog đời thường, kể chuyện điện ảnh, review UGC, món ăn cận cảnh, lookbook thời trang, giải thích công nghệ, sự kiện sôi động). Mỗi style có tên/mô tả VI-EN, chỉ dẫn góc máy-ánh sáng-nhịp cho Veo, khung hình gợi ý, màu nhận diện.
- API: `GET /api/v1/workspaces/{id}/ai/video-styles` (MANAGER/CREATOR) → AI `GET /api/v1/ai/video/styles`.
- `previewUrl` để trống cho tới khi có clip/ảnh xem trước; gallery hiện ô màu + khung hình. Gắn clip: điền `preview_url` trong catalog.
- Chọn style tự đổi khung hình theo gợi ý; chọn lại để bỏ style.
- **i18n:** `aiStudio.video.*` vi/en. **Light/Dark:** token theme; màu style chỉ là swatch nền có chữ trắng trên nền tối.
