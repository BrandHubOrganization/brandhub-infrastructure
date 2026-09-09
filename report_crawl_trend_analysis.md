# Báo Cáo Phân Tích Sâu Luồng Cào Dữ Liệu Xu Hướng (Crawl Trend Flow Analysis)
**Mã tài liệu:** AI-4.99-BLUEPRINT  
**Dự án:** BrandHub AI Trend System  

Tài liệu này phân tích chi tiết toàn bộ luồng cào dữ liệu xu hướng (Crawl Trend & Knowledge Ingestion Pipeline) được thống nhất bởi nhóm phát triển AI. Tài liệu làm rõ các công nghệ được sử dụng, cấu trúc dữ liệu đầu vào/đầu ra và các công thức toán học lõi cho từng bước xử lý.

---

## 1. Sơ Đồ Luồng Kỹ Thuật Tổng Thể (Flow Architecture)

```
[NGUỒN DỮ LIỆU (Google Trends, Social Media Firehose)]
                              │
                              ▼
┌────────────────────────────────────────────────────────┐
│ 1. DATA COLLECTION LAYER (Cào dữ liệu)                 │ ➔ Công nghệ: pytrends, Scrapy/Puppeteer
│    - MVP: Google Trends / TikTok Crawler               │
│    - Advanced: Social Media Firehose (Posts, Comments) │
└─────────────────────────────┬──────────────────────────┘
                              │
                              ▼
┌────────────────────────────────────────────────────────┐
│ 2. TREND PREDICTION ENGINE (Động cơ dự đoán xu hướng)  │ ➔ Công nghệ: Underthesea, rank_bm25, Neo4j GDS
│    - Tokenize & Clean: Tách từ & Làm sạch dữ liệu thô  │
│    - BM25 Anomaly Calc: Lọc 100 ứng cử viên điểm cao   │
│    - Graph Construction: Dựng đồ thị tương tác Neo4j   │
│    - Graph Algorithms: Centrality -> Điểm lan truyền   │
│    - Final Scoring (BM25 x Graph) -> Top Trending      │
└─────────────────────────────┬──────────────────────────┘
                              │
                              ├──────────────────► LƯU TRỮ VÀO CACHE REDIS & NEO4J
                              │
                              ▼ (Đối với chi tiết bài đăng/văn bản của trend)
┌────────────────────────────────────────────────────────┐
│ 3. NORMALIZATION & CLEANING                            │ ➔ Công nghệ: Regex, Python Dict
│    - Loại bỏ emoji rác, sửa viết tắt/từ lóng tiếng Việt│
└─────────────────────────────┬──────────────────────────┘
                              │
                              ├───► LƯU TRỮ VÀO VECTOR DB (ChromaDB) ➔ Chunks & Embeddings
                              │
                              └───► TRÍCH XUẤT THỰC THỂ (NER) ➔ Nodes & Edges nạp vào Neo4j
```

---

## 2. Chi Tiết Từng Bước Xử Lý (Step-by-Step Technical Blueprint)

### Bước 1: Data Collection Layer (Cào dữ liệu thô)
*   **Mô tả:** Thu thập dữ liệu từ các nguồn xu hướng mở và các bài đăng tương tác trên mạng xã hội tại Việt Nam.
*   **Công nghệ sử dụng:**
    *   `pytrends` (Python wrapper cho Google Trends API).
    *   `Playwright`/`Scrapy` (Để cào TikTok Creative Center).
    *   API trung gian (RapidAPI TikTok Scraper) để cào bài đăng mạng xã hội.
*   **Dữ liệu Đầu vào (Input):** Các tham số tìm kiếm (Quốc gia: VN, chu kỳ cào: 6 giờ).
*   **Dữ liệu Đầu ra (Output):** Danh sách các bài đăng thô dạng văn bản kèm metadata tương tác.
    *   *Ví dụ JSON Output:*
        ```json
        {
          "source": "tiktok",
          "crawl_time": "2026-07-18T20:00:00Z",
          "posts": [
            {
              "post_id": "tt_738291038102",
              "author": "ninheating",
              "content": "Hé lô mọi người, hôm nay đi uống thử trà sữa đất nung Hàng Bồ ngon lắm nè nha! #trasuadatnung",
              "interactions": {
                "likes": 45000,
                "shares": 1200,
                "comments_count": 850
              },
              "comments": [
                {"user": "reviewer_A", "text": "Quán này ở số 10 Hàng Bồ đúng không anh?"},
                {"user": "user_B", "text": "Nhìn thèm quá, hôm nào phải thử."}
              ]
            }
          ]
        }
        ```

---

### Bước 2: Động cơ Dự đoán Xu hướng (Trend Prediction Engine)

#### Bước 2.1: Tokenize & Clean (Tách từ và làm sạch)
*   **Mô tả:** Phân tách dòng văn bản thô thành các token có nghĩa bằng các thư viện phân đoạn từ tiếng Việt, loại bỏ ký tự nhiễu.
*   **Công nghệ:** Thư viện `Underthesea` (NLP tiếng Việt), `re` (Regex lọc nhiễu).
*   **Input:** Danh sách nội dung bài viết và comment thô từ Bước 1.
*   **Output:** Mảng các token đã được làm sạch và phân đoạn từ ghép.
    *   *Ví dụ Output:* `["trà sữa đất nung", "ngon", "quán", "trà sữa đất nung", "hàng bồ", "trasuadatnung"]`

#### Bước 2.2: BM25 Anomaly Calc (Lọc 100 ứng cử viên)
*   **Mô tả:** Sử dụng thuật toán BM25 để đo tần suất bất thường của từ khóa hôm nay so với lịch sử 30 ngày trước để chọn ra top 100 candidates.
*   **Công thức Toán học:**
    Tính điểm bất thường của từ khóa $q_i$ trong tập dữ liệu chu kỳ hiện tại $D$:
    \[\text{Anomaly\_Score}(D, q_i) = \text{IDF}(q_i) \cdot \frac{f(q_i, D) \cdot (k_1 + 1)}{f(q_i, D) + k_1 \cdot \left(1 - b + b \cdot \frac{|D|}{\text{avgdl}}\right)}\]
    Trong đó:
    *   \(\text{IDF}(q_i) = \ln \left( \frac{M - n(q_i) + 0.5}{n(q_i) + 0.5} + 1 \right)\) với \(M\) là số ngày trong tập tham chiếu (30 ngày), và \(n(q_i)\) là số ngày từ khóa \(q_i\) xuất hiện trong lịch sử.
    *   \(f(q_i, D)\) là tần suất từ khóa xuất hiện trong chu kỳ cào hiện tại.
    *   \(|D|\) là độ dài tài liệu hiện tại, \(\text{avgdl}\) là độ dài trung bình lịch sử.
    *   \(k_1 = 1.5, b = 0.75\) là các tham số mặc định.
*   **Input:** Token của chu kỳ hiện tại và baseline lịch sử 30 ngày.
*   **Output:** Top 100 ứng cử viên có điểm bất thường cao nhất.
    *   *Ví dụ Output:* `[{"keyword": "trà sữa đất nung", "anomaly_score": 8.45}, ...]`

#### Bước 2.3: Graph Construction (Dựng đồ thị tương tác Neo4j)
*   **Mô tả:** Truy vết và ghi trực tiếp các thực thể đang thảo luận về 100 ứng cử viên xu hướng vào Neo4j dưới dạng Node và Edge tương tác thô.
*   **Công nghệ:** Neo4j Driver (Python), Cypher Queries.
*   **Input:** Top 100 ứng cử viên và danh sách bài viết/comment thô có liên quan.
*   **Output:** Subgraph được ghi đè/tạo mới vào Neo4j Database.
    *   *Mẫu Cypher ghi dữ liệu:*
        ```cypher
        MERGE (u:User {username: $username})
        MERGE (t:Trend {name: $trendName})
        CREATE (u)-[:POSTED {timestamp: datetime(), likes: $likes}]->(t)
        ```

#### Bước 2.4: Graph Algorithms (Centrality -> Điểm lan truyền)
*   **Mô tả:** Chạy thuật toán đồ thị trong Neo4j (Degree Centrality và Betweenness Centrality) trên subgraph vừa dựng để chấm điểm lan truyền **Graph_Virality_Score** chuẩn hóa về khoảng `[0, 1]` cho từng ứng cử viên.
*   **Công thức Toán học:**
    *   **Degree Centrality (Chuẩn hóa):**
        \[C_D(v) = \frac{\text{deg}_{in}(v)}{N - 1}\]
    *   **Betweenness Centrality:**
        \[C_B(v) = \sum_{s \neq v \neq t} \frac{\sigma_{st}(v)}{\sigma_{st}}\]
    *   **Điểm lan truyền (Graph Virality Score):**
        \[Graph\_Virality\_Score(v) = w_1 \cdot C_D(v) + w_2 \cdot C_B(v) \quad (\text{với } w_1 = 0.3, w_2 = 0.7)\]
*   **Công nghệ:** Neo4j Graph Data Science (GDS) library.
*   **Input:** Đồ thị tương tác trong Neo4j.
*   **Output:** `Graph_Virality_Score` cho từng ứng cử viên xu hướng.
    *   *Ví dụ Output:* `[{"keyword": "trà sữa đất nung", "virality_score": 0.89}]`

#### Bước 2.5: Final Scoring (BM25 x Graph) -> Top Trending
*   **Mô tả:** Hợp nhất điểm bất thường và điểm lan truyền để tạo điểm xếp hạng xu hướng cuối cùng.
*   **Công thức:**
    \[Final\_Trend\_Score(v) = \text{Anomaly\_Score}(v) \times Graph\_Virality\_Score(v)\]
*   **Input:** Bảng điểm BM25 và Graph Virality của 100 ứng cử viên.
*   **Output:** Top 10 - 20 Trend chính thức được sắp xếp giảm dần.
    *   *Ví dụ Output:* `[{"rank": 1, "trend": "trà sữa đất nung", "final_score": 7.52}]`

---

### Bước 3: Normalization & Cleaning (Chuẩn hóa văn bản)
*   **Mô tả:** Chỉ thực hiện cào dữ liệu dạng văn bản (loại bỏ cào video/audio). Ở bước này, các bài đăng/comment chi tiết của các Trend chính thức (sau khi lọc ở Bước 5) sẽ được chuẩn hóa ngôn ngữ (loại bỏ emoji rác, chuyển từ viết tắt, từ lóng tiếng Việt về dạng chuẩn).
*   **Công nghệ:** Python `re` (Regex), custom synonym dictionary.
*   **Input:** Văn bản thô của các bài viết liên quan đến Top Trends.
*   **Output:** Văn bản sạch đã chuẩn hóa tiếng Việt.
    *   *Ví dụ Output:* `"Hôm nay đi uống thử món trà sữa đất nung đang hot. Quán Trà Sữa Đất Nung Hàng Bồ nằm tại số 10 Hàng Bồ, Hoàn Kiếm, Hà Nội..."`

---

### Bước 4: Lưu trữ cơ sở dữ liệu lai (Hybrid Database Ingestion)

#### Nhánh 1: ChromaDB (Vector DB)
*   **Mô tả:** Chia nhỏ văn bản sạch thành các chunk (size=500, overlap=50), chuyển thành Vector Embedding và lưu vào ChromaDB kèm tag xu hướng trong metadata.
*   **Công nghệ:** `ChromaDB` (Vector DB), mô hình embedding `all-MiniLM-L6-v2` hoặc OpenAI Embedding API.
*   **Dữ liệu Đầu vào/Đầu ra (JSON Schema ChromaDB):**
    ```json
    {
      "id": "doc_ninheating_01_chunk_0",
      "document": "Quán này là Trà Sữa Đất Nung Hàng Bồ, nằm tại số 10 Hàng Bồ, Hoàn Kiếm, Hà Nội. Trà được nướng trực tiếp trên ấm đất nung...",
      "embedding": [0.015243, -0.084312, 0.231109, "..."],
      "metadata": {
        "trendName": "trà sữa đất nung",
        "author": "ninheating",
        "platform": "TikTok",
        "chunkIndex": 0
      }
    }
    ```
*   **Cơ chế tìm kiếm tối ưu (HNSW Indexing):** 
    ChromaDB sử dụng chỉ mục phân tầng HNSW (Hierarchical Navigable Small World) để giải quyết bài toán tìm kiếm vector láng giềng gần nhất xấp xỉ (ANN). Thay vì duyệt cạn và tính khoảng cách với toàn bộ $N$ node trong cơ sở dữ liệu (tốn độ phức tạp $\mathcal{O}(N)$), giải thuật chỉ duyệt qua các node kết nối lân cận trực tiếp ($M \approx 16$) ở từng tầng và đi dần từ thô đến chi tiết (tương tự cấu trúc Skip List). Việc này giúp giảm độ phức tạp tìm kiếm xuống **$\mathcal{O}(\log N)$**, giảm số phép tính toán khoảng cách từ hàng triệu phép tính xuống còn vài trăm phép tính, đảm bảo thời gian truy vấn vector luôn dưới **50ms**.

#### Nhánh 2: Neo4j (Graph DB - Tri thức quan hệ)
*   **Mô tả:** Trích xuất thực thể (KOL, Dish, Location) từ bài viết và bình luận, lưu và liên kết trực tiếp với Node `:Trend` chính thức thông qua Cypher.
*   **Công nghệ:** LLM NER API, Neo4j DB.
*   **Dữ liệu Đầu vào/Đầu ra (JSON Schema Neo4j Node/Edge):**
    *   *Node Trend:* `:Trend {name: "trà sữa đất nung", finalScore: 7.52, rank: 1}`
    *   *Node KOL:* `:KOL {name: "ninheating", platform: "TikTok", followers: 1200000}`
    *   *Cạnh kết nối:* `(KOL)-[:PROMOTED {interactionCount: 1200000}]->(Trend)`

---

## 3. Quy Trình Đồng Bộ & Ghi Đồng Thời (Write Synchronization)

Sau khi có kết quả Top Trending ở Bước 5, hệ thống thực hiện ghi đồng thời xuống hai nơi:
1.  **Ghi đệm Redis (Cache):** Lưu cấu trúc Sorted Set (ZSET) với key `trends:vn:{date}:{category}` để dashboard Client lấy ngay lập tức mà không cần truy vấn DB chính.
2.  **Ghi đè Neo4j (Upsert):** Sử dụng mệnh đề `MERGE` để cập nhật điểm và thứ hạng của trend mà không làm mất lịch sử:
    ```cypher
    MERGE (t:Trend {name: $trendName})
    ON CREATE SET 
        t.createdAt = datetime(),
        t.finalScore = $finalScore,
        t.rank = $rank
    ON MATCH SET 
        t.finalScore = $finalScore,
        t.rank = $rank,
        t.updatedAt = datetime()
    ```
    *Dữ liệu thô cào về ở Bước 3 vẫn được giữ lại trong Neo4j để phục vụ việc duyệt đồ thị (Graph Traversal) ở luồng Query (GraphRAG), nhưng sẽ được dọn dẹp định kỳ (Clean up) hoặc lưu trữ archive sau 30 ngày để đảm bảo hiệu năng database.*

---

## 4. Kịch Bản Mô Phỏng Chạy Thực Tế (10 Trends Scenario)

Dưới đây là kịch bản mô phỏng thực tế cách hệ thống xử lý một lô dữ liệu cào chứa **10 chủ đề/từ khóa** thô khác nhau tại Việt Nam. Kịch bản này minh họa chi tiết đầu vào/đầu ra và cách biến đổi dữ liệu ở từng khâu.

### [LÔ DỮ LIỆU ĐẦU VÀO]: 10 chủ đề thô cào từ MXH & Google
1.  `trà sữa đất nung` (Món ăn đang rộ lên tại Hà Nội)
2.  `labubu` (Thú chơi art toy thịnh hành)
3.  `capybara` (Trend gấu túi/chuột lang nước dễ thương)
4.  `bánh mì than` (Đặc sản phục hồi tại Quảng Ninh)
5.  `đấu trường danh vọng` (Giải đấu game Liên Quân Mobile)
6.  `giảm giá sốc` (Từ khóa từ các tin nhắn/bài đăng spam bán hàng)
7.  `gomart` (Khai trương siêu thị GoMart mới)
8.  `mua sắm tết` (Thảo luận mua sắm chuẩn bị Tết - Tính chất theo mùa)
9.  `crypto tăng giá` (Thảo luận về Bitcoin)
10. `viral video mèo` (Xem các clip mèo hài hước thịnh hành)

---

### [BƯỚC 1]: Data Collection Layer (Cào dữ liệu)
*   **Hành động:** Bot của Tuấn quét Google Trends và các bài đăng từ 100 KOLs F&B/Lifestyle.
*   **Dữ liệu thu về:** 2,500 bài viết và 30,000 bình luận thô liên quan đến 10 chủ đề trên.
*   **Ví dụ văn bản thô thu về của chủ đề 1:** *"Quán trà sữa đất nung Hàng Bồ ở số 10 Hàng Bồ siêu ngon nha mn ơi, review bởi KOL ninheating đạt 1.2M view!"*

---

### [BƯỚC 2]: Trend Prediction Engine (Xử lý giải thuật)

#### 1. Tokenize & Clean (Làm sạch & tách từ)
*   **Xử lý:** Chuyển đổi chuỗi văn bản thô thành danh sách các token sạch thông qua quy trình 5 bước tuần tự:
    *   **Input thô:** `"Quán trà sữa đất nung Hàng Bồ ở số 10 Hàng Bồ siêu ngon nha mn ơi, review bởi KOL ninheating đạt 1.2M view! ❤️🥤 https://tiktok.com/ninheating"`
    *   **Bước 1.1: Loại bỏ Emojis, Ký tự đặc biệt & URLs (Làm sạch Regex):** Sử dụng các biểu thức chính quy (Regex) quét sạch các đường link `http/https`, emojis biểu cảm và các ký tự đặc biệt rác.
        *   *Kết quả:* `"Quán trà sữa đất nung Hàng Bồ ở số 10 Hàng Bồ siêu ngon nha mn ơi review bởi KOL ninheating đạt 12M view"`
    *   **Bước 1.2: Chuẩn hóa chữ thường (Lowercasing):** Đưa toàn bộ các từ về dạng viết thường để tránh phân biệt HOA/thường khi tính tần suất.
        *   *Kết quả:* `"quán trà sữa đất nung hàng bồ ở số 10 hàng bồ siêu ngon nha mn ơi review bởi kol ninheating đạt 12m view"`
    *   **Bước 1.3: Tách từ ghép tiếng Việt (Word Segmentation):** Do tiếng Việt dùng khoảng trắng để ngăn cách âm tiết, nếu tách đơn giản ta sẽ bị mất nghĩa từ ghép (ví dụ: `trà`, `sữa`, `đất`, `nung` bị tách rời). Hệ thống dùng hàm `word_tokenize(text, format="text")` của thư viện **Underthesea** để tự động nối các từ ghép bằng dấu gạch dưới `_`.
        *   *Kết quả:* `"quán trà_sữa_đất_nung hàng_bồ ở số 10 hàng_bồ siêu ngon nha mn ơi review bởi kol ninheating đạt 12m view"`
    *   **Bước 1.4: Loại bỏ Stop words & Từ đệm rác:** Sử dụng bộ từ điển dừng (Stopwords List) tùy chỉnh để quét và lọc bỏ các từ đệm, từ cảm thán, từ lóng rác mạng xã hội (`nha`, `mn`, `ơi`, `trùi_ui`), các con số (`10`, `12m`), và giới từ (`ở`, `bởi`, `đạt`, `số`, `quán`).
        *   *Kết quả:* `"trà_sữa_đất_nung hàng_bồ ngon review ninheating"`
    *   **Bước 1.5: Trả về danh sách Tokens sạch:** Tách chuỗi theo dấu khoảng trắng và chuyển đổi dấu gạch dưới `_` trở lại thành khoảng trắng bình thường để lưu vào mảng.
    *   **Output thu được:** `["trà sữa đất nung", "hàng bồ", "ngon", "review", "ninheating"]`

#### 2. BM25 Anomaly Calc (Đo độ bùng nổ số lượng)
*   **Xử lý:** So sánh tần suất xuất hiện trong 6 giờ qua so với baseline lịch sử 30 ngày trước.
*   **Bảng kết quả tính điểm bùng nổ (Anomaly Score):**

| Từ khóa / Chủ đề | Tần suất 6h qua ($TF$) | Tần suất lịch sử 30 ngày ($IDF$ tương đối) | Điểm Anomaly Score | Ghi chú từ thuật toán |
| :--- | :--- | :--- | :--- | :--- |
| `trà sữa đất nung` | 1,200 lần | Rất thấp (gần như bằng 0) | **9.20** | Đột biến cực cao (Tín hiệu trend mạnh) |
| `giảm giá sốc` | 8,500 lần | Rất cao (ngày nào cũng có spam) | **1.10** | Tần suất cao nhưng không bất thường (Loại nhiễu) |
| `labubu` | 950 lần | Thấp | **8.50** | Đột biến cao |
| `bánh mì than` | 400 lần | Trung bình thấp | **7.80** | Đột biến khá cao |
| `capybara` | 650 lần | Thấp | **7.20** | Đột biến cao |
| `đấu trường danh vọng`| 1,100 lần | Trung bình | **6.50** | Đột biến trung bình |
| `viral video mèo` | 2,200 lần | Trung bình cao | **4.80** | Thảo luận thường ngày, bùng nổ nhẹ |
| `crypto tăng giá` | 550 lần | Trung bình | **4.20** | Biến động theo thị trường |
| `gomart` | 150 lần | Rất thấp | **5.50** | Đột biến cục bộ |
| `mua sắm tết` | 300 lần | Trung bình cao | **4.00** | Xu hướng theo mùa, tăng từ từ |

#### 3. Graph Construction & Centrality Calc (Phân tích lan truyền đồ thị)
*   **Xử lý:** Nạp tương tác của 10 ứng cử viên vào Neo4j và chạy thuật toán Centrality để đo độ virality chéo giữa các nhóm cộng đồng (Community Clusters).
*   **Kết quả tính điểm lan truyền đồ thị (Graph Virality Score từ 0 đến 1):**
    *   `trà sữa đất nung`: **0.85** (Lan truyền mạnh sang nhiều nhóm: F&B, Reviewer, Giới trẻ Hà Nội).
    *   `labubu`: **0.82** (Lan truyền chéo nhóm Art Toy và Lifestyle).
    *   `capybara`: **0.78** (Lan truyền nhóm Meme và Thú cưng).
    *   `đấu trường danh vọng`: **0.80** (Game thủ lan truyền cực mạnh nhưng cô lập trong nhóm Game).
    *   `bánh mì than`: **0.75** (Du lịch và F&B).
    *   `viral video mèo`: **0.40** (Nhiều người xem nhưng ít chia sẻ tạo tương tác chéo).
    *   `gomart`: **0.50** (Chỉ lan truyền trong nhóm dân cư khu vực lân cận).
    *   `giảm giá sốc`: **0.10** (Tương tác ảo từ các bot spam, không có kết nối chéo tự nhiên).

#### 4. Final Scoring & Ranking (Hợp nhất xếp hạng)
Hệ thống tính điểm tổng hợp: $Final\_Score = Anomaly\_Score \times Graph\_Virality\_Score$.

*   **Bảng xếp hạng Top 10 Trend cuối cùng:**

| Hạng | Từ khóa / Chủ đề | Công thức tính toán | Điểm số cuối cùng | Trạng thái hệ thống |
| :---: | :--- | :--- | :---: | :--- |
| **1** | `trà sữa đất nung` | $9.20 \times 0.85$ | **7.82** | **Top Trend 1** (Chọn nạp tri thức) |
| **2** | `labubu` | $8.50 \times 0.82$ | **6.97** | **Top Trend 2** (Chọn nạp tri thức) |
| **3** | `bánh mì than` | $7.80 \times 0.75$ | **5.85** | **Top Trend 3** (Chọn nạp tri thức) |
| **4** | `capybara` | $7.20 \times 0.78$ | **5.61** | **Top Trend 4** (Chọn nạp tri thức) |
| **5** | `đấu trường danh vọng`| $6.50 \times 0.80$ | **5.20** | **Top Trend 5** (Chọn nạp tri thức) |
| 6 | `viral video mèo` | $4.80 \times 0.40$ | 1.92 | Bị loại (Không đủ độ viral) |
| 7 | `gomart` | $5.50 \times 0.50$ | 2.75 | Bị loại (Trend quá nhỏ) |
| 8 | `mua sắm tết` | $4.00 \times 0.60$ | 2.40 | Bị loại (Trend theo mùa bình thường) |
| 9 | `crypto tăng giá` | $4.20 \times 0.45$ | 1.89 | Bị loại |
| 10 | `giảm giá sốc` | $1.10 \times 0.10$ | 0.11 | Bị loại (Spam/Nhiễu) |

*➔ Kết quả:* Hệ thống chốt **Top 5 Trends** chính thức đi tiếp vào luồng lưu trữ và làm sạch.

---

### [BƯỚC 3]: Normalization & Cleaning (Lấy ví dụ Trend 1: Trà sữa đất nung)
*   **Văn bản thô cào sâu về:** *"Trùi ui quán trà sữa đất nung Hàng Bồ ở số 10 Hàng Bồ ngon hết nấc lun á mn, review bởi KOL ninheating đạt 1.2M view!"*
*   **Xử lý:** Lọc emoji, sửa từ lóng viết tắt ("trùi ui" -> "", "ngon hết nấc" -> "rất ngon", "lun á mn" -> "nội dung được quan tâm").
*   **Văn bản sạch:** `"Quán trà sữa đất nung Hàng Bồ nằm tại số 10 Hàng Bồ rất ngon, review bởi KOL ninheating đạt 1.2M view."`

---

### [BƯỚC 4]: Đồng bộ Caching & Lưu trữ cơ sở dữ liệu lai

#### 1. Ghi đồng thời kết quả xếp hạng xu hướng (Task `99-06`)
Chi tiết thiết kế luồng lưu trữ đệm và ghi đè xem tại: [Tài liệu Thiết kế Luồng Lưu Trữ Đệm Redis và Ghi Đè Neo4j (Upsert Flow)](file:///d:/FPT/FA26/brandhub-infrastructure/docs/database/DA-AI04-99-06_Redis_Neo4j_Upsert_Flow.md).

*   **Ghi Cache Redis:**
    Đẩy Top 5 trend vào Redis Sorted Set với key `trends:vn:2026-07-18:food` (sử dụng dấu gạch ngang phân tách ngày theo chuẩn `DA-E06-06`):
    ```bash
    ZADD trends:vn:2026-07-18:food 7.82 '{"keyword": "trà sữa đất nung", "platform": "google", "region": "VN", "rank": 1}'
    ZADD trends:vn:2026-07-18:food 6.97 '{"keyword": "labubu", "platform": "tiktok", "region": "VN", "rank": 2}'
    EXPIRE trends:vn:2026-07-18:food 21600 # Hết hạn sau 6 giờ (TTL 6 tiếng)
    ```
*   **Ghi đè thuộc tính Trend vào Neo4j (Batch Upsert):**
    Chạy Cypher sử dụng `UNWIND` kết hợp `MERGE` và `ON CREATE/MATCH SET` để cập nhật xếp hạng mà không mất lịch sử ngày tạo:
    ```cypher
    // Danh sách $batch: [{keyword: "trà sữa đất nung", score: 7.82, rank: 1, category: "food"}, ...]
    UNWIND $batch AS item
    MERGE (t:Trend {name: item.keyword})
    ON CREATE SET 
        t.category = item.category,
        t.createdAt = datetime(),
        t.finalScore = item.score,
        t.rank = item.rank,
        t.updatedAt = datetime()
    ON MATCH SET 
        t.finalScore = item.score,
        t.rank = item.rank,
        t.updatedAt = datetime()
    ```

#### 2. Nạp tri thức chi tiết phục vụ GraphRAG (Task `99-05`)
Chi tiết thiết kế sơ đồ dữ liệu lai xem tại: [Tài liệu Thiết kế Cấu trúc Cơ sở Dữ liệu Lai (ChromaDB + Neo4j)](file:///d:/FPT/FA26/brandhub-infrastructure/docs/database/DA-AI04-99-05_Hybrid_DB_Schema.md).

*   **Nạp vào ChromaDB (Lưu trữ Vector):**
    ```json
    {
      "id": "chunk_tra_sua_dat_nung_8a7f92b9b2c8a14b537d8009623b3f2c5d1e2f3a",
      "document": "Quán trà sữa đất nung Hàng Bồ nằm tại số 10 Hàng Bồ rất ngon, review bởi KOL ninheating đạt 1.2M view.",
      "embedding": [0.0152, -0.0843, 0.2311, -0.1102, "... (384 dimensions)"],
      "metadata": {
        "trendName": "trà sữa đất nung",
        "chunkIndex": 0,
        "sourcePlatform": "TikTok",
        "author": "ninheating",
        "interactionScore": 14.0,
        "docId": "mongo_doc_9904_001",
        "createdAt": "2026-07-20T09:00:00Z"
      }
    }
    ```
*   **Nạp vào Neo4j (Lưu trữ đồ thị thực thể quan hệ - NER Graph):**
    Chạy câu lệnh Cypher kết nối tri thức (Đảm bảo mọi quan hệ đều hướng về Node `:Trend`):
    ```cypher
    // Lấy node Trend đã cập nhật ở trên
    MATCH (t:Trend {name: "trà sữa đất nung"})
    
    // Tạo/Cập nhật node KOL và Location mới
    MERGE (k:KOL {username: "ninheating"})
    ON CREATE SET k.platform = "TikTok", k.followers = 1200000, k.updatedAt = datetime()
    
    MERGE (l:Location {name: "Hàng Bồ"})
    ON CREATE SET l.city = "Hà Nội", l.country = "Việt Nam", l.updatedAt = datetime()
    
    // Tạo các quan hệ ngữ nghĩa trỏ về node Trend t
    MERGE (k)-[:PROMOTED {views: 1200000, likes: 45000, platform: "TikTok", postedAt: datetime("2026-07-18T12:30:00Z")}]->(t)
    MERGE (l)-[:LOCATED_IN {mentionCount: 89, isOrigin: true, updatedAt: datetime()}]->(t)
    ```

*➔ Kết quả hoàn thành:* Đồ thị Neo4j lúc này đã được làm giàu bởi các mối quan hệ thực tế bao quanh xu hướng "trà sữa đất nung" với tất cả các quan hệ hướng về `:Trend`. Khi người dùng thực hiện truy vấn ở Luồng B, thuật toán GraphRAG sẽ duyệt đồ thị này và tìm ra chính xác KOL `ninheating` và địa điểm `Hàng Bồ` để cung cấp cho LLM sinh kịch bản bắt trend chất lượng nhất. Chi tiết giải thuật chạy nền xử lý trùng lặp thực thể (Entity Resolution) cũng được cấu hình định kỳ để hợp nhất các node viết tắt/đồng nghĩa (ví dụ: "HN" -> "Hà Nội").
