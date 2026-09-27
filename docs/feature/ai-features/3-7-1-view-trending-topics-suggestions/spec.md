# 3.7.1 View Trending Topics Suggestions

| | |
|---|---|
| FR Code | 3.7.1 |
| Feature | View Trending Topics Suggestions |
| Domain | AI Features (FR 3.7) |
| Role | CREATOR (và OWNER, MANAGER trong Workspace) |
| Version | 2.5 — 2026-09-27 — Chuyển đổi chuẩn SRS, chuẩn hóa mô hình Trend 7 tầng T1-T7 functional responsibilities (T0 Ingestion nằm ngoài 7 tầng theo PO D02), bộ lọc đa chiều (Category, Time Window 6h/24h/7d, Platform), cơ chế xử lý Stale Data / Degraded State khi pipeline chậm cập nhật, handoff ngữ cảnh sang Caption (3.7.2) và Hashtag (3.7.10). |
| Document status | Target Spec |
| Implementation status | In Progress |

## Function Trigger

Bắt đầu khi người dùng có vai trò `CREATOR`, `MANAGER`, hoặc `OWNER` điều hướng tới trang Khám phá Xu hướng tại đường dẫn `/workspaces/:workspaceId/ai/trends`, hoặc mở modal "Gợi ý Xu hướng" khi đang tạo/soạn thảo nội dung bài post trong quy trình công việc Task Detail (FR 3.6.4 / 3.7.2).

## Function Description

- **Actors / Roles:** `CREATOR` (sở hữu Bearer JWT hợp lệ và là thành viên có quyền truy cập vào `workspaceId`). `MANAGER` và `OWNER` của Workspace có quyền xem tương đương. Các yêu cầu không thuộc Workspace hoặc chưa đăng nhập đều bị chặn tại API Gateway.
- **Purpose:** Cung cấp bảng điều khiển trực quan tổng hợp các chủ đề, từ khóa và trào lưu (Trending Topics / Keywords) đang dẫn đầu xu hướng tương tác trên mạng xã hội và công cụ tìm kiếm tại Việt Nam. Cung cấp chỉ số lan truyền (Virality Score), phân loại ngành hàng, phân tích sắc thái cảm xúc (Sentiment/Mood), và các từ khóa liên quan giúp Creator nắm bắt thị hiếu tức thời, sáng tạo nội dung viral, và chọn trực tiếp chủ đề làm ngữ cảnh đầu vào cho bộ sinh Caption (FR 3.7.2) hoặc bộ gợi ý Hashtag (FR 3.7.10).
- **Interface:** Bảng điều khiển `/workspaces/:workspaceId/ai/trends`:
  - Thanh công cụ lọc đa chiều (Filter Toolbar):
    - *Ngành hàng (Category):* `all` (Tất cả), `tech` (Công nghệ), `entertainment` (Giải trí/Showbiz), `food` (Ẩm thực/F&B), `sports` (Thể thao), `lifestyle` (Đời sống/GenZ), `news` (Thời sự/Xã hội), `beauty` (Làm đẹp/Thời trang).
    - *Khung thời gian (Time Window):* `6h` (Live Snapshot - Thời gian thực), `24h` (Daily Accumulated - Xu hướng trong ngày), `7d` (Weekly Aggregate - Xu hướng trong tuần).
    - *Nền tảng tín hiệu (Platform):* `all` (Đa nền tảng), `tiktok`, `facebook`, `google_trends`, `news` (Báo điện tử).
  - Thanh trạng thái độ tươi mới dữ liệu (Data Freshness Bar):
    - Hiển thị thời điểm cập nhật gần nhất (`lastRefreshedAt`).
    - Huy hiệu trạng thái: Xanh lá (`Dữ liệu mới nhất`), hoặc Vàng cảnh báo (`Dữ liệu chậm cập nhật (> 12h) - Đang tái đồng bộ` khi xảy ra tình trạng Stale Data).
    - Nút "Làm mới (Refresh)" để tải lại danh sách xu hướng mới nhất từ Redis cache.
  - Lưới hiển thị thẻ xu hướng (Trend Cards Grid/List):
    - Thứ hạng xu hướng (#1, #2, ... #20).
    - Tên chủ đề / Từ khóa chính (`keyword` / `title`).
    - Điểm lan truyền (Virality Score từ 0 đến 100).
    - Huy hiệu mức độ nóng (Heat Level): 🔥 Bùng nổ (Score ≥ 85), 📈 Đang tăng trưởng (70 ≤ Score < 85), 🟢 Ổn định (Score < 70).
    - Phân tích sắc thái (Mood / Sentiment): `Positive` (Tích cực), `Excited` (Hào hứng), `Controversial` (Tranh cãi), `Neutral` (Trung tính).
    - Danh sách thực thể đồng xuất hiện và từ khóa phụ (Sub-keywords & Entities tags).
    - Nền tảng ghi nhận tín hiệu nổi trội kèm số lượng tương tác ước tính.
    - Cụm nút thao tác nhanh:
      - Nút "Viết bài theo Trend này" (Chuyển tiếp ngữ cảnh trend sang FR 3.7.2 Generate Caption).
      - Nút "Xem Hashtags liên quan" (Mở drawer gợi ý hashtag FR 3.7.10).
- **Data Processing:**
  - **Mô hình Pipeline Trend 7 Tầng (T0 Ingestion + T1-T7 Phân công Trách nhiệm Chức năng - PO D02/§2.3):**
    - *T0 — Ingestion (Thu nạp ngoài 7 tầng):* Thu thập bài viết thô từ các crawler đa nguồn (TikTok, Facebook, Google Trends, News theo FR 3.7.9) đẩy vào buffer hàng đợi S3 và Redis Stream.
    - *T1 — Bot & Spam Filter (Lọc rác):* Lọc bỏ các bài đăng quảng cáo rác, tài khoản bot, nội dung vi phạm tiêu chuẩn cộng đồng, áp dụng hàm băm SimHash/MD5 để khử trùng lặp nội dung (Deduplication) trong cửa sổ trượt 72 giờ.
    - *T2 — NLP & Vietnamese Tokenization (Xử lý ngôn ngữ tự nhiên):* Sử dụng công cụ tách từ chuyên sâu tiếng Việt, nhận diện thực thể có tên (Named Entity Recognition - NER: nhân vật, địa danh, thương hiệu), lọc danh sách từ dừng (Stopwords).
    - *T3 — Taxonomy Categorization (Phân loại chủ đề):* Phân loại bài viết vào các nhánh danh mục ngành hàng chuẩn hóa độc lập của hệ thống Trend (không dùng lẫn với taxonomy ngành hàng ảnh).
    - *T4 — BM25 Burst/Spike Detection (Phát hiện đột biến):* Tính toán sự tăng vọt bất thường về tần suất từ khóa so với đường nền lịch sử bằng thuật toán cửa sổ trượt BM25.
    - *T5 — Engagement & Mood Analysis (Phân tích tương tác và cảm xúc):* Đo lường gia tốc tương tác (like, share, comment velocity) và gán nhãn sắc thái tình cảm của cộng đồng đối với chủ đề.
    - *T6 — Graph Community & Virality (Đồ thị lan truyền):* Xây dựng đồ thị liên kết đồng xuất hiện (Co-occurrence network) giữa các thực thể và từ khóa, phân tích cụm cộng đồng để phát hiện mối liên hệ chéo giữa các chủ đề.
    - *T7 — Trend Fusion & Scoring (Hợp nhất và Xếp hạng):* Tổng hợp các trọng số tín hiệu đa nguồn thành một đối tượng xu hướng hoàn chỉnh (`TrendObject`), tính toán `finalScore` (0-100) và xuất danh sách Top 10-20 xu hướng hàng đầu.
  - **Lưu trữ và Truy vấn Siêu tốc:** Kết quả T7 được lưu vào Redis Sorted Set (ZSET) với các cấu trúc khóa: `trends:vn:live:{category}` cho khung 6h, `trends:vn:{date}:{category}` cho khung 24h, và kết hợp `ZUNIONSTORE` cho khung 7 ngày (`trends:vn:7d:{category}`). TTL của bảng danh sách trend là 6 giờ; TTL của Trend Context chi tiết là 30 phút (PO §2.3). Độ trễ phản hồi từ cache đạt dưới 10ms.
  - **Cơ chế Xử lý Stale Data / Degraded Mode (PO D07/D12):**
    - Nếu pipeline xử lý bị chậm hoặc crawler gặp sự cố dẫn tới quá 12 giờ chưa có đợt xử lý mới: Hệ thống tự động phục vụ dữ liệu gần nhất còn lưu trong Redis, bổ sung cờ `isStale: true` và `staleHours` trong response header/body để giao diện hiển thị cảnh báo người dùng thay vì báo lỗi hệ thống.
    - Nếu Redis cache rỗng hoàn toàn (Cold start hoặc sự cố máy chủ Redis): Hệ thống tự động fallback đọc bản snapshot dự phòng gần nhất từ S3 bucket (`s3://brandhub-trends/snapshots/latest.json`). Nếu cả S3 cũng không có dữ liệu, trả về mảng rỗng `data: []` kèm thông báo hướng dẫn, tuyệt đối không trả mã lỗi 500.

## Routes / DTOs (ground truth: `trends.py`, `trend_cache_service.py`, `trend_models.py`)

| Route | Auth | Request body | Response | Notes |
|---|---|---|---|---|
| `GET /api/v1/workspaces/{workspaceId}/ai/trends` | Bearer (CREATOR / MANAGER / OWNER) | Query: `period=24h&category=all&platform=all&limit=20` | `ApiResponse<TrendListResponse>` 200 | Lấy danh sách Top trends từ Redis ZSET (<10ms). Hỗ trợ lọc theo thời gian, ngành hàng, nền tảng. |
| `GET /api/v1/workspaces/{workspaceId}/ai/trends/{trendId}/context` | Bearer (CREATOR / MANAGER / OWNER) | none | `ApiResponse<TrendContextResponse>` 200 | Lấy ngữ cảnh chi tiết (bản tóm tắt <800 tokens, quan hệ thực thể, mẫu bài cào) để cấp cho Caption/Hashtag. |
| `GET /api/v1/ai/trends` (Internal Service) | `X-Internal-Api-Key` | Query: `period=24h&category=all&date=&limit=20` | `List<Dict<String, Object>>` 200 | Endpoint nội bộ của `ai-service` phục vụ `business-service` truy vấn dữ liệu thô từ Redis ZSET. |

### Chi tiết Request / Response DTO

```json
// GET /api/v1/workspaces/{workspaceId}/ai/trends?period=24h&category=entertainment&limit=10
// Response 200
{
  "success": true,
  "data": {
    "period": "24h",
    "category": "entertainment",
    "platform": "all",
    "lastRefreshedAt": "2026-09-27T08:30:00+07:00",
    "isStale": false,
    "totalTrends": 10,
    "trends": [
      {
        "trendId": "trd_vn_20260927_001",
        "rank": 1,
        "keyword": "Rap Viet 2026 Chung Ket",
        "finalScore": 96.5,
        "heatLevel": "EXPLOSIVE",
        "category": "entertainment",
        "mood": "EXCITED",
        "coOccurringEntities": ["HIEUTHUHAI", "JustaTee", "Quan Quan", "Track 01"],
        "primaryPlatform": "tiktok",
        "platformsDetected": ["tiktok", "facebook", "news"],
        "sampleSnippet": "Đêm chung kết Rap Việt 2026 bùng nổ với các màn trình diễn xuất sắc từ các thí sinh...",
        "detectedAt": "2026-09-27T06:00:00+07:00"
      },
      {
        "trendId": "trd_vn_20260927_002",
        "rank": 2,
        "keyword": "Ra Mat Dien Thoai Gap Mua Thu",
        "finalScore": 88.2,
        "heatLevel": "EXPLOSIVE",
        "category": "tech",
        "mood": "POSITIVE",
        "coOccurringEntities": ["Camera 200MP", "Pin 6000mAh", "Dat Truoc", "Gia Ban"],
        "primaryPlatform": "facebook",
        "platformsDetected": ["facebook", "google_trends", "news"],
        "sampleSnippet": "Dòng smartphone màn hình gập thế hệ mới chính thức mở đặt trước với nhiều ưu đãi lớn...",
        "detectedAt": "2026-09-27T04:15:00+07:00"
      }
    ]
  }
}
```

```json
// GET /api/v1/workspaces/{workspaceId}/ai/trends/trd_vn_20260927_001/context
// Response 200
{
  "success": true,
  "data": {
    "trendId": "trd_vn_20260927_001",
    "keyword": "Rap Viet 2026 Chung Ket",
    "category": "entertainment",
    "mood": "EXCITED",
    "summaryTokenCount": 240,
    "contextPromptSnippet": "Xu hướng: Chung kết Rap Việt 2026 đang bùng nổ trên mạng xã hội với sự chú ý vào các màn trình diễn bứt phá và quán quân mới. Cảm xúc cộng đồng: Hào hứng, sôi động. Các từ khóa liên quan: HIEUTHUHAI, JustaTee, Quán Quân, màn trình diễn đỉnh cao.",
    "suggestedHashtags": ["#RapViet2026", "#ChungKetRapViet", "#RapViet", "#HIEUTHUHAI", "#TrendingVN"],
    "cachedUntil": "2026-09-27T09:00:00+07:00"
  }
}
```

## Screen Layout

Căn cứ trang `/workspaces/:workspaceId/ai/trends`:
- **Top Header:**
  - Tiêu đề: "Khám Phá Xu Hướng Mạng Xã Hội (Trending Topics & Insights)".
  - Mô tả: "Tổng hợp các chủ đề nóng nhất từ TikTok, Facebook, Google và Báo chí phục vụ sáng tạo nội dung."
  - Thanh Freshness indicator: Dot trạng thái (Xanh / Vàng), nhãn "Cập nhật lúc 08:30 (Mới nhất)", nút bấm icon "Làm mới".
- **Filter Bar Container:**
  - Nhóm nút chuyển tab thời gian: `[ 6 Giờ (Live) ]` | `[ 24 Giờ (Ngày) ]` | `[ 7 Ngày (Tuần) ]`.
  - Dropdown chọn Ngành hàng: Icon ngành + Tên ngành (Tất cả ngành, Công nghệ, Ẩm thực, Giải trí, Thể thao, Đời sống, Tin tức, Làm đẹp).
  - Dropdown chọn Nền tảng: Tất cả nền tảng, TikTok, Facebook, Google Trends, Báo điện tử.
  - Ô tìm kiếm từ khóa xu hướng trong danh sách hiện tại.
- **Trend Grid View (Lưới thẻ xu hướng):**
  - Mỗi hàng/thẻ đại diện cho 1 Trend Object:
    - Huy hiệu thứ hạng nổi bật: Vàng kim cho Top 1, Bạc cho Top 2, Đồng cho Top 3, Xám cho các vị trí còn lại.
    - Cột thông tin chính: Keyword in đậm kích thước lớn, nhãn Category, huy hiệu Heat Level (Lửa đỏ cho Explosive, Mũi tên xanh cho Trending).
    - Cột Sắc thái (Mood): Badge màu phân biệt (Xanh lá - Hào hứng/Tích cực, Cam - Tranh cãi, Xám - Trung tính).
    - Cột Từ khóa đồng xuất hiện: Các chip từ khóa nhỏ có thể bấm để xem ngữ cảnh nhanh.
    - Cột Điểm lan truyền (Virality Score): Thanh đo tròn hoặc thanh ngang hiển thị điểm số trên thang 100.
    - Cột Nền tảng phát hiện: Cụm icon mạng xã hội có ghi nhận dữ liệu cào.
    - Cột Hành động:
      - Nút "Sáng tạo bài viết": Icon bút viết, click mở nhanh Drawer hoặc chuyển hướng sang Tạo Caption kèm bối cảnh trend đã chọn.
      - Nút "Hashtag": Icon thăng `#`, click mở nhanh danh sách hashtag gợi ý từ trend.
- **Empty & Stale States:**
  - *Stale State Banner:* Cảnh báo màu vàng phía trên bảng: *"Dữ liệu xu hướng chưa được làm mới trong 12 giờ qua do sự cố kết nối crawler. Bạn đang xem dữ liệu lưu trữ lúc {lastRefreshedAt}."*
  - *Empty State:* Hình minh họa radar quét xu hướng, text: *"Hiện chưa có xu hướng nào được ghi nhận cho bộ lọc đã chọn. Vui lòng thử chọn ngành hàng khác hoặc khung thời gian 24h/7d."*

## Function Details

### Data Specifications

- **Input required:**
  - `workspaceId`: UUID của Workspace đang làm việc (xác thực quyền thành viên).
- **Input optional:**
  - `period`: Chuỗi xác định khung thời gian, thuộc enum `["6h", "24h", "7d"]` (mặc định `"24h"`).
  - `category`: Chuỗi danh mục ngành hàng, thuộc enum `["all", "tech", "entertainment", "food", "sports", "lifestyle", "news", "beauty"]` (mặc định `"all"`).
  - `platform`: Chuỗi nền tảng, thuộc enum `["all", "tiktok", "facebook", "google_trends", "news"]` (mặc định `"all"`).
  - `limit`: Số nguyên dương quy định số lượng xu hướng trả về, phạm vi [1, 50], mặc định 20.
- **System data:**
  - Redis ZSET keys: `trends:vn:live:{category}`, `trends:vn:{date}:{category}`, `trends:vn:7d:{category}`.
  - Redis Context keys: `trend:context:{trendId}` (TTL 30 phút).
  - Metadata: `lastRefreshedAt`, `isStale`, `pipelineVersion`.
- **Output:**
  - `TrendListResponse`: Danh sách đối tượng xu hướng đã sắp xếp theo thứ tự giảm dần của `finalScore`.
  - `TrendContextResponse`: Bản tóm tắt ngữ cảnh chuẩn hóa (<800 tokens) sẵn sàng đưa vào prompt LLM.

### Business Rules

- **BR-AI-10 (Xác thực Quyền thành viên Workspace):** Người dùng chỉ được xem dữ liệu xu hướng khi là thành viên hợp lệ (vai trò `CREATOR`, `MANAGER`, hoặc `OWNER`) của `workspaceId` gửi trong yêu cầu. Mặc dù dữ liệu xu hướng là tài nguyên phân tích chung toàn hệ thống, API gateway bắt buộc kiểm tra quan hệ thành viên để phục vụ ghi log hoạt động và liên kết dự án.
- **BR-AI-11 (Mô hình 7 Tầng Trách nhiệm Chức năng & Tách biệt Taxonomy):**
  - Toàn bộ quy trình phát hiện xu hướng tuân thủ nghiêm ngặt 7 tầng trách nhiệm T1–T7 (T0 Ingestion nằm ngoài 7 tầng - PO D02/§2.3).
  - Taxonomy ngành hàng của Trend (`tech`, `food`, `entertainment`...) là cấu hình chuẩn hóa riêng biệt của module phân tích dữ liệu, tuyệt đối không được dùng lẫn lộn với phân loại phong cách ảnh của Image Studio hay Topic LoRA cũ (PO §2.3).
- **BR-AI-12 (Quy định Time Window và Cơ chế Cache Redis ZSET):**
  - Khung `6h`: Đại diện cho các từ khóa bùng nổ tức thì trong 6 giờ qua, đọc từ `trends:vn:live:{category}`.
  - Khung `24h`: Đại diện cho xu hướng tích lũy trong ngày, đọc từ `trends:vn:{date}:{category}`.
  - Khung `7d`: Đại diện cho xu hướng tuần, tổng hợp qua phép hợp tập hợp có trọng số `ZUNIONSTORE` từ 7 ngày gần nhất.
  - Điểm số `finalScore` trong ZSET đại diện cho Virality Index kết hợp giữa độ đột biến tần suất (BM25) và tín hiệu tương tác mạng xã hội, không được công bố hoặc gọi là "Search Volume tuyệt đối" khi không có dữ liệu search volume chính thức (PO §2.3).
- **BR-AI-13 (Chính sách Xử lý Dữ liệu Cũ và Suy thoái Dịch vụ - Stale Data / Degraded Mode):**
  - Nếu khoảng cách từ `lastRefreshedAt` đến hiện tại lớn hơn 12 giờ: Hệ thống tự động kích hoạt chế độ Stale Data, gán `isStale: true` trong phản hồi và hiển thị cảnh báo thân thiện trên giao diện.
  - Nếu Redis cache rỗng hoặc bị flush: Tự động fallback đọc snapshot S3 gần nhất. Tuyệt đối không để xảy ra tình trạng sập trang (HTTP 500) khi dữ liệu cào bị trễ.
- **BR-AI-14 (Không Tiêu tốn AI Credit):** Việc truy cập, xem bảng điều khiển xu hướng, lọc danh mục, hoặc đọc tóm tắt ngữ cảnh trend là hoàn toàn **MIỄN PHÍ** (0 AI Credit). Credit chỉ được tính khi người dùng chính thức sử dụng ngữ cảnh trend để sinh Caption (FR 3.7.2) hoặc sinh Script (FR 3.7.11) có gọi model LLM.
- **BR-AI-15 (Chuyển giao Ngữ cảnh Handoff sang Tạo Nội dung):**
  - Khi người dùng bấm "Viết bài theo Trend này", hệ thống trích xuất `TrendContext` (<800 tokens gồm tóm tắt, từ khóa đồng xuất hiện, mood) và chuyển trực tiếp làm tham số đầu vào cho FR 3.7.2 Generate Caption.
  - Creator không cần sao chép / dán nội dung thủ công giữa hai màn hình.

### Validation

- `workspaceId` không hợp lệ hoặc người dùng không thuộc Workspace → 403 `FORBIDDEN`, hiển thị: MSG-AI-10.
- `period` không nằm trong danh sách `["6h", "24h", "7d"]` → 400 `INVALID_PERIOD_PARAMETER`, hiển thị: MSG-AI-11.
- `category` không nằm trong danh mục hệ thống hỗ trợ → 400 `INVALID_CATEGORY_PARAMETER`, hiển thị: MSG-AI-12.
- `platform` không nằm trong danh sách nền tảng hỗ trợ → 400 `INVALID_PLATFORM_PARAMETER`, hiển thị: MSG-AI-13.
- `limit` nhỏ hơn 1 hoặc lớn hơn 50 → 400 `INVALID_LIMIT_PARAMETER`, hiển thị: MSG-AI-14.
- `trendId` không tồn tại trong cache hoặc đã quá hạn lưu trữ → 404 `TREND_NOT_FOUND`, hiển thị: MSG-AI-15.

## Functionalities

### Normal Flow

1. **Truy cập Dashboard Trend:** Creator đăng nhập vào Workspace, bấm chọn menu "AI Studio / Xu Hướng (Trends)". Trình duyệt gửi `GET /api/v1/workspaces/{workspaceId}/ai/trends?period=24h&category=all&platform=all&limit=20`.
2. **Kiểm tra Xác thực và Truy vấn Cache:** Hệ thống kiểm tra quyền thành viên Workspace, đọc dữ liệu trực tiếp từ Redis Sorted Set theo key `trends:vn:{current_date}:all`.
3. **Phản hồi Dữ liệu:** Redis trả về danh sách 20 xu hướng hàng đầu kèm điểm `finalScore` trong vòng dưới 10ms. Hệ thống tính toán thời gian `lastRefreshedAt`, xác nhận `isStale: false`, và trả về 200 OK kèm `TrendListResponse`.
4. **Hiển thị Giao diện:** Giao diện dựng lưới các thẻ xu hướng, hiển thị đầy đủ thứ hạng #1 đến #20, từ khóa, nhãn ngành hàng, icon nền tảng, huy hiệu sắc thái cảm xúc (Mood), và các từ khóa liên quan.
5. **Thực hiện Lọc theo Ngành:** Creator chọn danh mục "Ẩm thực (food)" và khung thời gian "6 Giờ (Live)". Trình duyệt gửi `GET /api/v1/workspaces/{workspaceId}/ai/trends?period=6h&category=food&limit=20`.
6. **Truy vấn Realtime Snapshot:** Hệ thống đọc Redis key `trends:vn:live:food`, trả về danh sách các trào lưu ẩm thực đang bùng nổ trong 6 giờ qua.
7. **Chọn Xu hướng để Viết bài:** Creator quan tâm đến xu hướng Top 1 và bấm nút "Viết bài theo Trend này".
8. **Handoff Ngữ cảnh sang Caption:** Hệ thống gọi `GET /api/v1/workspaces/{workspaceId}/ai/trends/{trendId}/context` để lấy gói tóm tắt <800 tokens, tự động mở Drawer/Modal Tạo Caption (FR 3.7.2) với trường `topic` và `trendContext` đã được điền sẵn đầy đủ.

### Abnormal Cases

- **1.a1: Người dùng không thuộc Workspace hoặc phiên làm việc hết hạn (BR-AI-10)**
  - *Hành vi:* API Gateway từ chối với HTTP 403 `FORBIDDEN` (MSG-AI-10).
  - *Xử lý phía UI:* Hiển thị thông báo: *"Bạn không có quyền truy cập dữ liệu xu hướng của Workspace này"* và chuyển hướng người dùng về trang chọn Workspace.
- **2.a1: Dữ liệu chưa cập nhật quá 12 giờ do sự cố Crawler (Stale Data Mode - BR-AI-13)**
  - *Hành vi:* Backend kiểm tra timestamp của bản ghi trong Redis, nhận thấy độ chênh lệch > 12h. Backend vẫn trả dữ liệu với HTTP 200 nhưng đính kèm `isStale: true` và `staleHours: 14`.
  - *Xử lý phía UI:* Giao diện vẫn hiển thị danh sách xu hướng bình thường nhưng hiển thị Banner vàng cảnh báo: *"Dữ liệu xu hướng được cập nhật lần cuối cách đây 14 giờ. Hệ thống đang tiến hành thu thập đợt mới."*
- **2.b1: Redis Cache rỗng hoàn toàn do vừa khởi động hệ thống (Cold Start / Cache Purge - BR-AI-13)**
  - *Hành vi:* Redis trả về mảng rỗng. Backend tự động chuyển hướng đọc file snapshot mới nhất từ S3 (`s3://brandhub-trends/snapshots/latest.json`). Nếu tìm thấy snapshot, nạp nhanh vào Redis và trả về kết quả.
  - *Xử lý phía UI:* Người dùng nhận kết quả bình thường với độ trễ phản hồi khoảng 200-300ms trong lần tải đầu tiên.
- **2.b2: Cả Redis và S3 đều chưa có dữ liệu (Hệ thống hoàn toàn mới, chưa từng chạy crawl)**
  - *Hành vi:* Backend trả về HTTP 200 với mảng rỗng `trends: []` kèm thông điệp giải thích.
  - *Xử lý phía UI:* Hiển thị màn hình Empty State thân thiện: *"Hệ thống AI đang khởi động quá trình thu thập dữ liệu xu hướng đầu tiên. Vui lòng quay lại sau ít phút hoặc liên hệ Quản trị viên."*
- **5.a1: Nhập tham số lọc không hợp lệ (Ví dụ: `period=90d`, `category=invalid_cat`)**
  - *Hành vi:* Backend xác thực schema, trả về HTTP 400 `INVALID_PARAMETER` kèm tên trường sai (MSG-AI-11 / MSG-AI-12).
  - *Xử lý phía UI:* Giao diện tự động reset bộ lọc về giá trị mặc định (`period=24h`, `category=all`) và hiển thị toast cảnh báo.
- **8.a1: Bấm lấy ngữ cảnh chi tiết nhưng `trendId` đã bị xóa khỏi cache (TTL 30 phút hết hạn)**
  - *Hành vi:* Backend truy vấn Redis `trend:context:{trendId}` bị cache miss, trả về HTTP 404 `TREND_NOT_FOUND` (MSG-AI-15).
  - *Xử lý phía UI:* Hệ thống tự động kích hoạt bước tái tạo ngữ cảnh (Regenerate context on-the-fly) từ dữ liệu tóm tắt thô hoặc thông báo người dùng chọn lại từ danh sách xu hướng hiện thời.

## Post-Conditions

- **Khi xem xu hướng thành công:**
  - Không có thay đổi trạng thái dữ liệu (thao tác thuần đọc - Idempotent).
  - Không có giao dịch credit nào bị trừ.
  - Trình duyệt lưu tạm danh sách xu hướng trong phiên (Session storage) để tránh gọi lại API liên tục khi người dùng chuyển đổi qua lại giữa các tab trong vòng 5 phút.
- **Khi chọn chuyển giao xu hướng sang Caption:**
  - `TrendContext` được lưu vào bộ nhớ tạm của trình soạn thảo.
  - Modal FR 3.7.2 được kích hoạt với đầy đủ bối cảnh xu hướng sẵn sàng cho bước lập trình tạo nội dung.

## Out of Scope

- Dự đoán chính xác doanh số bán hàng từ độ nóng của xu hướng (Hệ thống chỉ cung cấp chỉ số lan truyền truyền thông, không đảm bảo chuyển đổi kinh doanh).
- Tùy biến thuật toán xếp hạng T1-T7 theo từng tài khoản Creator (Toàn bộ các bước xử lý và trọng số là thống nhất toàn hệ thống).
- Xu hướng quốc tế ngoài phạm vi địa lý Việt Nam trong giai đoạn này (Hệ thống tập trung nguồn crawl tại Việt Nam theo cấu hình hiện tại).

## References

- **Căn cứ kế hoạch & Quyết định PO:** `docs/plan/ai-features-spec-alignment-plan.md` (Mục 1 Quyết định 2026-09-27, Mục 2.3 Trend Collection & Trend Context, Mục 3 Quyết định D02 Mô hình 7 Tầng, D07 Stale Data, Mục 4 Bảng điều chỉnh FR 3.7.1, Mục 8 Ghi nhận code local).
- **Phân tích Nghiệp vụ:** `docs/ba/06-ai-features.md` (Mục 3.7.1 View Trending Topics Suggestions); `docs/ba/use-cases/05-ai-features.md` (UC-74 View Trending Topics & Hashtag Suggestions).
- **Kiến trúc & Service Contract:** `docs/architecture/business-ai-rest-contract.md` (Endpoint `GET /internal/ai/trending`); `docs/architecture/service-boundaries.md`.
- **Hiện trạng Codebase:** `brandhub-ai-service/app/api/v1/endpoints/trends.py` (`GET /api/v1/ai/trends`), `brandhub-ai-service/app/services/trend_cache_service.py` (Redis ZSET Caching `trends:vn:*`), `brandhub-ai-service/app/services/trend_pipeline.py` (Pipeline steps T1–T7), `brandhub-ai-service/app/services/pipeline/steps/t6_graph_step.py`, `brandhub-ai-service/app/services/pipeline/steps/t7_fusion_step.py`.
- **Mã thông báo & Quy tắc:** `Section5_Requirement_Appendix.md` (Quy ước mã lỗi `MSG-AI-xx`, quy tắc phân quyền `BR-AI-xx`).
