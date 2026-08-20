# Thiết kế DA-568: Topic Classification, BM25 Anomaly Detection và Engagement Analysis

## 1. Mục tiêu (Objective)
Xây dựng nhóm tầng phân tích lõi (T3, T4, T5) của hệ thống AI-05 Trend Detection Pipeline nhằm mục đích:
- **T3 - Topic Classification:** Phân loại nhanh dữ liệu vào các chủ đề định sẵn.
- **T4 - BM25 Spike Detection:** Bắt các từ khóa hoặc cụm từ (keywords/phrases) có sự gia tăng đột biến về tần suất so với nền lịch sử.
- **T5 - Engagement Analysis:** Đánh giá mức độ lan truyền thực tế (viral) và cảm xúc (mood) của người dùng dựa trên hành vi tương tác.

## 2. Kiến trúc T3 — Topic Classification
**Đầu vào:** Mảng Tokens sạch từ tầng T2.

**Logic xử lý:**
- Tập trung vào **6 chủ đề chính:** `tech`, `food`, `sports`, `entertainment`, `news`, `education`.
- **Keyword matching:** So khớp từng token với tập keyword đặc trưng của từng chủ đề.
- **Ngưỡng gán nhãn:** 
  - Bài đăng phải có tối thiểu $\ge 3$ keyword trùng khớp thì mới được gán nhãn (nhằm chống gán nhầm đối với các văn bản nhiễu).
- **Phân loại đa chủ đề (Multi-topic):** Nếu điểm số của chủ đề đứng thứ hai đạt mức $\ge 70\%$ (bestScore $\times$ 0.7) so với chủ đề cao nhất, bài viết được gán nhãn đa chủ đề (Secondary topic).

**Đầu ra:** Nhãn chủ đề (Topic label) cho mỗi bài viết.

## 3. Kiến trúc T4 — BM25 Spike Detection
**Đầu vào:** Posts và nhãn Topic từ T3.

**Cơ chế phát hiện đột biến (Spike Detection):**
1. **Bigram Detection (Phát hiện cụm 2 từ):** Nếu hai token liền kề xuất hiện cùng nhau ở $\ge 5\%$ tổng số post (tối thiểu 2 lần), chúng được gom lại thành cụm từ (phrase) mang nghĩa hoàn chỉnh.
2. **Split Window (Cửa sổ thời gian):**
   - **Background ($T_{bg}$):** Nửa đầu tiên của khung thời gian (đóng vai trò nền tham chiếu).
   - **Target ($T_{target}$):** Nửa sau của khung thời gian (chứa dữ liệu đột biến hiện tại).
3. **Công thức BM25 cải tiến:**
   $$BM25(q) = \frac{TF_{target} \cdot (k_1 + 1)}{TF_{target} + k_1 \cdot \left(1 - b + b \cdot \frac{|T_{target}|}{\text{avg\_len}}\right)} \times IDF(q)$$
   - Các tham số: $k_1 = 1.5, b = 0.75$
   - $IDF = \ln\left(\frac{N_{bg} - DF_{bg} + 0.5}{DF_{bg} + 0.5}\right) + 1.0$
4. **Noise Filters (4 Bộ lọc phi tham số):**
   - $TF_{target} \ge 3$: Loại bỏ các từ vô tình xuất hiện (one-off).
   - $DF_{target} \ge 2$: Từ khóa phải lan ra qua ít nhất 2 bài viết khác nhau.
   - $DF_{bg} \le 50\% \times N_{bg}$: Từ khóa không được quá phổ biến trong tập nền (không phải là từ thông dụng hàng ngày).
   - Chiều dài từ khóa (term length) $> 2$.
5. **Bigram Boost:** Cộng thêm 20% điểm số (+20%) cho các cụm từ (phrase) do chúng chứa nhiều ngữ cảnh hơn từ đơn.
6. **Side-channel Boost (từ T1):** Các từ khóa thuộc bài viết được cắm cờ `trendSignals` ở T1 sẽ được cộng dồn trọng số.

**Đầu ra:** Danh sách các keyword có dấu hiệu đột phá (Keyword candidates).

## 4. Kiến trúc T5 — Engagement Analysis
**Đầu vào:** Posts và dữ liệu Reactions.

**Đánh giá mức độ lan truyền (Virality) & Tính điểm eScore:**
- Tính Baseline trung bình ($\mu$) và độ lệch chuẩn ($\sigma$) cho lượt tương tác và chia sẻ.
- **Spike Threshold (Ngưỡng bùng nổ):** $\text{Threshold} = \mu + 2\sigma$.
- **Cộng điểm Engagement Score (`eScore`):**
  - Nếu $TotalReactions > Threshold$ $\rightarrow$ $+1.0$
  - Nếu $Shares > Threshold$ $\rightarrow$ $+2.0$
  - Nếu $Comments > 10$ $\rightarrow$ $+0.5$
  - Tỷ lệ $(Haha + Wow) > 30\%$ $\rightarrow$ $+0.5$ (Dấu hiệu dễ lan truyền - shareable).
  - Tỷ lệ $Care > 20\%$ $\rightarrow$ $+0.3$ (Dấu hiệu đồng cảm - sympathy).
- **Quyết định Viral:** Bài viết được đánh giá là Viral nếu tổng `eScore \ge 1.0`.

**Tích hợp Flag Spam từ T1:**
- Nếu bài viết bị cắm cờ `is_anomaly` (KB3A) hoặc `is_fake_like` (KB3B) ở T1, điểm `eScore` sẽ bị chia đôi ($eScore \times 0.5$) cho mỗi loại cờ (giảm trọng số do có dấu hiệu tương tác giả).

**Phân tích cảm xúc (Mood/Emotion):**
Dựa trên tỷ lệ của 7 loại tương tác để gán nhãn metadata:
- $Haha > 30\%$ $\rightarrow$ Humor.
- $Sad + Angry > 15\%$ $\rightarrow$ Negative (Tiêu cực).
- $Angry > 5\%$ $\rightarrow$ Controversy (Gây tranh cãi).
- $Love > 15\%$ $\rightarrow$ Positive.
- $Wow > 10\%$ $\rightarrow$ Positive.
*Lưu ý: Mood đóng vai trò làm metadata (cảnh báo rủi ro thương hiệu, brand_risk) và không tham gia vào ranking của luồng T6, T7. Tác động của cảm xúc lên ranking sẽ đi qua trọng số Edge React ở T6.*

**Đầu ra:** Danh sách bài viết lan truyền (Viral posts), điểm `eScore` để truyền cho T6 và thống kê cảm xúc (mood).
