# Thiết kế DA-568: Trend Prediction với BM25 Anomaly Detection

## 1. Luồng xử lý NLP Tiếng Việt với `underthesea`

**Mục tiêu:** Làm sạch dữ liệu văn bản thô (comments, posts) và tách từ (word segmentation) để chuẩn bị cho bước trích xuất đặc trưng.

**Các bước thực hiện:**
1. **Tiền xử lý cơ bản (Basic Preprocessing):**
   - Loại bỏ HTML tags, URLs, ký tự đặc biệt, dấu câu và emoji.
   - Chuyển đổi toàn bộ văn bản về chữ thường (lowercase).
   - Chuẩn hóa Unicode (ví dụ: chuyển từ dạng tổ hợp sang dựng sẵn NFC) để tránh lỗi khi so sánh chuỗi tiếng Việt.
2. **Phân tích cú pháp Tiếng Việt (Word Segmentation):**
   - Sử dụng hàm `word_tokenize` từ thư viện `underthesea` (tham số `format="text"`).
   - Ví dụ: `"Điện thoại này chụp ảnh đẹp quá"` $\rightarrow$ `"Điện_thoại này chụp ảnh đẹp quá"`. Việc ghép các âm tiết có nghĩa giúp cải thiện độ chính xác cho việc tính toán TF-IDF và BM25 sau này.
3. **Loại bỏ Stopwords (Stopword Removal):**
   - Dùng một danh sách stopword tiếng Việt chuẩn (chứa các từ như: "là", "và", "của", "thì", "mà",...) để loại bỏ các từ không mang nhiều giá trị thông tin.
4. **Chuẩn hóa từ vựng (Từ lóng/Viết tắt):**
   - Xây dựng từ điển map các từ viết tắt phổ biến trên mạng xã hội (vd: "ko" $\rightarrow$ "không", "sp" $\rightarrow$ "sản phẩm", "đc" $\rightarrow$ "được").

## 2. Áp dụng thuật toán BM25 Anomaly Detection

**Mục tiêu:** Phát hiện sự gia tăng đột biến của các từ khóa (keywords) trong một khoảng thời gian ngắn hiện tại so với dữ liệu lịch sử, từ đó lọc ra top 100 trending keywords.

**Cơ chế hoạt động:**
1. **Chia dữ liệu theo Time Windows:**
   - **Tập Target ($T_{target}$):** Dữ liệu thu thập trong khoảng thời gian hiện tại cần phân tích (ví dụ: 24 giờ qua).
   - **Tập Background ($T_{background}$):** Dữ liệu thu thập trong quá khứ làm nền tảng tham chiếu (ví dụ: 7 ngày trước đó).
2. **Tính toán Term Frequency (TF) và Inverse Document Frequency (IDF):**
   - **TF:** Tính tần suất xuất hiện của một từ khóa $q$ trong tập $T_{target}$.
   - **IDF:** Tính dựa trên mức độ phổ biến của từ khóa trong tập $T_{background}$. Nếu một từ xuất hiện đều đặn trong quá khứ, IDF của nó sẽ thấp (bị phạt). Nếu nó ít xuất hiện trong quá khứ nhưng bùng nổ hiện tại, IDF sẽ cao.
3. **Tính Anomaly Score theo công thức biến thể của BM25:**
   - Dựa trên nền tảng của thuật toán Okapi BM25, Anomaly Score được tính toán để ưu tiên các cụm từ (unigram, bigram) có mật độ gia tăng đột biến:
   $$Score(q) = \sum \frac{TF(q, T_{target}) \cdot (k_1 + 1)}{TF(q, T_{target}) + k_1 \cdot \left(1 - b + b \cdot \frac{|T_{target}|}{\text{avg\_target\_len}}\right)} \times IDF(q, T_{background})$$
4. **Lọc Top 100 Trending Keywords:**
   - Đặt ngưỡng tối thiểu cho TF trong $T_{target}$ (ví dụ: phải xuất hiện ít nhất 10 lần) để loại bỏ các từ nhiễu, ít phổ biến.
   - Sắp xếp (Rank) tất cả các keywords theo điểm Anomaly Score giảm dần.
   - Cắt lấy top 100 từ khóa có điểm số cao nhất làm danh sách trending keywords.

## 3. Tóm tắt Kiến trúc Pipeline
- **Nguồn vào:** Dữ liệu raw text từ Social Listening.
- **Bước 1 (Clean & NLP):** `underthesea` (word segmentation), stopword filtering.
- **Bước 2 (Feature Extraction):** Tạo N-grams (Unigrams, Bigrams).
- **Bước 3 (BM25 Scoring):** Tính điểm Anomaly Score so sánh cửa sổ thời gian (Window-based comparison).
- **Đầu ra:** Top 100 từ khóa xu hướng đẩy vào Elasticsearch / CSDL để phục vụ Dashboard hoặc phân tích sâu.
