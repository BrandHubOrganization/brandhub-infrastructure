# Test — G6 AI Features (Mobile)

> [plan.md](./plan.md) | [task.md](./task.md)

| ID | Mô tả | AC/Edge | Kết quả mong đợi | Trạng thái |
|---|---|---|---|---|
| TC-01 | AI Hub hiện đúng credit balance | Mục 4 | `GET /ai/credits` hiển thị `remaining` đúng | Chưa test |
| TC-02 | Generate Caption thành công | Mục 4, đồng bộ | Trả 3 variant ngay, kèm `signals`+`compliance` | Chưa test |
| TC-03 | Generate Caption input quá ngắn/quá dài | Validate topic 10-1000 ký tự | Lỗi validate rõ ràng trước khi gọi API | Chưa test |
| TC-04 | Refine caption từ variant đã chọn | Mục 3.2 | `POST /captions/refine` trả 1 draft mới | Chưa test |
| TC-05 | Adapt caption sang platform khác | Mục 3.2 | `POST /captions/adapt` trả nhiều draft, 1/platform | Chưa test |
| TC-06 | Generate Video — submit job thành công | Mục 3.1, 202 Accepted | Hiện ngay "Đã trừ N credit — đang xử lý", job status PENDING | Chưa test |
| TC-07 | Poll video job tới khi COMPLETED | Mục 3.5 polling | `refetchInterval` dừng khi status đổi, hiện `videoUrl` | Chưa test |
| TC-08 | Video job FAILED | Mục 4, error case | Hiện `errorCode`, thông báo credit đã hoàn (`refunded=true`) | Chưa test |
| TC-09 | Video job PENDING quá lâu (server sweep 60s) | Mục 5, timeout 600s | Không cần mobile tự xử lý timeout, server tự fail+refund, mobile chỉ hỏi lại khi mở app | Chưa test |
| TC-10 | Insufficient credit khi generate video | Mục 6, 402 INSUFFICIENT_AI_CREDIT | Thông báo riêng "không đủ credit" + link Subscription (G7), không lỗi chung | Chưa test |
| TC-11 | Lỗi INVALID_REQUEST (style/ambassador sai) | Mục 6 | Không trừ credit, copy UI khác với job fail sau khi charge | Chưa test |
| TC-12 | Lỗi AI_SERVICE_UNAVAILABLE | Mục 6 | Không trừ credit, thông báo lỗi hạ tầng riêng biệt | Chưa test |
| TC-13 | Video History hiện đúng job gần nhất | Mục 3.1 | `GET /videos` tối đa 12 job | Chưa test |
| TC-14 | Generate Image (sau khi xác nhận shape + credit flow) | Mục 3.3, chặn trước đó | Flow hoạt động đúng theo shape thật đã xác nhận với BE | Chưa test |
| TC-15 | Generate Image — KHÔNG hiện sai thông tin trừ credit | Mục 6, chưa rõ credit flow | UI không hiển thị "đã trừ N credit" cho tới khi backend xác nhận | Chưa test |
| TC-16 | Gắn kết quả generate vào Task | Mục 4, liên kết G5 | Material/Video/Caption gắn đúng vào Task đã chọn | Chưa test |
| TC-17 | Lưu kết quả vào Material Repository | Mục 4, liên kết G2 | Material record tạo đúng loại | Chưa test |
| TC-18 | Export file về máy | FR 3.7.8 | File tải về đúng định dạng | Chưa test |
| TC-19 | Preview/download video lớn trên mobile data | Mục 8 câu 2 | Cảnh báo dùng Wifi trước khi tải | Chưa test |
