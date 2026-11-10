# Checklist E50-09 / DA-950

- [x] Đối chiếu master-plan, BA, entity, init PostgreSQL, API và UI.
- [x] Chốt spec và plan, tách phạm vi CRUD E50-08 / AI recommendation.
- [x] Bổ sung repository projection/locking và access helper.
- [x] Implement service, Workspace API, legacy assign/update adapters.
- [x] Thêm trang, sidebar, locale và link từ Campaign.
- [x] Viết backend tests và Playwright theo test.md.
- [x] Chạy Maven, lint/type-check/build, browser mock tests và HQL validation.
- [x] Cập nhật OpenAPI, master-plan/roadmap và giới hạn E50-08 còn lại.
- [ ] Chạy smoke PostgreSQL rollback-only khi Docker sẵn sàng; không seed/account mới.
- [ ] Smoke API có JWT và kiểm thử concurrent assignment trên PostgreSQL thật trước Jira Done.
- [ ] Delta 2026-10-13: active-only picker và same-transaction first-use marker theo DA-949 migration.
- [ ] Đồng bộ legacy/Workspace assign active guard; giữ inactive existing links readable/updateable/idempotent.
- [ ] Test race assign/delete/deactivate; parallel vi/en campaign.json badge/errors và light/dark/mobile regression.
