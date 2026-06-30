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
**Commit chính:** `docs(DA-155): cap nhat openapi spec ai-service`  
**File tạo ra / thay đổi:**
- `docs/api/DA-E07-06_OpenAPI_Spec.md` — tài liệu OpenAPI spec reference cho `brandhub-ai-service`, cùng format với DA-E07-05
- `docs/plan/sprints/sprint_04/members/tuannm.md` — cập nhật trạng thái và mô tả kết quả task DA-E07-06

**Mô tả công việc đã làm:**

Viết tài liệu OpenAPI spec reference cho `ai-service` theo format của `docs/api/DA-E07-05_OpenAPI_Spec.md`. Tài liệu mô tả deliverables, phạm vi endpoint, schema components, API design decisions, FastAPI integration, error codes, validation checklist và file reference cho artifact OpenAPI của `brandhub-ai-service`.

Các nhóm endpoint được mô tả gồm `/ai/content`, `/ai/image`, `/ai/video`, `/ai/ambassador`, `/ai/rag`, `/ai/trends`. Tài liệu cũng ghi rõ public endpoint `/health`, internal security bằng `X-Internal-Key`, response envelope theo DA-E07-04, async job pattern cho tác vụ chạy lâu và cách export `/openapi.json` từ FastAPI sau khi service chạy.

**Kết quả đạt được:**
- [x] Có deliverables table giống DA-E07-05
- [x] Có spec coverage cho Health, AI Content, AI Image, AI Video, AI Ambassador, AI RAG, AI Trends
- [x] Có schema components và reusable responses cần có cho OpenAPI YAML
- [x] Có API design decisions: `ApiResponse<T>`, `X-Internal-Key`, public/internal split, async job, no 204
- [x] Có FastAPI integration notes cho `/docs`, `/redoc`, `/openapi.json`
- [x] Có validation checklist và file reference
- [x] Tài liệu nằm đúng thư mục `docs/api`

**Khó khăn gặp phải:** Cần sửa lại hướng làm ban đầu vì DA-E07-05 trong repo là tài liệu OpenAPI reference, không phải raw YAML file. Vì vậy DA-E07-06 được làm lại theo cùng format để nhất quán tài liệu API của team.

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

- Sau khi `brandhub-ai-service` chạy được, nên export `/openapi.json` từ FastAPI và commit vào `brandhub-ai-service/docs/openapi.json`.
- Cần đồng bộ lại path/schema giữa OpenAPI reference và code FastAPI khi implementation hoàn tất.
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
