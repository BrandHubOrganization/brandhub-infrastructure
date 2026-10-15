# Tasks - FR 3.5.5

2026-10-10: draft delivery code is implemented; live verification remains below.
See [delivery plan](../campaign-delivery-plan.md). Open decisions are not approved scope.

- [x] Phase 1: total quantities and EVENT_PLAN/PRESS_RECOMMENDATION confirmed; Duplicate Workspace remains separate.
- [x] Audit Workspaces/agreements with multiple Campaigns; execute the explicitly approved cleanup after backup.
- [x] Preserve single-agreement Workspace queries and prevent agreement reassignment.
- [x] Add unique campaign/agreement constraint and concurrent-create guard.

- [x] Add `work_items` JSONB migration and V2 init schema update.
- [x] Implement approved-package validation and campaign creation.
- [x] Validate work-item IDs/types/due dates.
- [x] Implement versioned draft update and structured planning UI.
- [x] Implement total-quantity planning UI and guarded legacy-snapshot handling.
- [x] Add matching vi/en locale keys; mocked Campaign tests cover mobile/dark and desktop/light.
- [ ] Test one Campaign per Workspace, including concurrent creation and COMPLETED campaigns.

## Stage 2 checkpoint — 2026-10-08

- [x] Read-only local audit: 116 Campaign; 35 agreements have two Campaigns.
- [x] Implement scoped API, frozen deliverablePlan, workItems and guarded draft edits.
- [x] Write migration and matching init schema (not executed).
- [x] Add Campaign page/form/detail and sidebar; paired campaign vi/en locale files.
- [x] Targeted backend suite 66/66; production Web build; scoped lint.
- [x] Campaign browser create/edit, client view, legacy warning and stale input tests.
- [x] Người dùng duyệt xóa hẳn 35 Workspace trùng; backup rồi xóa trong transaction.
- [x] Apply migration và verify PostgreSQL: unique index, không còn duplicate/orphan.
- [x] Hibernate validate và khởi động Business Service thành công trên DB đã migrate.
- [ ] Verify authenticated API và concurrent requests qua Business Service đang chạy.
- [ ] Resolve/investigate existing utility redirect regression test failure (17/18 suite).

Live verification is not complete. See the 2026-10-10 pre-commit checkpoint in
[roadmap](../implementation-roadmap.md) for current test results and remaining work.
