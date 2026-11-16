# 06 — Hệ sinh thái Tính năng AI, Đồ thị Tri thức Xu hướng & Đề xuất Cộng tác viên (AI Features)

> [<< 05 - Content & Task Workflow](file:///D:/ProjectCode/BrandHub/brandhub-infrastructure/docs/ba/05-content-task-workflow.md) | [Overview](file:///D:/ProjectCode/BrandHub/brandhub-infrastructure/docs/ba/00-overview.md) | [Tiếp: 07 - Publishing & Social >>](file:///D:/ProjectCode/BrandHub/brandhub-infrastructure/docs/ba/07-publishing-social-collaborator.md)
>
> **Phạm vi FR chuẩn**: **Mục `3.7 AI Features` — 19 FR (`3.7.1` – `3.7.19`)** | `UC-088` – `UC-106`.
> Đã loại bỏ hoàn toàn tính năng sinh kịch bản Livestream (`Generate Livestream Script`) theo `AGENTS.md` và đồng bộ 100% với kiến trúc **RAG Brand Knowledge**, **Neo4j Trend Knowledge Graph**, **AI Video Studio**, **Collaborator Directory & AI Recommendation**, cùng cơ chế **4 Nhóm Tác vụ AI Tính phí vs. Tác vụ Miễn phí (`workspace-credit-unification`)**.

---

## 1. Bảng Tổng hợp 19 Yêu cầu Chức năng Chuẩn (`3.7.1` – `3.7.19`)

| Mã FR | Mã UC | Tên Chức năng Chuẩn (Atomic CRUD FR) | Actors / Roles Chuẩn | Phân loại Credit | Mô tả Nghiệp vụ Cốt lõi |
| :-: | :-: | :--- | :--- | :-: | :--- |
| **`3.7.1`** | `UC-088` | **View Trending Topics Suggestions** | `Owner`, `Manager`, `Creator` | Miễn phí | Xem danh sách chủ đề xu hướng nóng đa nền tảng (TikTok, Facebook, Instagram, YouTube, Google News) được cá nhân hóa theo lĩnh vực của Workspace. |
| **`3.7.2`** | `UC-089` | **View AI Trend Knowledge Graph** | `Owner`, `Manager`, `Creator` | Miễn phí | Khám phá trực quan Đồ thị Tri thức Xu hướng (`Neo4j Knowledge Graph`) thể hiện mối liên hệ giữa Chủ đề (`Topic`), Từ khóa (`Keyword`), Hashtag, Thực thể thương hiệu và Ý tưởng nội dung. |
| **`3.7.3`** | `UC-090` | **View Brand Knowledge Documents** | `Owner`, `Manager`, `Creator` | Miễn phí | Xem danh sách các tài liệu tri thức thương hiệu (`Brand Knowledge Documents`) đã nạp vào kho RAG của Workspace cùng trạng thái băm vector (`INDEXED`). |
| **`3.7.4`** | `UC-091` | **Upload Brand Knowledge Document** | `Owner`, `Manager`, `Creator` | Miễn phí | Tải lên tài liệu nhận diện thương hiệu, hồ sơ sản phẩm, cẩm nang giọng văn (PDF, DOCX, TXT, MD) để `brandhub-ai-service` phân mảnh và tạo vector embedding làm ngữ cảnh RAG. |
| **`3.7.5`** | `UC-092` | **Delete Brand Knowledge Document** | `Owner`, `Manager` | Miễn phí | Xóa tài liệu tri thức thương hiệu khỏi Workspace và gỡ bỏ các đoạn vector embedding tương ứng. |
| **`3.7.6`** | `UC-093` | **Generate Caption** | `Owner`, `Manager`, `Creator` | **Tính phí** (`CONTENT_GENERATE`) | Sinh nội dung bài viết / caption đa nền tảng kết hợp ngữ cảnh thương hiệu (RAG) và xu hướng Neo4j; hỗ trợ tinh chỉnh biến thể (`CAPTION_VARIANTS` — miễn phí) và làm mượt văn phong tự nhiên (`Content Humanizer`). |
| **`3.7.7`** | `UC-094` | **Generate Ambassador** | `Owner`, `Manager`, `Creator` | **Tính phí** (`AMBASSADOR_GENERATE`) | Khởi tạo hình mẫu Đại sứ Thương hiệu ảo bằng AI (`Virtual Brand Ambassador` — ngoại hình, phong cách, trang phục, bối cảnh) và sinh bảng góc mặt nhân vật (`CHARACTER_SHEET` — miễn phí). |
| **`3.7.8`** | `UC-095` | **View Image Style Template** | `Owner`, `Manager`, `Creator` | Miễn phí | Duyệt thư viện mẫu phong cách hình ảnh thương mại (`Commercial Image Presets` — Studio, Lifestyle, Minimalist, Luxury, Cyber, Seasonal...). |
| **`3.7.9`** | `UC-096` | **Generate Image** | `Owner`, `Manager`, `Creator` | **Tính phí** (`COMMERCIAL_IMAGE`) | Sinh ảnh quảng cáo thương mại / ảnh sản phẩm chất lượng cao bằng AI theo prompt, mẫu phong cách (`3.7.8`) hoặc ghép cùng Đại sứ thương hiệu (`3.7.7`). |
| **`3.7.10`** | `UC-097` | **View Video Style Template** | `Owner`, `Manager`, `Creator` | Miễn phí | Duyệt thư viện mẫu phong cách, bố cục chuyển cảnh và tỷ lệ khung hình (`9:16`, `16:9`, `1:1`) cho video ngắn / video sản phẩm. |
| **`3.7.11`** | `UC-098` | **Generate Video** | `Owner`, `Manager`, `Creator` | **Tính phí** (`VIDEO_GENERATE`) | Sinh video ngắn / video quảng cáo sản phẩm bằng AI (`AI Video Studio` / `Product Video` / `Video Space`) theo kịch bản, hình ảnh đầu vào và mẫu phong cách (`3.7.10`), xử lý bất đồng bộ kèm hoàn trả credit nếu lỗi. |
| **`3.7.12`** | `UC-099` | **Export File** | `Owner`, `Manager`, `Creator` | Miễn phí | Xuất nội dung AI đã tạo hoặc lưu trực tiếp hình ảnh/video/văn bản về thiết bị hoặc đẩy thẳng vào `Material Library` / phần `TaskSection` của công việc đang mở. |
| **`3.7.13`** | `UC-100` | **Crawl Schedule Config** | `Admin` | Hệ thống | Cấu hình lịch trình thu thập dữ liệu xu hướng tự động (`Crawler Cron Schedule`), nguồn thu thập đa nền tảng và kích hoạt chạy đường ống xu hướng tức thì (`Run Pipeline Now`). |
| **`3.7.14`** | `UC-101` | **Suggest Hashtag Trend** | `Owner`, `Manager`, `Creator` | Miễn phí (`HASHTAG_GENERATE`) | Gợi ý bộ Hashtag theo ngữ cảnh nội dung bài viết kết hợp dữ liệu xu hướng thực tế trong Workspace. |
| **`3.7.15`** | `UC-102` | **View Collaborator Directory** | `Owner`, `Manager`, `Creator` | Miễn phí | Xem danh bạ đối tác / KOL / KOC / Influencer / Freelancer (`Collaborator Directory`) của Agency kèm bộ lọc theo lĩnh vực, nền tảng, lượng người theo dõi và mức giá tham khảo. |
| **`3.7.16`** | `UC-103` | **Create Collaborator Profile** | `Owner`, `Manager` | Miễn phí | Thêm mới hồ sơ đối tác / KOL vào danh bạ của Agency (Tên, Lĩnh vực, Kênh MXH, Lượng follower, Tỷ lệ tương tác, Đơn giá tham khảo, Thông tin liên hệ). |
| **`3.7.17`** | `UC-104` | **Update Collaborator Profile** | `Owner`, `Manager` | Miễn phí | Cập nhật thông tin hồ sơ, chỉ số tương tác hoặc ghi chú hợp tác của KOL/Cộng tác viên trong danh bạ. |
| **`3.7.18`** | `UC-105` | **Remove Collaborator Profile** | `Owner`, `Manager` | Miễn phí | Xóa hồ sơ KOL/Cộng tác viên khỏi danh bạ của Agency. |
| **`3.7.19`** | `UC-106` | **Recommend Collaborator** | `Owner`, `Manager`, `Creator` | Miễn phí | Hệ thống AI phân tích mục tiêu chiến dịch, ngành hàng, ngân sách và đối tượng mục tiêu để đề xuất danh sách KOL/Cộng tác viên phù hợp nhất kèm điểm tương thích (`Match Score`) và lý do đề xuất. |

---

## 2. Đặc tả Nghiệp vụ Chi tiết Từng Nhóm Tính năng AI

### 2.1. Khám phá Xu hướng & Đồ thị Tri thức (`3.7.1`, `3.7.2`, `3.7.13`, `3.7.14`)
- **Đường ống thu thập đa nền tảng (`3.7.13 Crawl Schedule Config`)**:
  - Do `Admin` quản lý tại `/admin/crawler`. Hệ thống thu thập xu hướng theo lịch định kỳ hoặc kích hoạt chạy ngay (`Run Pipeline Now`), trích xuất chủ đề, từ khóa, cảm xúc (`sentiment`) và lưu trữ vào **Neo4j Knowledge Graph** cùng MongoDB.
- **Trình khám phá xu hướng trong Workspace (`3.7.1` & `3.7.2`)**:
  - Tại `/workspaces/:id/trends`, `Owner`, `Manager`, `Creator` (kể cả trong chế độ `PERSONAL`) xem được các xu hướng mới nhất, bấm vào từng nút trên **Đồ thị Tri thức (`AI Trend Knowledge Graph`)** để xem các góc tiếp cận nội dung (`content angles`) và chuyển hóa ngay 1 chạm thành bài đăng hoặc kịch bản video.
- **Gợi ý Hashtag thông minh (`3.7.14 Suggest Hashtag Trend`)**:
  - Ngay trong trình soạn thảo `POST.CAPTION` / `VIDEO.CAPTION`, người dùng bấm gợi ý Hashtag theo nội dung đang viết. Tác vụ này thuộc nhóm `HASHTAG_GENERATE` (**hoàn toàn miễn phí credit**, `unit_credits = 0`).

### 2.2. Kho Tri thức Thương hiệu RAG (`3.7.3` – `3.7.5`)
- Cho phép mỗi Workspace (cả `AGENCY` lẫn `PERSONAL`) xây dựng bộ nhớ dài hạn cho AI:
  - Khi người dùng tải lên tài liệu hướng dẫn thương hiệu, thông số sản phẩm hoặc đề cương bài tập lớn (`3.7.4 Upload Brand Knowledge Document`), `brandhub-ai-service` trích xuất văn bản, chia nhỏ (`chunking`) và lập chỉ mục vector.
  - Khi gọi `3.7.6 Generate Caption`, hệ thống tự động truy xuất các đoạn tri thức liên quan nhất (`RAG retrieval`) kết hợp với ngữ cảnh xu hướng Neo4j để sinh bài viết bám sát thông tin thật, không bịa đặt thông số sản phẩm.

### 2.3. Studio Sáng tạo Nội dung Đa phương thức (`3.7.6` – `3.7.12`)
1. **Sinh Bài viết & Tinh chỉnh Văn phong (`3.7.6 Generate Caption`)**:
   - Người dùng chọn nền tảng mục tiêu (**Facebook, Instagram, TikTok, Threads**), giọng văn (`Tone of Voice`), độ dài và từ khóa.
   - Tác vụ sinh bài mới tính phí theo mã `CONTENT_GENERATE`. Các bước tạo biến thể / rút gọn / mở rộng / làm tự nhiên văn phong (`CAPTION_VARIANTS` / `Content Humanizer`) được miễn phí credit.
   - Nội dung sinh ra tự động đi qua bộ lọc an toàn (`Caption Text Moderation` / `3.6.33`) trước khi hiển thị.
2. **Đại sứ Thương hiệu Ảo & Ảnh Thương mại (`3.7.7`, `3.7.8`, `3.7.9`)**:
   - Tạo nhân vật đại sứ thương hiệu nhất quán (`AMBASSADOR_GENERATE` — tính phí; sinh bảng góc mặt `CHARACTER_SHEET` — miễn phí).
   - Chọn mẫu phong cách ảnh thương mại (`3.7.8 View Image Style Template`) và sinh ảnh sản phẩm/quảng cáo (`3.7.9 Generate Image` — mã giá `COMMERCIAL_IMAGE`).
3. **Studio Video AI (`3.7.10`, `3.7.11`, `3.7.12`)**:
   - Hỗ trợ xem mẫu phong cách video (`3.7.10`) và tạo video bằng AI (`3.7.11 Generate Video` — mã giá `VIDEO_GENERATE`) trong các không gian chuyên biệt: **AI Video Studio**, **Product Video Studio** và **Video Space**.
   - Vì quá trình dựng video AI chạy bất đồng bộ (asynchronous job), hệ thống thực hiện **tạm giữ credit (`HOLD` / `Reserve`)** khi bắt đầu job; chỉ khi video hoàn tất thành công mới thực hiện **khấu trừ thật (`SETTLE` / `Commit`)**; nếu provider lỗi hoặc timeout, hệ thống tự động **hoàn trả toàn bộ số credit tạm giữ (`RELEASE`)**.

### 2.4. Danh bạ Cộng tác viên / KOL & Đề xuất bằng AI (`3.7.15` – `3.7.19`)
- Phục vụ trực tiếp cho việc lập kế hoạch truyền thông và thực thi loại công việc **`KOL_BOOKING`**:
  - `Owner` và `Manager` quản lý danh bạ đối tác/KOL (`3.7.15`–`3.7.18`).
  - Khi cần chọn KOL cho chiến dịch hoặc công việc `KOL_BOOKING`, `Owner`, `Manager`, `Creator` gọi **`3.7.19 Recommend Collaborator`**: AI đối chiếu thông tin chiến dịch với hồ sơ trong danh bạ để xếp hạng các KOL phù hợp nhất và điền nhanh vào phần `KOL.SHORTLIST`.

---

## 3. Cơ chế Trừ AI Credit trong Chế độ `AGENCY` và `PERSONAL`

Theo kiến trúc hợp nhất tại `docs/feature/workspace-credit-unification/spec.md`:
1. **Nguồn tiền duy nhất (`Single Funding Source`)**: Mọi chi phí AI đều được trừ từ ví `agency_credit_wallets` của `Agency` (hoặc của `Personal Hub Agency` khi ở chế độ `PERSONAL`), ưu tiên trừ **Plan Credit (credit theo chu kỳ gói)** trước rồi mới trừ **Purchased Credit (credit mua thêm không hết hạn)**.
2. **Trần ngân sách cấp Workspace (`Workspace Credit Cap`)**:
   - `Owner` có thể đặt hạn mức `workspaceLimit` cho từng Workspace (hoặc để `NULL` = dùng tự do theo số dư ví tổng; `0` = khóa các tác vụ AI tính phí).
   - Cả `Owner`, `Manager` và `Creator` khi dùng AI trong một Workspace đều tiêu thụ ngân sách của Workspace đó.
3. **4 Nhóm Tác vụ Tính phí Duy nhất**:
   - Chỉ đúng 4 nhóm `CONTENT_GENERATE`, `AMBASSADOR_GENERATE`, `COMMERCIAL_IMAGE`, `VIDEO_GENERATE` mới trừ credit theo bảng giá cố định của `Admin`. Mọi thao tác AI hỗ trợ khác đều miễn phí (`unit_credits = 0`).
