> Checkpoint 2026-10-17: restored specification and historical verification for retained Media Package/Campaign UI. Task UI changes described as rolled back remain out of this UX scope. API/classification changes after this checkpoint are governed by the Media Package package-simplification spec; historical fixture test results are not a new verification run.

# Implementation plan

1. Campaign page: actionable prerequisite state using shared Button/Link. CampaignNextStep: contextual guidance for managers/clients, semantic section anchors and task navigation; preserve existing business actions.
2. Task hook: separate typed and applied search, debounce 300 ms, immediate submit/reset, retain latest-request protection.
3. Task page/filter: keep index.tsx as a short orchestrator and move the existing view into components/WorkspaceTaskView.tsx. Use shared Input, labeled filters, reset and result feedback, distinct empty states, URL view preservation and role-aware campaign navigation.
4. Task table: remove inert selection, provide title buttons and sorting buttons; translate priority and pagination, retain existing status styling and row actions.
5. Update vi/en campaign.json and tasks.json together. No new styling tokens or dependencies.
6. Validate through typecheck/build, scoped ESLint and real browser interactions using existing mock patterns. Capture light/dark and responsive screenshots under output/playwright.

Risks: search timers must not load a stale page; changing views must preserve task query parameters and unsaved edit guards. Cross-links must follow route access. Browser fixtures demonstrate frontend behavior, not live backend integration.
