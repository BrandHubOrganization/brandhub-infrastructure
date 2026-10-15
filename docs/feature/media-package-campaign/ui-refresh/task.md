# UI refresh — task checklist

- [x] Confirm scope, current BA, UI rules and design direction.
- [x] Write/read spec, plan, task, test before implementation.
- [x] Package catalogue/detail and grouped create form.
- [x] Negotiation/diff/approval and link to Campaign.
- [x] Campaign plan, structured review and deployment/progress.
- [x] Chat presentation, day groups and composer/connection states.
- [x] Update parallel vi/en locale keys.
- [x] Check keyboard, mobile/tablet/desktop and light/dark mode.
- [x] Run type-check, lint, build and existing regression checks (29/30; exception below).
- [x] Verify protected shared files and unrelated changes remain untouched.

Verification completed on 2026-10-11. One existing regression case remains red:
cold navigation to the unscoped `/media-package` shortcut redirects to `/dashboard`
in the shared AuthGuard. Workspace-scoped routes pass. Shared route/permission
code was not changed by this UI slice; see test.md for evidence and limitations.

Local commits authorized on 2026-10-11, grouped by Jira scope. Push and Jira status
changes are not requested. Browser artifacts and unrelated edits stay uncommitted.

## Corrections — 2026-10-11

- [x] Separate milestone/work-item section labels and guidance in parallel vi/en.
- [x] Verify independent editing and unchanged timeline/workItems save payload.
- [x] Fix Owner search/filter wrapper layout without editing shared primitives.
- [x] Translate Vietnamese approval copy; add parallel vi/en edit-lock hint.
- [x] Resolve Campaign role from URL Workspace and explain immutable plans.
- [x] Browser-check Owner toolbar, Manager editing, Client restriction and themes.
- [x] Run type-check/scoped lint/build and record evidence.
- [x] Restore the explicitly approved single draft's deliverable_plan from snapshot;
  verify status/version/work items/approvals unchanged, no other Workspace writes.
