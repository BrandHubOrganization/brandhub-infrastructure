# Thiết kế DA-569: Graph Virality Score, Centrality & Fusion Assembly

## 1. Mục tiêu (Objective)
Thiết kế kiến trúc mạng lưới đồ thị (Graph) ở tầng T6 và cơ chế gom cụm từ khóa ở tầng T7 nhằm:
- **T6 - Graph + GDS (Graph Data Science):** Chuyển hóa dữ liệu keyword thành cấu trúc đồ thị, sử dụng các độ đo trung tâm (Degree, PageRank, Betweenness) để tách các Trend thực sự lan truyền khỏi các tín hiệu Spam cục bộ.
- **T7 - Fusion (Trend Assembly):** Ghép nối các từ khóa lẻ rời rạc thành một "Đối tượng Xu hướng" (Trend Object) hoàn chỉnh và mang ý nghĩa kinh doanh.

## 2. Kiến trúc T6 — Graph Data Science
**Đầu vào:** Posts, Keywords (từ T4) và `eScore` (từ T5).

### 2.1. Thiết kế Đồ thị (Graph Schema - DA-747)
- **Nodes (Các đỉnh):** User (Người dùng), Post (Bài viết), Keyword (Từ khóa đột biến).
- **Edges (Các cạnh và Trọng số - w):**
  - Cạnh `POSTED` (w = 1.0)
  - Cạnh `SHARED` (w = $3 \times \ln(1 + \text{shares})$)
  - Cạnh `COMMENTED` (w = $2 \times \ln(1 + \text{comments})$)
  - Cạnh `HAS_KEYWORD` (w = 1.0)
  - Cạnh `REACTED`: Trọng số phân tách rõ rệt dựa vào loại Emoji để truyền tải cảm xúc vào ranking:
    - $w = \ln(1 + rxnW)$
    - **Angry** ($rxnW \times 2.0$) > **Sad** ($rxnW \times 1.8$) > **Haha/Wow** ($rxnW \times 1.5$) > **Love** ($rxnW \times 1.2$) > **Like/Care** ($rxnW \times 1.0$).

### 2.2. Lọc Spam qua Degree Centrality (DA-749)
- **Mục đích:** Nhận diện các keyword được spam cục bộ (có thể do seeding farm).
- **Thuật toán:** Tính In-degree (số liên kết trỏ tới keyword).
- **Soft-signal threshold:** Điểm dị thường được tính bằng $\text{avg\_deg} + 3\times \text{std\_deg}$. Tuy nhiên, vì một xu hướng (trend) thật cũng có degree cực cao, đồ thị áp dụng bộ lọc mềm thay vì drop ngay lập tức.
- **Điều kiện Drop:** Một keyword chỉ bị đánh dấu là Spam khi đồng thời:
  - Degree rất cao (vượt ngưỡng spam_threshold).
  - AND PageRank rất thấp ($< 0.2$).
  - AND Betweenness Centrality cực thấp ($< 1.0$).

### 2.3. PageRank đo lường độ phủ (Virality - DA-750)
- Sử dụng thuật toán Personalized PageRank ($\alpha = 0.85$, 50 vòng lặp).
- Xác định sự lan truyền của một keyword được thúc đẩy bởi sự ủng hộ của các Node uy tín (bài viết có nhiều lượt chia sẻ/tương tác).

### 2.4. Betweenness Centrality đo lường tính kết nối (Bridge - DA-751)
- Sử dụng thuật toán Brandes duyệt BFS từ mỗi keyword.
- Tìm ra các keyword có đóng vai trò là "cầu nối" nằm trên đường đi ngắn nhất giữa các cụm người dùng. Keyword có betweenness cao chứng tỏ nó đang lan truyền xuyên cộng đồng.

### 2.5. Công thức xếp hạng cuối cùng (Final Score - DA-752)
Kết hợp sức mạnh từ T4 (Đột biến) và T6 (Mạng lưới lan truyền) cùng lực đẩy tương tác từ T5 (`engagement_boost` = 1 + eScore):
$$Final(q) = BM25_{anomaly} \times \left(1.0 + PageRank_{virality} + 0.5 \times Betweenness_{bridge}\right) \times engagement\_boost$$

### 2.6. Tìm kiếm Cộng đồng (Community Detection)
Sử dụng thuật toán **Jaccard Clustering**. Các keyword cùng được chia sẻ ở $\ge 2$ post hoặc có độ tương đồng (Jaccard Similarity) $> 0.3$ sẽ được phân vào cùng một cộng đồng (Community).

## 3. Kiến trúc T7 — Fusion (Trend Assembly)
**Đầu vào:** Tập hợp Keyword đã được chấm điểm Final Score và gom nhóm từ T6.

**Logic tổng hợp Trend Object:**
1. **Gộp cụm nâng cao (Co-occurrence Grouping):** Gộp các từ khóa có tỷ lệ Jaccard $> 0.25$ hoặc cùng xuất hiện trong $\ge 2$ post thành một cụm chủ đề duy nhất (để không bị hiển thị rời rạc nhiều keyword cùng nghĩa).
2. **Khởi tạo Trend Object:**
   - **Title:** Lấy 2-3 top keyword nối lại với nhau làm tiêu đề xu hướng.
   - **Topic:** Chủ đề thống trị (dominant topic) trong cụm.
   - **Mood:** Cảm xúc thống trị (dominant mood) từ T5.
   - **Status (Trạng thái):** 
     - *Peaking:* Trung bình lượt post $> 30$, $\ge 2$ keyword.
     - *Rising:* Trung bình lượt post $> 15$.
     - *New:* Mới xuất hiện.
3. **Cross-topic Detection (Siêu xu hướng):** Nếu một cụm keyword lọt vào Top 20 BM25 ở từ $\ge 2$ Topic trở lên $\rightarrow$ Đánh dấu là **SUPER TREND** (Xu hướng vĩ mô vượt qua khuôn khổ một lĩnh vực).
4. **Sắp xếp (Ranking):** Các trend chứa cụm nhiều keyword (multi-keyword) được xếp hạng ưu tiên, các trend chỉ chứa một keyword (solo) sẽ bị đẩy xuống cuối vì rủi ro mang tính nhiễu (noise).

**Đầu ra:** Mảng danh sách các đối tượng Xu Hướng hoàn chỉnh (Trend Objects), sẵn sàng phục vụ cho báo cáo và ứng dụng client.
