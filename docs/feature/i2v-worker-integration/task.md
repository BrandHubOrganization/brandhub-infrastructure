# Tasks

- [x] Add failing adapter and routing tests.
- [x] Implement separate settings and image-only adapter.
- [x] Add web mode/prompt/duration/aspect controls with matching vi/en labels.
- [x] Configure ignored local worker URL/key; verify authenticated health without rendering.
- [x] Run checks and document remaining runtime limits.
- [x] Remove duplicate working-tree declarations blocking compilation; exclude vendored code from application lint and rerun checks.

Verified: 31 focused backend tests passed; npm run ci passed (lint, type-check, build); configured worker /health returned HTTP 200. Worker key absent from generated JS. No real video render or AWS upload was submitted. AI Service must load the updated environment on start/restart.

- [ ] 2026-11-09: resolve four Web stash conflicts without losing brief, image+prompt or reference modes; verify type/build and no markers.
