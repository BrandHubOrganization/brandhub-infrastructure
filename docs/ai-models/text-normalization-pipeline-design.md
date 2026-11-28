# Thiết kế DA-570: Tiền xử lý văn bản, Lọc Bot/Spam & Chuẩn hóa NLP (T0–T2.5)

> [<< Knowledge Base Home](../index.md) · [AI Models & Research](./README.md) · [AI Service Architecture](../architecture/ai-service-architecture.md)

## 1. Mục tiêu (Objective)
Xây dựng chuỗi tầng tiền xử lý đầu vào (`T0` → `T1` → `T2` → `T2.5`) trong `brandhub-ai-service/app/services/pipeline/` cho hệ thống **Trend Detection & Social Listening (`FR 3.7.15`–`3.7.19`)**:
- **`T0` — Ingestion (`t0_ingest_step.py`)**: Nạp, chuẩn hóa schema đa nguồn (TikTok, Facebook, Google Trends, News) và khử trùng lặp 2 lớp.
- **`T1` — Bot/Clone/Spam Filter (`t1_spam_filter_step.py`)**: Loại bỏ seeding/bot tự động và gắn cờ tương tác ảo trước khi tính toán thống kê.
- **`T2` — NLP & PhoBERT Labeling (`t2_nlp_step.py` — `NLPStep`)**: Làm sạch văn bản tiếng Việt, gán nhãn chủ đề + 7 cảm xúc + thực thể tên riêng (NER) bằng **PhoBERT**, kết hợp khôi phục cụm danh từ riêng (`Np`) qua `underthesea.pos_tag`.
- **`T2.5` — Low-Confidence LLM Disambiguation (`t2_5_label_check_step.py`)**: Kiểm định lại bằng Claude đối với các bài đăng có độ tự tin phân loại chủ đề (`topic_confidence`) thấp từ PhoBERT.

---

## 2. Kiến trúc `T0` — Ingestion (Parse + 2-Layer Deduplication)
**Đầu vào:** Luồng dữ liệu JSON/NDJSON thô từ các adapter cào mạng xã hội (`TikTok`, `Facebook`, `Google Trends`).

**Quy trình xử lý:**
1. **Chuẩn hóa cấu trúc (`RawTrendItem`):**
   - Nội dung gốc (`raw_text` hợp nhất từ `text`, `raw`, `message`, `content`).
   - Định danh tác giả (`author`, `external_id`) và thời điểm thu thập (`crawled_at`).
   - Tương tác chi tiết: Đọc đủ **7 loại Reaction** (`like`, `love`, `care`, `haha`, `wow`, `sad`, `angry` trong `extra_metadata.reactions`), cùng `shares`, `comments_count`, `topComments`, và `extra_metadata.trend_terms` (hashtag/sound gốc từ TikTok).
2. **Khử trùng lặp 2 lớp (Two-Tier Deduplication):**
   - **URL / External ID Dedup:** Loại bỏ ngay các bản ghi trùng chính xác đường dẫn hoặc mã bài đăng.
   - **Normalized Prefix Hash Dedup:** Băm (`SHA-256` / fingerprint) 100 ký tự đầu tiên sau chuẩn hóa để phát hiện bài đăng copy-paste re-share hàng loạt qua nhiều fanpage vệ tinh.

---

## 3. Kiến trúc `T1` — Bot / Clone / Seeding Filter (`KB1`–`KB6`)
**Đầu vào:** Bình luận thô (`topComments`), ID tác giả, dấu thời gian đăng và phân bố cảm xúc gốc (giữ nguyên URL/Emoji trước khi xóa để bắt mẫu spam).

| Quy tắc | Ngưỡng phát hiện | Hành động trong Pipeline |
| :--- | :--- | :--- |
| **`KB1` — Velocity** | Bình luận dài `> 50` ký tự nhưng xuất hiện `< 5 giây` sau khi bài viết lên sóng | **DROP** bình luận (bot auto-reply). |
| **`KB2` — Frequency** | Cùng một `author.id` bình luận trên `> 10` bài viết trong `< 5 phút` | **BLACKLIST** toàn bộ `author.id` trong chu kỳ. |
| **`KB3A` — Brigading** | Tỷ lệ `Comments / Total Reactions > 10` trong khi tổng tương tác `< 20` | **FLAG `anomaly`** (giảm trọng số ở tầng Engagement `T5`, không xóa bài). |
| **`KB3B` — Like-buying** | Tổng tương tác `> 500` nhưng bình luận `< 5` **hoặc** độ đa dạng reaction `< 2` loại | **FLAG `fake_like`** (giảm trọng số ở tầng `T5`). |
| **`KB5` — Coordinated Burst** | `> 5` tài khoản khác nhau bình luận trên 1 bài trong `< 30 giây` với độ đa dạng câu chữ `< 0.3` | **BLACKLIST** cụm tài khoản seeding. |
| **`KB6` — Organic Cross-Post** | Cùng một cụm từ/câu có nghĩa xuất hiện tự nhiên bởi nhiều người dùng độc lập trên nhiều bài khác nhau | **BOOST `trendSignals[]`** cho tầng tính điểm đột biến `T4` & đồ thị `T6`. |

---

## 4. Kiến trúc `T2` & `T2.5` — NLP Preprocessing, PhoBERT & `Np` Recovery (`t2_nlp_step.py`)

Trong mã nguồn thực tế (`app/services/pipeline/steps/t2_nlp_step.py`), class `NLPStep` thực thi song song làm sạch ngôn ngữ, suy luận mô hình ngôn ngữ tiếng Việt **PhoBERT**, và trích xuất cụm danh từ riêng:

### 4.1 Chuỗi làm sạch văn bản tiếng Việt (`NLPStep._process_sync`)
1. **Loại bỏ nhiễu cấu trúc:** Xóa URL (`http\S+`), thẻ HTML (`<[^>]+>`), và chuỗi hashtag dính liền (`#\S+` — các hashtag quan trọng đã được adapter bảo toàn riêng trong `extra_metadata["trend_terms"]`).
2. **Bảo toàn bảng chữ cái Tiếng Việt đầy đủ (`_VN_ALL`):** Chỉ giữ ký tự chữ-số và tập nguyên âm có dấu tiếng Việt (`àáảãạăắằẳẵặâấầẩẫậ...ỳýỷỹỵđ` cả hoa lẫn thường), chuẩn hóa khoảng trắng và chuyển về lowercase lưu vào `ctx.cleaned_texts`.
3. **Từ điển Stopwords & Slang (`DictionaryLoader` & `generic_phrase`):** Nạp bộ từ dừng tiếng Việt (`DictionaryLoader.get_stopwords()`) và bộ lọc cụm từ chung chung (`app/services/pipeline/quality.py:generic_phrase`) để loại bỏ các danh từ báo chí lặp lại ngày nào cũng có (như `"khu vực"`, `"giá trị"`, `"thời gian"`).

### 4.2 Gán nhãn đa tác vụ bằng PhoBERT (`label_posts`) & Hậu kiểm Claude (`T2.5`)
- Hàm `label_posts(texts)` (`app/services/pipeline/llm_label.py` & `phobert.py`) trả về đồng thời 6 đầu ra cho toàn bộ lô bài viết:
  - `topics` & `topic_probs`: Chủ đề ngành hàng và độ tự tin `ctx.topic_confidence[external_id]` (nếu nguồn TikTok đã gắn sẵn `extra_metadata["topic"]` thì ưu tiên nhãn gốc của adapter). Các bài có `topic_confidence` thấp sẽ được bước `T2.5` (`LabelCheckStep`) gửi sang Claude phân loại lại.
  - `emotions` & `emotion_probs`: Phân phối xác suất trên `EMOTION_LABELS` lưu vào `ctx.emotion_dists[external_id]`.
  - `entities` (`ctx.ner_entities`) & `keyphrases`: Thực thể định danh (người, tổ chức, địa điểm, sản phẩm, sự kiện) và cụm từ khóa ứng viên.

### 4.3 Khôi phục Cụm Danh Từ Riêng bằng `underthesea.pos_tag` (`extract_noun_phrases`)
Vì bộ NER đôi khi bỏ sót tên sản phẩm mới, tên đội tuyển hoặc địa danh check-in viết hoa, `t2_nlp_step.py` chạy thêm bước quét POS-tag có bộ nhớ đệm `@functools.lru_cache(maxsize=4096)` trên **400 ký tự đầu giữ nguyên chữ hoa/thường gốc**:
- Chỉ trích xuất các token mang nhãn **`Np` (Proper Noun)** ghép từ 2 âm tiết trở lên (`_NOUN_PHRASE_RE`), không nằm trong `stopwords` và không vi phạm `generic_phrase()`.
- Ghép hợp nhất không trùng lặp theo thứ tự: `labeled_phrases` (PhoBERT) → `extract_noun_phrases()` (`underthesea` `Np`) → `extra_metadata["trend_terms"]` (TikTok hashtags/sounds), đồng thời lưu tập từ gốc tên riêng vào `ctx.proper_nouns` để cộng điểm ưu tiên ở bước xếp hạng cuối (`T7`).

---

## 5. Chuẩn hóa & Cắt nhỏ Tài liệu Tri thức Thương hiệu (Brand RAG Chunking)
Đối với luồng nạp tài liệu thương hiệu (`FR 3.7.1`–`3.7.2`) và bài viết chi tiết của Top Trends vào ChromaDB (`client_{clientId}`):
- Văn bản sau khi chuẩn hóa Unicode `NFC` và từ viết tắt mạng xã hội (`ko` → `không`, `sp` → `sản phẩm`, `đc` → `được`) được chia nhỏ bằng `RecursiveCharacterTextSplitter` với **`chunk_size = 500`**, **`chunk_overlap = 50`**, ưu tiên cắt tại ranh giới đoạn `\n\n`, xuống dòng `\n`, dấu kết câu `.` / `!` / `?` để không làm đứt ngữ nghĩa câu tiếng Việt trước khi sinh vector nhúng `384` chiều.
