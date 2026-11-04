# Test cases before code
- S01: create/draft/detail/assign stay TODO, no source/ID/plan changes.
- S02: missing brief/deadline, invalid dates, wrong Creator/QC, duplicate QC => no assignment/start/outbox.
- S03: explicit assigned Creator start => IN_PROGRESS + first marker; opening editor does not start.
- S04: working/review/terminal/legacy unknown first-start => Manager remains locked.
- S05: legacy/canonical read + filters + closure; five groups, derived reviewStep, FINISHED terminal.
- S06: targeted field allowlist, preserved untouched fields, stale version/conflicting edit => 409 retains draft.
- S07: blur/selection saves once; queued mutations share acknowledged revision; list and panel stay synchronized.
- S08: validation/network/conflict retain input and offer retry/discard; closing/switching/navigation cannot silently discard pending/failed edits.
- S09: only Manager assignment/deadline and assigned Creator start in list; Client readonly; no arbitrary status selector.
- S10: 375/768/1440, long list/detail; outer main no vertical scroll, list/detail independently scroll, toolbars/footer fixed.
- S11: keyboard/focus after refresh, vi/en/light-dark, readable dates and accessibility feedback.
- S12: migration dry-run/apply/repeat/conflicts => no document writes/backfill, preserve existing validators/indexes.
- S13: no teammate editor or Approval endpoint changes; cannot arbitrarily finish a Task.
## Evidence — 2026-10-15

- Web full unit suite: 15 files / 136 tests passed. Type-check/build passed. Scoped ESLint: no errors; React-refresh/effect warnings remain. Existing Library dynamic-import build warning is outside this slice.
- Business focused workflow/lifecycle/reader/closure unit tests passed; isolated Mongo replica-set integration: 5 tests passed (CAS, rollback, assignment/outbox atomicity, explicit null evidence, worker lease).
- Offline schema/checker suite: 25 tests passed, including fresh-init parity, additive repeatability, invalid-document/conflict abort without writes.
- Real Mongo schema integration in a new network-isolated container passed: final checker 12 MATCH; DRY_RUN/APPLY/repeat, all five canonical states, invalid reviewStep rejection and unchanged legacy documents.
- Browser uses real Task components in a bounded mock shell/API (not a live logged-in end-to-end test): 1440 desktop, 375 mobile, vi/en/light/dark, nonmodal detail, inline assign/deadline, blur-only save, revision queue, 409 draft+close guard, explicit retry, keyboard close/focus and Creator explicit start, Client readonly passed. Outer page/main overflow=0; list overflow=447px, independently scrollable.
- Local screenshots/script: `.local-backups/task-ui-audit-20261015/inline-{desktop,dark-en,mobile}.png`, `browser-inline-check.js`. Vite HMR WebSocket local-network console warnings are browser harness limitations, not Chat API failures; intentional 409 was exercised.
- Atlas metadata APPLY was explicitly authorized by user, preceded by staged preflight of all three actual scripts. All three effects MATCH; workflow foundation/five-state readiness true. At the metadata-only stage, 31 Task count+SHA-256 remained unchanged; metadata backup before/after retained locally. No live authenticated API smoke test.
- A later, separately approved test-data operation deleted exactly six empty drafts without document backup at user request. User explicitly confirmed all 25 remaining test Tasks never started; one Mongo transaction initialized TODO/revision=0/first-start markers=null, preserving other content/links. Read-only post-check: 25 workflow-ready Tasks, deleted IDs absent, nine Campaign/two ACCEPTED Request links intact. No PostgreSQL writes or seed. This is operator-confirmed reconciliation, not permission to infer start history in other environments. Scripts/receipts are local only.

Limits: cross-route browser Back/Forward outside the Task route is not a router-wide navigation blocker; query-based Task switching/Back is guarded, plus same-origin links, list controls and browser unload. 768/landscape/reduced-motion/zoom were not re-run in this slice. Approval/submit/reject is teammate-owned and not implemented or tested here. Comments schema is preparation, not FR 3.6.3 completion.

## Setup before testing

1. Atlas metadata is already updated; do not run init or replay earlier migrations.
2. Restart Business with this code and refresh Web. Gateway forwarding is unchanged.
3. Use a newly created Task, or the 25 test Tasks explicitly reconciled above. Other legacy Tasks without revision/explicit first-start evidence remain readable but locked; any further reconciliation requires separate review. Fourteen reconciled Tasks belong to Workspaces absent from this local PostgreSQL; do not create/delete those Workspace records implicitly.
4. As actual Manager: enter description, choose a valid deadline; then assign active Creator, optional different QC/Client approval. As that Creator: explicitly start. After start, Manager edits/reassignment lock.
5. Do not test approval transitions through arbitrary status changes: coordinate the five-state/reviewStep/first-start contract with the teammate owning Approval.
