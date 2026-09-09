# AI Iteration 1 Report — Research & Evaluation

---

## 1. Thông tin Iteration

| Field | Value |
|---|---|
| Iteration | Iteration 1 — Research & Evaluation |
| Timeline | Parallel with Sprints 1-3 |
| Goal | Evaluate AI tools for all 3 tracks (ambassador, video, image composition) and set up the ai-service project foundation |
| Report date | 2026-07-18 |
| Reported by | Nguyễn Thành Lộc (AI Track Aggregator) |

---

## 2. Tổng kết hoàn thành

### 2.1 Tỉ lệ hoàn thành theo Epic

| Epic | Tổng tasks | Done | In Review | In Progress | To Do | % Done |
|---|---|---|---|---|---|---|
| AI-01 — AI Model Research & Evaluation | 8 | 8 | 0 | 0 | 0 | 100% |
| AI-02 — AI Service Infrastructure Setup | 7 | 7 | 0 | 0 | 0 | 100% |
| **Tổng** | **15** | **15** | **0** | **0** | **0** | **100%** |

### 2.2 Tỉ lệ hoàn thành theo thành viên

| Thành viên | Tasks được giao | Done/In Review | Chưa làm | Ghi chú |
|---|---|---|---|---|
| Tuấn (AI) | 5 | 5 | 0 | Hoàn thành xuất sắc nghiên cứu Virtual Ambassador và setup API clients. |
| Ân (AI) | 4 | 4 | 0 | Thiết lập thành công Video Generation Chaining và Pydantic base models. |
| Lộc (Frontend / AI Infra) | 5 | 5 | 0 | Xây dựng base FastAPI, Dockerfile tối ưu và cấu hình AWS S3 helper. |
| All (Shared Task) | 1 | 1 | 0 | So sánh Llama 3 (Groq) vs Claude API cho caption tiếng Việt. |

---

## 3. Deliverables đã hoàn thành

| Deliverable | File/Link | Tác giả | Chất lượng |
|---|---|---|---|
| Video Generation Research Report | [Video_Generation_Research_Report.md](file:///d:/FPT/FA26/brandhub-infrastructure/docs/plan/iterations/iteration_1/Video_Generation_Research_Report.md) | Ân | ⭐⭐⭐⭐⭐ |
| AI Fashion Model Platform Analysis | [DA-59_AI_Fashion_Model_Generation_Platforms.md](file:///d:/FPT/FA26/brandhub-infrastructure/docs/AI_Models/DA-59_AI_Fashion_Model_Generation_Platforms.md) | Tuấn | ⭐⭐⭐⭐ |
| ChromaDB Collection Design Document | [DA-AI02-07_ChromaDB_Collection_Design.md](file:///d:/FPT/FA26/brandhub-infrastructure/docs/database/DA-AI02-07_ChromaDB_Collection_Design.md) | Tuấn | ⭐⭐⭐⭐⭐ |
| FastAPI Project Scaffold & Foundation | [brandhub-ai-service](file:///d:/FPT/FA26/brandhub-ai-service) | Lộc | ⭐⭐⭐⭐⭐ |
| AWS S3 Client & boto3 helper functions | `app/utils/s3.py` (brandhub-ai-service) | Lộc | ⭐⭐⭐⭐⭐ |
| Docker Multi-stage configuration | `Dockerfile` (brandhub-ai-service) | Lộc | ⭐⭐⭐⭐⭐ |
| Pydantic Base Request/Response Schemas | `app/models/base.py` (brandhub-ai-service) | Ân | ⭐⭐⭐⭐⭐ |
| Video Prompt Library (30 templates) | `app/utils/video_templates.py` (brandhub-ai-service) | Ân | ⭐⭐⭐⭐⭐ |
| Google Veo Async Polling Endpoints | `app/api/v1/endpoints/video.py` (brandhub-ai-service) | Ân | ⭐⭐⭐⭐⭐ |
| Internal API Authentication Middleware | `app/core/security.py` (brandhub-ai-service) | Tuấn | ⭐⭐⭐⭐⭐ |

---

## 4. Deliverables chưa hoàn thành

| Task ID | Mô tả | Assignee | Lý do | Kế hoạch |
|---|---|---|---|---|
| *(Không có)* | | | | |

---

## 5. Đánh giá chất lượng

- **Kiến trúc Asynchronous & Performance**: Toàn bộ luồng media xử lý nặng (Google Veo API, FFmpeg stitching, FLUX inpainting) đều chạy bất đồng bộ dưới dạng background task kết hợp với polling status từ Redis, giúp API gateway phản hồi tức thì và không bị nghẽn luồng.
- **Chất lượng hình ảnh/video đầu ra**: Kỹ thuật **Video Chaining** (dùng frame cuối làm ảnh tham chiếu) khóa chặt được visual của sản phẩm/nhân vật qua nhiều cảnh quay. Việc sử dụng **FLUX.1-schnell** mang lại chất lượng inpainting với biên hòa trộn và đổ bóng xuất sắc.
- **Độ tin cậy của mã nguồn**: Dự án `brandhub-ai-service` được bao phủ unit tests đầy đủ cho module S3 bằng thư viện `moto`. Dữ liệu đầu vào được kiểm soát chặt chẽ bằng Pydantic V2 schemas giúp ngăn ngừa dữ liệu lỗi.

---

## 6. Blocked tasks & Dependencies

*(Không có)*

---

## 7. Individual highlights

- **Lộc**: Thiết lập khung dự án FastAPI chuẩn chỉnh, tối ưu Dockerfile multi-stage build kết hợp PyTorch CPU giúp giảm dung lượng image đáng kể, bao phủ unit test AWS S3 bằng `moto`.
- **Ân**: Đưa ra giải pháp Video Chaining và FFmpeg stitching chạy ngầm giúp sinh video dài (15s-20s) từ Google Veo API một cách ổn định, bảo toàn cấu trúc sản phẩm.
- **Tuấn**: Xây dựng ma trận đánh giá chi tiết các mô hình Virtual Ambassador (InstantID, Z-Image) và thiết kế ChromaDB collection schema khoa học, làm tiền đề cho pha R&D tiếp theo.

---

## 8. Iteration Retrospective

### 8.1 What went well?

- Toàn đội đã nghiên cứu thực nghiệm sâu sắc cả 3 mảng cốt lõi (Video AI, Virtual Ambassador, Image Compositing), tạo cơ sở dữ liệu và rubric đánh giá thực tế cho các quyết định kiến trúc.
- Hoàn thành 100% các task đúng hạn với các deliverables chất lượng cao, có tài liệu và mã nguồn sạch.
- Phối hợp nhịp nhàng để thống nhất chuẩn API response format (`ApiResponse<T>`) và cơ chế bảo mật `X-Internal-Key`.

### 8.2 What didn't go well?

- Chi phí gọi các API Cloud (Fal.ai, Replicate, Google Veo) phục vụ benchmark tương đối cao, cần tối ưu hóa và quản lý key tiết kiệm hơn.
- Xử lý FFmpeg bằng Background Task trực tiếp của FastAPI có rủi ro gây cạn RAM/CPU khi chịu tải đồng thời lớn.

### 8.3 Action items cho Iteration 2

| Action | Owner | Deadline |
|---|---|---|
| Nghiên cứu thay thế Background Tasks bằng RabbitMQ + Celery để xử lý media xếp hàng | Ân | Iteration 2 Week 1 |
| Tích hợp luồng gửi email thông báo ngầm khi Ban User | Lộc | Iteration 2 Week 2 |
| Bắt đầu triển khai RAG pipeline và LLM Content Generation | Tuấn & Team | Iteration 2 Week 1 |

---

## 9. Kế hoạch Iteration 2

| Priority | Task | Assignee | Ghi chú |
|---|---|---|---|
| 🔴 Critical | AI-03 RAG Knowledge Base Pipeline | Tuấn, Ân, Lộc | |
| 🔴 Critical | AI-04 LLM Content Generation | Ân, Tuấn, Lộc | |
| 🟡 High | AI-05 Trend Crawler Service | Ân | |

---

## 10. Links & References

| Resource | Link |
|---|---|
| Jira AI Track Board | https://letritrung2605.atlassian.net/jira/software/projects/DA/boards |

