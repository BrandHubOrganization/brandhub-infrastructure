# Media Package, Campaign and Chat — scoped UI refresh

## Current amendment — 2026-10-19

User requests compact Package/Campaign headers, grouped readable Package terms/deliverables with clear value labels, secondary explanations behind keyboard/touch-accessible question-mark help, and a top Change package action exposing the catalogue without scrolling. Preserve selection/approved/Campaign locks and negotiation dirty guards; no new role permissions. Remove redundant Campaign partner link (already in menu), duplicate heading/description and Task Detail approval shortcut. Fix approval page height propagation/independent scrolling with long media without changing shared PageWrapper for other pages.

Campaign end date: user confirmed auto-filled suggestion, still editable by Manager; source is approved agreement durationWeeks, never mutable catalogue. Suggest start + weeks*7 calendar days (not minus one); missing duration keeps manual input. Preserve manually chosen end dates when start changes, unless end is empty or matches the previous calculated suggestion. Reopening existing drafts must not rewrite stored dates. No backend/schema/data edits.

## Objective / user story

Owner manages Agency packages; Client and Manager review package terms and the
single Campaign in a Workspace; active members exchange plain-text chat messages.
Improve readability and navigation without changing the existing business contracts.
User approved the layout and added Chat to scope on 2026-10-10.

## Acceptance criteria

- Package catalogue puts name, value and deliverables before secondary actions;
  local search/filter does not change API results or availability permissions.
- Detail view groups scope, deliverables and acceptance criteria. Negotiation keeps
  the current version, Client proposal count and both approvals visible. Compare
  previous/current terms with textual change indicators, not colour alone.
- Package approval leads to the existing Campaign route, not an embedded second
  Campaign editor. Keep one Campaign/Workspace, immutable approved content, total
  quantities, Client feedback/Manager editing and version-bound approvals unchanged.
- Campaign groups plan, review and deployment/progress; differences show business
  labels and structured milestones/work items rather than raw JSON.
- Chat retains existing history, context, connection and delivery states; readable
  messages, day separators and composer. No attachments/reactions/read receipts.
- Closing an edited package form requires confirmation; pending requests cannot
  dismiss the form. No persistent draft storage or backend changes.
- All new labels use parallel `mediaPackage.ui.*`, `campaign.ui.*`, `chat.ui.*` keys
  in vi/en. Existing font, semantic colour tokens and light/dark modes are retained.
- Responsive at 375/768/1440px; visible keyboard focus, labelled inputs and no
  unintended horizontal page overflow. Loading/error/empty states remain usable.
- No changes to global CSS/theme, shared primitives/layout/sidebar/routes/access,
  other pages, service payloads, database or existing uncommitted partner work.

## API / errors / edge cases

Reuse existing services and hooks. Keep role checks, package gate, conflicts,
proposal limits, deployment retry and completion reasons. No automatic approval,
deploy, Task completion or data mutation during browser verification.

## Sources / out of scope / DoD

Sources: ../phase-1-design/spec.md, ../README.md, ../../../ba/04-media-package-campaign.md,
../../content-task-workflow/3-6-36-realtime-workspace-chat/spec.md and brandhub-web/rule.md.
Out of scope: reports, new Jira tasks, backend/data changes and UI owned by others.
DoD: scoped diff, type-check/lint/build, existing regression suite and browser
evidence where available. Environment limitations are recorded, not marked passed.

## UI corrections — 2026-10-11

- Campaign form separates milestones and planned work items into named sections.
  Use distinct `campaign.milestoneName` / `campaign.workItemName` labels in vi/en;
  milestone guidance explains dates only, work-item guidance explains Task creation
  after deployment. No shared “work item / milestone” label or payload changes.
- Catalogue search, availability filter and result count must remain separate,
  operable controls, including the Owner catalogue where the filter is present.
- Vietnamese Package/Campaign approval labels use “khách hàng” and “công ty truyền
  thông/quản lý”; remove parenthesized English role/approval labels. English locale
  remains available, with parallel keys unchanged.
- Campaign permissions resolve from the Workspace in the URL, matching the shared
  access guard, not a stale selected Workspace role. Managers can edit valid DRAFT
  plans. APPROVED/IN_PROGRESS/COMPLETED plans remain immutable; show why editing is
  unavailable instead of silently hiding the action. Legacy guards remain intact.
- No backend or shared primitive/access changes; no reopening an approved Campaign.

User-approved data correction: restore only draft Campaign
`d366c84e-93c3-41c8-b433-5bab58a14341` in Workspace
`b84bd2d0-b069-44e9-95e1-1f7b5bc8111d`. Its frozen v3 package snapshot equals the
approved Workspace terms and contains 2 deliverables, but deliverable_plan is empty.
Copy those snapshot deliverables only; keep status/contentVersion/approvals/work items
unchanged. This is not a schema migration or a conversion of monthly quantities.
