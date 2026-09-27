# 3.7.2 Generate Caption

| | |
|---|---|
| FR Code | 3.7.2 |
| Feature | Generate Caption |
| Domain | AI Features (FR 3.7) |
| Role | CREATOR (và OWNER, MANAGER trong Workspace) |
| Version | 2.5 — 2026-09-27 — Chuyển đổi chuẩn SRS, tích hợp Brand Knowledge RAG grounding theo `workspaceId`/`clientId` (AI-03), Trend Context Adapter (AI-05), hỗ trợ song ngữ vi/en, sinh 3 phương án (3 variants) đồng thời, inline quick-edit, regenerate-with-feedback, cơ chế quản lý tín dụng Reserve/Settle/Release (PO D06), và lưu vết vào Content Version của Task (FR 3.6.35) không tạo trực tiếp Draft Post V1 (PO §2.1, E51-14). |
| Document status | Target Spec |
| Implementation status | In Progress |

## Function Trigger

Bắt đầu khi người dùng có vai trò `CREATOR`, `MANAGER`, hoặc `OWNER` đang ở màn hình soạn thảo nội dung bài post (Task Detail / Content Writing View - FR 3.6.4 / 3.6.35) bấm vào nút "AI Caption Studio" hoặc "Tạo Caption bằng AI", hoặc khi người dùng bấm "Viết bài theo Trend này" từ Bảng điều khiển Xu hướng (FR 3.7.1).

## Function Description

- **Actors / Roles:** `CREATOR` (hoặc `MANAGER`, `OWNER`) sở hữu Bearer JWT hợp lệ và là người được giao việc (Assignee) hoặc quản trị của Task thuộc `workspaceId`.
- **Purpose:** Ứng dụng mô hình ngôn ngữ lớn (LLM) kết hợp công nghệ Truy xuất Dữ liệu Tăng cường (RAG) từ kho tài liệu thương hiệu (Brand Knowledge - AI-03) và bối cảnh xu hướng mạng xã hội thời gian thực (Trend Context - AI-05) để tạo ra các phương án bài viết mạng xã hội (Caption) chuẩn SEO, bám sát nhận diện thương hiệu, chống bịa đặt (no hallucination), hỗ trợ tiếng Việt và tiếng Anh, tự động sinh 3 phương án có phong cách tiếp cận khác biệt (Hook mạnh mẽ, Kể chuyện Storytelling, Kêu gọi hành động CTA) cho phép chỉnh sửa trực tiếp, tạo lại có phản hồi (regenerate with feedback), và áp dụng an toàn vào lịch sử phiên bản của Task (`content_versions`).
- **Interface:** Modal / Drawer "AI Caption Studio":
  - *Cột Cấu hình Đầu vào (Input Configuration Panel - Bên trái):*
    - Ô nhập Chủ đề / Ý tưởng bài viết (`topic` - Textarea tối đa 1000 ký tự, tự động điền nếu mở từ Trend Dashboard).
    - Dropdown Giọng văn Thương hiệu (`tone` - 7 phong cách chuẩn hóa: `professional`, `friendly`, `humorous`, `inspirational`, `bold`, `empathetic`, `trendy`).
    - Bộ chọn Ngôn ngữ đầu ra (`language`: `vi` Tiếng Việt, `en` Tiếng Anh).
    - Dropdown Nền tảng đăng bài (`platform`: `facebook`, `instagram`, `tiktok`, `threads`, `linkedin`).
    - Nhóm nút chọn Độ dài mong muốn (`length`: `short` < 100 từ, `medium` 100-300 từ, `long` > 300 từ).
    - Toggle đính kèm xu hướng (`includeTrend`: true/false, cho phép tìm kiếm hoặc giữ `trendId` đã chọn).
    - Huy hiệu trạng thái Tri thức Thương hiệu (Brand Knowledge Status): Hiển thị icon Khiên bảo vệ kèm nhãn: *"Brand RAG: Đã kết nối (N tài liệu khả dụng)"* hoặc *"Brand RAG: Chưa nạp tài liệu (Chế độ phong cách tự do)"*.
  - *Cột Hiển thị 3 Biến thể (Variants Preview Panel - Bên phải):*
    - Tab chuyển đổi hoặc bố cục xem song song 3 phương án:
      - **Biến thể A — Hook-Driven (Gây chú ý mạnh):** Mở đầu bằng câu hỏi giật tít, con số gây sốc, đánh trúng tâm lý tò mò.
      - **Biến thể B — Storytelling (Kể chuyện cảm xúc):** Dẫn dắt trải nghiệm khách hàng, câu chuyện nguồn cảm hứng, tạo sự đồng cảm.
      - **Biến thể C — Value & CTA (Trực diện & Chuyển đổi):** Tập trung vào tính năng, lợi ích sản phẩm, ưu đãi và lời kêu gọi hành động dứt khoát.
    - Mỗi biến thể có:
      - Tiêu đề phương án, khung nội dung hỗ trợ định dạng Markdown, danh sách Hashtag gợi ý đính kèm.
      - Bộ đếm số từ / số ký tự kèm thanh cảnh báo an toàn độ dài theo nền tảng.
      - Thanh công cụ trên từng biến thể:
        - Nút "Chỉnh sửa trực tiếp" (Mở Inline Editor cho phép gõ sửa trực tiếp).
        - Nút "Sao chép" (Copy nội dung).
        - Nút "Tạo lại với góp ý" (Mở drawer nhập nhận xét chỉnh sửa).
        - Nút "Áp dụng vào Task" (Apply vào Task Content Version).
  - *Khung Tạo lại có Phản hồi (Regenerate with Feedback Popover):*
    - Ô nhập phản hồi cải tiến: *"Nhấn mạnh hơn vào chế độ bảo hành 2 năm"*, *"Giọng điệu bớt trang trọng hơn"*, *"Thêm 2 câu hỏi tương tác"*.
    - Nút "Tạo lại (1 Credit)".
  - *Thanh Điều khiển & Chi phí (Studio Footer):*
    - Thông tin số dư tín dụng: *"Số dư khả dụng: N Credits | Hạn mức cá nhân: M/100 Credits"*.
    - Nhãn chi phí: *"Chi phí: 1 Credit / lần sinh (cho cả 3 phương án)"*.
    - Nút "Tạo Caption (1 Credit)" (Primary Button, hiển thị spinner và thanh trạng thái khi đang gọi LLM).
- **Data Processing:**
  - **1. Kiểm tra và Giữ chỗ Credit (Credit Reservation - PO D06):**
    - `business-service` xác thực số dư trong `ai_credit_ledgers` của Agency và hạn mức của Creator trong `ai_credit_creator_limits`.
    - Tạo bản ghi giao dịch tín dụng `credit_transaction` ở trạng thái `RESERVED` (khóa 1 credit).
    - Nếu số dư không đủ hoặc vượt hạn mức, trả về 402 `INSUFFICIENT_AI_CREDIT` hoặc 403 `CREATOR_CREDIT_LIMIT_EXCEEDED` ngay lập tức, không kích hoạt AI pipeline.
  - **2. Truy xuất Tri thức Thương hiệu & Xu hướng (Brand RAG & Trend Retrieval - AI-03, AI-05):**
    - Truy vấn cơ sở dữ liệu vector ChromaDB và đồ thị tri thức Neo4j dựa theo `workspaceId`/`clientId` để trích xuất các đoạn thông tin thương hiệu (Brand Context) có độ tương đồng cosine ≥ 0.70 (tối đa 1500 tokens).
    - Nếu người dùng bật `includeTrend`, hệ thống đọc bản tóm tắt Trend Context (<500 tokens) từ Redis Cache theo `trendId`.
    - **Nguyên tắc Chống Bịa đặt & Đảm bảo Tính xác thực (Grounding Policy - PO §2.4, D07):**
      - Tuyệt đối cấm LLM tự sáng tác giá bán, số điện thoại hotline, thông số kỹ thuật, địa chỉ chi nhánh, hoặc chương trình giảm giá nếu Brand Knowledge không chứa thông tin đó.
      - Khi Brand Knowledge rỗng, AI chỉ sinh nội dung gợi mở phong cách chung, tự động chèn các placeholder `[Liên hệ hotline...]` thay vì bịa số điện thoại.
  - **3. Dựng Prompt & Sinh Nội dung qua LLM (Prompt Assembly & LLM Generation):**
    - Hệ thống ghép nối System Prompt (chứa quy tắc 7 Giọng văn, quy chuẩn định dạng nền tảng, quy tắc Grounding chống bịa đặt), Brand Context, Trend Context và User Prompt.
    - Yêu cầu mô hình xuất ra cấu trúc JSON hợp lệ chứa cả 3 biến thể trong 1 lượt gọi duy nhất (Single-call multi-variant).
    - Gọi LLM Provider chính: Groq API (`llama-3.3-70b-versatile`). Nếu Groq gặp sự cố mạng hoặc 429 Rate Limit, cơ chế Circuit Breaker tự động chuyển tiếp sang mô hình phụ: Google Gemini 1.5 Flash.
  - **4. Quyết toán hoặc Hoàn trả Credit (Credit Settlement / Release - PO D06):**
    - Nếu sinh thành công: `business-service` cập nhật trạng thái giao dịch sang `SETTLED`, tăng `usedAmount` trong `ai_credit_ledgers`, và ghi nhật ký chi tiết vào `ai_usage_logs`.
    - Nếu quá trình sinh thất bại (timeout, lỗi 502/504 từ nhà cung cấp): Hệ thống tự động chuyển giao dịch sang `RELEASED` và hoàn trả 100% credit đã reserve cho người dùng.
    - *Quy tắc Retry:* Thử lại kỹ thuật cùng một yêu cầu không tính thêm lượt credit.
    - *Quy tắc Regenerate:* Creator chủ động bấm tạo lại có feedback được tính là một lượt sinh mới (trừ 1 credit mới).
  - **5. Lưu vết vào Task Content Version (PO §2.1, E51-14):**
    - Khi Creator bấm "Áp dụng vào Task", nội dung caption được ghi nhận thành một bản ghi mới trong bảng `content_versions` gắn với `taskId` (FR 3.6.35).
    - Tuyệt đối không tự động tạo bài viết ở bảng `posts` (Draft Post V1) khi chưa có lệnh xuất bản thành công (E51-14).

## Routes / DTOs (ground truth: `content.py`, `llm_service.py`, `prompt_builder.py`)

| Route | Auth | Request body | Response | Notes |
|---|---|---|---|---|
| `POST /api/v1/workspaces/{workspaceId}/ai/caption/generate` | Bearer (CREATOR / MANAGER / OWNER) | `CaptionGenerateRequest` | `ApiResponse<CaptionGenerateResponse>` 200 | Khởi tạo sinh 3 biến thể caption. Quản lý reserve/settle credit. |
| `POST /api/v1/workspaces/{workspaceId}/ai/caption/regenerate` | Bearer (CREATOR / MANAGER / OWNER) | `CaptionRegenerateRequest` | `ApiResponse<CaptionGenerateResponse>` 200 | Sinh lại biến thể kèm nhận xét/feedback của Creator. |
| `POST /api/v1/workspaces/{workspaceId}/tasks/{taskId}/apply-caption` | Bearer (CREATOR / MANAGER / OWNER) | `ApplyCaptionRequest` | `ApiResponse<TaskContentVersionResponse>` 200 | Lưu caption vào Task Content Version mới (FR 3.6.35). |
| `POST /internal/ai/caption` (Internal Service) | `X-Internal-Api-Key` | `InternalCaptionRequest` | `InternalCaptionResponse` 200 | Giao tiếp nội bộ giữa `business-service` và `ai-service`. |

### Chi tiết Request / Response DTO

```json
// POST /api/v1/workspaces/{workspaceId}/ai/caption/generate
// Request Body
{
  "taskId": "tsk_0199a8b7-c6d5-4e3f-2a1b-0c9d8e7f6a5b",
  "topic": "Ra mắt dòng sản phẩm giày chạy bộ TrailRunner Pro siêu nhẹ, đệm carbon trợ lực.",
  "tone": "inspirational",
  "language": "vi",
  "platform": "facebook",
  "length": "medium",
  "includeTrend": true,
  "trendId": "trd_vn_20260927_005",
  "targetAudience": "Người yêu chạy bộ, leo núi, giới trẻ năng động"
}
```

```json
// Response 200
{
  "success": true,
  "data": {
    "generationId": "gen_cap_8f7e6d5c-4b3a-2a1b-0c9d-8e7f6a5b4c3d",
    "creditsDeducted": 1,
    "remainingCredits": 142,
    "brandRagUsed": true,
    "brandDocsReferenced": ["Catalogue_TrailRunner_2026.pdf", "Brand_Voice_Guidelines.docx"],
    "trendContextUsed": true,
    "variants": [
      {
        "variantId": "var_hook",
        "variantType": "HOOK_DRIVEN",
        "title": "Chinh Phục Mọi Cung Đường",
        "caption": "Bạn đã bao giờ nghĩ đôi giày chạy bộ có thể nhẹ hơn cả một chiếc lông vũ nhưng mang sức bật của lò xo carbon? 🔥\n\nKhông chỉ là chạy bộ — đó là hành trình bứt phá giới hạn bản thân cùng TrailRunner Pro. Công nghệ đệm carbon trợ lực độc quyền giúp bạn giảm 30% áp lực lên khớp gối, sẵn sàng chinh phục mọi địa hình hiểm trở nhất!\n\nĐừng để rào cản ngăn bước chân bạn. Khám phá ngay trải nghiệm chạy bộ thế hệ mới!",
        "hashtags": ["#TrailRunnerPro", "#ChayBoVietNam", "#ButPhaGioiHan", "#ChayDiaHinh"],
        "wordCount": 85,
        "characterCount": 492,
        "platformSafety": { "safe": true, "recommendedMaxChars": 2000 }
      },
      {
        "variantId": "var_story",
        "variantType": "STORYTELLING",
        "title": "Hành Trình Chinh Phục Đỉnh Cao",
        "caption": "5 giờ sáng, sương mù phủ kín triền dốc Tam Đảo. Tiếng thở dốc, từng nhịp tim đập dồn dập...\n\nĐó là khoảnh khắc mà bất kỳ runner nào cũng từng trải qua. Nhưng hôm nay, từng bước chạm đất trở nên êm ái lạ kỳ. Với TrailRunner Pro, mỗi bước chạy không còn là sự gồng mình, mà là cảm giác lướt đi nhẹ tênh nhờ đế trợ lực carbon nguyên khối.\n\nMỗi vết bùn trên giày là một tấm huy chương của sự bền bỉ. Bạn đã sẵn sàng viết tiếp câu chuyện của riêng mình?",
        "hashtags": ["#TrailRunnerPro", "#CauChuyenRunner", "#SongDamMe", "#TamDaoTrail"],
        "wordCount": 92,
        "characterCount": 548,
        "platformSafety": { "safe": true, "recommendedMaxChars": 2000 }
      },
      {
        "variantId": "var_cta",
        "variantType": "DIRECT_CTA",
        "title": "Ưu Đãi Ra Mắt Độc Quyền",
        "caption": "SỞ HỮU NGAY SIÊU PHẨM GIÀY CHẠY BỘ ĐỆM CARBON — TRAILRUNNER PRO! ⚡\n\nĐược thiết kế chuyên biệt cho địa hình khắc nghiệt với:\n✅ Trọng lượng siêu nhẹ chỉ 185g.\n✅ Tấm đệm carbon nguyên khối trợ lực tối đa.\n✅ Đế cao su Vibram chống trơn trượt tuyệt đối.\n\nƯu đãi đặt trước: Tặng ngay áo thể thao phản quang cao cấp cho 50 đơn hàng đầu tiên trong tuần lễ ra mắt.\n👉 Nhấn vào link dưới phần bình luận để đặt hàng ngay hôm nay!",
        "hashtags": ["#TrailRunnerPro", "#UuDaiDocQuyen", "#GiayChayCarbon", "#PreOrder"],
        "wordCount": 88,
        "characterCount": 526,
        "platformSafety": { "safe": true, "recommendedMaxChars": 2000 }
      }
    ]
  }
}
```

```json
// POST /api/v1/workspaces/{workspaceId}/ai/caption/regenerate
// Request Body
{
  "generationId": "gen_cap_8f7e6d5c-4b3a-2a1b-0c9d-8e7f6a5b4c3d",
  "variantId": "var_story",
  "previousCaption": "5 giờ sáng, sương mù phủ kín...",
  "feedback": "Làm giọng văn hài hước, trẻ trung hơn, thêm yếu tố rủ rê bạn bè cùng tham gia chạy.",
  "taskId": "tsk_0199a8b7-c6d5-4e3f-2a1b-0c9d8e7f6a5b"
}
```

```json
// POST /api/v1/workspaces/{workspaceId}/tasks/{taskId}/apply-caption
// Request Body (Lưu vào Task Content Version - FR 3.6.35)
{
  "selectedCaption": "Bạn đã bao giờ nghĩ đôi giày chạy bộ...",
  "selectedHashtags": ["#TrailRunnerPro", "#ChayBoVietNam"],
  "generationId": "gen_cap_8f7e6d5c-4b3a-2a1b-0c9d-8e7f6a5b4c3d",
  "variantType": "HOOK_DRIVEN"
}

// Response 200
{
  "success": true,
  "data": {
    "taskId": "tsk_0199a8b7-c6d5-4e3f-2a1b-0c9d8e7f6a5b",
    "versionNumber": 3,
    "appliedContent": "Bạn đã bao giờ nghĩ đôi giày chạy bộ...\n\n#TrailRunnerPro #ChayBoVietNam",
    "updatedAt": "2026-09-27T09:40:00+07:00",
    "message": "Caption applied to Task Content Version successfully."
  }
}
```

## Screen Layout

Căn cứ Modal / Drawer "AI Caption Studio":
- **Header:**
  - Tiêu đề: "Trợ Lý Tạo Caption AI (AI Caption Studio)".
  - Huy hiệu ngữ cảnh: Tên Task đang mở + Huy hiệu Nền tảng đích (Ví dụ: Facebook Post).
  - Huy hiệu Tri thức: Dot xanh *"Brand RAG Active"*.
  - Nút đóng (X).
- **Body 2 Cột:**
  - **Cột Trái (Form Cấu hình - 40% Chiều rộng):**
    - Ô Textarea: "Chủ đề / Thông điệp bài viết" (Placeholder: "Nhập ý tưởng chính, thông điệp cốt lõi hoặc sản phẩm cần quảng bá...").
    - Dropdown Giọng văn: 7 lựa chọn có icon minh họa (Chuyên nghiệp, Thân thiện, Hài hước, Truyền cảm hứng, Nổi bật/Khẩn cấp, Thấu hiểu, Bắt trend).
    - Bộ chuyển Ngôn ngữ: `[ Tiếng Việt (vi) ]` | `[ English (en) ]`.
    - Dropdown Nền tảng: Facebook, Instagram, TikTok, Threads, LinkedIn.
    - Nhóm nút Độ dài: `[ Ngắn (<100 từ) ]` | `[ Trung bình (100-300 từ) ]` | `[ Dài (>300 từ) ]`.
    - Checkbox / Toggle: `[x] Tích hợp Bối cảnh Xu hướng (Trend Context)`.
    - Khung tóm tắt Tri thức Thương hiệu: Hiển thị 2 tài liệu tham chiếu gần nhất được tải từ Brand Collection.
  - **Cột Phải (Hiển thị 3 Biến thể - 60% Chiều rộng):**
    - Nhóm 3 Tabs: `[ 🎯 Hook Mạnh Mẽ ]` | `[ 📖 Kể Chuyện ]` | `[ ⚡ Kêu Gọi Hành Động (CTA) ]`.
    - Nội dung Tab đang chọn:
      - Ô xem trước / Chỉnh sửa trực tiếp: Cho phép Creator nhấp chuột vào để sửa từng câu chữ, thêm bớt emoji ngay trên khung văn bản.
      - Khung Tags: Hiển thị các chip hashtag, có nút dấu X nhỏ trên từng chip để xóa nhanh.
      - Thanh trạng thái kỹ thuật: Hiển thị số từ, số ký tự, mức độ an toàn hiển thị của nền tảng (Ví dụ: *"Facebook: 548/2000 ký tự - Hiển thị tối ưu trước nút Xem thêm"*).
      - Cụm nút thao tác trên biến thể:
        - Nút "Tạo lại với góp ý" (Icon Refresh + Chat, mở popover nhập feedback).
        - Nút "Sao chép" (Icon Clipboard).
        - Nút "Áp dụng vào Task" (Icon Checkmark, nút nổi bật nhất).
- **Footer:**
  - Nhãn hiển thị số dư: "Số dư Agency: 142 Credits | Hạn mức của bạn: Còn 48 lượt trong tháng".
  - Nút "Tạo 3 Phương Án (1 Credit)" (Nút chính góc phải dưới).

## Function Details

### Data Specifications

- **Input required:**
  - `workspaceId`: UUID xác thực Workspace làm việc.
  - `taskId`: UUID của Task đang soạn thảo nội dung.
  - `topic`: Chuỗi chủ đề hoặc ý tưởng, độ dài từ 10 đến 1000 ký tự.
- **Input optional:**
  - `tone`: Chuỗi enum `["professional", "friendly", "humorous", "inspirational", "bold", "empathetic", "trendy"]` (mặc định `"friendly"`).
  - `language`: Chuỗi enum `["vi", "en"]` (mặc định `"vi"`).
  - `platform`: Chuỗi enum `["facebook", "instagram", "tiktok", "threads", "linkedin"]` (mặc định `"facebook"`).
  - `length`: Chuỗi enum `["short", "medium", "long"]` (mặc định `"medium"`).
  - `includeTrend`: Boolean (mặc định `false`).
  - `trendId`: Chuỗi UUID của xu hướng đã chọn (bắt buộc nếu `includeTrend=true`).
  - `targetAudience`: Chuỗi mô tả đối tượng người đọc (tối đa 255 ký tự).
- **System data:**
  - Brand RAG context: ChromaDB embeddings (384d) + Neo4j entity graph theo `workspaceId`.
  - Trend context: Redis key `trend:context:{trendId}`.
  - Credit status: `ai_credit_ledgers` (PostgreSQL), `ai_credit_creator_limits` (PostgreSQL).
- **Output:**
  - `CaptionGenerateResponse`: Danh sách 3 biến thể nội dung kèm danh sách tài liệu tham chiếu, số credit đã trừ và số dư còn lại.
  - `TaskContentVersionResponse`: Bản ghi phiên bản mới lưu trong Task.

### Business Rules

- **BR-AI-30 (Xác thực Quyền Task và Workspace):** Người dùng thực hiện phải có vai trò `CREATOR`, `MANAGER`, hoặc `OWNER` trong Workspace và có quyền chỉnh sửa trên Task chỉ định (`taskId`). Nếu Task đang ở trạng thái bị khóa (`LOCKED`), đã duyệt hoàn tất (`APPROVED`), hoặc đã xuất bản (`PUBLISHED`), hệ thống từ chối cập nhật với lỗi 400 `TASK_CONTENT_LOCKED`.
- **BR-AI-31 (Vòng đời Quản lý Credit Nghiêm ngặt: Reserve -> Settle -> Release - PO D06):**
  - **Bước Reserve (Giữ chỗ):** Trước khi gọi AI Service, hệ thống kiểm tra số dư Agency và hạn mức cá nhân của Creator. Nếu thỏa mãn, tạo bản ghi giao dịch ở trạng thái `RESERVED` khóa đúng 1 credit.
  - **Bước Settle (Quyết toán):** Khi AI Service trả về kết quả thành công chứa đầy đủ 3 biến thể, giao dịch được chuyển sang `SETTLED`. Số dư khả dụng bị trừ 1 credit và ghi log kiểm toán vào `ai_usage_logs`.
  - **Bước Release (Hoàn trả):** Nếu AI Service gặp sự cố (timeout quá 30 giây, mã lỗi 502/504, lỗi phân tích cú pháp LLM), hệ thống tự động giải phóng giao dịch sang `RELEASED`, hoàn lại 100% hạn mức credit cho người dùng.
  - **Retry kỹ thuật:** Nếu hệ thống tự động retry cùng một request do timeout mạng, tuyệt đối không tạo thêm bản ghi giữ chỗ credit mới.
  - **Chủ động Regenerate:** Khi Creator bấm nút "Tạo lại với góp ý", đây được xem là một hành động sinh mới độc lập và bị tính 1 credit riêng biệt.
- **BR-AI-32 (Grounding Tri thức Thương hiệu & Nghiêm cấm Bịa đặt - PO §2.4, D07):**
  - Mọi dữ kiện liên quan đến tính năng kỹ thuật, chứng chỉ chất lượng, địa chỉ cửa hàng, số điện thoại, giá bán và chương trình khuyến mãi bắt buộc phải có nguồn gốc xác thực từ tài liệu Brand Knowledge RAG (AI-03).
  - Nghiêm cấm mô hình tự sáng tác (hallucinate) thông tin giả mạo. Trong trường hợp Brand Knowledge không chứa dữ kiện người dùng hỏi, AI bắt buộc phải dùng các mẫu câu trung tính hoặc chèn placeholder rõ ràng (ví dụ: `[Vui lòng liên hệ hotline để nhận báo giá chi tiết]`).
  - Nếu Brand Knowledge của Workspace hoàn toàn chưa được nạp tài liệu: Hệ thống vẫn cho phép tạo caption nhưng chuyển sang Chế độ Phong Cách Tự Do, đồng thời đính kèm cảnh báo: *"Chưa có tài liệu thương hiệu — Nội dung được tạo dựa trên kiến thức tổng quát."*
- **BR-AI-33 (Đa ngôn ngữ vi/en và Chuẩn hóa 7 Giọng văn - PO §2.4):**
  - Hệ thống hỗ trợ đầy đủ 2 ngôn ngữ: Tiếng Việt chuẩn ngữ pháp mạng xã hội hiện đại (`vi`) và Tiếng Anh thương mại tự nhiên (`en`).
  - 7 phong cách giọng văn chuẩn hóa (`professional`, `friendly`, `humorous`, `inspirational`, `bold`, `empathetic`, `trendy`) được cấu hình bằng các bộ chỉ thị ngữ điệu (system prompt directives) riêng biệt, đảm bảo độ phân hóa rõ rệt giữa các tone.
- **BR-AI-34 (Sinh Đồng thời 3 Biến thể Độc lập):**
  - Mỗi lượt sinh thành công bắt buộc trả về chính xác 3 biến thể với 3 góc độ truyền thông khác nhau: `HOOK_DRIVEN`, `STORYTELLING`, và `DIRECT_CTA`.
  - Cả 3 biến thể được tạo trong cùng một lượt gọi LLM có cấu trúc JSON nhằm tối ưu hóa chi phí API và đảm bảo thời gian phản hồi dưới 15 giây.
- **BR-AI-35 (Chỉnh sửa Trực tiếp và Tạo lại có Phản hồi):**
  - Creator có quyền bấm trực tiếp vào nội dung của bất kỳ biến thể nào để sửa đổi câu từ, thêm bớt emoji trước khi bấm áp dụng.
  - Thao tác chỉnh sửa trực tiếp (Inline Edit) diễn ra trên trình duyệt máy trạm và không tiêu tốn bất kỳ credit AI nào.
  - Thao tác "Tạo lại với góp ý (Regenerate with feedback)" gửi kèm nội dung biến thể cũ và nhận xét của Creator để LLM tinh chỉnh bám sát yêu cầu.
- **BR-AI-36 (Khả năng Phục hồi qua Circuit Breaker & Fallback LLM):**
  - Hệ thống sử dụng Groq (`llama-3.3-70b-versatile`) làm nhà cung cấp LLM chính (độ trễ siêu nhanh).
  - Nếu Groq phản hồi mã lỗi 429 (Rate Limit), 500, 503 hoặc timeout quá 15 giây, bộ điều phối Circuit Breaker tự động chuyển hướng yêu cầu sang Google Gemini 1.5 Flash mà không làm đứt đoạn phiên làm việc của người dùng.
- **BR-AI-37 (Lưu trữ Content Version & Chống Tạo Draft Post Trực tiếp - PO §2.1, E51-14):**
  - Khi Creator bấm "Áp dụng vào Task", nội dung caption được lưu thành một bản ghi mới trong bảng `content_versions` của Task (FR 3.6.35).
  - Tuyệt đối không tự động tạo bài viết ở bảng `posts` (Draft Post V1) khi chưa có lệnh xuất bản thành công (E51-14).
  - Việc tái sử dụng nội dung caption đã sinh từ trước cho các Task khác không bị trừ thêm credit AI.

### Validation

- `workspaceId` hoặc `taskId` không hợp lệ hoặc không có quyền chỉnh sửa → 403 `FORBIDDEN`, hiển thị: MSG-AI-30.
- `topic` rỗng hoặc độ dài nhỏ hơn 10 ký tự hoặc vượt quá 1000 ký tự → 400 `INVALID_TOPIC_LENGTH`, hiển thị: MSG-AI-31.
- `tone` không nằm trong danh sách 7 giọng văn hỗ trợ → 400 `INVALID_TONE_SELECTION`, hiển thị: MSG-AI-32.
- `language` không thuộc `["vi", "en"]` → 400 `INVALID_LANGUAGE`, hiển thị: MSG-AI-33.
- `platform` không thuộc danh sách mạng xã hội hỗ trợ → 400 `INVALID_PLATFORM`, hiển thị: MSG-AI-34.
- Số dư credit của Agency không đủ 1 credit → 402 `INSUFFICIENT_AI_CREDIT`, hiển thị: MSG-AI-35.
- Creator đã vượt quá hạn mức sử dụng credit cá nhân trong tháng → 403 `CREATOR_CREDIT_LIMIT_EXCEEDED`, hiển thị: MSG-AI-36.
- Task đang ở trạng thái bị khóa (`LOCKED`), đã duyệt (`APPROVED`) hoặc đã xuất bản (`PUBLISHED`) → 400 `TASK_CONTENT_LOCKED`, hiển thị: MSG-AI-37.

## Functionalities

### Normal Flow

1. **Mở Studio:** Creator mở Task Detail loại Post, nhấp vào nút "AI Caption Studio". Giao diện mở Drawer/Modal với trường thông tin chủ đề lấy sẵn từ mô tả công việc (Task Description).
2. **Thiết lập tham số:** Creator chọn giọng văn `inspirational` (Truyền cảm hứng), ngôn ngữ `vi` (Tiếng Việt), nền tảng `facebook`, độ dài `medium` (Trung bình), và tích chọn đính kèm xu hướng `Rap Viet 2026`.
3. **Gửi yêu cầu:** Creator bấm nút "Tạo 3 Phương Án (1 Credit)". Trình duyệt gửi `POST /api/v1/workspaces/{workspaceId}/ai/caption/generate`.
4. **Giữ chỗ Credit (Reserve):** `business-service` xác thực số dư credit của Agency và hạn mức của Creator. Tạo bản ghi giao dịch `credit_transaction` trạng thái `RESERVED` khóa 1 credit.
5. **Truy xuất RAG & Trend Context:** `ai-service` truy xuất tài liệu nhận diện thương hiệu từ ChromaDB/Neo4j theo `workspaceId`, đồng thời đọc tóm tắt xu hướng Rap Việt từ Redis Cache.
6. **Gọi LLM & Sinh 3 Biến thể:** Hệ thống dựng Prompt với chỉ thị chống bịa đặt, gọi Groq API. LLM sinh thành công cấu trúc JSON chứa đầy đủ 3 biến thể (`HOOK_DRIVEN`, `STORYTELLING`, `DIRECT_CTA`).
7. **Quyết toán Credit (Settle):** `business-service` cập nhật giao dịch sang `SETTLED`, trừ 1 credit vào sổ cái `ai_credit_ledgers`, ghi log kiểm toán vào `ai_usage_logs`.
8. **Hiển thị Kết quả:** Giao diện nhận dữ liệu, hiển thị 3 biến thể trên 3 tab trực quan. Mỗi biến thể có đầy đủ tiêu đề, nội dung, hashtag gợi ý và số lượng từ/ký tự.
9. **Chỉnh sửa và Tinh chỉnh:** Creator chọn tab "Biến thể A (Hook)", bấm trực tiếp vào khung chữ để chỉnh lại câu kêu gọi hành động cuối bài theo ý thích cá nhân.
10. **Áp dụng vào Task:** Creator bấm nút "Áp dụng vào Task". Trình duyệt gửi `POST /api/v1/workspaces/{workspaceId}/tasks/{taskId}/apply-caption`. Hệ thống lưu bản ghi mới vào `content_versions` của Task. Modal đóng lại, nội dung bài viết trong Task Detail được cập nhật phiên bản mới. Toast thông báo: *"Đã áp dụng caption vào Task thành công."*

### Abnormal Cases

- **1.a1: Người dùng không có quyền truy cập Task hoặc Workspace (BR-AI-30)**
  - *Hành vi:* API Gateway từ chối với HTTP 403 `FORBIDDEN` (MSG-AI-30).
  - *Xử lý phía UI:* Hiển thị thông báo: *"Bạn không có quyền chỉnh sửa Task này"* và đóng modal Studio.
- **2.a1: Số dư Credit của Agency đã cạn kiệt (BR-AI-31)**
  - *Hành vi:* Backend kiểm tra `ai_credit_ledgers`, phát hiện số dư bằng 0. Từ chối yêu cầu với HTTP 402 `INSUFFICIENT_AI_CREDIT` (MSG-AI-35).
  - *Xử lý phía UI:* Hiển thị popup thông báo hết credit kèm nút "Mua thêm Credit" (điều hướng Owner/Manager tới trang nạp credit FR 3.9.6).
- **2.a2: Creator vượt quá hạn mức cá nhân được phân bổ trong tháng (BR-AI-31)**
  - *Hành vi:* Backend kiểm tra `ai_credit_creator_limits`, phát hiện Creator đã sử dụng hết định mức tháng. Trả về HTTP 403 `CREATOR_CREDIT_LIMIT_EXCEEDED` (MSG-AI-36).
  - *Xử lý phía UI:* Hiển thị thông báo: *"Bạn đã sử dụng hết hạn mức AI Credit được cấp trong tháng này. Vui lòng liên hệ Quản lý để nâng hạn mức."*
- **3.a1: Workspace chưa có bất kỳ tài liệu Brand Knowledge nào (BR-AI-32)**
  - *Hành vi:* Bước truy xuất vector trong ChromaDB trả về danh sách rỗng. Hệ thống không dừng luồng mà tự động chuyển sang chế độ Phong cách Tự do (General Knowledge Mode).
  - *Xử lý phía UI:* Biến thể sinh ra được đính kèm huy hiệu màu xám: *"Chưa áp dụng Brand RAG do chưa nạp tài liệu thương hiệu."*
- **6.a1: Groq API bị quá tải hoặc lỗi mạng (Circuit Breaker kích hoạt - BR-AI-36)**
  - *Hành vi:* Yêu cầu gửi tới Groq bị lỗi 429 hoặc timeout 15s. Circuit Breaker tự động chuyển hướng sang Google Gemini 1.5 Flash.
  - *Xử lý phía UI:* Người dùng nhận kết quả bình thường với độ trễ kéo dài thêm khoảng 2-3 giây mà không gặp bất kỳ thông báo lỗi nào.
- **6.a2: Cả 2 nhà cung cấp LLM đều sập hoặc timeout hoàn toàn (Downstream Failure - BR-AI-31)**
  - *Hành vi:* Cả Groq và Gemini đều không phản hồi sau 30 giây. Hệ thống bắt ngoại lệ, lập tức gọi hàm `releaseCredit(transactionId)` để hoàn lại 1 credit cho người dùng, trả về HTTP 502 `AI_SERVICE_UNAVAILABLE`.
  - *Xử lý phía UI:* Hiển thị thông báo lỗi thân thiện: *"Dịch vụ AI đang bảo trì hoặc quá tải. 1 Credit đã được hoàn trả về tài khoản của bạn. Vui lòng thử lại sau ít phút."*
- **9.a1: Bấm "Tạo lại với góp ý" nhưng để trống ô phản hồi (BR-AI-35)**
  - *Hành vi:* Giao diện kiểm tra client-side, nếu ô nhận xét rỗng sẽ highlight đỏ và không cho gửi request.
  - *Xử lý phía UI:* Báo lỗi: *"Vui lòng nhập nhận xét cải thiện (ví dụ: Viết ngắn gọn hơn, thêm emoji) trước khi tạo lại."*
- **10.a1: Áp dụng vào Task khi Task đã được phê duyệt hoặc bị khóa (BR-AI-30)**
  - *Hành vi:* Backend kiểm tra thấy trạng thái Task là `APPROVED` hoặc `LOCKED`. Trả về HTTP 400 `TASK_CONTENT_LOCKED` (MSG-AI-37).
  - *Xử lý phía UI:* Hiển thị thông báo lỗi: *"Task này đã được phê duyệt và khóa nội dung. Không thể ghi đè phiên bản mới."* Cho phép Creator sao chép nội dung ra Clipboard để lưu thủ công.

## Post-Conditions

- **Khi sinh caption thành công:**
  - 1 Credit AI được quyết toán và trừ chính xác trong sổ cái `ai_credit_ledgers`.
  - Bản ghi nhật ký sử dụng AI được tạo trong bảng `ai_usage_logs` ghi rõ `taskId`, `userId`, `tokensUsed`, `providerUsed`.
  - 3 biến thể caption được lưu tạm trong phiên làm việc của người dùng.
- **Khi áp dụng vào Task thành công:**
  - Một bản ghi phiên bản nội dung mới (`versionNumber = versionNumber + 1`) được chèn vào bảng `content_versions` gắn với `taskId`.
  - Không tự động tạo bài viết ở bảng `posts` (Draft Post V1) khi chưa xuất bản thành công.
  - Trạng thái Task giữ nguyên hoặc chuyển sang `IN_PROGRESS` tùy quy trình kiểm duyệt.

## Out of Scope

- Tự động thiết kế ảnh minh họa kèm theo bài viết (Thao tác này thuộc về FR 3.7.5 Generate Image).
- Tự động đặt lịch đăng bài lên các nền tảng mạng xã hội ngay từ Studio này (Thao tác này thuộc về FR 3.8.7 Schedule Platform Post).
- Dịch thuật tự động sang các ngôn ngữ hiếm ngoài tiếng Việt và tiếng Anh trong giai đoạn này.

## References

- **Căn cứ kế hoạch & Quyết định PO:** `docs/plan/ai-features-spec-alignment-plan.md` (Mục 1 Quyết định 2026-09-27, Mục 2.1 Ranh giới nghiệp vụ & Task Content Version, Mục 2.2 Brand Knowledge RAG AI-03, Mục 2.4 Caption và Hashtag, Mục 3 Quyết định D06 Credit Reserve/Settle/Release, D07 Grounding Policy, Mục 4 Bảng điều chỉnh FR 3.7.2).
- **Phân tích Nghiệp vụ:** `docs/ba/06-ai-features.md` (Mục 3.7.2 Generate Caption); `docs/ba/use-cases/05-ai-features.md` (UC-75 Generate Caption with AI); `docs/ba/05-content-task-workflow.md` (FR 3.6.4 List Task View, FR 3.6.35 View Content History & Versioning); `docs/ba/08-subscription-billing.md`.
- **Kiến trúc & Service Contract:** `docs/architecture/business-ai-rest-contract.md` (Endpoint `POST /internal/ai/caption`, quy tắc nguồn sự thật credit); `docs/architecture/service-boundaries.md`.
- **Hiện trạng Codebase:** `brandhub-ai-service/app/api/v1/endpoints/content.py` (`POST /generate`), `brandhub-ai-service/app/services/llm_service.py` (Groq/Gemini fallback), `brandhub-ai-service/app/utils/prompt_builder.py`, `brandhub-business-service/src/main/java/com/brandhub/business/model/AiCreditLedger.java`, `brandhub-business-service/src/main/java/com/brandhub/business/model/AiCreditCreatorLimit.java`.
- **Mã thông báo & Quy tắc:** `Section5_Requirement_Appendix.md` (Quy ước mã lỗi `MSG-AI-xx`, quy tắc phân quyền `BR-AI-xx`).
