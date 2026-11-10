# Task — trend-fit (GĐ1)

Nhánh: `brandhub-ai-service` → `feature/trend-fit` (tách từ `feat/ai-features`). Làm theo TDD: test đỏ → code → test xanh.

## ai-service

- [x] T1. `lunar.py` + test ngày Tết/Trung thu 2023–2026.
- [x] T2. `moments_vn.json` (~50 dịp) + `moments.py`: lần xảy ra gần nhất, `active`, `upcoming`; test cửa sổ đăng, moment âm lịch, thứ-trong-tháng (Black Friday, Ngày của Mẹ).
- [x] T3. `trend_formats.json` (format evergreen, có `expire_at`) + `safety.py` + `store.py` (`TrendItem`, tra `trend_id` 3 lớp); test lọc thời sự/nhạy cảm/declining/hết hạn.
- [x] T4. `matching.tier1`: bảng topic↔ngành, chặn taboo; test.
- [x] T5. `matching.judge` + `for_brand` + cache; test parse JSON xấu, id lạ, technique lạ, solemn, fallback, cache hit.
- [x] T6. Endpoint `POST /api/v1/ai/trends/for-brand`; test 401/422/200.
- [x] T7. Caption: `trend_id`, `techniques`, `brand_profile`, `image_urls`, `trend_technique`, `signals.issues`; Gemini multimodal + JSON mode + retry; endpoint async + 404/422; test (7 test cũ vẫn pass).
- [x] T8. `POST /api/v1/ai/content/brand-profile/extract`; test.
- [x] T9. Smoke Gemini thật. Ban đầu là `scripts/smoke_trend_fit.py`; đã xoá (2026-10-20) vì UI Streamlit
      `content-pipeline-ui/pages/1_Trend_fit.py` làm đúng việc này và hiện đủ từng bước.
- [x] T10. Chạy toàn bộ `tests/unit`, ghi kết quả vào `test.md`.

## Nối web chính (GĐ1b)

- [x] T11. business-service: endpoint `trend-fit`, `trendId/techniques` khi tạo caption, `brandProfile()`; test (15/15 pass).
- [x] T12. brandhub-web: `aiCaptionService.ts` + khối `BrandFitTrends` trong `AiCaptionDialog`; `tsc` + `eslint` sạch.
- [x] T13. Cập nhật `vi/aiStudio.json` + `en/aiStudio.json` (khối `trendFit`, key song song).
- [x] T14. Kiểm tra light/dark mode trên trình duyệt (user kiểm, đạt, 2026-10-20).

## Dọn dẹp đã ghi nhận (chưa làm)

- `TrendItem.mood`, `TrendItem.risk` (ai-service) gán nhưng không đọc → bỏ.
- `FitTrend` (BE + kiểu web): 8 field web chưa dùng (`fact`, `insight`, `solemn`, `hashtags`, `relevance`, `voiceFit`, `timing`, `risk`) → bỏ hoặc hiện lên UI.
- Logic xoay 3 format/ngày chép 2 nơi (`store.py`, trang Streamlit) → tách `store.daily_formats(day)`.
- `_VARIANT_TYPES` trùng `_EXPECTED_TYPES` trong `caption_service.py` → gộp.
- `hashtags()` ở BE chỉ gọi `strings()` → gọi thẳng.
- `_extract_json` là hàm riêng của `caption_service.py` nhưng `trend_fit/matching.py` và `profile.py` import → chuyển sang `app/utils`.
- Khóa i18n đang ở `aiStudio.trendFit` nhưng dùng trong hộp caption của editor → chuyển sang `editor.aiCaption.trendFit` khi `editor.json` hết merge dở.
- [x] Code trend-fit ở cả 4 repo đã nằm trên nhánh `feature/trend-fit` (gồm `feat/ai-features` + merge develop), PR vào `develop` (2026-10-20).
- Chưa ai gọi, giữ có chủ đích: `POST /content/brand-profile/extract` (chờ form hồ sơ brand); đường đọc ảnh `image_urls` (chờ web gắn ảnh).
- [x] Bỏ dropdown "Bắt trend" cũ trong hộp caption (user chốt 2026-10-20); web không gửi `trend` nữa.
  Còn lại: 4 key `editor.aiCaption.{trend, noTrend, trendTopic, trendRisk}` không còn dùng → xoá khỏi `vi/editor.json` + `en/editor.json`
  khi hết merge dở; field `Request.trend` ở BE + `trend_context` ở ai-service giữ cho caller cũ (API tương thích ngược).

## Làm sau

- [x] business-service (2026-10-20, chưa commit, nằm trên cây `feat/ai-features` đang merge dở): `GET /api/v1/workspaces/{id}/ai/trend-fit` (không trừ credit); `AiCaptionService.generate` gửi `trend_id/techniques/brand_profile`; trả `trendTechnique` + `signals.issues`. Hồ sơ brand tạm dựng từ workspace (mức ngôn ngữ 1).
- [x] brandhub-web: khối "Trend hợp brand hôm nay" + "Sắp tới" trong `AiCaptionDialog` (i18n `aiStudio.trendFit.*` vi/en, light/dark); chọn trend → gửi `trendId/techniques`; phương án hiện góc nối + cảnh báo.
- [ ] business-service: cột JSONB `brand_profile` + form xác nhận hồ sơ brand trên web (nút "Trích từ tài liệu" gọi `/content/brand-profile/extract`).
- [ ] Web gắn ảnh vào caption (cần nơi lưu media có URL https).
- [ ] Ops: giảm page tin tức trong pool crawl, thêm page giải trí/lifestyle.
- [ ] S3 theo loại kênh (user làm sau, đã chốt 2026-10-20): thêm `channel_type` (`brand` | `meme`) vào `BrandProfile`.
  - `brand`: lọc gắt như hiện tại.
  - `meme`: được dùng drama showbiz, scandal, tranh cãi, tin pháp luật/tội phạm dạng đưa tin.
  - **Luôn chặn, kể cả kênh meme:** đùa trên cái chết/tai nạn có nạn nhân thật; tự tử; xâm hại tình dục, xâm hại trẻ em;
    thiên tai đang có thương vong; chính trị trong nước, lãnh đạo (rủi ro pháp lý theo Luật An ninh mạng).
  - Cần tách `SENSITIVE` thành 2 nhóm (luôn chặn / chỉ chặn với `brand`) và sửa prompt Gemini theo loại kênh.
- [ ] Chốt luật trạng thái S3: dữ liệu thật 2026-10-20 có 11/25 trend `new`, 11/25 `declining`; giữ chỉ `rising/peaking` hay cho `new` vào để Gemini chấm.
- [ ] GĐ2: S2 tự động (phát hiện cụm câu lặp), kịch bản video TikTok.
- [ ] Fine-tune VLM (bake-off Gemma 4 E4B / Qwen3.5-4B) thay lời gọi Gemini ở S10.
