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
| DA-179 | [DA-179](https://letritrung2605.atlassian.net/browse/DA-179) | DA-E07-02 Define endpoints cho ai-service *(carry over từ Sprint 3)* | 🔴 Critical | ✅ Done |

**Tổng:** 2 tasks | Done: 1 | In Review: 0 | Chưa hoàn thành: 1

---

## 3. Chi tiết công việc đã làm

---

### [DA-179] — DA-E07-02 Define endpoints cho ai-service

**Jira status:** Done  
**Branch:** `docs/DA-59-analyze-ai-fashion-model-platforms`  
**Commit chính:** `docs(DA-179): dinh nghia endpoints ai-service`  
**File tạo ra / thay đổi:**
- `docs/api/endpoints/DA-E07-02_AI-service-endpoints.md` — tài liệu contract chi tiết cho toàn bộ endpoint group của `ai-service`
- `docs/plan/sprints/sprint_04/members/tuannm.md` — cập nhật trạng thái và mô tả kết quả task DA-E07-02

**Mô tả công việc đã làm:**

Viết tài liệu endpoint contract cho `brandhub-ai-service`, bao phủ đầy đủ 6 nhóm endpoint được yêu cầu: `/ai/content`, `/ai/image`, `/ai/video`, `/ai/ambassador`, `/ai/rag`, `/ai/trends`. Tài liệu xác định base URL nội bộ `http://ai-service:8082`, API prefix `/api/v1`, cơ chế gọi nội bộ bằng `X-Internal-Key`, response envelope theo DA-E07-04 `ApiResponse<T>`, mã lỗi phổ biến và constraints đầu vào.

Trong từng nhóm endpoint, bổ sung method, request path, request body mẫu, response body mẫu, validation rules và lỗi thường gặp. Với các tác vụ chạy lâu như image/video/ambassador generation, tài liệu nêu rõ hướng async job/polling để DA-E07-06 có thể chuyển tiếp thành OpenAPI YAML mà không phải đoán contract.

**Kết quả đạt được:**
- [x] `/ai/content` được mô tả với generate và regenerate flow
- [x] `/ai/image` được mô tả với request tạo ảnh và response asset URL
- [x] `/ai/video` được mô tả với async generate job và endpoint polling status
- [x] `/ai/ambassador` được mô tả cho face-consistent generation
- [x] `/ai/rag` được mô tả cho upload, query và delete knowledge document
- [x] `/ai/trends` được mô tả với query params và response trend suggestions
- [x] Có validation/input constraints và common error notes cho từng nhóm endpoint
- [x] Unblock cho DA-E07-06 OpenAPI YAML spec cho ai-service

**Khó khăn gặp phải:** Cần thống nhất giữa endpoint prefix trong plan (`/ai/*`) và FastAPI README hiện tại (`/api/v1/ai/*`). Chọn ghi rõ `API prefix: /api/v1` và path đầy đủ `/api/v1/ai/...` để khớp cấu trúc service hiện có.

**Thời gian thực tế:** ~3 giờ

---

## 4. Tasks chưa hoàn thành

| Task ID | Lý do chưa hoàn thành | Mức độ ảnh hưởng | Hành động tiếp theo |
|---|---|---|---|
| DA-E10-03 | Chưa thực hiện trong phạm vi task này | Trung bình — CI cho ai-service chưa được cấu hình | Tạo GitHub Actions workflow riêng cho ai-service ở task DA-E10-03 |

---

## 5. Đóng góp ngoài tasks chính

- Chuẩn hóa contract endpoint để business-service, ai-service và OpenAPI spec dùng cùng một nguồn tham chiếu.
- Ghi rõ các constraints và common errors để giảm rủi ro hiểu sai khi implement FastAPI hoặc viết OpenAPI YAML.

---

## 6. Học được gì trong sprint này

1. **API contract cần đủ chi tiết trước OpenAPI:** Nếu chỉ liệt kê path thì DA-E07-06 vẫn bị block vì thiếu schema, status code và error cases.
2. **AI endpoint nên phân biệt sync/async rõ ràng:** Content/RAG query có thể sync, còn video/image/ambassador cần thiết kế theo job để tránh timeout.
3. **Internal auth phải nhất quán:** `X-Internal-Key` cần được document rõ vì `ai-service` không dành cho client gọi trực tiếp.

---

## 7. Feedback & Đề xuất

- Nên dùng `docs/api/endpoints/DA-E07-02_AI-service-endpoints.md` làm nguồn chính khi viết DA-E07-06 OpenAPI YAML.
- Cần rà soát lại implementation trong `brandhub-ai-service` để đảm bảo path thực tế, model Pydantic và error code khớp tài liệu.
- Nên bổ sung contract tests sau khi FastAPI endpoint được implement để tránh lệch giữa docs và code.

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
