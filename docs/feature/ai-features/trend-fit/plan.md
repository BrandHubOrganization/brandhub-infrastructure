# Plan — trend-fit (GĐ1)

## Kiến trúc

```
moments_vn.json ─► moments.py (lunar.py) ─┐
trend_formats.json ─► formats             ├─► store.py: TrendItem (3 lớp, tra theo trend_id)
Redis trends:v2:{date}:{cat} ─► safety.py ┘            │
                                                       ▼
BE: brand profile ─► POST /ai/trends/for-brand ─► matching.py
                                                   tier1 (luật, chặn cứng) ─► top 20
                                                   tier2 (Gemini 1 call, JSON) ─► cache Redis
                                                       │
web chọn trend ─► BE ─► POST /ai/content/captions/generate {trend_id, techniques, brand_profile, image_urls}
                          └► store.get(trend_id) → trend card → caption_service → Gemini (kèm ảnh) → 3 variants
```

## Module mới — `app/services/trend_fit/`

| File | Trách nhiệm | Phụ thuộc |
|---|---|---|
| `lunar.py` | Đổi âm lịch → dương lịch (thuật toán Hồ Ngọc Đức, múi giờ +7). Không thêm thư viện. | stdlib `math`, `datetime` |
| `moments.py` | Đọc `moments_vn.json`; tính lần xảy ra gần nhất; `active(day)` và `upcoming(day, 30)` → `TrendItem` | `lunar.py` |
| `safety.py` | `SENSITIVE` (+V3) copy từ bộ lọc dataset; `event_allowed(candidate)` | `re` |
| `store.py` | `TrendItem`; `formats(day)`; `events(day)` từ `TrendCacheService`; `get(trend_id, day)` | moments, safety, Redis |
| `matching.py` | `tier1(items, brand)`; `judge(brand, items)` gọi Gemini; `for_brand(...)` + cache | llm_service, Redis |

Model Pydantic mới đặt tại `app/models/trend_fit_models.py`: `BrandProfile`, `TrendItem`, `TrendMatch`,
`TrendForBrandRequest/Response`, `BrandProfileExtractRequest`, `TECHNIQUES`.

## Định dạng `trend_id`

| Lớp | Mẫu | Tra cứu |
|---|---|---|
| moment | `moment:{id}:{peak YYYY-MM-DD}` | tính lại từ JSON |
| format | `format:{id}` | JSON, kiểm `expire_at` |
| event | `trend:{date}:{category}:{slug}` (đã có ở pipeline) | `HGET trends:v2:{date}:{category}:data` rồi tới key `live` |

## Tầng 1 (S6)

- Bảng `TOPIC_FIT[topic][industry]` ∈ {0,1,2} cho 12 topic PhoBERT × 10 ngành. `OTHER` = 1 cho mọi topic.
- Moment: hợp nếu `industries` chứa ngành của brand hoặc `*`.
- Format: điểm 1 (dùng được mọi ngành trừ khi format ghi `industries`).
- Chặn cứng: `taboos` của brand xuất hiện trong text trend; trend sự kiện không qua `safety.event_allowed`.
- Xếp: điểm hợp → moment đang ở cửa sổ đỉnh → `final_score` của sự kiện. Lấy 20.
- shortcut: chưa có embedding brand↔trend; thêm khi luật bỏ sót nhiều (đo bằng bộ nhãn tay ở test.md).

## Tầng 2 (S7) — Gemini JSON mode, retry 429/5xx

- 1 lần gọi Gemini cho cả ≤20 ứng viên → JSON `{"items":[{trend_id, relevance, voice_fit, timing, risk, verdict, reason, techniques}]}`.
- Kiểm hậu kỳ: bỏ `trend_id` lạ; verdict ngoài enum → bỏ item; techniques lọc theo enum, tối đa 2;
  moment `solemn` ép techniques = `["khoanh_khac"]`.
- Xếp: `nen` trước `can_nhac`, rồi tổng `relevance + voice_fit + timing - risk`.
- Cache: `trendfit:{client_id}:{date}:{sha1(brand)[:12]}`, TTL 24h. Đổi hồ sơ → hash khác → chấm lại.
- Lỗi (`LLMQualityError`, `httpx.HTTPError`, `RuntimeError` chưa init client) → fallback tầng 1, `judged=false`.

## Viết bài (S9–S11)

- Endpoint `/captions/generate` thành `async`: nếu có `trend_id` thì `await store.get(...)`, rồi chạy
  `generate_caption_variants(request, trend)` trong threadpool (giữ nguyên code sync hiện có).
- Prompt thêm 4 khối khi có dữ liệu: **trend card**, **giọng brand** (mức ngôn ngữ + xưng hô + emoji + fan + sự thật + điều cấm),
  **5 kỹ thuật** (định nghĩa 1 dòng mỗi kỹ thuật, ưu tiên `techniques` từ for-brand), **luật** (prompt user > giọng brand;
  fact chỉ từ brand/trend/prompt/ảnh; moment trang trọng: không đùa, không khuyến mãi).
- JSON mỗi variant thêm `"trend_technique"`. Giá trị lạ → `null` (không fail cả response).
- Ảnh: `GeminiClient.generate(prompt, images=())` gửi `inlineData`; `llm_service.generate_text(..., images=())`
  có ảnh thì đi thẳng Gemini (Groq không đọc ảnh).
- `signals.issues`: `foreign_script` (Hangul/CJK/Thái), `prompt_leak`, `sensitive`, `too_long`. Chạy cho cả refine/adapt.
- Khi có fine-tune model (GĐ sau): thay đúng lời gọi `llm_service.generate_text` trong `caption_service`,
  gọi 3 lần/1 kỹ thuật như thiết kế S10 — schema response không đổi.

## Hồ sơ brand (S5)

- `POST /api/v1/ai/content/brand-profile/extract`: `knowledge_chunks(client_id, ...)` (đã có) + mô tả/website → Gemini → `BrandProfile`.
- BE lưu (JSONB) và web cho user sửa/xác nhận: **chưa làm** (repo BE/web đang dở việc khác).

## Nối vào web chính (GĐ1b)

| Repo | File | Thay đổi |
|---|---|---|
| business-service | `controller/AiCaptionController.java` | `GET /workspaces/{id}/ai/trend-fit` |
| business-service | `service/ai/AiCaptionService.java` | `trendFit()`; `Request.trendId/techniques`; map `trend_technique`, `signals.issues` |
| business-service | `service/ai/CaptionContextService.java` | `brandProfile()` dựng từ workspace |
| business-service | `test/.../AiCaptionServiceTest.java`, `CaptionContextServiceTest.java` | test mới |
| brandhub-web | `services/aiCaptionService.ts` | kiểu `FitTrend`, `TrendFit`; `trendFit()`; `trendId/techniques` |
| brandhub-web | `components/ai/AiCaptionDialog.tsx` | khối `BrandFitTrends`; chip góc nối + `issues` |
| brandhub-web | **`i18n/locales/vi/aiStudio.json`, `i18n/locales/en/aiStudio.json`** | khối `trendFit` |

Công cụ test ngoài dự án (không push): `khongpush_gihub_MCP/content-pipeline-ui/pages/1_Trend_fit.py` (Streamlit,
xem từng bước S1→S11, duyệt S1/S2), `run_api.bat` (API cổng 8090 cho Swagger).

## Rủi ro

| Rủi ro | Giảm thiểu |
|---|---|
| Gemini chấm sai/thiên vị | Bộ nhãn tay 30 cặp đo độ khớp; luật chặn cứng chạy trước LLM |
| Trend sự kiện ít vì luật `rising/peaking` gắt | Đo số trend còn lại trên dữ liệu thật; nới sang `new` nếu cần (1 dòng) |
| Format/meme hết hot | `expire_at` bắt buộc; người duyệt hằng tuần |
| Ngày âm lịch sai | Test với Tết/Trung thu đã biết các năm 2023–2026 |
| Free tier Gemini dùng dữ liệu để train | Production dùng key trả phí |
