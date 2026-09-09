# Sprint 4 Report — Ân (Individual)

---

## 1. Thông tin Sprint

| Field | Value |
|---|---|
| Sprint | Sprint 4 |
| Goal | Hoàn thiện Google Veo Video Ecosystem và Admin API |
| Report date | 2026-07-12 |
| Reported by | Ân (AI Agent) |

---

## 2. Tổng kết hoàn thành

### 2.1 Tỉ lệ hoàn thành cá nhân
| Thành viên | Tasks được giao | Done/In Review | Chưa làm | Ghi chú |
|---|---|---|---|---|
| Ân (AI) | 5 | 5 | 0 | Hoàn thành xuất sắc toàn bộ khối Video AI |

---

## 3. Deliverables đã hoàn thành

| Deliverable | File | Tác giả | Chất lượng |
|---|---|---|---|
| Multi-segment Video Prompts | `video_templates.py` | Ân | ⭐⭐⭐⭐⭐ |
| Async Polling Endpoint | `video.py` | Ân | ⭐⭐⭐⭐⭐ |
| Admin API Regex/Ban | `admin.py` | Ân | ⭐⭐⭐⭐⭐ |
| FFmpeg & S3 Storage | `veo_client.py` | Ân | ⭐⭐⭐⭐ |
| clone-all Automation | `clone-all.sh` | Ân | ⭐⭐⭐⭐⭐ |

---

## 4. Deliverables chưa hoàn thành

*(Không có)*

---

## 5. Đánh giá chất lượng

### 5.1 Điểm mạnh của sprint này
- **Kiến trúc Asynchronous:** Áp dụng triệt để Async/Await từ API sang cơ sở dữ liệu giúp Server không bị treo khi load video nặng.
- **Tối ưu băng thông/chi phí:** Kết hợp FFmpeg để extract thumbnail ngay trên server.

### 5.2 Vấn đề gặp phải
- Việc ước tính giới hạn API của Google Veo còn khó do thiếu tài liệu chính thức đầy đủ, phải liên tục thử nghiệm thông qua system_prompts_leaks.

### 5.3 Technical debt để lại
- Thiết kế Background Tasks hiện tại để render video có thể nghẽn nếu xử lý > 100 req/s.

---

## 6. Blocked tasks & Dependencies

*(Không có)*

---

## 7. Individual highlights

- Vận dụng thành công các bài học từ `system_prompts_leaks` để refactor bộ 30 video templates thành cấu trúc Multi-segment hoàn chỉnh. Xử lý triệt để bài toán Video Chaining cho Veo.

---

## 8. Sprint Retrospective

### 8.1 What went well?
- Tối ưu được thời gian render bằng cách polling bằng Redis thay vì giữ connect HTTP.

### 8.2 What didn't go well?
- Mất thời gian cấu trúc FFmpeg command lines để tương thích trên nhiều OS khác nhau.

### 8.3 Action items cho Sprint 5
| Action | Owner | Deadline |
|---|---|---|
| Thử nghiệm Message Queue (RabbitMQ) | Ân | Sprint 5 Week 1 |
