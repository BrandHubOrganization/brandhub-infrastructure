# 3.7.10 Suggest Hashtag Trend

| | |
|---|---|
| FR Code | 3.7.10 |
| Feature | Suggest Hashtag Trend |
| Domain | AI Features (FR 3.7) |
| Role | CREATOR (và OWNER, MANAGER trong Workspace) |
| Version | 2.5 — 2026-09-27 — Chuyển đổi chuẩn SRS, làm rõ 2 ngữ cảnh sử dụng (In-editor khi soạn bài Post vs Nạp vào Workspace Hashtag Collection FR 3.6.19), phân loại minh bạch General Trend vs Niche Trend, chuẩn hóa cú pháp `#`, khử trùng lặp (dedup), lọc blacklist, chiến lược trích xuất Zero-LLM kết hợp Trend Cache và chính sách miễn phí credit (PO §2.4, D06). |
| Document status | Target Spec |
| Implementation status | In Progress |

## Function Trigger

Bắt đầu khi người dùng có vai trò `CREATOR`, `MANAGER`, hoặc `OWNER` kích hoạt tính năng thông qua một trong hai ngữ cảnh:
- **Ngữ cảnh A (In-editor khi viết bài):** Creator đang ở màn hình soạn thảo nội dung bài post (Task Detail / Content Writing View - FR 3.6.4 / 3.7.2) và bấm nút "Gợi ý Hashtag".
- **Ngữ cảnh B (Nạp vào Workspace Hashtag Collection):** Creator hoặc Manager đang ở màn hình Quản lý Bộ sưu tập Hashtag (`/workspaces/:workspaceId/hashtags` - FR 3.6.18) và bấm nút "Khám phá & Nạp Hashtag Trend".

## Function Description

- **Actors / Roles:** `CREATOR` (hoặc `MANAGER`, `OWNER`) thuộc Workspace. Yêu cầu Bearer JWT hợp lệ và quyền thao tác trên Task hoặc Workspace.
- **Purpose:** Tự động phân tích nội dung văn bản bài viết, chủ đề và ngành hàng để đề xuất danh sách hashtag tối ưu hóa thuật toán phân phối trên mạng xã hội. Phân định rạch ròi giữa **General Trending Hashtags** (các hashtag thực sự có bằng chứng đang thịnh hành trên toàn mạng xã hội từ Redis Trend Cache - PO §2.4) và **Niche / Topical Hashtags** (các hashtag chuyên sâu về ngành nghề, sản phẩm, cộng đồng ngách). Hỗ trợ chèn trực tiếp vào nội dung bài đăng hoặc lưu hàng loạt vào Workspace Hashtag Collection (FR 3.6.19) để tái sử dụng lâu dài.
- **Interface:** Modal / Drawer "Gợi Ý Hashtag Xu Hướng":
  - *Khu vực Nhập liệu (Input Section):*
    - Ô nhập văn bản tóm tắt bài viết (`content`) hoặc từ khóa chủ đề (`keywords` / `topic`). Tự động điền trước nếu mở từ Editor.
    - Dropdown chọn Nền tảng phân phối (`platform`): `tiktok`, `instagram`, `facebook`, `threads` (mỗi nền tảng có giới hạn số lượng và quy chuẩn riêng).
    - Dropdown chọn Ngành hàng (`category`): `all`, `tech`, `food`, `entertainment`, `lifestyle`, `beauty`, `sports`.
    - Thanh trượt số lượng hashtag mong muốn (`count`): từ 3 đến 30 tag (mặc định 10 tag).
    - Bộ lọc hiển thị: Checkbox `[x] General Trends (Đang bùng nổ)`, `[x] Niche & Brand (Chuyên sâu)`.
  - *Khu vực Hiển thị Kết quả (Hashtag Chips Display):*
    - **Nhóm 1 — General Trending (Xu hướng diện rộng):** Các tag gắn huy hiệu Ngọn lửa 🔥 kèm chỉ số Virality Score. Chỉ những hashtag có bằng chứng xác thực từ Redis Trend Cache mới được gán huy hiệu này (PO §2.4).
    - **Nhóm 2 — Niche & Topical (Ngành hàng & Ngách):** Các tag gắn huy hiệu 🏷️ đại diện cho từ khóa bám sát sản phẩm, ngành hàng và nội dung bài viết.
    - Mỗi tag là một Chip có thể bấm để chọn/bỏ chọn riêng lẻ, hiển thị số lượt bài viết/độ phổ biến ước tính.
  - *Thanh Thao tác (Action Footer):*
    - Nút "Chọn tất cả" / "Bỏ chọn tất cả".
    - Nút "Sao chép bộ tag" (Copy dạng chuỗi `#tag1 #tag2` vào Clipboard).
    - Nút "Chèn vào bài viết" (chỉ hiển thị trong Ngữ cảnh A — tự động chèn các tag đã chọn vào cuối trình soạn thảo Caption).
    - Nút "Lưu vào Hashtag Collection" (hiển thị trong cả 2 ngữ cảnh — mở popup lưu nhanh vào FR 3.6.19 với purpose `trending` hoặc `campaign`).
- **Data Processing:**
  - **Chiến lược Trích xuất Đa tầng (Zero-LLM ưu tiên & Fallback - PO §2.4):**
    - *Bước 1 (Truy vấn Trend Cache):* Hệ thống đọc danh sách Top Trends từ Redis ZSET (`trends:vn:live:{category}` và fallback sang `trends:vn:{date}:{category}`). Trích xuất các `keyword` chính và danh sách `keywords` mở rộng.
    - *Bước 2 (Khớp ngữ nghĩa & Bằng chứng Trending):* So khớp từ khóa trong văn bản đầu vào với các từ khóa trong Trend Cache. Những từ khóa trùng khớp hoặc tương đương ngữ nghĩa được gắn nhãn `trending: true` (General Trends).
    - *Bước 3 (Trích xuất Ngữ pháp Cục bộ - Local NLP):* Sử dụng công cụ NLP tách từ để trích xuất các danh từ, thực thể thương hiệu từ chính văn bản bài viết để hình thành nhóm Niche Trends.
    - *Bước 4 (LLM Fallback khi Cache rỗng hoặc bài viết quá dị biệt):* Nếu không có từ khóa nào khớp với Trend Cache và văn bản quá ngắn không trích xuất được Niche tags, hệ thống tự động kích hoạt LLM Fallback để suy luận danh sách hashtag phù hợp nhất.
  - **Chuẩn hóa & Khử trùng lặp (Sanitization & Deduplication):**
    - Đảm bảo mọi hashtag đều bắt đầu bằng ký tự `#`.
    - Loại bỏ toàn bộ khoảng trắng, dấu câu, ký tự đặc biệt và biểu tượng cảm xúc (emoji).
    - Hỗ trợ tiếng Việt không dấu (`#tet2026`) hoặc tiếng Việt có dấu dạng CamelCase (`#TetNguyenDan2026`).
    - Khử trùng lặp không phân biệt hoa thường (`#Tet2026` và `#tet2026` chỉ giữ lại 1 bản thể chuẩn hóa).
    - Lọc bỏ các từ cấm (Banned / Shadowban list) theo tiêu chuẩn kiểm duyệt của các mạng xã hội.
  - **Cắt gọt Tối ưu hóa theo Nền tảng (Platform Clamping):**
    - TikTok: Giới hạn tối đa 5-8 tags tốt nhất (tránh loãng thuật toán For You Page).
    - Instagram: Cho phép tối đa 30 tags, khuyến nghị 10-15 tags (cân bằng giữa reach rộng và reach ngách).
    - Facebook: Giới hạn 3-5 tags trọng tâm.
    - Threads: Giới hạn 1-3 tags chủ đề chính.
  - **Chính sách Tín dụng AI Credit (PO §2.4, D06):**
    - Chế độ Zero-LLM (trích xuất từ Redis Trend Cache và Local NLP): **0 AI Credit** (Hoàn toàn miễn phí).
    - Chế độ LLM Fallback (khi phải gọi model LLM để sinh từ khóa sáng tạo): Tính 1 micro-credit hoặc miễn phí theo chính sách của gói đăng ký.

## Routes / DTOs (ground truth: `content.py`, `hashtag_extractor.py`, `trend_cache_service.py`)

| Route | Auth | Request body | Response | Notes |
|---|---|---|---|---|
| `POST /api/v1/workspaces/{workspaceId}/ai/suggest-hashtags` | Bearer (CREATOR / MANAGER / OWNER) | `HashtagSuggestRequest` | `ApiResponse<HashtagSuggestResponse>` 200 | Trích xuất và đề xuất danh sách hashtag phân nhóm Trending vs Niche. |
| `POST /api/v1/workspaces/{workspaceId}/hashtags/bulk` | Bearer (CREATOR / MANAGER / OWNER) | `BulkAddHashtagsRequest` | `ApiResponse<BulkAddHashtagsResponse>` 201 | Lưu hàng loạt hashtag đã chọn vào Workspace Hashtag Collection (FR 3.6.19). |
| `POST /api/v1/content/hashtags` (Internal Service) | `X-Internal-Api-Key` | `HashtagGenerateRequest` | `HashtagGenerateResponse` 200 | Endpoint nội bộ của `ai-service` thực thi Zero-LLM extraction từ Redis ZSET. |

### Chi tiết Request / Response DTO

```json
// POST /api/v1/workspaces/{workspaceId}/ai/suggest-hashtags
// Request Body
{
  "content": "Trải nghiệm dòng smartphone màn hình gập mới nhất với camera 200MP và hiệu năng cực khủng. Đặt trước hôm nay nhận ngay quà tặng độc quyền!",
  "topic": "Ra mắt điện thoại gập",
  "category": "tech",
  "platform": "tiktok",
  "count": 8,
  "includeGeneralTrends": true,
  "includeNicheTrends": true
}
```

```json
// Response 200
{
  "success": true,
  "data": {
    "platform": "tiktok",
    "totalReturned": 8,
    "strategyUsed": "ZERO_LLM_TREND_CACHE",
    "creditsUsed": 0,
    "hashtags": [
      {
        "tag": "#DienThoaiGap",
        "type": "GENERAL_TREND",
        "isTrending": true,
        "viralityScore": 92.4,
        "evidenceSource": "tiktok",
        "description": "Xu hướng công nghệ đang thịnh hành trên TikTok"
      },
      {
        "tag": "#TechReview",
        "type": "GENERAL_TREND",
        "isTrending": true,
        "viralityScore": 85.1,
        "evidenceSource": "tiktok",
        "description": "Hashtag review công nghệ phổ biến"
      },
      {
        "tag": "#Camera200MP",
        "type": "NICHE_TREND",
        "isTrending": false,
        "viralityScore": 68.0,
        "evidenceSource": "content_nlp",
        "description": "Tính năng nổi bật trích xuất từ bài viết"
      },
      {
        "tag": "#Smartphone2026",
        "type": "NICHE_TREND",
        "isTrending": false,
        "viralityScore": 62.5,
        "evidenceSource": "content_nlp",
        "description": "Chủ đề ngành hàng công nghệ"
      }
    ],
    "formattedString": "#DienThoaiGap #TechReview #Camera200MP #Smartphone2026"
  }
}
```

```json
// POST /api/v1/workspaces/{workspaceId}/hashtags/bulk
// Request Body (Lưu vào Collection FR 3.6.19)
{
  "tags": ["#DienThoaiGap", "#Camera200MP"],
  "purpose": "trending",
  "campaignId": null
}

// Response 201
{
  "success": true,
  "data": {
    "addedCount": 2,
    "existingCount": 0,
    "addedHashtags": [
      { "id": "htg_111", "tag": "#DienThoaiGap", "purpose": "trending" },
      { "id": "htg_222", "tag": "#Camera200MP", "purpose": "trending" }
    ]
  }
}
```

## Screen Layout

Căn cứ Modal / Drawer "Gợi Ý Hashtag Xu Hướng":
- **Header:**
  - Tiêu đề: "Gợi Ý Hashtag Phù Hợp & Bắt Trend".
  - Huy hiệu nền tảng đang chọn (Ví dụ: Icon TikTok, nhãn "Đang tối ưu cho TikTok - Tối đa 8 tags").
  - Nút Đóng (Icon X).
- **Body Cột Trái / Khung Nhập:**
  - Ô Textarea: "Nội dung bài viết hoặc ý tưởng chính" (có đếm số từ).
  - Cụm điều khiển: Chọn Platform (Buttons radio: TikTok / Instagram / Facebook / Threads), Thanh kéo số lượng (Slider 3 - 30).
  - Nút "Tìm Hashtag" (Primary Button).
- **Body Cột Phải / Khung Kết Quả:**
  - Nhóm 1: "Xu hướng Nổi bật (General Trends - Có bằng chứng thực tế)"
    - Lưới các Chip màu cam/đỏ, icon ngọn lửa 🔥, kèm điểm Virality. Có nút checkbox nhỏ trên từng chip.
  - Nhóm 2: "Hashtag Ngành hàng & Ngách (Niche & Relevant)"
    - Lưới các Chip màu xanh dương/xám, icon 🏷️.
  - Khung xem trước chuỗi gộp: Ô readonly hiển thị chuỗi kết quả gộp (Ví dụ: `#DienThoaiGap #TechReview #Camera200MP`).
- **Footer:**
  - Nhãn hiển thị chi phí: "Chi phí AI: 0 Credit (Miễn phí từ Trend Cache)".
  - Cụm nút thao tác:
    - Nút "Sao chép": Icon Copy, sao chép chuỗi vào Clipboard kèm toast "Đã sao chép 4 hashtags".
    - Nút "Lưu vào Bộ sưu tập": Icon Bookmark, mở dialog chọn bộ sưu tập (FR 3.6.19).
    - Nút "Chèn vào Bài viết": Icon Check/Arrow, chèn vào vị trí con trỏ hoặc cuối bài viết và tự động đóng modal (chỉ hiển thị khi mở từ Content Editor).

## Function Details

### Data Specifications

- **Input required:**
  - `workspaceId`: UUID xác thực Workspace đang làm việc.
  - Ít nhất một trong hai trường: `content` (nội dung bài viết) hoặc `topic` (chủ đề bài viết).
- **Input optional:**
  - `category`: Ngành hàng (mặc định `"all"`).
  - `platform`: Nền tảng đích thuộc enum `["tiktok", "instagram", "facebook", "threads"]` (mặc định `"tiktok"`).
  - `count`: Số lượng hashtag cần gợi ý, số nguyên trong khoảng [3, 30] (mặc định 10).
  - `includeGeneralTrends`: Boolean, có lấy tag xu hướng diện rộng không (mặc định `true`).
  - `includeNicheTrends`: Boolean, có lấy tag ngách nội dung không (mặc định `true`).
- **System data:**
  - Redis Trend ZSET: `trends:vn:live:{category}`, `trends:vn:{date}:{category}`.
  - Blacklist / Sensitive Word Registry: Danh sách từ khóa nhạy cảm, cấm kỵ.
- **Output:**
  - `HashtagSuggestResponse`: Danh sách hashtag đã phân nhóm kèm điểm số, nguồn chứng cứ và chuỗi định dạng sẵn.

### Business Rules

- **BR-AI-20 (Xác thực Quyền truy cập Workspace):** Người dùng phải có quyền `CREATOR`, `MANAGER`, hoặc `OWNER` trong Workspace chỉ định mới được yêu cầu gợi ý hashtag hoặc lưu vào Hashtag Collection.
- **BR-AI-21 (Nguyên tắc Bằng chứng Trending - Evidence-based Trending):**
  - Tuyệt đối cấm gán nhãn `isTrending: true` hoặc icon Ngọn lửa 🔥 cho các hashtag tự suy diễn từ LLM mà không có bằng chứng xuất hiện trong Redis Trend Cache (PO §2.4, Bảng điều chỉnh FR 3.7.10).
  - Mọi hashtag mang huy hiệu Trending phải đối soát được với ít nhất 1 Trend Candidate trong Redis ZSET có `finalScore` ≥ 70.
- **BR-AI-22 (Quy tắc Chuẩn hóa Ký tự và Khử trùng lặp - Deduplication):**
  - Mọi hashtag xuất ra phải có ký tự `#` ở đầu.
  - Loại bỏ hoàn toàn khoảng trắng, dấu gạch ngang, dấu chấm, dấu phẩy, ký tự đặc biệt (`!@$%^&*`) và emoji.
  - So sánh khử trùng lặp không phân biệt chữ hoa, chữ thường: `#RapViet` và `#rapviet` được coi là một. Bản thể giữ lại sẽ ưu tiên định dạng CamelCase để tăng tính dễ đọc cho người dùng.
- **BR-AI-23 (Giới hạn Cắt gọt theo Nền tảng - Platform Clamping):**
  - Hệ thống tự động giới hạn số lượng tag tối đa theo chuẩn khuyến nghị của từng mạng xã hội: TikTok (tối đa 8), Facebook (tối đa 5), Threads (tối đa 3), Instagram (tối đa 30).
  - Nếu người dùng yêu cầu số lượng vượt quá ngưỡng an toàn của platform, hệ thống tự động clamp về ngưỡng an toàn và đính kèm cảnh báo khuyến nghị.
- **BR-AI-24 (Lọc Danh sách Đen & Chống Shadowban):**
  - Mọi hashtag trích xuất ra phải chạy qua bộ lọc Blacklist kiểm duyệt từ cấm (nội dung bạo lực, khiêu dâm, cờ bạc, từ ngữ thù ghét, các hashtag đã bị Meta/TikTok đưa vào danh sách hạn chế).
  - Các hashtag vi phạm lập tức bị loại bỏ khỏi danh sách gợi ý.
- **BR-AI-25 (Chính sách Tín dụng Zero-LLM):**
  - Toàn bộ thao tác gợi ý hashtag dựa trên Zero-LLM (đọc Trend Cache và Local NLP Extractor) được tính phí **0 AI Credit**.
  - Không tạo bản ghi giữ chỗ hay trừ hạn mức trong `AiCreditLedger`.
- **BR-AI-26 (Tích hợp 2 Chiều với Workspace Hashtag Collection):**
  - Người dùng có thể chọn 1, nhiều hoặc tất cả các hashtag gợi ý để lưu trực tiếp vào bảng `workspace_hashtags` (FR 3.6.19).
  - Nếu hashtag đã tồn tại sẵn trong Collection của Workspace, hệ thống tự động bỏ qua (skip), không báo lỗi trùng lặp gây ngắt quãng trải nghiệm lưu hàng loạt.

### Validation

- `workspaceId` không hợp lệ hoặc không có quyền truy cập → 403 `FORBIDDEN`, hiển thị: MSG-AI-20.
- Cả `content` và `topic` đều rỗng → 400 `CONTENT_OR_TOPIC_REQUIRED`, hiển thị: MSG-AI-21.
- `platform` không thuộc danh sách hỗ trợ (`tiktok`, `instagram`, `facebook`, `threads`) → 400 `INVALID_PLATFORM`, hiển thị: MSG-AI-22.
- `count` nhỏ hơn 3 hoặc lớn hơn 30 → 400 `INVALID_HASHTAG_COUNT`, hiển thị: MSG-AI-23.
- Toàn bộ nội dung nhập vào chỉ chứa ký tự đặc biệt hoặc từ cấm → 422 `UNPROCESSABLE_CONTENT`, hiển thị: MSG-AI-24.
- Lỗi lưu vào Hashtag Collection do mất kết nối cơ sở dữ liệu → 500 `COLLECTION_SAVE_FAILED`, hiển thị: MSG-AI-25.

## Functionalities

### Normal Flow

#### Kịch bản A: Gợi ý và chèn trực tiếp vào bài viết (In-editor)

1. **Kích hoạt từ Trình soạn thảo:** Creator đang chỉnh sửa bài post trong Task Detail, bấm nút "Gợi ý Hashtag".
2. **Thu thập dữ liệu bài viết:** Giao diện tự động lấy văn bản hiện có trong editor, xác định nền tảng đăng bài đã chọn (ví dụ: TikTok), và gửi `POST /api/v1/workspaces/{workspaceId}/ai/suggest-hashtags`.
3. **Trích xuất Đa tầng:** Backend đọc Redis Trend Cache theo ngành hàng, so khớp từ khóa để lọc General Trends, chạy Local NLP trên nội dung bài viết để trích xuất Niche Trends.
4. **Chuẩn hóa và Cắt gọt:** Backend khử trùng lặp, lọc từ cấm, clamp số lượng phù hợp với TikTok (tối đa 8 tags), và trả về HTTP 200 kèm `HashtagSuggestResponse`.
5. **Hiển thị Modal:** Giao diện mở Modal hiển thị các thẻ Chip phân chia 2 nhóm: General Trending (có icon ngọn lửa 🔥) và Niche Tags. Tất cả các thẻ mặc định được chọn.
6. **Tùy chỉnh lựa chọn:** Creator bỏ chọn 1 tag không thích và bấm nút "Chèn vào bài viết".
7. **Cập nhật Editor:** Chuỗi hashtag `#DienThoaiGap #TechReview #Camera200MP` được chèn thẳng vào cuối nội dung bài post trong trình soạn thảo. Modal tự động đóng lại.

#### Kịch bản B: Khám phá và lưu vào Workspace Hashtag Collection

1. **Kích hoạt từ Màn hình Bộ sưu tập:** Manager truy cập `/workspaces/:workspaceId/hashtags` (FR 3.6.18) và bấm nút "Khám phá & Nạp Hashtag Trend".
2. **Nhập chủ đề:** Manager nhập chủ đề "Chiến dịch Tết 2026", chọn ngành hàng "F&B", chọn số lượng 15 tags và bấm "Tìm Hashtag".
3. **Phản hồi Danh sách:** Hệ thống trích xuất và trả về danh sách 15 tags thịnh hành và liên quan đến Tết và ẩm thực.
4. **Chọn và Lưu:** Manager tích chọn 8 tags ưng ý, bấm nút "Lưu vào Hashtag Collection", chọn mục đích sử dụng (Purpose) là `trending`.
5. **Lưu Hàng loạt:** Trình duyệt gửi `POST /api/v1/workspaces/{workspaceId}/hashtags/bulk`. Hệ thống kiểm tra trùng lặp với các tag đã có trong Workspace, lưu các tag mới vào cơ sở dữ liệu (FR 3.6.19) và trả về 201 Created kèm số lượng tag đã thêm thành công. Toast thông báo: *"Đã lưu thành công 8 hashtag vào bộ sưu tập của Workspace."*

### Abnormal Cases

- **1.a1: Người dùng không có quyền truy cập Workspace (BR-AI-20)**
  - *Hành vi:* API Gateway từ chối với HTTP 403 `FORBIDDEN` (MSG-AI-20).
  - *Xử lý phía UI:* Hiển thị thông báo: *"Bạn không có quyền thực hiện thao tác trên Workspace này"* và đóng modal.
- **2.a1: Người dùng mở modal nhưng không nhập bất kỳ nội dung hay chủ đề nào**
  - *Hành vi:* Nút "Tìm Hashtag" bị disabled ở giao diện. Nếu gọi API trực tiếp, backend trả về HTTP 400 `CONTENT_OR_TOPIC_REQUIRED` (MSG-AI-21).
  - *Xử lý phía UI:* Focus vào ô nhập liệu và hiển thị viền đỏ: *"Vui lòng nhập nội dung bài viết hoặc chủ đề để gợi ý hashtag."*
- **3.a1: Trend Cache rỗng và bài viết không chứa từ khóa phổ biến (BR-AI-21)**
  - *Hành vi:* Không có General Trends nào khớp. Hệ thống kích hoạt Local NLP để tạo Niche tags. Nếu vẫn ít hơn 3 tags, tự động gọi LLM Fallback với prompt tối giản.
  - *Xử lý phía UI:* Các tag sinh từ LLM Fallback được hiển thị ở nhóm Niche Tags và tuyệt đối không gắn icon Ngọn lửa 🔥 hay nhãn Trending.
- **4.a1: Nội dung bài viết chứa từ khóa thuộc Blacklist từ cấm (BR-AI-24)**
  - *Hành vi:* Bộ lọc Blacklist của backend phát hiện từ cấm và loại bỏ hoàn toàn các tag đó khỏi danh sách trả về.
  - *Xử lý phía UI:* Nếu toàn bộ các tag trích xuất đều dính từ cấm, hệ thống trả về thông báo: *"Không thể tạo hashtag do nội dung bài viết chứa từ ngữ vi phạm tiêu chuẩn cộng đồng."*
- **5.a1: Lưu vào Collection nhưng toàn bộ hashtag đã tồn tại từ trước (BR-AI-26)**
  - *Hành vi:* Backend kiểm tra thấy toàn bộ danh sách `tags` gửi lên đã có trong bảng `workspace_hashtags`, trả về HTTP 200 kèm `addedCount: 0` và `existingCount: N`.
  - *Xử lý phía UI:* Hiển thị toast thông báo nhẹ nhàng: *"Tất cả các hashtag đã chọn đều đã có sẵn trong Bộ sưu tập của bạn."*
- **5.b1: Lỗi cơ sở dữ liệu khi lưu vào Collection (Database Error)**
  - *Hành vi:* Backend không thể ghi vào cơ sở dữ liệu, trả về HTTP 500 `COLLECTION_SAVE_FAILED` (MSG-AI-25).
  - *Xử lý phía UI:* Hiển thị thông báo lỗi: *"Không thể lưu hashtag vào bộ sưu tập lúc này. Vui lòng thử lại sau."* Dữ liệu trên modal không bị mất để người dùng có thể bấm lưu lại.

## Post-Conditions

- **Khi chèn vào bài viết (Ngữ cảnh A):**
  - Nội dung bài viết trong trình soạn thảo Task được nối thêm chuỗi hashtag đã chọn.
  - Không trừ bất kỳ credit AI nào.
  - Bản nháp bài viết được tự động lưu tạm trên máy trạm (Local draft auto-save).
- **Khi lưu vào Hashtag Collection (Ngữ cảnh B):**
  - Các bản ghi hashtag mới được chèn vào bảng `workspace_hashtags` với phân loại `purpose="trending"`.
  - Danh sách Hashtag Collection của Workspace được cập nhật ngay lập tức mà không cần tải lại toàn bộ trang.

## Out of Scope

- Tự động theo dõi số lượng view, like thực tế của từng hashtag theo thời gian thực trên các nền tảng mạng xã hội sau khi xuất bản (Việc theo dõi này thuộc về module Post Analytics FR 3.8.4).
- Tự động bình luận hashtag vào phần comment của bài viết sau khi đăng (Được xử lý tại module Publishing FR 3.8).

## References

- **Căn cứ kế hoạch & Quyết định PO:** `docs/plan/ai-features-spec-alignment-plan.md` (Mục 1 Quyết định 2026-09-27, Mục 2.4 Caption và Hashtag, Mục 4 Bảng điều chỉnh FR 3.7.10, Mục 8 Ghi nhận code local `HashtagExtractor(llm_enabled=False)`).
- **Phân tích Nghiệp vụ:** `docs/ba/06-ai-features.md` (Mục 3.7.10 Suggest Hashtag Trend); `docs/ba/use-cases/05-ai-features.md` (UC-74 View Trending Topics & Hashtag Suggestions); `docs/ba/05-content-task-workflow.md` (FR 3.6.18 View Hashtag Collection, FR 3.6.19 Add Hashtag Collection).
- **Kiến trúc & Service Contract:** `docs/architecture/business-ai-rest-contract.md`; `docs/architecture/service-boundaries.md`.
- **Hiện trạng Codebase:** `brandhub-ai-service/app/api/v1/endpoints/content.py` (`POST /hashtags`), `brandhub-ai-service/app/services/hashtag_extractor.py`, `brandhub-ai-service/app/services/trend_cache_service.py`.
- **Mã thông báo & Quy tắc:** `Section5_Requirement_Appendix.md` (Quy ước mã lỗi `MSG-AI-xx`, quy tắc phân quyền `BR-AI-xx`).
