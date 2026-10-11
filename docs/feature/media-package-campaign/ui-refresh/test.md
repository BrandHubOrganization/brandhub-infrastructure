# UI refresh — verification matrix

| Case | Expected |
|---|---|
| Owner catalogue | Search/filter without mutation; detail/copy/availability actions preserved |
| Client selection | Only Agency-available packages; existing package-switch lock retained |
| Create/copy form | Existing payload, validation and loading; dirty close asks before discard |
| Negotiation | Client-locked fields unchanged; latest terms/proposal count/two approvals visible |
| Package differences | Old/new business labels, changed text badge, mobile stacking and long text wrapping |
| Package approved | Link to unique Campaign; no embedded duplicate editor |
| Campaign plan | Existing create/edit/save payloads; milestones and work items distinct |
| Campaign review | Correct version, dual approval, Client feedback; structured version comparison |
| Deployment | Existing pending/failure/retry/progress/completion reason behavior retained |
| Chat | History/day groups/sender/time/context/delivery; no raw HTML; Enter/Shift+Enter unchanged |
| Disconnected chat | Visible connection feedback; no fabricated online/member/read states |
| vi/en and light/dark | Parallel keys, readable states, no missing-key labels |
| 375/768/1440px | No horizontal page overflow, focus visible, controls reachable |
| Scope regression | Shared UI/layout/theme/routes/access, services/hooks and partner UI untouched |

## Execution evidence — 2026-10-11

- `npm run type-check`: passed.
- `npm run lint`: passed with 0 errors and 81 warnings repository-wide during this
  slice. Final scoped ESLint on Package/Campaign/Chat: 0 errors, 1 existing
  `react-hooks/set-state-in-effect` warning in NegotiateTermsModal's initialization effect.
- `npm run build`: passed (Vite 8.3.1). Existing ineffective dynamic-import warning
  concerns mockContentLibraryService in the unrelated Library module.
- Existing Playwright suites: **29/30 passed**, including **12/12 Campaign Partners**.
  Commands: `npx playwright test tests/e2e/media-package tests/e2e/campaign-partners --workers=2 --reporter=list`.
- JSON key parity: mediaPackage 184, campaign 132, chat 26 keys; vi/en match.
- `git diff --check`: passed; CRLF conversion notices are not whitespace errors.

### Browser-only checks

All API and WebSocket traffic in the CLI audit was intercepted with fixtures;
no accounts, seeds, real approvals, deployments or Campaign completion were created.

- Package responsive checks passed at 375/768/1440px in light/dark through the
  existing suite. Catalogue create/copy, selection, hard gate and stale-save cases passed.
- Chat and Campaign CLI matrix: 12 page/width/theme combinations, no horizontal
  page overflow and no uncaught page errors. Client Campaign edit controls absent.
- Approved Package links to the separate Campaign page; no embedded Campaign editor.
- English switch renders the approved-package Campaign link correctly.
- Client negotiation: model/max changes/unit remain disabled; changing quantity
  12 → 16 then cancelling and keeping editing preserves 16. Mock submission reaches
  the proposal limit, shows guidance and disables another proposal.
- Package detail opens and closes with Escape.
- Chat: connected status, date groups, message roles/context and composer visible.
  Shift+Enter inserts a newline; Enter sends. Mock server rejection displays
  failed delivery. Simulated socket loss displays reconnecting and disables composer.
- Campaign progress fixture displays accessible progress 0/1 correctly.

CLI scripts and screenshots are local artifacts under
`brandhub-web/output/playwright/ui-refresh/`; generated browser logs are under
`brandhub-web/.playwright-cli/`. They are not application runtime fixtures.

### Known failing regression and boundaries

`media-package.spec.ts:435` expects cold navigation to `/media-package` to reach
the Workspace-scoped page, but receives `/dashboard`. Inspection of shared
`src/components/layout/AuthGuard.tsx` shows `/media-package` is absent from its
legacy Workspace route list; the access check can reject the shortcut before
WorkspaceScopedRedirect mounts. Neither file was changed by this UI refresh.
Direct `/workspaces/{id}/media-package` and scoped hard-gate tests pass. A shared
guard fix is deliberately deferred outside the approved UI scope.

API/backend/database, existing services and transport hooks were not modified.
Pre-existing E50-09 partner routes/sidebar/access/locale changes remain preserved.
Browser fixtures do not replace live end-to-end verification with the running backend.
Older-history scroll anchoring and reload/tab-close warnings are implemented but
were not separately exercised in the browser audit.

## Correction cases — 2026-10-11

- Campaign form: milestone section uses “Tên mốc”, work-item section uses “Tên đầu
  việc”; English has separate labels too. No combined “Tên đầu việc / mốc” label.
  Adding/removing a milestone must not change workItems and vice versa; saved
  timeline.milestones and workItems retain their existing structure. Keep sections
  readable in both themes at 375/768/1440px.
- Owner catalogue at 375/768/1440px, light/dark: search/filter controls have usable
  width, do not overlap, result count stays together; both search and filter work.
- Vietnamese approval: no “Dual Approval”, “(Client)” or “(Manager)” in Package
  approval area; Campaign approval uses Vietnamese role labels.
- URL Workspace MANAGER with stale/missing current role: valid DRAFT exposes edit,
  opens populated form and saves through the existing update API/version contract.
- Client on the same draft: no edit button.
- Manager on APPROVED/IN_PROGRESS/COMPLETED: disabled edit and visible explanation;
  no update API request. Legacy data stays guarded, no silent conversion.
- User-approved single draft correction: before DRAFT v1, package v3, frozen snapshot
  equals approved terms, 0 deliverables/0 work items; after 2 snapshot deliverables,
  same status/version/approvals/work items. Only the exact Campaign/Workspace may match.

### Correction results

- Milestone/work-item clarification: CLI mock audit passed independent add/remove,
  edited names and existing save payload structure; separate vi/en labels verified.
  Both named sections remained separate with no horizontal overflow at 375/768/1440px
  in light/dark (6 cases). TypeScript app/node checks, scoped ESLint, Vite build and
  campaign locale key parity passed. No backend or database writes. Local artifacts:
  `output/playwright/ui-refresh/audit-milestones.js` and `milestones-*.png`.
- Owner toolbar: 6 width/theme cases passed. Search/filter widths respectively
  343/343px (375 viewport), 267/320px (768), 448/320px (1440). No overlap or horizontal
  overflow after shared breakpoint transitions settle. Search and hidden filter work.
- Vietnamese approval: heading “Phê duyệt hai bên”, “Phía khách hàng” and “Phía công ty
  truyền thông”; no parenthesized English approval/role labels in the audited area.
- Mock Manager: URL Workspace role remains authoritative despite a stale selected
  Client role. Opening populated form and saving issues one PATCH with expectedVersion;
  new contentVersion is rendered. Client edit controls remain absent.
- APPROVED/IN_PROGRESS/COMPLETED: disabled edit button and explanatory copy verified.
- CLI correction audit: no uncaught page errors. Screenshots/scripts under the same
  local output/playwright/ui-refresh directory (owner-corrected-* and audit-corrections.js).
- Type-check, targeted ESLint and build passed. vi/en key parity passed. Existing
  suites rerun: 29/30, same unscoped-shortcut failure; all 12 partner cases passed.

### Explicitly approved local data repair

Actual cause for Workspace `b84bd2d0-b069-44e9-95e1-1f7b5bc8111d`: Campaign
`d366c84e-93c3-41c8-b433-5bab58a14341` was DRAFT v1 with an empty deliverable_plan,
triggering the legacy guard. Snapshot v3 equalled approved Workspace terms and
contained 2 DELIVERABLE_BUNDLE deliverables; this was not a monthly conversion.

After explicit user approval, one conditional UPDATE restored deliverable_plan from
that exact Campaign snapshot. PostgreSQL reported UPDATE 1. Post-check confirmed
DRAFT/content_version=1/package_terms_version=3, 2 deliverables matching snapshot,
0 work items, both approval timestamps still NULL. Internal row_version advanced
0 → 1 for optimistic locking; no business content-version increment, schema change,
deployment or Task creation. No other Workspace was updated. Live save through the
user's authenticated browser was not exercised; refresh that Workspace to re-test.
