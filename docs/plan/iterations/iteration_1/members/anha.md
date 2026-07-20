# AI Iteration 1 — Individual Report

---

## 1. Thông tin cá nhân

| Field | Value |
|---|---|
| Họ tên | Hà Thị Ân |
| GitHub | [@anha] |
| Role | AI Engineer |
| Iteration | Iteration 1 — Research & Evaluation |
| Ngày nộp | 2026-07-12 |

---

## 2. Tasks được giao trong iteration này

| Task ID | Jira Link | Mô tả | Priority | Status cuối iteration |
|---|---|---|---|---|
| DA-AI01-03 | [DA-AI01-03](https://letritrung2605.atlassian.net/browse/DA-AI01-03) | Research Google Veo API: capabilities, pricing, rate limits, movement parameters | 🔴 Critical | ✅ Done |
| DA-AI01-04 | [DA-AI01-04](https://letritrung2605.atlassian.net/browse/DA-AI01-04) | Collect and test 20+ video generation prompts, classify results | 🔴 Critical | ✅ Done |
| DA-AI01-08 | [DA-AI01-08](https://letritrung2605.atlassian.net/browse/DA-AI01-08) | Write AI Research Summary Document consolidating results from all 3 tracks | 🟢 Medium | ✅ Done |

**Tổng:** 3 tasks | Done: 3 | In Review: 0 | Chưa hoàn thành: 0

---

## 3. Chi tiết công việc đã làm

### [DA-AI01-03] — Research Google Veo API: capabilities, pricing, rate limits, movement parameters

**Jira status:** Done  
**Branch:** `feature/anha` (brandhub-ai-service) & `anha` (brandhub-infrastructure)  
**Commit chính:** `3dbb0af` & `4e4894a` (brandhub-ai-service)  
**File tạo ra / thay đổi:**
- `app/services/veo_client.py` (brandhub-ai-service)
- `app/api/v1/endpoints/video.py` (brandhub-ai-service)
- `Dockerfile` (brandhub-ai-service)
- `requirements.txt` (brandhub-ai-service)

**Mô tả công việc đã làm:**
- Nghiên cứu toàn diện về API Google Veo (mô hình chính `veo-3.1-flash`, định giá $0.40/5s cho 1080p và $0.15/5s cho 720p, các giới hạn 4s/6s/8s per call).
- Thiết lập giải pháp **Video Chaining** vượt giới hạn 8s bằng cách lấy frame cuối của video trước làm `image_url` (Character/Product reference) đầu vào cho cuộc gọi tiếp theo nhằm khóa chuyển động và giữ vững tính nhất quán của sản vật/nhân vật.
- Sử dụng FFmpeg ngầm trong Background Task để ghép (stitch) các đoạn video ngắn thành một file duy nhất và tự động upload lên AWS S3.

**Kết quả đạt được:**
- [x] Khảo sát chi tiết tính năng, chi phí, giới hạn API Google Veo.
- [x] Thiết lập cơ chế Video Chaining giúp tạo video Marketing dài (15s-20s) mà vẫn đảm bảo tính nhất quán của sản phẩm/nhân vật.
- [x] Implement API endpoint bất đồng bộ (Async) tích hợp Motor, FastAPI, Redis.

**Khó khăn gặp phải:** Tài liệu chính thức của Google Veo còn hạn chế về rate limit và các tham số chuyển động chi tiết, phải benchmark thực nghiệm nhiều lần.  
**Thời gian thực tế:** ~8 giờ

---

### [DA-AI01-04] — Collect and test 20+ video generation prompts, classify results

**Jira status:** Done  
**Branch:** `feature/anha` (brandhub-ai-service)  
**Commit chính:** `951e0b1` (brandhub-ai-service)  
**File tạo ra / thay đổi:**
- `app/services/video_prompt_service.py` (brandhub-ai-service)
- `app/utils/prompts.json` (brandhub-ai-service)
- `app/utils/video_params.py` (brandhub-ai-service)
- `app/utils/video_templates.py` (brandhub-ai-service)
- `tests/test_video_params.py` (brandhub-ai-service)

**Mô tả công việc đã làm:**
- Thu thập và thử nghiệm hơn 30 prompt sinh video, phân loại theo mục đích sử dụng (Product Intro - Static/Pan, Lifestyle - Zoom In, Unboxing - Static, v.v.).
- Tối ưu hóa cấu trúc prompt theo cấu trúc tuyến tính (bối cảnh -> nhân vật chính -> hành động -> góc máy -> ánh sáng), giảm thiểu từ nhiễu (noise words) và sử dụng các thuật ngữ điện ảnh tiêu chuẩn (*slow pan left, dynamic zoom in*).
- Thiết lập Benchmark table đánh giá chất lượng (đạt trung bình 4.6/5 sao), thời gian render (trung bình ~20s) và chi phí ($0.40).

**Kết quả đạt được:**
- [x] 30 templates chất lượng tốt được chuẩn hóa lưu trữ trong `video_templates.py`.
- [x] Phân loại rõ ràng các loại cảnh quay và hướng dẫn tối ưu hóa prompt dựa trên thực nghiệm.

**Thời gian thực tế:** ~6 giờ

---

### [DA-AI01-08] — Write AI Research Summary Document consolidating results from all 3 tracks

**Jira status:** Done  
**Branch:** `anha` (brandhub-infrastructure)  
**Commit chính:** `91a0597` (brandhub-infrastructure)  
**File tạo ra / thay đổi:**
- [Video_Generation_Research_Report.md](file:///d:/FPT/FA26/brandhub-infrastructure/docs/plan/iterations/iteration_1/Video_Generation_Research_Report.md) — 53 dòng, báo cáo benchmark & nghiên cứu video

**Mô tả công việc đã làm:**
- Tổng hợp kết quả nghiên cứu từ các mảng (Video AI, Virtual Ambassador, Admin APIs) để viết báo cáo nghiên cứu và benchmark tổng thể Iteration 1.
- Làm rõ mô hình, chi phí, giới hạn kỹ thuật và giải pháp kiến trúc (Video Chaining, FFmpeg stitching, Async execution).
- Xác định các rủi ro về mặt an toàn nội dung (Google Safety Filter) và lỗi biến dạng hình ảnh (warping) khi nhân vật di chuyển quá nhanh.

**Kết quả đạt được:**
- [x] Hoàn thành tài liệu tổng kết nghiên cứu chất lượng cao, cung cấp hướng dẫn rõ ràng cho các giai đoạn tiếp theo.

**Thời gian thực tế:** ~5 giờ

---

## 4. Tasks chưa hoàn thành

*Không có task nào chưa hoàn thành.*

---

## 5. Đóng góp ngoài tasks chính

- Tham gia thiết kế hệ thống Admin API (Regex search, Ban user) trong `admin.py`.
- Setup kịch bản tự động hóa và script `clone-all.sh`.
- Hỗ trợ team setup Docker Compose cho `brandhub-ai-service`.

---

## 6. Học được gì trong iteration này

1. **Video Chaining & Character/Product Consistency:** Cách sử dụng frame cuối của video trước làm input tham chiếu cho video sau để giữ tính nhất quán về mặt visual.
2. **Kiến trúc Async/Await trong xử lý Media:** Hiểu rõ tầm quan trọng của việc đưa các tác vụ nặng (như FFmpeg stitching, upload S3) vào background tasks nhằm tối ưu hóa throughput của FastAPI server.
3. **Prompt Engineering nâng cao cho Video:** Quy tắc viết câu lệnh tuyến tính, các thuật ngữ góc máy camera chuẩn điện ảnh đem lại hiệu quả vượt trội so với ngôn ngữ tự nhiên thông thường.

---

## 7. Feedback & Đề xuất

### 7.1 Về quy trình làm việc
Quá trình thử nghiệm API của Google Veo tốn nhiều thời gian và chi phí, cần có ngân sách test rõ ràng từ đầu Iteration.

### 7.2 Về kỹ thuật & hệ thống
Sử dụng Background Tasks của FastAPI để chạy FFmpeg có rủi ro gây cạn kiệt RAM/CPU khi lượng truy cập lớn. Đề xuất chuyển sang kiến trúc Message Queue với RabbitMQ và Celery ở Iteration 2 để xử lý hàng đợi render tốt hơn.

---

## 8. Self-assessment

| Tiêu chí | Điểm (1-5) | Ghi chú |
|---|---|---|
| Hoàn thành đúng deadline | 5/5 | Hoàn thành toàn bộ deliverables trước ngày report |
| Chất lượng deliverable | 5/5 | 30 templates chất lượng tốt, giải pháp Video Chaining chạy ổn định |
| Giao tiếp với team | 4/5 | Cần chủ động hơn trong việc review PR |
| Chủ động xử lý blocker | 5/5 | Tự giải quyết được giới hạn 8s của Google Veo |
| **Tổng** | **19/20** | |

---

*Deadline nộp: cuối Iteration 1 (song song Sprint 5–6)*
