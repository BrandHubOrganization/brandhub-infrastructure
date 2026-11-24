# UC 05 — AI Features (`UC-088` – `UC-106`)

> [<< 04-content-task-workflow.md](./04-content-task-workflow.md) | [UC Index](./README.md) | [Domain BA Spec: 06-ai-features.md](../06-ai-features.md) | [06-publishing-social.md >>](./06-publishing-social.md)
>
> Đồng bộ chuẩn xác 1-đối-1 với `Các FR của hệ thống - Feature_Function Requirement.csv` và `AGENTS.md`. Chỉ sử dụng **6 Vai trò Hệ thống Chuẩn (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`)**.

---

## 1. Bảng Tổng Hợp Use Cases (19 UCs)

| UC ID | Use Case Title | Canonical Actor(s) | Related FR | Business Rules |
| :-: | :--- | :--- | :-: | :--- |
| `UC-088` | View Trending Topics Suggestions | `Owner`, `Manager`, `Creator` | `3.7.1` | `BR-45` |
| `UC-089` | View AI Trend Knowledge Graph | `Owner`, `Manager`, `Creator`, `Admin` | `3.7.2` | `BR-45` |
| `UC-090` | View Brand Knowledge Documents | `Owner`, `Manager`, `Creator`, `Client` | `3.7.3` | `BR-20, BR-46` |
| `UC-091` | Upload Brand Knowledge Document | `Owner`, `Manager`, `Client` | `3.7.4` | `BR-20, BR-46, BR-49` |
| `UC-092` | Delete Brand Knowledge Document | `Owner`, `Manager`, `Client` | `3.7.5` | `BR-20, BR-47` |
| `UC-093` | Generate Caption | `Owner`, `Manager`, `Creator` | `3.7.6` | `BR-46, BR-48, BR-49, BR-60, BR-64` |
| `UC-094` | Generate Ambassador | `Owner`, `Manager`, `Creator` | `3.7.7` | `BR-46, BR-48, BR-49, BR-60, BR-64` |
| `UC-095` | View Image Style Template | `Owner`, `Manager`, `Creator` | `3.7.8` | `BR-46, BR-49` |
| `UC-096` | Generate Image | `Owner`, `Manager`, `Creator` | `3.7.9` | `BR-46, BR-48, BR-49, BR-50, BR-60, BR-64` |
| `UC-097` | View Video Style Template | `Owner`, `Manager`, `Creator` | `3.7.10` | `BR-46, BR-49` |
| `UC-098` | Generate Video | `Owner`, `Manager`, `Creator` | `3.7.11` | `BR-46, BR-48, BR-49, BR-50, BR-60, BR-64` |
| `UC-099` | Export File | `Owner`, `Manager`, `Creator` | `3.7.12` | `BR-20, BR-50` |
| `UC-100` | Crawl Schedule Config | `Admin` | `3.7.13` | `BR-45, BR-62, BR-65` |
| `UC-101` | Suggest Hashtag Trend | `Owner`, `Manager`, `Creator` | `3.7.14` | `BR-39, BR-45` |
| `UC-102` | View Collaborator Directory | `Owner`, `Manager` | `3.7.15` | `BR-20, BR-51` |
| `UC-103` | Create Collaborator Profile | `Owner`, `Manager` | `3.7.16` | `BR-15, BR-51` |
| `UC-104` | Update Collaborator Profile | `Owner`, `Manager` | `3.7.17` | `BR-51` |
| `UC-105` | Remove Collaborator Profile | `Owner`, `Manager` | `3.7.18` | `BR-15, BR-51` |
| `UC-106` | Recommend Collaborator | `Owner`, `Manager` | `3.7.19` | `BR-51, BR-52` |

---

## UC-088 — View Trending Topics Suggestions

- **Related FR:** `3.7.1` (3.7 AI Features)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`
- **Business Rules:** `BR-45`
- **System Messages:** `MSG01, MSG02, MSG03, MSG07`
- **Specification & Flow:** Xem bảng điều khiển gợi ý các chủ đề và từ khóa xu hướng đang thịnh hành (View Trending Topics Suggestions — /workspaces/:id/ai/trends). Hệ thống thu thập dữ liệu thị trường Việt Nam, tính điểm bùng nổ xu hướng thông qua thuật toán phát hiện bất thường BM25 kết hợp xếp hạng đồ thị Neo4j (Personalized PageRank & Betweenness Centrality) để gợi ý các chủ đề viral phù hợp với ngành hàng của Workspace (BR-45).

---

## UC-089 — View AI Trend Knowledge Graph

- **Related FR:** `3.7.2` (3.7 AI Features)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`, `Admin`
- **Business Rules:** `BR-45`
- **System Messages:** `MSG01, MSG02, MSG03, MSG07`
- **Specification & Flow:** Khám phá trực quan Đồ thị Tri thức Xu hướng (View AI Trend Knowledge Graph — /workspaces/:id/ai/trends/graph). Hiển thị mạng lưới các nút (Từ khóa, Chủ đề, Thực thể, Hashtag) và các cạnh liên kết đồng xuất hiện trong cơ sở dữ liệu đồ thị Neo4j, giúp người làm nội dung nắm bắt ngữ cảnh lan truyền của từng xu hướng (BR-45).

---

## UC-090 — View Brand Knowledge Documents

- **Related FR:** `3.7.3` (3.7 AI Features)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`, `Client`
- **Business Rules:** `BR-20, BR-46`
- **System Messages:** `MSG01, MSG02, MSG03, MSG07`
- **Specification & Flow:** Xem danh sách và tìm kiếm ngữ nghĩa các tài liệu Brand Guideline trong kho tri thức AI của Workspace (View Brand Knowledge Documents — /workspaces/:id/ai/knowledge). Hiển thị trạng thái vector hóa (PENDING, INDEXED, FAILED), số lượng đoạn văn bản (chunks) đã nhúng trong ChromaDB và cho phép kiểm tra truy vấn ngữ nghĩa theo từng Workspace độc lập (BR-20, BR-46).

---

## UC-091 — Upload Brand Knowledge Document

- **Related FR:** `3.7.4` (3.7 AI Features)
- **Canonical Actor(s):** `Owner`, `Manager`, `Client`
- **Business Rules:** `BR-20, BR-46, BR-49`
- **System Messages:** `MSG02, MSG07, MSG22, MSG46`
- **Specification & Flow:** Tải lên tài liệu Brand Guideline (định dạng PDF, DOCX, TXT, HTML, tối đa 10 MB (hoặc Web URL)) vào kho tri thức RAG của Workspace (Upload Brand Knowledge Document — /workspaces/:id/ai/knowledge). Hệ thống quét bảo mật tệp (magic-byte & macro), lưu bản gốc lên S3, tự động băm nhỏ văn bản (chunking) và tạo vector nhúng lưu vào phân vùng ChromaDB riêng biệt của Workspace để làm ngữ cảnh chuẩn khi AI sinh nội dung (BR-20, BR-46).

---

## UC-092 — Delete Brand Knowledge Document

- **Related FR:** `3.7.5` (3.7 AI Features)
- **Canonical Actor(s):** `Owner`, `Manager`, `Client`
- **Business Rules:** `BR-20, BR-47`
- **System Messages:** `MSG01, MSG02, MSG03, MSG07, MSG46`
- **Specification & Flow:** Xóa tài liệu Brand Guideline khỏi kho tri thức AI của Workspace (Delete Brand Knowledge Document — /workspaces/:id/ai/knowledge/:docId). Hệ thống xóa tệp tài liệu trên S3 đồng thời xóa sạch toàn bộ các đoạn vector nhúng (embeddings) tương ứng trong ChromaDB để AI không còn truy xuất dữ liệu cũ (BR-20, BR-47).

---

## UC-093 — Generate Caption

- **Related FR:** `3.7.6` (3.7 AI Features)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`
- **Business Rules:** `BR-46, BR-48, BR-49, BR-60, BR-64`
- **System Messages:** `MSG02, MSG07, MSG47, MSG48, MSG49`
- **Specification & Flow:** Sinh tự động nội dung bài viết / caption mạng xã hội bằng mô hình ngôn ngữ lớn kết hợp kho tri thức thương hiệu (Generate Caption — /workspaces/:id/ai/caption). Sử dụng kiến trúc Brand Hybrid GraphRAG (truy xuất ngữ cảnh thương hiệu từ ChromaDB + xu hướng từ Neo4j) đưa vào LLM (Groq Llama / Gemini) để tạo caption chuẩn giọng điệu thương hiệu theo từng nền tảng; kiểm tra và khấu trừ AI Credit nguyên tử (atomic) theo bảng giá hiện hành, tự động hoàn trả credit nếu tiến trình AI gặp lỗi (BR-49, BR-48).

---

## UC-094 — Generate Ambassador

- **Related FR:** `3.7.7` (3.7 AI Features)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`
- **Business Rules:** `BR-46, BR-48, BR-49, BR-60, BR-64`
- **System Messages:** `MSG02, MSG07, MSG47, MSG48, MSG49`
- **Specification & Flow:** Khởi tạo hình mẫu Đại sứ Thương hiệu Ảo bằng AI (Generate Ambassador — /workspaces/:id/ai/ambassadors). Cho phép tạo và lưu trữ các nhân vật/người mẫu ảo đại diện nhất quán cho thương hiệu (dựa trên ảnh chân dung tham chiếu kết hợp mô tả ngoại hình, độ tuổi, phong cách bằng pipeline Qwen Image 2.1 LoRA) để tái sử dụng xuyên suốt khi sinh hình ảnh sản phẩm (3.7.9) và video ngắn (3.7.11) khi nhãn hàng chưa có người mẫu riêng (BR-49, BR-48).

---

## UC-095 — View Image Style Template

- **Related FR:** `3.7.8` (3.7 AI Features)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`
- **Business Rules:** `BR-46, BR-49`
- **System Messages:** `MSG01, MSG02, MSG03, MSG07`
- **Specification & Flow:** Xem thư viện các mẫu phong cách hình ảnh thiết lập sẵn (View Image Style Template — /workspaces/:id/ai/image-styles). Hệ thống cung cấp các Style Preset mẫu (như Studio Product, Anime, Mùa xuân, Hồi ức Vintage, Cyberpunk, Minimalist Editorial...) kèm ảnh minh họa và thông số kỹ thuật ẩn để người dùng chọn nhanh phong cách mà không cần viết câu lệnh (prompt) phức tạp (BR-49).

---

## UC-096 — Generate Image

- **Related FR:** `3.7.9` (3.7 AI Features)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`
- **Business Rules:** `BR-46, BR-48, BR-49, BR-50, BR-60, BR-64`
- **System Messages:** `MSG02, MSG07, MSG47, MSG48, MSG49`
- **Specification & Flow:** Sinh hình ảnh quảng cáo/bài đăng bằng AI (Generate Image — /workspaces/:id/ai/image). Tổng hợp dữ liệu đầu vào từ biểu mẫu mô tả + Mẫu phong cách (3.7.8) + Đại sứ ảo (3.7.7) + Tư liệu sản phẩm trong kho để tạo câu lệnh hoàn chỉnh đưa vào mô hình khuếch tán tích hợp LoRA (Qwen Image 2.1 (ComfyUI GPU)); kiểm tra hạn mức, khấu trừ AI Credit nguyên tử và lưu ảnh kết quả vào kho tư liệu (BR-49, BR-48).

---

## UC-097 — View Video Style Template

- **Related FR:** `3.7.10` (3.7 AI Features)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`
- **Business Rules:** `BR-46, BR-49`
- **System Messages:** `MSG01, MSG02, MSG03, MSG07`
- **Specification & Flow:** Xem thư viện các mẫu phong cách và chuyển động máy quay cho Video AI (View Video Style Template — /workspaces/:id/ai/video-styles). Tương tự thư viện mẫu ảnh (3.7.8) nhưng chuyên biệt cho sinh video ngắn: cung cấp các mẫu chuyển động camera (Pan, Zoom, Orbit, Cinematic Slow-mo), ánh sáng và nhịp điệu hình ảnh cho Reels/TikTok/Shorts (BR-49).

---

## UC-098 — Generate Video

- **Related FR:** `3.7.11` (3.7 AI Features)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`
- **Business Rules:** `BR-46, BR-48, BR-49, BR-50, BR-60, BR-64`
- **System Messages:** `MSG02, MSG07, MSG47, MSG48, MSG49`
- **Specification & Flow:** Sinh video ngắn phục vụ đăng tải mạng xã hội bằng AI (Generate Video — /workspaces/:id/ai/video). Kết hợp câu lệnh mô tả kịch bản cảnh quay, hình ảnh tham chiếu / Đại sứ thương hiệu ảo (3.7.7) và Mẫu phong cách video (3.7.10) thông qua API sinh video chuyên dụng (Google Veo / Google Veo 3.1); xử lý bất đồng bộ qua hàng đợi, khấu trừ AI Credit theo thời lượng/độ phân giải và tự động hoàn trả credit nếu tiến trình render thất bại (BR-49, BR-48).

---

## UC-099 — Export File

- **Related FR:** `3.7.12` (3.7 AI Features)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`
- **Business Rules:** `BR-20, BR-50`
- **System Messages:** `MSG02, MSG03, MSG07, MSG22`
- **Specification & Flow:** Xuất và chuyển đổi định dạng tệp đa phương tiện do AI khởi tạo về máy cá nhân (Export File — /workspaces/:id/ai/export). Khác với tải xuống tư liệu gốc đơn thuần (3.6.19), chức năng Export cho phép người dùng lựa chọn xuất ra nhiều định dạng chuẩn tối ưu cho từng mạng xã hội (Video: MP4 H.264, WebM; Ảnh: PNG, JPG, WEBP) và tỷ lệ khung hình (9:16, 1:1, 16:9) mà không tốn thêm AI Credit (BR-50, BR-50).

---

## UC-100 — Crawl Schedule Config

- **Related FR:** `3.7.13` (3.7 AI Features)
- **Canonical Actor(s):** `Admin`
- **Business Rules:** `BR-45, BR-62, BR-65`
- **System Messages:** `MSG02, MSG03, MSG07, MSG60`
- **Specification & Flow:** Cấu hình lịch trình và nguồn thu thập dữ liệu tự động cho bộ cào xu hướng (Crawl Schedule Config — /admin/crawler-config). Thiết lập biểu thức thời gian chạy định kỳ (Cron schedule), danh sách trang/nguồn dữ liệu mục tiêu, lĩnh vực từ khóa, và giới hạn số lượng bài thu thập mỗi phiên cho tiến trình ngầm AI Trend Crawler (BR-45).

---

## UC-101 — Suggest Hashtag Trend

- **Related FR:** `3.7.14` (3.7 AI Features)
- **Canonical Actor(s):** `Owner`, `Manager`, `Creator`
- **Business Rules:** `BR-39, BR-45`
- **System Messages:** `MSG02, MSG07, MSG47, MSG49`
- **Specification & Flow:** Gợi ý tự động bộ thẻ Hashtag đang thịnh hành bằng AI (Suggest Hashtag Trend — /workspaces/:id/ai/hashtags). Hoạt động tại 2 vị trí: (1) Gợi ý trực tiếp trong trình soạn thảo nội dung (3.6.10) dựa trên nội dung bài viết đang viết, và (2) Gợi ý khi quản lý bộ sưu tập Hashtag của Workspace (3.6.22) để các thành viên thêm nhanh các hashtag có điểm xu hướng cao (BR-45, BR-45).

---

## UC-102 — View Collaborator Directory

- **Related FR:** `3.7.15` (3.7 AI Features)
- **Canonical Actor(s):** `Owner`, `Manager`
- **Business Rules:** `BR-20, BR-51`
- **System Messages:** `MSG01, MSG02, MSG03, MSG07`
- **Specification & Flow:** Xem và lọc danh bạ đối tác truyền thông bên thứ ba của Agency (View Collaborator Directory — /workspaces/:id/collaborators). Quản lý tập trung danh sách KOL, KOC, Báo điện tử, Mạng lưới đặt Banner quảng cáo và Kênh truyền hình TV kèm theo lĩnh vực, bảng giá tham khảo, chỉ số tiếp cận và trạng thái hợp tác trong chiến dịch (BR-51).

---

## UC-103 — Create Collaborator Profile

- **Related FR:** `3.7.16` (3.7 AI Features)
- **Canonical Actor(s):** `Owner`, `Manager`
- **Business Rules:** `BR-15, BR-51`
- **System Messages:** `MSG02, MSG03, MSG04, MSG07, MSG50`
- **Specification & Flow:** Thêm mới hồ sơ đối tác truyền thông bên thứ ba (KOL/KOC, Báo điện tử, Trang treo Banner, Kênh TV) vào danh bạ của Agency (Create Collaborator Profile — /workspaces/:id/collaborators/new). Lưu trữ Tên đối tác, Phân loại kênh, Lĩnh vực chuyên môn, Quy mô độc giả/người theo dõi, Đơn giá dự kiến và Thông tin liên hệ đầu mối (BR-51).

---

## UC-104 — Update Collaborator Profile

- **Related FR:** `3.7.17` (3.7 AI Features)
- **Canonical Actor(s):** `Owner`, `Manager`
- **Business Rules:** `BR-51`
- **System Messages:** `MSG01, MSG02, MSG03, MSG07, MSG50`
- **Specification & Flow:** Cập nhật thông tin hồ sơ đối tác truyền thông và tiến độ hợp tác trong chiến dịch (Update Collaborator Profile — /workspaces/:id/collaborators/:collaboratorId). Theo dõi trạng thái làm việc thực tế (CONTACTED -> NEGOTIATING -> CONFIRMED -> LIVE_ON_AIR -> COMPLETED), chi phí thực tế và đường dẫn nghiệm thu bài đăng/quảng cáo (Proof of Performance) (BR-51).

---

## UC-105 — Remove Collaborator Profile

- **Related FR:** `3.7.18` (3.7 AI Features)
- **Canonical Actor(s):** `Owner`, `Manager`
- **Business Rules:** `BR-15, BR-51`
- **System Messages:** `MSG01, MSG02, MSG03, MSG07, MSG36, MSG50`
- **Specification & Flow:** Xóa mềm hoặc ngừng kích hoạt hồ sơ đối tác truyền thông khỏi danh bạ hoạt động của Agency (Remove Collaborator Profile — /workspaces/:id/collaborators/:collaboratorId). Bảo toàn lịch sử chi phí và dữ liệu nghiệm thu của đối tác trong các chiến dịch đã thực hiện trước đó (BR-51).

---

## UC-106 — Recommend Collaborator

- **Related FR:** `3.7.19` (3.7 AI Features)
- **Canonical Actor(s):** `Owner`, `Manager`
- **Business Rules:** `BR-51, BR-52`
- **System Messages:** `MSG01, MSG02, MSG07, MSG50`
- **Specification & Flow:** Đề xuất thông minh danh sách đối tác truyền thông bên thứ ba phù hợp bằng AI (Recommend Collaborator — /workspaces/:id/ai/collaborator-recommendations). Dựa trên mục tiêu chiến dịch, ngành hàng thương hiệu và ngân sách dự kiến, AI chấm điểm độ tương thích và phân cấp các phương án tối ưu (Báo điện tử, Trang chạy Banner, Kênh truyền hình TV, KOL/KOC) để Agency và Client lựa chọn (BR-52).
