# 06 — AI Features

> [<< Về Overview](00_Overview.md)

## Danh sách FR đầy đủ (3.7.1 – 3.7.12)

| FR | Tên | Role | Mô tả |
|---|---|---|---|
| 3.7.1 | View Trending Topics Suggestions | CREATOR | Dashboard xem keyword trend hiện tại |
| 3.7.2 | Generate Caption | CREATOR | Dùng LLM + prompt để tạo caption cho bài post |
| 3.7.3 | Generate Ambassador | CREATOR | Dùng LLM generate Model (người ảo) khi brand không có model thật. Model được dùng để generate Image và Video |
| 3.7.4 | View Image Style Template | CREATOR | Gợi ý template mẫu phong cách (anime, mùa xuân, hồi ức...) để tạo Image theo style mà không cần mô tả nhiều |
| 3.7.5 | Generate Image | CREATOR | Dùng LLM + prompt tạo Image. Input = form + model + materials khác → chuyển thành prompt. Có LoRA lai với model LLM gen Image |
| 3.7.6 | View Video Style Template | CREATOR | Tương tự 3.7.4 nhưng áp dụng cho LLM gen Video |
| 3.7.7 | Generate Video | CREATOR | Dùng LLM + prompt tạo Video (dùng API gen video bên thứ 3). Có thể mở rộng thành studio |
| 3.7.8 | Export File | CREATOR | Export file về máy sau khi generate, nhiều định dạng — chủ yếu upload social thì mp4 hoặc webM |
| 3.7.9 | Crawl Schedule Config | ADMIN | Cấu hình bộ cào data phục vụ tìm keyword trend: thời gian, page nào, số bài/lần |
| 3.7.10 | Suggest Hashtag Trend | CREATOR | Gợi ý hashtag trend cho content creator |
| 3.7.11 | Generate Livestream Script | CREATOR | Tạo mẫu kịch bản cho livestream |
| 3.7.12 | Recommend Collaborator | CREATOR | Gợi ý bên thứ 3 (báo điện tử, trang chạy banner, kênh TV) để Client chọn làm đối tác truyền thông cho chiến dịch, có phân cấp option |

## Ghi chú nghiệp vụ quan trọng

### Generate Ambassador → Image/Video (3.7.3)
- Model ảo (Ambassador) sinh ra từ LLM được **dùng làm input** cho cả Generate Image và Generate Video — không phải feature độc lập, mà là 1 nguồn "diễn viên ảo" tái sử dụng xuyên suốt pipeline tạo nội dung khi brand không có người mẫu/đại sứ thật.

### Generate Image — pipeline input (3.7.5)
- Input để generate ảnh = **form (do Creator điền) + model (ambassador nếu có) + materials khác** (từ Material Repository/Brand Collection) → hệ thống ghép lại thành 1 prompt hoàn chỉnh gửi cho model AI.
- Có sử dụng **LoRA** lai (fine-tune nhẹ) với model LLM gen Image — cho phép custom phong cách riêng theo brand.

### Recommend Collaborator (3.7.12) — liên kết module mới
- Đây chính là AI tool hỗ trợ cho module **Third-party Collaborator** (đối tác truyền thông ngoài social media) — xem chi tiết đầy đủ ở [07_Publishing_Social_Collaborator.md](07_Publishing_Social_Collaborator.md) mục 2.
- AI chỉ **gợi ý** — không tự động ký kết hay liên hệ, quyết định cuối vẫn do Client/Manager chọn.

### Crawl Schedule Config (3.7.9) — duy nhất thuộc ADMIN
- Đây là FR AI duy nhất trong nhóm 3.7 thuộc quyền ADMIN (không phải CREATOR) — vì việc cấu hình crawler ảnh hưởng toàn hệ thống (tài nguyên server, tần suất gọi API bên ngoài), không phải thao tác cấp workspace.

### Generate Livestream Script (3.7.11) — hỗ trợ Loại Task Livestream
- Tool này hỗ trợ trực tiếp cho FR 3.6.23 (Write Livestream Script) ở [05_Content_Task_Workflow.md](05_Content_Task_Workflow.md) — Creator dùng AI để có bản kịch bản mẫu trước khi tự viết/chỉnh sửa hoàn chỉnh.
