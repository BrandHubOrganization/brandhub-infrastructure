# Sprint 4 — Individual Report

---

## 1. Thông tin cá nhân

| Field | Value |
|---|---|
| Họ tên | Hà Thị Ân |
| GitHub | [@anha] |
| Role | AI Engineer |
| Sprint | Sprint 4 |
| Ngày nộp | 2026-08-02 |

---

## 2. Tasks được giao trong sprint này

| Task ID | Jira Link | Mô tả | Priority | Status cuối sprint |
|---|---|---|---|---|
| DA-E06-06 | [DA-184](https://letritrung2605.atlassian.net/browse/DA-184) | Document Redis key patterns (JWT blacklist, rate limit, OAuth state, trending cache) | 🟡 High | ✅ Done |

> **Carry over từ Sprint 3** — DA-184 được chuyển tiếp sang Sprint 4.

**Tổng:** 1 task | Done: 1 | In Review: 0 | Chưa hoàn thành: 0

---

## 3. Chi tiết công việc đã làm

### DA-E06-06 — Document Redis Key Patterns

**Jira status:** Done
**Branch:** `docs/DA-184-redis-key-patterns`
**File tạo ra:**
- `docs/database/DA-E06-06_Redis_Key_Patterns.md`

**Mô tả công việc đã làm:**
- Thiết kế và tài liệu hóa toàn bộ Redis key contracts cho BrandHub, đảm bảo các service không tạo key trùng lặp, sai format, hoặc sai TTL.
- Định nghĩa naming convention: lowercase namespace prefix ngăn cách bởi `:`, highest-cardinality identifier ở cuối key, mọi key phải có TTL.
- Document 4 key families:
  1. **JWT blacklist** (`jwt:blacklist:{jti}`) — String `"1"`, TTL 15 phút (bằng access token TTL). Writer: business-service, Reader: api-gateway + business-service.
  2. **Rate limiting** (`ratelimit:{userId}:{minute}`) — Integer string từ `INCR`, TTL 60 giây. Writer/Reader: api-gateway. Chốt pattern `INCR` + conditional `EXPIRE` (không Lua).
  3. **OAuth state** (`oauth:state:{state}`) — JSON chứa provider, redirectUri, và optional PKCE context. TTL 10 phút, xóa sau callback để one-time use.
  4. **Trending cache** (`trends:vn:{date}:{category}`) — JSON list trend items, TTL 6 giờ. Writer/Reader: ai-service. Cache miss → live crawl → repopulate Redis.
- Lập ownership matrix phân rõ service nào write/read key nào, tránh publisher-service vô tình đọc/ghi sai namespace.
- Tất cả acceptance checklist items được checked.

**Kết quả đạt được:**
- [x] 4 key families documented với template, example, value type, TTL, reader/writer đầy đủ
- [x] JWT blacklist TTL = access token TTL (15 phút)
- [x] Rate limiting pattern chốt: `INCR` + `EXPIRE` on first increment
- [x] Ownership matrix rõ ràng: gateway (rate limit, JWT blacklist read), business-service (JWT blacklist write, OAuth state), ai-service (trending cache), publisher-service (none)
- [x] Tài liệu unblock DA-E11-03 (rate limiting filter implementation)

---

## 4. Tasks chưa hoàn thành

*Không có task nào chưa hoàn thành.*

---

## 5. Đóng góp ngoài tasks chính

- Phối hợp với Tuấn để align Redis key patterns giữa DA-E06-06 và DA-E11-03 (rate limiting filter), đảm bảo key contract nhất quán trước khi implement.

---

## 6. Học được gì trong sprint này

1. **Redis là cache layer, không phải primary DB:** Mọi key phải có TTL, không dùng Redis để lưu dữ liệu nghiệp vụ (user, workspace, post, billing).
2. **Key naming convention quan trọng cho multi-service:** Nếu không có contract tập trung, mỗi service tự chọn pattern → xung đột namespace, sai TTL, khó debug.
3. **Atomic operation cho rate limiting:** `INCR` + `EXPIRE` tách rời có race condition (key không TTL nếu crash giữa 2 lệnh). Dùng conditional `EXPIRE` khi count==1 để an toàn hơn.

---

## 7. Feedback & Đề xuất

- DA-E06-06 ban đầu được assign ở Sprint 3 nhưng bị delay. Nên estimate kỹ hơn cho các task document design — thường mất 3-5 ngày để research + align với team + viết.
- Các service team nên reference document này trước khi thêm Redis key mới, tránh drift khỏi contract.

---

## 8. Self-assessment

| Tiêu chí | Điểm (1-5) | Ghi chú |
|---|---|---|
| Hoàn thành đúng deadline | 3/5 | Carry over từ Sprint 3, hoàn thành trong Sprint 4 |
| Chất lượng deliverable | 5/5 | Document đầy đủ 4 key families, naming rules, ownership matrix, acceptance checklist |
| Giao tiếp với team | 4/5 | Align với Tuấn về rate limiting key contract |
| Chủ động xử lý blocker | 3/5 | Delay từ Sprint 3 do cần research thêm |
| **Tổng** | **15/20** | |

---

*Deadline nộp: 2026-07-14 | Nộp muộn: 2026-08-02*
