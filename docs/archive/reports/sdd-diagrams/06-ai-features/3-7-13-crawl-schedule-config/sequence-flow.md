# Sequence Flow — Crawl Schedule Config

> Supplements `spec.md` (FR 3.7.9). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **User** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `AdminCrawlConfigPanel (UI)`.
- **System** — `AdminCrawlConfigController` / `AdminCrawlConfigService`.

---

## Flow A — Luồng thực thi chính: Crawl Schedule Config

1. admincrawlconfigpane -> admincrawlconfigcont: `GET/PATCH /admin/ai/crawl-config Or GET/POST /admin/ai/crawl-runs`
2. systemadministrator -> admincrawlconfigpane: `View settings/history, save, or crawl now`
3. admincrawlconfigcont -> admincrawlconfigserv: `get(actor) / runs(actor) / update(actor, request) / runNow(actor)`
4. admincrawlconfigserv -> adminaccountservice: `requireAdmin(actor)`
5. adminaccountservice -> usersystemrolereposi: `findByUserId(actor)`
6. usersystemrolereposi --> adminaccountservice: `Optional<UserSystemRole>`
7. adminaccountservice --> admincrawlconfigserv: `ADMIN verified (void) / FORBIDDEN`
8. admincrawlconfigserv --> admincrawlconfigcont: `FORBIDDEN`
9. admincrawlconfigcont --> admincrawlconfigpane: `403 — access denied`
10. admincrawlconfigpane --> systemadministrator: `Show access error`
11. admincrawlconfigserv -> aiservicetrendsapi: `GET /api/v1/ai/trends/crawl-config Or /api/v1/ai/trends/crawl-runs`
12. aiservicetrendsapi --> admincrawlconfigserv: `Current config/run data or AI error`
13. admincrawlconfigserv -> admincrawlconfigserv: `Validate schedule, source URLs and limits`
14. admincrawlconfigserv -> aiservicetrendsapi: `POST /api/v1/ai/trends/crawl-config Or /api/v1/ai/trends/crawl-runs`
15. aiservicetrendsapi --> admincrawlconfigserv: `Saved config / accepted run / AI error`
16. admincrawlconfigserv --> admincrawlconfigcont: `BusinessException / AiServiceException`
17. admincrawlconfigcont --> admincrawlconfigpane: `400 / 409 / 502 / 503 — request failed`
18. admincrawlconfigpane --> systemadministrator: `Show error; keep the input`
19. admincrawlconfigserv -> admincrawlconfigserv: `Record the admin audit`
20. admincrawlconfigserv --> admincrawlconfigcont: `ObjectNode — selected operation result`
21. admincrawlconfigcont --> admincrawlconfigpane: `200 OK / 202 Accepted`
22. admincrawlconfigpane --> systemadministrator: `Show settings, history or new run`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
