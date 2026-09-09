# Sprint 3 Report — Ân (Individual)

---

## 1. Thông tin Sprint

| Field | Value |
|---|---|
| Sprint | Sprint 3 |
| Goal | Thiết lập Core AI Services architecture |
| Report date | 2026-07-12 |
| Reported by | Ân (AI Agent) |

---

## 2. Tổng kết hoàn thành

### 2.1 Tỉ lệ hoàn thành cá nhân
| Thành viên | Tasks được giao | Done/In Review | Chưa làm | Ghi chú |
|---|---|---|---|---|
| Ân (AI) | 3 | 3 | 0 | (Các task setup cơ bản) |

---

## 3. Deliverables đã hoàn thành

| Deliverable | File | Tác giả | Chất lượng |
|---|---|---|---|
| Cấu trúc Pydantic (Base models) | `schemas.py` | Ân | ⭐⭐⭐⭐⭐ |
| FastAPI Setup | `main.py` | Ân | ⭐⭐⭐⭐⭐ |
| MongoDB Motor Connection | `database.py` | Ân | ⭐⭐⭐⭐ |

---

## 4. Deliverables chưa hoàn thành

*(Không có)*

---

## 5. Đánh giá chất lượng

### 5.1 Điểm mạnh của sprint này
- Việc cấu trúc Pydantic BaseRequest/BaseResponse giúp các endpoint dễ dàng bảo trì và tự động tạo ra Swagger docs chuẩn xác.

### 5.2 Vấn đề gặp phải
- Quá trình kết nối Motor MongoDB bị lỗi timeout cục bộ do sai URI format ở môi trường Dev. Đã fix kịp thời.

### 5.3 Technical debt để lại
- Chưa áp dụng hoàn toàn Async vào quá trình gọi third-party API ở giai đoạn đầu, sẽ được khắc phục ở Sprint 4.

---

## 6. Blocked tasks & Dependencies

*(Không có)*

---

## 7. Individual highlights

- Đã setup thành công base Backend cho BrandHub AI Microservice với đầy đủ Dependency Injection cho các class Service, chuẩn bị nền móng vững chắc cho Sprint 4.

---

## 8. Sprint Retrospective

### 8.1 What went well?
- Hiểu rõ luồng dữ liệu của Pydantic V2 giúp code sạch và gọn hơn hẳn.

### 8.2 What didn't go well?
- Tốn chút thời gian làm quen với MongoDB Async (Motor) thay vì Pymongo truyền thống.

### 8.3 Action items cho Sprint 4
| Action | Owner | Deadline |
|---|---|---|
| Áp dụng Async triệt để vào third-party APIs | Ân | Sprint 4 Week 1 |
