# Checklist

- [x] Show warning/list first; cancellation opt-in, collapsed initially and reset on collapse.
- [x] Update vi/en disclosure labels and verify keyboard/mobile/light-dark behavior (isolated browser mock).

- [x] Update confirmed BA and affected FR specs/master plan.
- [x] Link new Request Tasks to current Campaign with lock/idempotent provenance.
- [x] Completion preflight and strict final server gate.
- [x] Atomic batch cancellation, per-Task audit and reason enum.
- [x] Add Mongo migration/init/checker parity; no live writes.
- [x] UI separate supplemental group; closure dialog, links, explicit selection/confirmation.
- [x] vi/en labels, keyboard, responsive and semantic light/dark styles (browser mock).
- [x] Backend regression and isolated Mongo tests, UI typecheck/build/lint.
- [x] Setup instructions and disclose legacy reconciliation/manual checks.
- [ ] Live migration/application restart and end-to-end test with approved test data.
- [ ] Inform Task workflow team of terminal CANCELLED contract before merging.
