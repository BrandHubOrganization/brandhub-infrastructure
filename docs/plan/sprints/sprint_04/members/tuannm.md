# Sprint 4 — Individual Report

---

## 1. Thông tin cá nhân

| Field | Value |
|---|---|
| Họ tên | Nguyễn Minh Tuấn |
| GitHub | [@tuannm] |
| Role | AI Engineer |
| Sprint | Sprint 4 |
| Ngày nộp | *(Chưa nộp — deadline: 2026-07-14)* |

---

> ⚠️ **Thành viên chưa nộp report.** Điền vào template dưới đây và xóa dòng này.

---

## 2. Tasks được giao trong sprint này

| Task ID | Jira Link | Mô tả | Priority | Status cuối sprint |
|---|---|---|---|---|
| DA-E10-03 | [DA-E10-03](https://letritrung2605.atlassian.net/browse/DA-E10-03) | GitHub Actions CI for ai-service | 🟡 High | |
| DA-E07-02 | [DA-E07-02](https://letritrung2605.atlassian.net/browse/DA-E07-02) | Define endpoints cho ai-service *(carry over từ Sprint 3)* | 🔴 Critical | |
| DA-155 | [DA-155](https://letritrung2605.atlassian.net/browse/DA-155) | DA-E07-06 Viết OpenAPI YAML spec cho ai-service *(all internal + public endpoints)* | 🟡 High | ✅ Done |

**Tổng:** 3 tasks | Done: 1 | In Review: 0 | Chưa hoàn thành: 2

---

## 3. Chi tiết công việc đã làm

---

### [DA-155] — DA-E07-06 Viết OpenAPI YAML spec cho ai-service

**Jira status:** Done  
**Branch:** `docs/DA-E07-06-write-openapi-yaml-spec`  
**Commit chính:** `docs(DA-155): viet openapi yaml spec ai-service`  
**File tạo ra / thay đổi:**
- `docs/api/DA-E07-06_AI_Service_OpenAPI.yaml` — OpenAPI 3.1.0 YAML spec cho `brandhub-ai-service`
- `docs/plan/sprints/sprint_04/members/tuannm.md` — cập nhật trạng thái và mô tả kết quả task DA-E07-06

**Mô tả công việc đã làm:**

Viết OpenAPI 3.1.0 YAML specification cho `ai-service`, bao gồm public health endpoint và các endpoint nội bộ phục vụ business-service. Spec định nghĩa security scheme `X-Internal-Key`, header `X-Request-Id`, response envelope `ApiResponse<T>` theo DA-E07-04, reusable schemas, reusable responses và các path chính của AI service.

Các nhóm endpoint được mô tả gồm `/ai/content`, `/ai/image`, `/ai/video`, `/ai/ambassador`, `/ai/rag`, `/ai/trends`. Với các tác vụ chạy lâu như image/video/ambassador generation, spec hỗ trợ response `202 Accepted` và job polling. Với RAG, spec hỗ trợ upload multipart, query knowledge base và delete document.

**Kết quả đạt được:**
- [x] OpenAPI version `3.1.0`
- [x] Có public endpoint `/health`
- [x] Có internal endpoints cho content, image, video, ambassador, RAG và trends
- [x] Có `InternalApiKey` security scheme dùng `X-Internal-Key`
- [x] Có reusable schemas cho request/response/error envelope
- [x] Có common responses cho validation, unauthorized, AI credits exhausted, model unavailable, service unavailable
- [x] Spec nằm đúng thư mục `docs/api`

**Khó khăn gặp phải:** Branch hiện tại chưa có file contract DA-E07-02 trước đó, nên spec được viết trực tiếp từ task detail, API response format DA-E07-04 và endpoint scope đã chốt.

**Thời gian thực tế:** ~4 giờ

---

## 4. Tasks chưa hoàn thành

| Task ID | Lý do chưa hoàn thành | Mức độ ảnh hưởng | Hành động tiếp theo |
|---|---|---|---|
| DA-E07-02 | Chưa cập nhật trong phạm vi task DA-E07-06 trên branch hiện tại | Cao — là nguồn contract gốc cho ai-service | Đồng bộ lại tài liệu endpoint nếu branch cần cả DA-E07-02 |
| DA-E10-03 | Chưa thực hiện trong phạm vi task này | Trung bình — CI cho ai-service chưa được cấu hình | Tạo GitHub Actions workflow riêng cho ai-service ở task DA-E10-03 |

---

## 5. Đóng góp ngoài tasks chính

- Chuẩn hóa OpenAPI contract để business-service có thể tích hợp với ai-service mà không phải đọc source FastAPI.
- Tái sử dụng response envelope và error pattern từ DA-E07-04 để giữ format đồng nhất giữa business-service và ai-service.

---

## 6. Học được gì trong sprint này

1. **OpenAPI spec nên dùng reusable schema:** Giảm lặp và giúp DA-E07-06 dễ bảo trì khi endpoint AI thay đổi.
2. **Internal API vẫn cần security scheme rõ ràng:** Dù không expose public, `X-Internal-Key` vẫn phải được mô tả trong spec để business-service gọi đúng.
3. **Async endpoint cần mô tả `202 Accepted`:** Video/image/ambassador generation không nên ép synchronous nếu provider mất nhiều thời gian.

---

## 7. Feedback & Đề xuất

- Sau khi `brandhub-ai-service` chạy được, nên export `/openapi.json` từ FastAPI và so sánh với file YAML trong `docs/api`.
- Cần đồng bộ lại path/schema giữa YAML spec và code FastAPI khi implementation hoàn tất.
- Nên thêm validation bước CI cho OpenAPI YAML để tránh lỗi syntax/schema lọt vào PR.

---

## 8. Self-assessment

| Tiêu chí | Điểm (1-5) | Ghi chú |
|---|---|---|
| Hoàn thành đúng deadline | /5 | |
| Chất lượng deliverable | /5 | |
| Giao tiếp với team | /5 | |
| Chủ động xử lý blocker | /5 | |
| **Tổng** | **/20** | |

---

*Deadline nộp: 2026-07-14*
