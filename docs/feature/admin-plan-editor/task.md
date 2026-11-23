# Admin Plan Editor — task

- [x] T1 Migration `billing_plan_change_log` + nối init-postgres-v2.sql
- [x] T2 ErrorCode mới
- [x] T3 `AdminPlanService` + request/response record
- [x] T4 `AdminPlanController`
- [x] T5 Public catalog endpoint + SecurityConfig
- [x] T6 Gateway route + allowlist
- [x] T7 StorageQuotaService / NewsletterQuotaService đọc từ phiên bản gói
- [x] T8 Unit test AdminPlanService (validate, conflict, unchanged, sale lock)
- [x] T9 Web service + AdminPlansPanel + dialog sửa/lịch sử + nav
- [x] T10 Landing Pricing đọc API public
- [x] T11 Cập nhật vi.json + en.json
- [x] T12 Kiểm tra light/dark mode
- [ ] T13 mvn test, tsc, vitest; chạy migration trên DB local; thử E2E

Trạng thái 2026-11-22: T1–T11 xong. T12 (light/dark) và E2E trên trình duyệt chưa làm vì Chrome extension
không kết nối. T13: AdminPlanServiceTest 7/7, tsc sạch (trừ lỗi có sẵn ở SectionFieldsBlock.tsx), vitest 389/390
(1 lỗi có sẵn ở SectionListField.tsx), SQL luồng sửa gói chạy thử trên Postgres local trong transaction ROLLBACK.
