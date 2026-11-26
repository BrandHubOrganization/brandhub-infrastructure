# Creator Task Creation Policy — Tasks

- [x] T1 Enum + settings field + PATCH request + response default `FREE`
- [x] T2 Gate in `createTask` / `createStandaloneTask`
- [x] T3 `creationApproval` on Task + workflow lock
- [x] T4 Approve / reject service, controller, notifications
- [x] T5 List response field
- [x] T6 Web: policy hook + gates
- [x] T7 Web: quick-create APPROVAL mode
- [x] T8 Web: detail banner + list/board badge
- [x] T9 Web: workspace setting card + vi/en i18n
- [x] T10 Mobile: create button hidden when DISABLED, "Gửi đề xuất" + alert when APPROVAL, approve/reject card on task detail (policy picker stays web-only; mobile has no workspace settings screen)
- [x] T11 SRS checked: no Create Task FR lists Creator; only NFR line "Manager or Creator ... Create Task", still true under default FREE - no change
- [x] T12 Dashboard "Next up" skips tasks with creationApproval PENDING (no START on a locked task)
- [ ] T13 Browser test (waiting for business-service restart)
