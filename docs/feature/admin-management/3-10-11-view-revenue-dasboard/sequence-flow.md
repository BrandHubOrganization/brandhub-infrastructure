# Sequence Flow — View Revenue Dasboard

> Supplements `spec.md` (FR 3.10.11). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **Admin** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `AdminRevenuePanel (UI)`.
- **System** — `AdminRevenueController` / `AdminRevenueService`.

---

## Flow A — Luồng thực thi chính: View Revenue Dasboard

1. admin -> adminrevenuepanelui: `Select reporting period and filters`
2. adminrevenuepanelui -> adminrevenuecontroll: `GET /api/v1/admin/revenue(period, timezone)`
3. adminrevenuecontroll -> adminaccountservice: `requireAdmin(actorId)`
4. adminaccountservice --> adminrevenuecontroll: `200 OK (ADMIN verified)`
5. adminrevenuecontroll -> adminrevenueservice: `getRevenueMetrics(period, timezone)`
6. adminrevenueservice -> revenuetransactionre: `findRevenueTransactions(period)`
7. revenuetransactionre --> adminrevenueservice: `return transactionsList`
8. adminrevenueservice -> adminrevenueservice: `calculateRevenueKPIs(transactionsList)`
9. adminrevenueservice --> adminrevenuecontroll: `return RevenueMetricsResponse`
10. adminrevenuecontroll --> adminrevenuepanelui: `200 OK (RevenueMetricsResponse)`
11. adminrevenuepanelui --> admin: `Display revenue KPIs, charts and ledger`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
