# Tasks

- [x] Inspect production chat, role rules, contracts and design system.
- [x] Write spec, plan, tasks and verification scenarios in order.
- [x] Confirm real backend scope with the user and update spec/plan.
- [x] Add channel/member/DM persistence and authorization.
- [x] Add message/thread/search/reaction/pin/read APIs and migration indexes (prepared; not applied to shared databases).
- [x] Preserve legacy general-only access and secure realtime delivery.
- [x] Add backend regressions for authorization, idempotency and query isolation.
- [x] Implement conversation filtering, sidebar and responsive workspace layout.
- [x] Implement collaborative message rows, search, details and copy.
- [x] Implement reliable retry, connection isolation and visible-message read state.
- [x] Update Vietnamese and English locales together.
- [x] Check light/dark mode, keyboard and 375/768/1440px layouts.
- [x] Fix and verify keyboard focus restoration after closing controlled mobile sheets.
- [x] Fix and verify optimistic/failed message isolation when changing specific business contexts.
- [x] Run relevant TypeScript, lint, build and browser checks.
- [x] Record executed results and unexecuted live integration scenarios.

Deployment validation remains separate: apply the reviewed Mongo migration in the target environment and exercise real authenticated multi-user REST/STOMP sessions. Neither action was performed by these local checks.
