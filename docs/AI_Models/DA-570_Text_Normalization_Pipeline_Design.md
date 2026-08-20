# Thiết kế DA-570: Tiền xử lý văn bản và Chuẩn hóa dữ liệu (Ingestion, Bot Filter, NLP)

## 1. Mục tiêu (Objective)
Xây dựng các tầng tiền xử lý đầu tiên (T0, T1, T2) cho hệ thống AI-05 Trend Detection Pipeline nhằm mục đích:
- **T0 - Ingestion:** Nạp và chuẩn hóa cấu trúc dữ liệu thô từ Social Listening.
- **T1 - Bot/Spam Filter:** Lọc bỏ các tài khoản giả mạo, clone, spam và seeding trước khi đưa vào phân tích để đảm bảo tính trung thực của xu hướng.
- **T2 - NLP Preprocessing:** Làm sạch văn bản, chuẩn hóa từ lóng và tách từ tiếng Việt để chuẩn bị cho các mô hình đánh giá đột biến và đồ thị phía sau.

## 2. Kiến trúc T0 — Ingestion (Parse + Dedup)
**Đầu vào:** File JSON thô xuất ra từ các công cụ crawl mạng xã hội (Facebook, v.v.).

**Quy trình xử lý:**
1. **Parse dữ liệu:** Đọc các file JSON/NDJSON với nhiều định dạng lồng nhau (vd: `data.posts`).
2. **Trích xuất trường thông tin (Extraction):**
   - Nội dung (`text`, `raw`, `message`, `content`).
   - Tác giả (`user_name`, `from`, `author`).
   - Tương tác: Lấy đủ 7 loại Reaction (like, love, care, haha, wow, sad, angry).
   - Dữ liệu lan truyền: `shares`, `comments`, `topComments`, `hashtags`, thời gian, video/group.
3. **Khử trùng lặp (Deduplication 2 lớp):**
   - **URL dedup:** Bỏ qua các post trùng lặp chính xác về URL.
   - **Text hash dedup:** Mã hóa (hash) 100 ký tự đầu tiên đã được chuẩn hóa để phát hiện bài đăng copy-paste (re-share khác URL) và bỏ qua.

**Đầu ra:** Object bài đăng (Post objects) đã được chuẩn hóa cấu trúc và loại bỏ trùng lặp.

## 3. Kiến trúc T1 — Bot / Clone / Spam Filter
**Đầu vào:** Nội dung bình luận thô (`topComments`), ID tác giả (`author.id`), và thời gian đăng (`time`). Yêu cầu phải nhận text thô (chưa xóa URL/Emoji).

**Cơ chế phát hiện và xử lý dựa trên 5 Rule (KB):**
- **KB1 - Velocity:** Nếu độ dài bình luận > 50 ký tự nhưng xuất hiện < 5 giây sau khi bài post được đăng $\rightarrow$ **Hành động: DROP** (Bot tự động).
- **KB2 - Frequency:** Cùng một ID bình luận liên tục trên > 10 bài viết trong vòng < 5 phút $\rightarrow$ **Hành động: BLACKLIST** toàn bộ ID.
- **KB3A - Brigading:** Số lượng bình luận chiếm áp đảo (Comments/Total Reactions > 10) trong khi tổng số lượng tương tác rất thấp (< 20) $\rightarrow$ **Hành động: FLAG anomaly** (Gắn cờ để giảm trọng số ở tầng Engagement T5, KHÔNG DROP).
- **KB3B - Like-buying:** Lượng tương tác lớn (> 500) nhưng số bình luận rất ít (< 5) HOẶC đa dạng cảm xúc (reaction diversity) < 2 loại $\rightarrow$ **Hành động: FLAG fake_like** (Gắn cờ giảm trọng số ở T5).
- **KB5 - Burst (Spam hàng loạt):** Xuất hiện > 5 ID khác nhau bình luận trên 1 bài trong < 30 giây với độ đa dạng nội dung (text diversity) < 0.3 $\rightarrow$ **Hành động: BLACKLIST**.
- **KB6 - Cross-post (Tín hiệu Trend):** Cùng một nội dung bình luận (có nghĩa) xuất hiện ở nhiều bài viết bởi nhiều ID khác nhau $\rightarrow$ Không phải filter mà là **Tín hiệu lan truyền**. Ghi nhận vào `trendSignals[]` để **Boost (Tăng trọng số)** ở tầng T4 và T6.

**Đầu ra:** Danh sách comment sạch (đã drop spam), danh sách blacklist, và tín hiệu trend (trendSignals).

## 4. Kiến trúc T2 — NLP Preprocessing
**Đầu vào:** Văn bản bài đăng sau khi đã được lọc từ T1.

**Quy trình chuẩn hóa:**
1. **Cleaning:** Loại bỏ các thành phần rác (URLs, HTML tags, hashtags, emojis).
2. **Normalize Unicode:** Áp dụng chuẩn NFKC (chuyển các font chữ đặc biệt, in đậm toán học về ASCII) và chuẩn hóa về dạng dựng sẵn NFC.
3. **Lowercase & Strip:** Đưa về chữ in thường, xóa ký tự đặc biệt (chỉ giữ lại hệ ký tự Vietnamese Latin Extended).
4. **Tokenization (Tách từ):** Phân mảnh văn bản bằng dấu cách, dựa trên cấu trúc đã được tách sẵn của thư viện Underthesea.
5. **Slang Mapping:** Thay thế từ lóng/teencode bằng từ điển tự định nghĩa (~90 rules). Ví dụ: `ko` $\rightarrow$ `không`, `vl` $\rightarrow$ `rất`, `dc` $\rightarrow$ `được`.
6. **Stopword Removal:** Loại bỏ các từ vô nghĩa không đóng góp vào xu hướng (~150 từ stopword tiếng Việt), và bỏ các ký tự ASCII đơn lẻ (vẫn giữ lại các từ tiếng Việt 1 ký tự có nghĩa như `ý`, `ở`, `ạ`).

**Đầu ra:** Mảng Token sạch sẽ chuẩn bị cho việc phát hiện đột biến BM25.
