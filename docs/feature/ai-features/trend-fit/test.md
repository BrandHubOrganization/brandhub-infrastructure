# Test — trend-fit (GĐ1)

## 1. Unit (pytest, không mạng; Gemini và Redis đều giả)

| Nhóm | Ca test | File |
|---|---|---|
| Âm lịch | Tết 2023-01-22, 2024-02-10, 2025-01-29, 2026-02-17; Trung thu 2024-09-17, 2025-10-06 (năm có tháng nhuận) | `tests/unit/services/test_trend_fit.py` |
| Moment | 20/10 nằm trong cửa sổ từ 10/10; hết sau ngày đỉnh + tail; Black Friday 2026 = 27/11; `upcoming` 30 ngày | 〃 |
| Lọc S3 | Bỏ `thời_sự`, từ nhạy cảm, `brand_risk=high`, `declining`; giữ `rising/peaking` sạch | 〃 |
| Format | Hết `expire_at` → không có | 〃 |
| Tầng 1 | FNB nhận `ẩm_thực`, không nhận `tài_chính`; taboo chặn; moment sai ngành bị loại | 〃 |
| Tầng 2 | JSON hỏng → fallback `judged=false`; `trend_id` lạ bị bỏ; technique lạ bị lọc; moment trang trọng chỉ `khoanh_khac`; `bo` không trả; cache hit không gọi Gemini lần 2 | 〃 |
| API for-brand | 401 thiếu key; 422 sai `industry`/`voice_level`; 200 đúng shape | `tests/unit/api/test_trend_fit_api.py` |
| Caption | Request cũ không đổi; có trend → prompt chứa trend card + giọng brand + kỹ thuật; `trend_technique` parse; giá trị lạ → `null`; `issues` bắt chữ Hàn/lộ prompt; ảnh → gọi Gemini với `images`; `trend_id` lạ → 404; URL http → 422 | `tests/unit/services/test_caption_service.py`, API test |
| Brand profile | Gemini trả JSON → `BrandProfile`; JSON hỏng → 502 | API test |

## 2. Tích hợp local

1. Redis local + `scripts/dev_seed_trends_from_local.py` để có trend sự kiện thật.
2. Gọi `for-brand` cho 3 brand mẫu khác nhau (FNB mức 2, công nghệ/game mức 3, tài chính mức 0).
3. Kiểm: không có trend thời sự; FinGo không bị gợi ý meme; moment 20/10 có cho FNB.

## 3. Smoke Gemini thật

UI Streamlit `khongpush_gihub_MCP/content-pipeline-ui` (`run.bat` → http://localhost:8502, trang "Trend fit"):
3 brand mẫu, chọn ngày giả lập, nguồn sự kiện (pipeline local / Redis), xem lý do giữ/loại ở từng bước,
prompt + output thô của Gemini, viết 3 caption có upload ảnh. Key Gemini lấy từ env/.env hoặc ô nhập trong phiên.

## 3b. Web chính (GĐ1b)

| Ca test | Mong đợi |
|---|---|
| Mở "Tạo caption AI" trong một workspace | Khối "Trend hợp brand hôm nay" hiện spinner rồi danh sách; dòng "Sắp tới" |
| AI service tắt | Khối hiện "Chưa tải được gợi ý trend."; vẫn tạo caption thường được |
| Bấm 1 thẻ, rồi bấm lại chính thẻ đó | Lần 1 chọn (viền cam), lần 2 bỏ chọn; hộp không còn dropdown "Bắt trend" |
| Tạo caption với thẻ đã chọn | Mỗi phương án có chip "Góc nối: …"; request có `trendId`, `techniques` |
| Tạo caption không chọn trend | Request không có `trendId`, BE không gửi `brand_profile` (test BE) |
| Đổi ngôn ngữ vi ↔ en | Mọi chữ trong khối đổi theo, không hiện key thô, không vỡ bố cục |
| Chuyển light ↔ dark | Nhãn Nên/Cân nhắc, cảnh báo, viền thẻ đọc rõ ở cả 2 theme |

## 4. Người đánh giá

- User gán nhãn tay ~30 cặp brand × trend (Nên/Cân nhắc/Bỏ) → đo tỉ lệ khớp với Gemini. Mục tiêu ≥ 70% khớp,
  0 trường hợp Gemini "Nên" mà người "Bỏ" vì lý do an toàn.
- User đọc caption: đúng giọng/mức ngôn ngữ, bám trend tự nhiên, không bịa số liệu.

## Kết quả

**2026-10-20, nhánh `feature/trend-fit` (brandhub-ai-service):**

- Unit: `test_trend_fit.py` + `test_trend_fit_api.py` + `test_caption_service.py` + `test_llm.py` → 51 passed.
- Toàn bộ `tests/unit`: không có test fail. 27 lỗi collect/fixture có sẵn từ trước, không liên quan (venv thiếu `moto`, `pytest-httpx`; package `scripts` ngoài site-packages che `scripts/` của repo).
- Smoke Gemini thật (lúc đó bằng `scripts/smoke_trend_fit.py`, nay thay bằng UI Streamlit; 3 brand mẫu, chưa có Redis nên 0 trend sự kiện):
  - `gemini-3.1-flash-lite`: 503 / timeout phần lớn lần gọi. `gemini-3.5-flash-lite`: chạy ổn.
  - Tầng chấm: lý do cụ thể theo brand; FinGo (mức 0) nhận 20/10 + mùa cưới, giọng trang trọng.
  - Caption: đúng mức ngôn ngữ (Trà Chill mức 2 có slang, FinGo mức 0 trang trọng), `issues` rỗng, không có số bịa.
  - Ảnh: Gemini đọc đúng ưu đãi in trên ảnh (combo 2 chai 50ml, đơn từ 249K); các số này bị gắn "chưa xác minh" như thiết kế.
- Lỗi tìm ra khi chạy thật và đã sửa: (1) caption có ngoặc kép làm vỡ JSON → bật JSON mode; (2) model chép id `khoanh_khac` thành "khoanh khắc" → cấm trong prompt + `prompt_leak` bắt; (3) `reason` viết như caption → sửa prompt; (4) format evergreen lấn át → 3 format/ngày; (5) in nguyên cặp xưng hô "Cocoon - bạn" → sửa nhãn prompt.
- UI Streamlit + Redis thật (ngày 15/10): 8 trend sự kiện, loại 6 vì thời sự, 1 vì từ nhạy cảm, 1 vì trạng thái `new`.
- Web chính (GĐ1b): BE `AiCaptionServiceTest` 10 + `CaptionContextServiceTest` 2 + `AiTrendControllerTest` 3 → 15 pass;
  web `tsc` + `eslint` sạch; stack chạy lại với code mới (AI :8082, BE :8081 `ddl-auto=validate`, web :3000).
- Mục 3b trên trình duyệt (i18n, light/dark): user kiểm, đạt (2026-10-20).
- Chưa chạy: bộ nhãn tay 30 cặp.
