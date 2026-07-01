# Sprint 4 — Individual Report

---

## 1. Thông tin cá nhân

| Field | Value |
|---|---|
| Họ tên | Nguyễn Minh Tuấn |
| GitHub | [@tuannm] |
| Role | AI Engineer |
| Sprint | Sprint 4 |
| Ngày nộp | 2026-06-29 |

---

## 2. Tasks được giao trong sprint này

| Task ID | Jira Link | Mô tả | Priority | Status cuối sprint |
|---|---|---|---|---|
| DA-184 | [DA-184](https://letritrung2605.atlassian.net/browse/DA-184) | DA-E06-06 Document Redis key patterns (JWT blacklist, rate limit, OAuth state, trending cache) | 🟡 High | 🔄 In Review |
| DA-448 | [DA-448](https://letritrung2605.atlassian.net/browse/DA-448) | DA-E47-24 Write individual sprint report for Sprint 4 — Tuấn | 🟣 Medium | 🔄 In Review |

**Tổng:** 2 tasks | Done: 2 | In Review: 0 | Chưa hoàn thành: 0

---

## 3. Chi tiết công việc đã làm

---

### [DA-184] — Document Redis key patterns

**Jira status:** Done  
**Branch:** `docs/DA-E06-06-redis-patterns`  
**Commit chính:** `ef42f29` — `docs(DA-184): document Redis key patterns`  
**File tạo ra / thay đổi:**
- `docs/database/DA-E06-06_Redis_Key_Patterns.md` — tài liệu contract chính cho Redis key patterns
- `docs/database/DA-E06-06_Redis_Key_Patterns_vn.md` — bản tiếng Việt UTF-8 để team review nội bộ
- `docs/database/Database_Strategy.md` — thêm link sang Redis key contract, cập nhật TTL và rate-limit note
- `docs/database/DA-E06-04_Indexing_Strategy.md` — cập nhật Redis TTL summary
- `docs/plan/BrandHub_Task_Details.md` — đồng bộ DA-E11-03 và logout blacklist theo contract mới
- `docs/api/endpoints/01_auth.md` — cập nhật logout blacklist TTL
- `docs/plan/sprints/sprint_03/PLAN.md` — sửa ghi chú JWT blacklist TTL
- `docs/plan/sprints/sprint_05/PLAN.md` — sửa ghi chú JWT blacklist TTL
- `frontend/docs-tree.json` — regenerate để file English xuất hiện trong docs portal

**Mô tả công việc đã làm:**

Viết document chuẩn hóa toàn bộ Redis key patterns được dùng giữa các service. Tài liệu định nghĩa rõ key template, example key, value type, value content, TTL, service ghi và service đọc cho 4 nhóm key bắt buộc: JWT blacklist, rate limiting, OAuth state, và trending/analytics cache.

Chốt các contract quan trọng:
- `jwt:blacklist:{jti}` lưu value `"1"`, TTL **15 minutes**, bằng access token TTL.
- `ratelimit:{userId}:{minute}` lưu request count từ Redis `INCR`, TTL 60 seconds.
- Rate limiting dùng `INCR` + `EXPIRE`, chỉ set `EXPIRE` khi `INCR` trả về `1`; không dùng Lua script trong scope task này.
- `oauth:state:{state}` lưu JSON có `provider`, `redirectUri`, và optional context như `workspaceId`, `userId`, `codeVerifier`, TTL 10 minutes.
- `trends:vn:{date}:{category}` lưu JSON serialized list, TTL 6 hours, owner là ai-service.

Ngoài file chính, rà soát các tài liệu liên quan và sửa các điểm đang mâu thuẫn với acceptance criteria. Cụ thể, một số docs cũ ghi JWT blacklist TTL là "remaining token lifetime" hoặc hướng DA-E11-03 dùng Lua script; các điểm này đã được sửa về contract mới để tránh team implement sai.

**Kết quả đạt được:**
- [x] Đủ 4 Redis key pattern families theo acceptance criteria
- [x] Mỗi pattern có key template, example key, value type, value content, TTL, writer và reader
- [x] JWT blacklist TTL ghi rõ bằng access token TTL: 15 minutes
- [x] Rate limiting ghi rõ dùng `INCR` + `EXPIRE` khi first increment, không dùng Lua
- [x] Có bản tiếng Việt UTF-8 để review nội bộ
- [x] Docs portal tree được regenerate cho bản English

**Khó khăn gặp phải:** Tài liệu hiện có chưa đồng nhất. `BrandHub_Task_Details.md` từng ghi DA-E11-03 có thể dùng Lua script, trong khi task DA-E06-06 yêu cầu dùng `INCR` + `EXPIRE` cho đơn giản. Ngoài ra một số nơi ghi TTL JWT blacklist là remaining token lifetime, nhưng acceptance criteria yêu cầu TTL bằng access token TTL 15 minutes. Cần rà nhiều file để tránh để lại thông tin mâu thuẫn.

**Thời gian thực tế:** ~3 giờ

---

### [DA-448] — Write individual sprint report for Sprint 4

**Jira status:** Done  
**Branch:** `docs/DA-E06-06-redis-patterns`  
**Commit chính:** *(chưa commit tại thời điểm viết report)*  
**File tạo ra / thay đổi:**
- `docs/plan/sprints/sprint_04/members/tuannm.md` — báo cáo cá nhân Sprint 4

**Mô tả công việc đã làm:**

Cập nhật báo cáo cá nhân Sprint 4 theo format tham khảo từ report Sprint 3 của leader. Báo cáo tập trung vào những thay đổi thực tế đã làm trong nhánh hiện tại, gồm task Redis key patterns và phần report cá nhân. Không ghi nhận các task khác trong ảnh Sprint 4 nếu nhánh này không có commit hoặc file thay đổi tương ứng.

**Kết quả đạt được:**
- [x] Report có thông tin cá nhân, task table, chi tiết công việc, kết quả, khó khăn, thời gian thực tế
- [x] Nội dung bám sát branch `docs/DA-E06-06-redis-patterns`
- [x] Ghi rõ các file chính đã tạo/cập nhật
- [x] Không khai báo hoàn thành các task ngoài scope nhánh

**Khó khăn gặp phải:** Sprint 4 plan cũ có task DA-E10-03 và DA-E07-02 gán cho Tuấn, nhưng nhánh hiện tại chỉ có thay đổi cho DA-184 và report. Vì vậy báo cáo cần phân biệt rõ "task trong sprint" và "work thực tế trong nhánh này" để không gây sai lệch tiến độ.

**Thời gian thực tế:** ~45 phút

---

## 4. Tasks chưa hoàn thành

*Không có task chưa hoàn thành trong phạm vi nhánh này.*

Ghi chú: DA-E10-03 và DA-E07-02 xuất hiện trong Sprint 4 plan cũ của Tuấn, nhưng nhánh hiện tại không có thay đổi liên quan đến ai-service CI hoặc ai-service endpoint documentation. Hai task đó không được đưa vào phần completed work của report này.

---

## 5. Đóng góp ngoài tasks chính

- Rà và sửa mâu thuẫn giữa Redis key contract mới với các tài liệu cũ.
- Bổ sung bản tiếng Việt UTF-8 cho Redis key patterns để team dễ review.
- Giữ bản `_vn` không map vào docs tree theo yêu cầu, tránh sidebar dài không cần thiết.

---

## 6. Học được gì trong sprint này

1. **Redis key contract là cross-service contract:** Key name, TTL, value format, writer và reader cần được ghi ở một nơi thống nhất để gateway, business-service và ai-service không tự hiểu khác nhau.
2. **TTL là một phần của behavior:** JWT blacklist TTL nếu lệch access token TTL sẽ làm blacklist entry sống quá lâu hoặc hết hạn quá sớm, ảnh hưởng trực tiếp tới auth behavior.
3. **Docs cũ có thể conflict với acceptance criteria mới:** Khi làm tài liệu kỹ thuật, cần rà các file đang tham chiếu cùng concept, không chỉ tạo file mới.

---

## 7. Feedback & Đề xuất

### 7.1 Về quy trình làm việc

Nên xem `docs/database/DA-E06-06_Redis_Key_Patterns.md` là source of truth cho Redis key. Các task phụ thuộc như DA-E11-03 nên link trực tiếp tới file này thay vì copy lại rule vào nhiều nơi.

### 7.2 Về tài liệu

Khi có bản tiếng Việt phục vụ review nội bộ, nên thống nhất naming suffix `_vn.md` và quyết định rõ file đó có map vào docs portal hay không. Với file này, bản `_vn` không map để tránh sidebar dư.

### 7.3 Đề xuất cho Sprint tiếp theo

- DA-E11-03 nên implement đúng contract `INCR` + conditional `EXPIRE`, không dùng Lua script.
- Nếu phát sinh Redis key mới như password reset, workspace invite hoặc manual refresh rate limit, nên cập nhật Redis key contract thay vì chỉ ghi trong task detail.

---

## 8. Self-assessment

| Tiêu chí | Điểm (1-5) | Ghi chú |
|---|---|---|
| Hoàn thành đúng deadline | 5/5 | Hoàn thành Redis key docs và report trong nhánh |
| Chất lượng deliverable | 5/5 | Đủ key patterns, TTL, value format, readers/writers |
| Giao tiếp với team | 4/5 | Làm rõ mâu thuẫn docs cũ và contract mới |
| Chủ động xử lý blocker | 5/5 | Sửa các tài liệu phụ thuộc để tránh implement sai |
| **Tổng** | **19/20** | |

---

*Nộp: 2026-06-29 | Sprint 4 ends: 2026-07-14*
