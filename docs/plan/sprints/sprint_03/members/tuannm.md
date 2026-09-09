# Sprint 3 — Individual Report

---

## 1. Thông tin cá nhân

| Field | Value |
|---|---|
| Họ tên | Nguyễn Minh Tuấn |
| GitHub | [@tuannm] |
| Role | AI Engineer |
| Sprint | Sprint 3 |
| Ngày nộp | 2026-06-30 |

---

## 2. Tasks được giao trong sprint này

| Task ID | Jira Link | Mô tả | Priority | Status cuối sprint |
|---|---|---|---|---|
| DA-59 | [DA-59](https://letritrung2605.atlassian.net/browse/DA-59) | Investigate and Analyze 3 AI Fashion Model Generation Platforms | 🟡 High | 🔄 In Review |
| DA-184 | [DA-184](https://letritrung2605.atlassian.net/browse/DA-184) | DA-E06-06 Document Redis key patterns (JWT blacklist, rate limit, OAuth state, trending cache) | 🟡 High | 🔄 In Review |
| DA-179 | [DA-179](https://letritrung2605.atlassian.net/browse/DA-179) | DA-E07-02 Định nghĩa endpoints cho ai-service | 🔴 Critical | 🔄 In Review |
| DA-155 | [DA-155](https://letritrung2605.atlassian.net/browse/DA-155) | DA-E07-06 Viết OpenAPI YAML spec cho ai-service | 🟡 High | 🔄 In Review |

**Tổng:** 4 tasks | Done: 0 | In Review: 4 | Chưa hoàn thành: 0

---

## 3. Chi tiết công việc đã làm

---

### [DA-59] — Investigate and Analyze 3 AI Fashion Model Generation Platforms

**Jira status:** In Review  
**Branch:** `docs/DA-59-analyze-ai-fashion-model-platforms`  
**Commit chính:** `3ba1704` — `docs(DA-59): write report analyze AI model fashion`  
**File tạo ra / thay đổi:**
- `docs/AI_Models/DA-59_AI_Fashion_Model_Generation_Platforms.md` — 239 dòng, báo cáo phân tích 3 hướng/model tạo AI fashion model

**Mô tả công việc đã làm:**

Nghiên cứu và so sánh 3 workflow/model phục vụ tạo fashion model bằng AI: `InstantID`, `InstantID + ControlNet`, và `Z-Image`. Báo cáo tập trung vào khả năng hiểu prompt, giữ nhất quán khuôn mặt, chất lượng pose/body, độ thực tế của trang phục, chất lượng background, tốc độ sinh ảnh và mức độ phù hợp với BrandHub. Ngoài 3 lựa chọn chính, có ghi chú lý do loại `ControlNet standalone` và `IP-Adapter` khỏi phần đánh giá chính do chưa có demo đủ để kiểm chứng thực tế.

**Kết quả đạt được:**
- [x] Xác định được 3 ứng viên chính cho use case AI fashion model generation
- [x] Có bảng tiêu chí đánh giá rõ ràng theo nhu cầu marketing của BrandHub
- [x] Ghi nhận ưu/nhược điểm và mức độ phù hợp production của từng hướng

**Khó khăn gặp phải:** Một số workflow AI image không có demo ổn định hoặc thiếu kết quả test trực tiếp, nên cần phân biệt rõ phần đã test và phần chỉ nên xem là hướng tham khảo.

**Thời gian thực tế:** ~4 giờ

---

### [DA-184] — Document Redis key patterns

**Jira status:** In Review  
**Branch:** `docs/DA-E06-06-redis-patterns`  
**Commit chính:** `ef42f29` — `docs(DA-184): document Redis key patterns`  
**File tạo ra / thay đổi:**
- `docs/database/DA-E06-06_Redis_Key_Patterns.md` — 154 dòng, tài liệu Redis key patterns bản tiếng Anh
- `docs/database/DA-E06-06_Redis_Key_Patterns_vn.md` — 154 dòng, tài liệu Redis key patterns bản tiếng Việt

**Mô tả công việc đã làm:**

Viết tài liệu chuẩn hóa Redis key contracts cho BrandHub, bao gồm JWT blacklist, rate limiting, OAuth state và trending cache. Mỗi nhóm key được mô tả theo template thống nhất: key template, ví dụ key, value type, nội dung value, TTL, service ghi, service đọc và Redis command gợi ý. Tài liệu cũng làm rõ Redis chỉ là cache/coordination layer, không được dùng làm primary storage cho user, workspace, billing hoặc audit data.

**Kết quả đạt được:**
- [x] Có source of truth cho Redis key naming và TTL
- [x] Tránh trùng namespace hoặc sai format value giữa các service
- [x] Unblock phần rate limiting và cache trending cho các task backend tiếp theo

**Khó khăn gặp phải:** Cần cân bằng giữa document đủ chi tiết để implement và không biến Redis thành nơi lưu dữ liệu chính. Các TTL phải được chọn theo đúng vòng đời nghiệp vụ, ví dụ JWT blacklist TTL bằng access token TTL.

**Thời gian thực tế:** ~3 giờ

---

### [DA-179] — Define endpoints cho ai-service

**Jira status:** In Review  
**Branch:** `docs/DA-E07-02-define-endpoint-ai`  
**Commit chính:** `7c3d8c5` — `docs(DA-179): dinh nghia endpoints ai-service`  
**File tạo ra / thay đổi:**
- `docs/api/endpoints/DA-E07-02_AI-service-endpoints.md` — 639 dòng, tài liệu endpoint contract cho `ai-service`

**Mô tả công việc đã làm:**

Định nghĩa endpoint contract cho `ai-service` với các nhóm chính: `/ai/content`, `/ai/image`, `/ai/video`, `/ai/ambassador`, `/ai/rag`, và `/ai/trends`. Mỗi endpoint có mục đích sử dụng, HTTP method, request path, request body mẫu, response body mẫu, status code phổ biến, validation/input constraints và lỗi thường gặp. Tài liệu cũng xác định rõ `ai-service` là internal service, client app không gọi trực tiếp mà đi qua `business-service`, đồng thời dùng `X-Internal-Key` và `X-Request-Id` cho xác thực nội bộ và trace log.

**Kết quả đạt được:**
- [x] Định nghĩa đầy đủ endpoint surface cho ai-service
- [x] Chuẩn hóa response theo `ApiResponse<T>` envelope
- [x] Làm rõ validation cho platform, language, tone, style, aspect ratio, prompt và quota
- [x] Tạo nền cho task DA-E07-06 viết OpenAPI spec

**Khó khăn gặp phải:** Phải giữ boundary giữa `business-service` và `ai-service` rõ ràng để tránh frontend gọi trực tiếp AI endpoint, đồng thời vẫn đủ thông tin cho team backend implement sau này.

**Thời gian thực tế:** ~6 giờ

---

### [DA-155] — Viết OpenAPI YAML spec cho ai-service

**Jira status:** In Review  
**Branch:** `docs/DA-E07-06-write-openapi-yaml-spec`  
**Commit chính:** `3142da9` — `docs(DA-155): cap nhat openapi spec ai-service`  
**File tạo ra / thay đổi:**
- `docs/api/DA-E07-06_OpenAPI_Spec.md` — 195 dòng, tài liệu yêu cầu và checklist OpenAPI cho `ai-service`

**Mô tả công việc đã làm:**

Viết tài liệu định nghĩa phạm vi OpenAPI 3.1 cho `ai-service`, bao gồm health check và các endpoint nội bộ cho content generation, image generation, video generation, ambassador generation, RAG upload/query/delete và trends. Tài liệu mô tả 10 operations qua 7 tags, danh sách reusable schemas, reusable responses, reusable parameters, security scheme bằng internal API key và checklist validation trước khi export OpenAPI runtime từ FastAPI.

**Kết quả đạt được:**
- [x] Xác định rõ coverage bắt buộc của OpenAPI cho ai-service
- [x] Liên kết spec với endpoint contract từ DA-E07-02
- [x] Chuẩn hóa schemas và error responses để thống nhất với API response format chung
- [x] Có checklist giúp validate spec trước khi team implement/export từ service thực tế

**Khó khăn gặp phải:** Task này phụ thuộc vào DA-E07-02, nên cần đảm bảo endpoint contract ổn định trước khi viết OpenAPI guideline. Ngoài ra, canonical OpenAPI runtime vẫn cần export từ `brandhub-ai-service` sau khi FastAPI routes được implement.

**Thời gian thực tế:** ~4 giờ

---

## 4. Tasks chưa hoàn thành

*Không có task nào chưa hoàn thành. Các task đã hoàn tất phần tài liệu và đang ở trạng thái In Review trên Jira.*

---

## 5. Đóng góp ngoài tasks chính

- Merge các nhánh tài liệu cá nhân vào nhánh report tổng hợp `docs/DA-441-tuan-sprint-3-report-after-merge`
- Rà soát lại liên kết giữa Redis key patterns, ai-service endpoint contract và OpenAPI spec để đảm bảo các tài liệu không mâu thuẫn nhau
- Cập nhật report cá nhân theo template chung của team để phục vụ review cuối sprint

---

## 6. Học được gì trong sprint này

1. **Thiết kế internal API contract:** Cần xác định rõ caller, auth header, request/response envelope và lỗi phổ biến trước khi service được implement.
2. **Redis key design:** TTL, namespace và ownership phải được viết thành contract để tránh mỗi service tự đặt key theo một kiểu khác nhau.
3. **AI workflow evaluation:** Khi đánh giá model tạo ảnh, cần tách rõ kết quả test thực tế với nhận định lý thuyết, đặc biệt với các workflow như InstantID, ControlNet và Z-Image.
4. **OpenAPI planning:** Với FastAPI, tài liệu infrastructure nên mô tả coverage và validation checklist; spec runtime cuối cùng nên export từ source code service sau khi route được implement.

---

## 7. Feedback & Đề xuất

### 7.1 Về quy trình làm việc

Việc tách nhánh theo từng task giúp nội dung dễ review, nhưng khi cần tổng hợp report cần kiểm tra kỹ nhánh nào đã push remote và nhánh nào chỉ tồn tại local. Trường hợp `docs/DA-E07-02-define-endpoint-ai` chỉ có ở local nên không thể `git pull origin` trực tiếp.

### 7.2 Về tài liệu

Các tài liệu API nên giữ cùng format: mục đích endpoint, method, path, request mẫu, response mẫu, status code, validation và lỗi thường gặp. Điều này giúp chuyển từ Markdown contract sang OpenAPI dễ hơn.

### 7.3 Đề xuất cho sprint tiếp theo

- Implement route thật trong `brandhub-ai-service` dựa trên DA-E07-02 và DA-E07-06
- Export OpenAPI runtime từ FastAPI để so sánh với tài liệu guideline
- Kết nối Redis rate limit/trending cache với api-gateway và ai-service theo key contract đã viết

---

## 8. Self-assessment

| Tiêu chí | Điểm (1-5) | Ghi chú |
|---|---|---|
| Hoàn thành đúng deadline | 4/5 | Các deliverable chính đã hoàn tất và đang In Review |
| Chất lượng deliverable | 4/5 | Tài liệu có cấu trúc rõ, đủ request/response, constraints và checklist |
| Giao tiếp với team | 4/5 | Chủ động tổng hợp nhánh và cập nhật report theo template |
| Chủ động xử lý blocker | 4/5 | Xử lý phụ thuộc giữa endpoint contract và OpenAPI spec; nhận diện nhánh local/remote khi merge |
| **Tổng** | **16/20** | |

---

*Nộp: 2026-06-30 | Sprint 3 ends: 2026-06-30*
