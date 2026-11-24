# Thiết kế DA-568: Động cơ Phát hiện Đột biến Xu hướng (Temporal Burst & BM25 Pruning)

> [<< Knowledge Base Home](../index.md) · [AI Models & Research](./README.md) · [AI Service Architecture](../architecture/ai-service-architecture.md)

## 1. Tổng quan Hai Vai trò của Thuật toán Phát hiện Đột biến & BM25
Trong `brandhub-ai-service`, mô hình thống kê tần suất từ khóa và Okapi BM25 đảm nhiệm **2 nhiệm vụ tách biệt** ở hai luồng Offline và Online:
1. **Offline Trend Pipeline (`T4_BurstStep` — `app/services/pipeline/steps/t4_burst_step.py`)**: Chấm điểm đột biến đa tín hiệu (**Density Spike + Temporal Velocity + Author/Source Coverage + Multi-Reaction Engagement**) trên tập cụm từ khóa & thực thể tiếng Việt để phát hiện các xu hướng bùng nổ thật sự và sinh chuỗi thời gian (`velocity`, `acceleration`).
2. **Online Hybrid GraphRAG (`BM25 Scoring & Context Pruning`)**: Chấm điểm độ tương quan Okapi BM25 giữa câu truy vấn đã chuẩn hóa của người dùng và các node/chunk thu được từ ChromaDB + Neo4j (1–2 hops) để cắt tỉa 30%–40% ngữ cảnh nhiễu trước khi gửi vào LLM.

---

## 2. Kiến trúc `T4_BurstStep` trong Production (`t4_burst_step.py`)

### 2.1 Mở rộng Cụm từ bằng Khớp Thực thể Chéo (`NER Cross-Post Backfill`)
Đầu vào của `BurstStep` là danh sách `ctx.keyphrases` và `ctx.ner_entities` từ bước `T2_NLPStep`:
- Các thực thể thuộc nhóm `ENTITY_TYPES = {"person", "org", "location", "product", "event"}` có độ dài `>= 3` ký tự (bao gồm cả mã sản phẩm 1 từ như `"vf3"`) nếu được NER nhận diện ở **tối thiểu 2 bài viết độc lập (`posts >= 2`)** sẽ được biên dịch thành biểu thức chính quy ranh giới từ (`(?<!\w)...(?!\w)`).
- Hệ thống quét ngược lại toàn bộ `raw_text` của lô bài đăng để gắn bổ sung thực thể đó vào những bài mà bộ NER bỏ sót. Ngưỡng `posts >= 2` ngăn chặn triệt để lỗi một danh từ phổ thông bị gắn nhầm nhãn thực thể ở 1 bài rồi lan sang hàng trăm bài khác.

### 2.2 Công thức Điểm Đột Biến 4 Tín hiệu (`BurstStep.process`)
Với mỗi cụm từ ứng viên `term` xuất hiện trong ít nhất `MIN_DF = 2` bài đăng, hệ thống gom nhóm số lượng bài theo từng ngày thu thập `cnt = [c_1, c_2, ..., c_k]` và tổng lượng tương tác đa cảm xúc `engagement(item)` (cộng toàn bộ 7 loại reaction `like/love/care/haha/wow/sad/angry` + `shares` + `comments_count`):

$$\text{BurstScore}(t) = 1.0 \cdot \ln(1 + \max(0, \text{Density}(t))) + 0.5 \cdot \text{Velocity}(t) + 0.4 \cdot \text{Coverage}(t) + 0.6 \cdot \ln\left(1 + \frac{\sum \text{Engagement}(t)}{\text{DF}(t)}\right)$$

Trong đó 4 thành phần trọng số thực tế trong code (`DENSITY_W = 1.0`, `VELOCITY_W = 0.5`, `COVERAGE_W = 0.4`, `ENGAGE_W = 0.6`) được định nghĩa như sau:

| Thành phần | Trọng số | Công thức trong `BurstStep` | Ý nghĩa thực tiễn |
| :--- | :---: | :--- | :--- |
| **`_density(cnt)`** | `1.0` | Với chuỗi `>= 3` ngày: Z-score của ngày cao điểm nhất `mx` so với trung bình `mu` và độ lệch chuẩn `sd` của các ngày còn lại `(mx - mu) / sd` (lọc bỏ các từ có `density < MIN_BURST = 1.0`). Dưới 3 ngày dùng `float(max(cnt))`. | Bắt chính xác cú nhảy vọt đột ngột (spike) và loại bỏ các từ khóa phổ biến đều đặn hàng ngày. |
| **`_velocity(cnt)`** | `0.5` | Độ dốc trung bình chuẩn hóa: `((cnt[-1] - cnt[0]) / (len(cnt) - 1)) / (1 + mean(cnt))`. | Phân biệt xu hướng **đang đi lên** (`> 0`) với xu hướng đã qua đỉnh và đang thoái trào (`< 0`). |
| **`_coverage(idxs, items)`** | `0.4` | `ln(1 + unique_authors) + ln(1 + unique_sources)`. | Thưởng điểm cho chủ đề lan tỏa qua nhiều tác giả độc lập và xuất hiện đồng thời trên nhiều nền tảng (`TikTok`, `Facebook`, `Google Trends`). |
| **`eng` (Engagement)** | `0.6` | `ln(1 + eng_sum[term] / df_t)`. | Bắt trúng các trào lưu meme/viral ngắn có ít bài đăng gốc nhưng mỗi bài thu hút hàng chục nghìn lượt thả haha/tim và chia sẻ. |

### 2.3 Kết xuất Chuỗi Thời Gian Động học (`TOP_TS = 50`)
Đối với **Top 50** cụm từ có `BurstScore` cao nhất (`ctx.anomaly_scores`), `BurstStep` tính sẵn đạo hàm bậc 1 (**Velocity**: chênh lệch bài đăng giữa 2 ngày liên tiếp) và đạo hàm bậc 2 (**Acceleration**: gia tốc bùng nổ) lưu vào `ctx.time_series[term]` để truyền sang tầng chấm điểm lan truyền đồ thị Neo4j (`T6`) và hiển thị biểu đồ động lượng trên Dashboard.

---

## 3. Công thức Okapi BM25 cho So sánh Cửa sổ Lịch sử & Cắt tỉa Ngữ cảnh GraphRAG

Bên cạnh `BurstStep` theo chuỗi ngày, công thức **Okapi BM25** chuẩn (`k_1 = 1.5`, `b = 0.75`) được sử dụng khi đối chiếu tập tài liệu mục tiêu $T_{\text{target}}$ với kho nền lịch sử $T_{\text{background}}$ (30 ngày) và khi **cắt tỉa ngữ cảnh GraphRAG (`BM25 Context Pruning`)**:

$$\text{BM25}(D, Q) = \sum_{q_i \in Q} \text{IDF}(q_i, T_{\text{background}}) \cdot \frac{f(q_i, D) \cdot (k_1 + 1)}{f(q_i, D) + k_1 \cdot \left(1 - b + b \cdot \frac{|D|}{\text{avgdl}}\right)}$$

- **Trong luồng Offline (Windowed Anomaly Baseline):** Từ khóa xuất hiện dày đặc trong 30 ngày trước có $\text{IDF}(q_i, T_{\text{background}})$ thấp nên tự động bị triệt tiêu dù có $TF$ cao trong ngày (ví dụ: `"khuyến mãi"`, `"freeship"`).
- **Trong luồng Online (`DA-AI03-04.2` — GraphRAG Pruning):** Sau khi ChromaDB trả về các Entry Points và Neo4j duyệt mở rộng 1–2 bước nhảy (`:KOL`, `:Dish`, `:Location`), mô-đun Pruning tính điểm `BM25(node_context, normalized_user_query)` và loại bỏ các node lân cận dưới ngưỡng tương quan, giữ gói ngữ cảnh gửi sang Groq/Claude gọn nhẹ và chống ảo giác thông tin.
