# Spec — trend-fit (GĐ1: chọn trend hợp brand + viết bài theo trend)

> Nguồn thiết kế đã duyệt: `khongpush_gihub_MCP/docs/trend-fit/TREND_FIT_FLOW.md` (S1–S11).
> GĐ1 chạy bằng **Gemini API**, chưa fine-tune. Model fine-tune có đọc ảnh là GĐ sau (thay đúng 1 chỗ gọi LLM).

## Objective

BrandHub gợi ý **trend hợp với từng brand** (không chạy theo bản tin thời sự) và viết 3 phương án bài
đăng bám trend đó, đúng giọng brand, đúng mức ngôn ngữ (0 trang trọng → 3 teencode), có thể đọc ảnh user gắn.

## User Story

- Là Creator, tôi mở "Trend cho brand bạn" và thấy danh sách trend xếp hạng, mỗi trend có nhãn
  **Nên / Cân nhắc**, lý do 1 câu và 1–2 góc nối gợi ý; kèm danh sách **moment sắp tới 30 ngày**.
- Tôi chọn 1 trend, gõ prompt, gắn ảnh (tuỳ chọn) → nhận 3 phương án, mỗi phương án ghi rõ dùng kỹ thuật bắt trend nào.

## Phạm vi GĐ1 (repo `brandhub-ai-service`)

| Bước | Làm gì | Ở đâu |
|---|---|---|
| S1 | Lịch moment VN (~50 dịp), tính ngày âm lịch bằng thuật toán, cửa sổ đăng | `app/data/moments_vn.json` + `trend_fit/moments.py` |
| S2 tối thiểu | Thư viện format/meme do người nhập, có hạn dùng; mỗi ngày chỉ đưa 3 format (xoay vòng) vào danh sách chấm | `app/data/trend_formats.json` |
| S3 | Lọc trend sự kiện của pipeline AI-05 **lúc đọc**: bỏ `thời_sự`, nhạy cảm, `brand_risk=high`; chỉ giữ `rising`/`peaking` | `trend_fit/safety.py` |
| S4 | Schema chung `TrendItem` cho 3 lớp + tra cứu theo `trend_id` | `trend_fit/store.py` |
| S5 | Trích hồ sơ giọng brand từ tài liệu RAG bằng Gemini (user xác nhận ở BE/web) | `POST /api/v1/ai/content/brand-profile/extract` |
| S6 | Tầng 1: luật topic↔ngành, chặn cứng điều cấm/nhạy cảm, lấy top 20 | `trend_fit/matching.py` |
| S7 | Tầng 2: Gemini chấm 1 lần/brand/ngày, cache Redis | `trend_fit/matching.py` |
| S9–S10 | `/captions/generate` nhận `trend_id`, `brand_profile`, `techniques`, `image_urls`; mỗi phương án có `trend_technique` | `caption_service.py` |
| S11 | Kiểm tra nhẹ: lẫn chữ nước ngoài, lộ prompt, từ nhạy cảm, quá dài | `CaptionSignals.issues` |

**Phạm vi GĐ1b (nối vào web chính, thêm ngày 2026-10-20):**

| Bước | Làm gì | Ở đâu |
|---|---|---|
| S8 | Khối "Trend hợp brand hôm nay" + "Sắp tới" trong hộp tạo caption AI | brandhub-web `AiCaptionDialog` |
| S5 tạm | Hồ sơ brand dựng từ workspace (tên, ngành, slogan, mô tả), mức ngôn ngữ 1, emoji `few` | business-service `CaptionContextService.brandProfile` |
| S6–S7 | `GET /api/v1/workspaces/{workspaceId}/ai/trend-fit` gọi `for-brand` | business-service `AiCaptionController` |
| S9–S11 | Chọn trend → gửi `trendId` + `techniques`; BE thêm `brand_profile`; hiện góc nối + cảnh báo | BE `AiCaptionService` + web |

**Ngoài phạm vi (làm sau):** form xác nhận hồ sơ brand + cột JSONB (khi đó mới gọi `brand-profile/extract`),
gắn ảnh trên web, S2 tự động, kịch bản video TikTok, S12–S13, embedding ở tầng 1, fine-tune.

**Không đổi pipeline AI-05.** Lọc S3 chạy lúc đọc cho trend-fit nên trang Trend chung vẫn thấy đủ trend như cũ.

## Acceptance Criteria

- [ ] `POST /api/v1/ai/trends/for-brand` trả `trends` (chỉ Nên/Cân nhắc, đã xếp hạng) + `upcoming` (moment 30 ngày tới) + `judged`.
- [ ] Thiếu/sai `X-Internal-Key` → **401**; body sai schema → **422**.
- [ ] Trend `thời_sự`, khớp từ nhạy cảm, `brand_risk=high`, `declining`, hết hạn, chạm `taboos` của brand → **không bao giờ** xuất hiện.
- [ ] Moment trang trọng (30/4, 2/9, 27/7, Vu Lan, Giỗ Tổ…) chỉ được gợi ý kỹ thuật `khoanh_khac`.
- [ ] Gemini lỗi → vẫn trả kết quả tầng 1 với `judged=false`, **không 5xx**, không cache kết quả fallback.
- [ ] Gọi lại cùng brand + cùng ngày + cùng hồ sơ → lấy cache, không gọi Gemini lần 2.
- [ ] `/captions/generate` request cũ (không có field mới) chạy y như trước (7 test cũ pass).
- [ ] Có `trend_id` → prompt chứa trend card đầy đủ; `trend_id` không tồn tại/hết hạn → **404**.
- [ ] Mỗi phương án trả `trend_technique` ∈ 5 kỹ thuật (hoặc `null` khi không dùng trend).
- [ ] Có `image_urls` → gọi Gemini kèm ảnh (multimodal); URL không phải https hoặc tải lỗi → **422**.
- [ ] `POST /api/v1/ai/content/brand-profile/extract` trả bản nháp `BrandProfile` hợp lệ; Gemini lỗi → **502**.
- [ ] Không ghi API key vào file nào; key chỉ đọc từ env.

## API Contract

### `POST /api/v1/ai/trends/for-brand`

Header `X-Internal-Key`. BE gửi hồ sơ brand trong body (ai-service không giữ hồ sơ).

```json
{
  "client_id": "ws-123",
  "date": "2026-10-20",
  "limit": 10,
  "brand": {
    "name": "Trà Chill",
    "industry": "FNB",
    "description": "Chuỗi trà sữa cho sinh viên",
    "audience": "Sinh viên 18-24, TP.HCM",
    "voice_level": 2,
    "pronoun": "tụi mình - mấy bà",
    "emoji": "many",
    "fan_name": "Hội Chill",
    "product_facts": ["Trà sữa nướng", "Topping tự chọn"],
    "taboos": ["đối thủ", "giảm cân"]
  }
}
```

- `industry` ∈ `FNB, FASHION, BEAUTY, TECHNOLOGY, REAL_ESTATE, EDUCATION, HEALTHCARE, SERVICES, RETAIL, OTHER` (khớp `WORKSPACE_INDUSTRIES` của web).
- `voice_level`: 0 trang trọng · 1 thân thiện · 2 slang Gen Z · 3 teencode.
- `date` mặc định hôm nay (giờ VN); `limit` 1–20, mặc định 10.

**Response 200:**

```json
{
  "date": "2026-10-20",
  "judged": true,
  "trends": [
    {
      "trend": {"trend_id": "moment:20-10:2026-10-20", "type": "moment", "name": "Ngày Phụ nữ Việt Nam 20/10",
                "fact": "...", "start": "2026-10-10", "peak": "2026-10-20", "end": "2026-10-20",
                "insight": "...", "hashtags": ["#20thang10"], "solemn": false, "...": "..."},
      "verdict": "nen",
      "scores": {"relevance": 5, "voice_fit": 4, "timing": 5, "risk": 1},
      "reason": "Khách nữ sinh viên, dịp tặng quà, trà sữa là quà nhỏ dễ mua.",
      "techniques": ["khoanh_khac", "brand_la_fan"]
    }
  ],
  "upcoming": [{"trend_id": "moment:halloween:2026-10-31", "type": "moment", "...": "..."}]
}
```

- `verdict` ∈ `nen | can_nhac` (trend bị chấm `bo` không trả về). Khi `judged=false`: `verdict`, `scores`, `reason` = `null`, `techniques` = `[]`.
- `techniques` ⊂ `khoanh_khac, choi_chu, muon_format, muon_bieu_tuong, brand_la_fan` (tối đa 2).
- `risk` trong `scores`: 1 = an toàn, 5 = rủi ro cao.

### `POST /api/v1/ai/content/captions/generate` (mở rộng, tương thích ngược)

Field mới, đều tuỳ chọn:

| Field | Kiểu | Ghi chú |
|---|---|---|
| `trend_id` | string ≤200 | Lấy từ `for-brand`. ai-service tự tra trend card. |
| `techniques` | list ≤3 của 5 kỹ thuật | Góc nối từ `for-brand`; trống → model tự chọn. |
| `brand_profile` | `BrandProfile` (như trên) | Giọng, mức ngôn ngữ, xưng hô, emoji, tên fan, sự thật sản phẩm, điều cấm. |
| `image_urls` | list ≤3, https | Ảnh user gắn; ai-service tải (≤5 MB, jpeg/png/webp) rồi gửi Gemini. |

- `topic` vẫn là prompt của user. **Prompt của user > giọng brand** (user đòi teencode thì viết teencode).
- Có `trend_id` / `brand_profile` / `image_urls` → gọi **Gemini** (`provider="gemini"`); request cũ giữ provider mặc định.
- Response: mỗi `variant` thêm `trend_technique` (nullable); `signals.issues` (list mã: `foreign_script`, `prompt_leak`, `sensitive:<từ>`, `too_long`).
- Số đọc từ ảnh (giá, dung tích) không nằm trong nguồn văn bản nên bị gắn vào `unverified_claims` → user phải soát. Đây là chủ ý.
- Vẫn đúng 3 `variant_type` HOOK_DRIVEN / STORYTELLING / DIRECT_CTA (**ghép 2 lớp** đã duyệt: mỗi type gắn thêm 1 kỹ thuật).

### `POST /api/v1/ai/content/brand-profile/extract`

```json
{"client_id": "ws-123", "name": "Trà Chill", "industry": "FNB", "description": "...", "website_text": "..."}
```

→ 200 `BrandProfile` (bản nháp để user sửa/xác nhận). Lấy ngữ cảnh từ knowledge base (RAG) của `client_id`.

### business-service (web gọi)

`GET /api/v1/workspaces/{workspaceId}/ai/trend-fit` — vai trò MANAGER, CREATOR; **không trừ AI credit**
(ai-service chấm 1 lần/brand/ngày rồi cache).

```json
{"data": {"date": "2026-10-20", "judged": true,
  "trends": [{"trendId": "moment:phu-nu-viet-nam:2026-10-20", "type": "moment", "name": "Ngày Phụ nữ Việt Nam 20/10",
              "peak": "2026-10-20", "verdict": "nen", "reason": "...", "techniques": ["khoanh_khac"], "...": "..."}],
  "upcoming": [{"trendId": "moment:halloween:2026-10-31", "name": "Halloween 31/10", "peak": "2026-10-31", "...": "..."}]}}
```

`POST /api/v1/workspaces/{workspaceId}/ai/captions` nhận thêm `trendId` (≤200) và `techniques` (≤3, 5 kỹ thuật).
Có `trendId` thì BE gửi kèm `brand_profile`. Mỗi caption trả thêm `trendTechnique`; `signals.issues`.

## UI/UX (brandhub-web, hộp "Tạo caption AI")

- Khối **"Trend hợp brand hôm nay"** nằm dưới hàng chọn giọng điệu/nền tảng/độ dài: tối đa 6 thẻ, mỗi thẻ có
  nhãn Nên/Cân nhắc, loại (Dịp/Format/Sự kiện), ngày đỉnh, lý do, góc nối. Dòng **"Sắp tới: …"** liệt kê tối đa 5 moment.
- Bấm thẻ để chọn, bấm lại để bỏ; mỗi lần 1 trend. **Dropdown "Bắt trend" cũ (trend thô FR 3.7.1) đã bỏ**
  (user chốt 2026-10-20): nó cho chọn cả trend thời sự, trái mục tiêu "trend hợp brand". Trang Trend FR 3.7.1 giữ nguyên.
- Mỗi phương án hiện chip **"Góc nối: …"** và cảnh báo `issues` (nền vàng như cảnh báo số chưa xác minh).
- **Trạng thái:** đang tải (spinner + chữ) · lỗi (chữ mờ, dialog vẫn dùng được) · rỗng · `judged=false`
  ("AI chưa chấm được, đang xếp theo luật ngành", thẻ không có nhãn Nên/Cân nhắc).
- **i18n** (key song song trong `vi/aiStudio.json` và `en/aiStudio.json`, không chuỗi cứng trong JSX):
  `aiStudio.trendFit.{title, notJudged, loading, error, empty, upcoming, techniqueLabel}`,
  `aiStudio.trendFit.verdict.{nen, can_nhac}`, `aiStudio.trendFit.type.{moment, format, event}`,
  `aiStudio.trendFit.techniques.{khoanh_khac, choi_chu, muon_format, muon_bieu_tuong, brand_la_fan}`,
  `aiStudio.trendFit.issues.{foreign_script, prompt_leak, sensitive, too_long}`.
  shortcut: key để ở `aiStudio` vì `editor.json` đang nằm trong merge dở; chuyển sang `editor.aiCaption.trendFit` sau.
- **Light/Dark:** chỉ dùng token sẵn có (`border-border`, `bg-muted`, `text-muted-foreground`, `brand-orange`) và
  màu trạng thái có cặp `dark:` (`emerald`/`amber` như trang Trend FR 3.7.1). Không thêm token, không mã màu cứng.

## Error Handling

| Tình huống | Kết quả |
|---|---|
| Sai key | 401 |
| Body sai | 422 |
| `trend_id` không có/hết hạn | 404 `Trend not found or expired` |
| Ảnh không https / tải lỗi / sai loại / >5 MB | 422 |
| Gemini lỗi ở `for-brand` | 200, `judged=false`, kết quả tầng 1 |
| Gemini lỗi ở captions / brand-profile | 502 (như hành vi hiện có) |
| Redis lỗi khi đọc trend sự kiện | bỏ lớp sự kiện, vẫn trả moment + format |
| BE không gọi được `for-brand` | `AI_SERVICE_UNAVAILABLE`; web hiện "Chưa tải được gợi ý trend.", vẫn viết caption được |

## Bảo mật

- Mọi endpoint mới cần `X-Internal-Key` (chỉ BE gọi).
- `image_urls` chỉ chấp nhận `https://`; không theo redirect; giới hạn 5 MB.
  shortcut: chưa có allowlist host — thêm khi BE chốt nơi lưu media (S3/CDN).
- Gemini gọi ở **JSON mode** (`responseMimeType: application/json`) và tự thử lại 2 lần khi 429/5xx.
- Model lấy từ env `GEMINI_MODEL` (mặc định `gemini-3.1-flash-lite`). Ngày 2026-10-20 bản 3.1 trả 503/timeout liên tục; `gemini-3.5-flash-lite` chạy ổn. `gemini-2.5-flash-lite` trả 404.
- Gemini key chỉ đọc từ env `GEMINI_API_KEY`. Lưu ý: free tier của Gemini dùng dữ liệu để train → production dùng gói trả phí.
