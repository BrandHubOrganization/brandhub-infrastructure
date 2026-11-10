# Sequence Flow — System Health Monitoring

> Supplements `spec.md` (FR 3.10.3). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **ADMIN** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `Admin Dashboard`.
- **System** — `MonitoringHealthController` / `HealthQueryService`.

---

## Flow A — Luồng thực thi chính: System Health Monitoring

1. healthqueryservice -> healthqueryservice: `Require current ADMIN; validate query`
2. admindashboard -> admindashboard: `Stop feeds; clear auth on 401`
3. admindashboard -> admindashboard: `Replace source snapshot`
4. admin -> admindashboard: `Access System Monitoring`
5. admindashboard -> monitoringhealthcont: `GET /api/monitoring/health-targets`
6. monitoringhealthcont -> healthqueryservice: `list(principal, MonitoringFilter)`
7. monitoringrepositori -> usersystemrole: `Read current system role`
8. healthqueryservice -> monitoringrepositori: `Read current system role`
9. usersystemrole --> monitoringrepositori: `role`
10. healthqueryservice --> monitoringhealthcont: `access denied`
11. monitoringhealthcont --> admindashboard: `Return 401 / 403`
12. healthqueryservice --> monitoringhealthcont: `INVALID_REQUEST`
13. monitoringhealthcont --> admindashboard: `400; display invalid parameters`
14. monitoringrepositori -> monitoringserver: `Query hosts and heartbeats`
15. healthqueryservice -> monitoringrepositori: `Load host pages and heartbeats`
16. monitoringserver --> monitoringrepositori: `sourceOutcome`
17. healthqueryservice --> monitoringhealthcont: `source failure`
18. monitoringhealthcont --> admindashboard: `Load error; retain prior authorized snapshot`
19. healthqueryservice -> healthqueryservice: `Map freshness; apply status filter`
20. healthqueryservice --> monitoringhealthcont: `rows, serverTime, totalPages`
21. monitoringhealthcont --> admindashboard: `Source page`
22. admindashboard --> admin: `Display source status, filters and details`
23. admindashboard -> admindashboard: `Poll again 5s after completion if authorized; HTTP timeout 5s`
24. admin -> systemhealthdashboar: `Open /admin/system-health (Servers tab)`
25. systemhealthdashboar -> monitoringservercont: `GET /api/monitoring/servers(page, size, filters)`
26. monitoringservercont -> adminaccountservice: `requireAdmin(actorId)`
27. adminaccountservice --> monitoringservercont: `200 OK (ADMIN verified)`
28. monitoringservercont -> servermonitoringserv: `listServers(principal, page, size, filters)`
29. servermonitoringserv -> servermetricsreposit: `findServerMetrics(filters, pageable)`
30. servermetricsreposit --> servermonitoringserv: `return serverMetricsPage`
31. servermonitoringserv -> servermonitoringserv: `calculateHealthStatus(serverMetricsPage)`
32. servermonitoringserv --> monitoringservercont: `return ServerMonitoringResponse`
33. monitoringservercont --> systemhealthdashboar: `200 OK (ServerMonitoringResponse)`
34. systemhealthdashboar --> admin: `Render server status feed & resource gauges`
35. admin -> systemhealthdashboar: `Open /admin/system-health (Services tab)`
36. systemhealthdashboar -> monitoringhealthcont: `GET /api/monitoring/health-targets(page, size, filters)`
37. monitoringhealthcont -> adminaccountservice: `requireAdmin(actorId)`
38. adminaccountservice --> monitoringhealthcont: `200 OK (ADMIN verified)`
39. monitoringhealthcont -> healthqueryservice: `listHealthTargets(principal, filters, pageable)`
40. healthqueryservice -> servicehealthreposit: `findHealthTargets(filters, pageable)`
41. servicehealthreposit --> healthqueryservice: `return targetHealthList`
42. healthqueryservice -> healthqueryservice: `evaluateDependencyUptime(targetHealthList)`
43. healthqueryservice --> monitoringhealthcont: `return HealthTargetsResponse`
44. monitoringhealthcont --> systemhealthdashboar: `200 OK (HealthTargetsResponse)`
45. systemhealthdashboar --> admin: `Render services status & dependency tree`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
