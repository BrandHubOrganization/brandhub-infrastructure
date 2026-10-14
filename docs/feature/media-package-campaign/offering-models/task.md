# Tasks

- [x] Confirm scope and monthly/no-rollover/manual RETAINER behavior with user.
- [x] Inspect existing package and Campaign implementation.
- [x] Update BA/master-plan references for Workshop Meet and survey scope.
- [x] Add migration and matching fresh-init columns.
- [x] Implement typed offering validation and snapshot negotiation.
- [x] Implement authorized draft Campaign creation and allocation limits.
- [x] Add offering form, summary and draft Campaign UI.
- [x] Update vi.json + en.json (existing split mediaPackage locale namespace).
- [x] Test light/dark mode and responsive layout.
- [x] Supply a local Admin-template refresh using existing feature-test accounts.
  - The earlier isolated seed approach was withdrawn; see seed-guide.md.
- [x] Run backend/frontend regression checks and record results (including unrelated failures in test.md).

Remaining verification: migration repeatability/fresh-init parity and live API/Hibernate
smoke checks are not re-run at the commit checkpoint. Campaign approval/deployment and
adaptation to the new one-agreement/one-Campaign rule are subsequent work.
