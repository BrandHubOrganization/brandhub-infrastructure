# Tasks / trạng thái triển khai

- [x] Gateway/Business correlation, header/CORS, MDC, bounded metrics và log billing.
- [x] Migration, issue store, fingerprint và lease/fencing PostgreSQL.
- [x] Đối soát local wallet/grant/ledger/payment, bỏ qua credit kỳ FUTURE chưa đến hạn.
- [x] Đối soát SePay read-only với budget, pagination, UNKNOWN khi provider lỗi.
- [x] Admin API kiểm tra quyền mới nhất; coordinator định kỳ/thủ công; cấu hình mặc định tắt.
- [x] Collector cảnh báo/recovery cho target subscriptionCritical trước ingestion.
- [x] Log credit/nâng cấp chỉ sau commit; không log payload provider trong exception billing.
- [x] Runbook tại tuan-research/subscription_observability_runbook.md.
- [ ] Chạy lại PostgreSQL/API/gateway sau thay đổi cuối, gồm test rollback/after-commit mới.
- [ ] Chạy đầy đủ hồi quy monitoring trong môi trường cho phép loopback/Docker.
- [ ] Áp dụng migration staging/production, bật job, cấu hình target và receiver cảnh báo thực theo quy trình release.

Không commit. Các kiểm thử đã PASS và giới hạn thực tế được ghi trong runbook; không đánh dấu đã release production.
