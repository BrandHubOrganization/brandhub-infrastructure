# AI Iteration 1 — Individual Report

---

## 1. Thông tin cá nhân

| Field | Value |
|---|---|
| Họ tên | Nguyễn Thành Lộc |
| GitHub | [@locnt] |
| Role | Frontend / AI Infra |
| Iteration | Iteration 1 — Research & Evaluation |
| Ngày nộp | 13/07/2026 |

---

## 2. Tasks được giao trong iteration này

| Task ID | Jira Link | Mô tả | Priority | Status cuối iteration |
|---|---|---|---|---|
| DA-AI01-05 | [DA-AI01-05](https://letritrung2605.atlassian.net/browse/DA-AI01-05) | Research product + model image compositing techniques | 🟡 High | 🟢 Done |
| DA-AI01-06 | [DA-AI01-06](https://letritrung2605.atlassian.net/browse/DA-AI01-06) | Test 3 compositing methods on 10 product + model image pairs | 🟡 High | 🟢 Done |
| DA-AI02-01 | [DA-AI02-01](https://letritrung2605.atlassian.net/browse/DA-AI02-01) | Initialize brandhub-ai-service project: FastAPI + Python 3.13 + folder structure | 🔴 Critical | 🟢 Done |
| DA-AI02-03 | [DA-AI02-03](https://letritrung2605.atlassian.net/browse/DA-AI02-03) | Configure AWS S3 client with boto3, write helper functions | 🔴 Critical | 🟢 Done |
| DA-AI02-05 | [DA-AI02-05](https://letritrung2605.atlassian.net/browse/DA-AI02-05) | Write Dockerfile for ai-service + add to docker-compose.yml | 🔴 Critical | 🟢 Done |

**Tổng:** 5 tasks | Done: 5 | In Review: 0 | Chưa hoàn thành: 0

---

## 3. Chi tiết công việc đã làm

### 1. DA-AI01-05 — Nghiên cứu các kỹ thuật ghép ảnh sản phẩm + model
- **Nội dung nghiên cứu:** Tập trung nghiên cứu phương pháp ghép vật phẩm/sản phẩm vào bối cảnh người mẫu (Product In-Context / Model Compositing) bằng các kỹ thuật sinh ảnh khuếch tán tiên tiến kết hợp xử lý đồ họa truyền thống, trọng tâm là mô hình **black-forest-labs/FLUX.1-schnell**:
  1. **FLUX.1-schnell (Black Forest Labs):** Nghiên cứu tích hợp mô hình text-to-image/image-to-image thế hệ mới sử dụng cấu trúc Flow Matching Transformer. Sử dụng FLUX.1-schnell Inpainting (hoặc các adapter như Flux Fill) để tự động hòa trộn vật phẩm thô vào tay hoặc cơ thể người mẫu.
     - *Ưu điểm:* Khả năng bám sát prompt và hiểu cấu trúc không gian cực tốt; tốc độ sinh ảnh siêu nhanh (chỉ cần 4 steps nhờ cơ chế Latent Adversarial Diffusion Distillation); chất lượng ánh sáng, chi tiết da người, nếp gấp trang phục và bóng đổ xung quanh vật phẩm đạt mức độ tự nhiên vượt trội so với dòng SDXL cũ.
     - *Nhược điểm:* Dung lượng mô hình rất nặng (yêu cầu cấu hình phần cứng VRAM lớn, chạy tối ưu từ 12GB+ FP8/NF4 trở lên); nếu không bảo vệ vùng mặt nạ (mask) và căn chỉnh denoising strength chuẩn xác thì mô hình dễ làm biến dạng logo hoặc thay đổi kiểu dáng chi tiết của sản phẩm.
  2. **ControlNet Inpainting & DALL-E Edit API:** Nghiên cứu làm phương án so sánh đối chiếu. DALL-E 3 Edit cho chất lượng tốt nhưng chi phí API cao ($0.02 - $0.08/ảnh) và phụ thuộc internet; ControlNet SDXL cần nhiều bước lặp hơn (20-30 steps) nên chậm hơn đáng kể so với FLUX.1-schnell.
  3. **Rembg + Pillow Composite (Xếp lớp đồ họa):** Tách nền vật phẩm dán đè lên mẫu bằng Pillow. Giữ nguyên 100% thương hiệu sản phẩm nhưng biên ghép thô và hoàn toàn không tự động sinh được bóng tiếp xúc (contact shadows).
- **Kết quả & Đề xuất:** Đề xuất kiến trúc lai: Sử dụng **Rembg + Pillow** để định vị vật phẩm chính xác lên mẫu, sau đó khoét mask vùng tiếp giáp (bàn tay cầm, chân tiếp xúc bệ) và đưa qua **FLUX.1-schnell Inpainting (Denoising thấp ~0.3 - 0.4)** để sinh ánh sáng và bóng đổ hòa trộn biên mà không làm hỏng chi tiết lõi của sản phẩm.

### 2. DA-AI01-06 — Thử nghiệm 3 phương pháp ghép ảnh trên 10 cặp ảnh sản phẩm + mẫu
- **Quá trình thực hiện:** Tiến hành ghép thử nghiệm 10 vật phẩm (như túi xách thời trang, bình giữ nhiệt, mỹ phẩm dạng chai thủy tinh) lên các hình ảnh tư thế người mẫu khác nhau. Thử nghiệm inpainting với **FLUX.1-schnell** thông qua cloud API (Fal.ai / Replicate) và so sánh chất lượng với SDXL và Pillow thuần túy.
- **Kết quả đánh giá (Rubric điểm 1-5):**
  - *FLUX.1-schnell Inpainting:* Điểm biên hòa trộn (4.7), Điểm bóng tiếp xúc (4.6), Ánh sáng nhất quán (4.7), Thời gian (1.8s), Chi phí (~$0.003 trên serverless GPU).
  - *Rembg + Pillow thuần:* Điểm biên (3.5), Điểm bóng (2.5), Ánh sáng (3.0), Thời gian (1.2s), Chi phí ($0).
  - *ControlNet SDXL Inpainting:* Điểm biên (4.2), Điểm bóng (4.0), Ánh sáng (4.1), Thời gian (4.8s trên GPU T4), Chi phí (~$0.015).
- **Kết luận từ thử nghiệm:** FLUX.1-schnell vượt trội hoàn toàn về mặt thẩm mỹ nghệ thuật quảng cáo. Tuy nhiên, đối với các sản phẩm có chữ/logo nhỏ, inpainting vẫn có tỉ lệ làm biến dạng chữ nhẹ (đạt 2/10 case bị méo logo nhẹ ở denoising strength > 0.45). Do đó, giải pháp tối ưu là giữ mask vùng logo cố định và chỉ inpaint vùng biên xung quanh vật phẩm tiếp xúc với người mẫu.

### 3. DA-AI02-01 — Khởi tạo dự án brandhub-ai-service (FastAPI + Python 3.13)
- **Công việc thực hiện:**
  - Khởi tạo khung dự án sử dụng FastAPI và quản lý dependency bằng `requirements.txt`.
  - Cấu trúc thư mục chuẩn hóa giúp phát triển song song dễ dàng:
    - `app/api/v1/endpoints/`: Định nghĩa các router cho từng feature (`content.py`, `image.py`, `video.py`, `ambassador.py`, `compose.py`, `rag.py`, `trends.py`).
    - `app/core/`: Quản lý file cấu hình `config.py` (sử dụng `pydantic-settings` để đọc từ `.env`) và bảo mật `security.py` (chứa dependency `verify_internal_key`).
    - `app/services/`: Nơi chứa logic nghiệp vụ chính.
    - `app/utils/`: Các cấu hình dùng chung như kết nối S3.
    - `tests/`: Nơi viết unit test cho hệ thống.
  - Setup thành công endpoint `GET /health` trả về `{"status": "ok"}` khi khởi động qua uvicorn trên cổng 8082.

### 4. DA-AI02-03 — Cấu hình AWS S3 client với boto3 & viết các helper functions
- **Công việc thực hiện:**
  - Viết file `app/utils/s3.py` triển khai client kết nối S3 thông qua thư viện `boto3`, lấy credentials từ biến môi trường.
  - Triển khai 3 hàm helper chính:
    - `upload_file(local_path, s3_key)`: Hỗ trợ truyền cả đường dẫn file cục bộ hoặc dữ liệu dạng `bytes` trong bộ nhớ (hữu ích cho việc upload trực tiếp ảnh vừa sinh từ AI). Tự động xác định MIME type chính xác (`image/png`, `video/mp4`) để trình duyệt hiển thị đúng.
    - `get_presigned_url(s3_key, expires_in)`: Sinh URL tạm thời có thời hạn truy cập an toàn.
    - `delete_file(s3_key)`: Xóa tệp tin trên S3.
  - Viết bộ unit tests đầy đủ tại `tests/test_s3.py` sử dụng thư viện mock `moto` để chạy test độc lập trong môi trường CI/CD mà không cần AWS credentials thật.

### 5. DA-AI02-05 — Viết Dockerfile cho ai-service và tích hợp vào docker-compose.yml
- **Công việc thực hiện:**
  - Viết `Dockerfile` tối ưu sử dụng cơ chế multi-stage build để giảm dung lượng file ảnh chạy cuối cùng:
    - Stage `builder`: Cài đặt build dependencies và cài trước gói `torch==2.5.1+cpu` từ index URL riêng của PyTorch để tránh cài bản GPU quá nặng, sau đó cài các dependencies trong `requirements.txt`.
    - Stage `runner`: Sử dụng image base `python:3.11-slim` siêu nhẹ, copy packages đã build từ stage builder sang, đảm bảo ứng dụng chạy mượt mà và an toàn.
  - Cập nhật file `docker-compose.apps.yml` trong repository infrastructure để định nghĩa service `ai-service` chạy trên port 8082, liên kết network với `chromadb` và `redis`, mount config qua file `.env`.
  - Kiểm thử khởi động service thông qua container docker chạy ổn định, thời gian build lần đầu dưới 3 phút.

---

## 4. Tasks chưa hoàn thành

- Không có. Hoàn thành 100% các task được giao đúng tiến độ.

---

## 5. Đóng góp ngoài tasks chính

- Hỗ trợ các thành viên khác cấu hình môi trường chạy Docker cục bộ để tích hợp chung các dịch vụ.
- Hỗ trợ cài đặt và debug các thư viện Python, xử lý lỗi cài đặt dependency `moto` và `boto3` trên môi trường Windows.

---

## 6. Học được gì trong iteration này

- Hiểu sâu về các kỹ thuật xử lý ảnh, tách nền sử dụng mô hình học máy (U2Net, ISNet) và cách ghép ảnh theo tọa độ, quản lý kênh alpha thông qua Pillow trong Python.
- Nâng cao kinh nghiệm thiết kế kiến trúc REST API hướng microservice sử dụng FastAPI.
- Học cách viết unit test mock AWS S3 hiệu quả bằng `pytest` và `moto` giúp quá trình phát triển độc lập và an toàn hơn.
- Hiểu rõ cơ chế tối ưu dung lượng image Docker cho ứng dụng Python có sử dụng các thư viện tính toán lớn như PyTorch.

---

## 7. Feedback & Đề xuất

- Cần thống nhất sớm chuẩn format API giữa Frontend/Backend và AI Service (đã làm trong DA-E07-04) để tránh mất thời gian map data ở các iteration sau.
- Nên xây dựng sớm bộ test dataset chuẩn cho cả 3 nhánh AI (hình ảnh sản phẩm thật, model thật, video mẫu) để quá trình đánh giá chất lượng đầu ra được đồng đều và khách quan hơn.

---

## 8. Self-assessment

| Tiêu chí | Điểm (1-5) | Ghi chú |
|---|---|---|
| Hoàn thành đúng deadline | 5/5 | Hoàn thành toàn bộ 5/5 task đúng hạn |
| Chất lượng deliverable | 5/5 | Code được bao phủ bởi unit test đầy đủ, docker chạy ổn định, báo cáo nghiên cứu chi tiết |
| Giao tiếp với team | 5/5 | Chủ động thảo luận, thống nhất cấu trúc dự án và hỗ trợ team |
| Chủ động xử lý blocker | 5/5 | Chủ động tìm hiểu giải pháp mock S3 và tối ưu build PyTorch CPU |
| **Tổng** | **20/20** | |

---

*Deadline nộp: cuối Iteration 1 (song song Sprint 5–6)*
