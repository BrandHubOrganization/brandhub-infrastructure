# Technical plan

1. Add additive planning fields and backwards-compatible DTO constructors. Default only newly created records. Introduce scoped batched timeline response; reuse workflow policy and member validation. Revision-checked schedule updates never write Post/publish fields. Embedded subtask writes use parent revision/CAS.
2. Web feature files under pages/campaign/{components,hooks,services,types,utils}; keep orchestrator short. Query timeline once (no row request waterfall), reuse TaskWorkflowContent and existing subtask UI in Task dialog. Reuse deployment/closure components without changing publish.
3. Serialized Campaign field saves and query invalidation; row scheduling uses current server revision and rollback on failure. Filters preserve hierarchy. Pointer capture for drag and column resize, keyboard alternatives; derive view bounds independently from Campaign.
4. Locale changes: src/i18n/locales/vi/campaign.json and en/campaign.json. Semantic colors, existing primitives, no React Bits dependency required for a data-dense timeline.
5. Add Mongo migration in docs/database/migrations; merge optional date validator properties into init; update TaskSampleSeeder. Do not APPLY shared DB or touch unrelated Post validators.
6. Run Web CI and relevant backend tests/build. Keep newly authored test artifacts outside src and uncommitted local-only. Validate light/dark, keyboard, 375/768/1440, filters, continuous creation, revision conflicts, default timezone and free dates.

## Layout refinement
1. Add a viewport sizing hook and right-rail plan editor, preserve field-level auto-save and unsaved gating.
2. Extract interactive milestone rail with local draft/version, preview, direct create/edit, error retry and keyboard support. Reuse Campaign update API.
3. Correct calendar scale to match actual lane width, add fit zoom, clearer date ruler and vertical borders; add direct unscheduled range preview.
4. Update campaign vi/en locales and CSS only within feature. Test real React components with intercepted API, no shared DB writes.

## Simplification implementation
Move Campaign date fields to a compact timeline toolbar; keep strategy as a right-rail disclosure. Enforce persisted-width minima and minimum daily pixel scale. Use Campaign bounds without decorative padding/today extension; preserve actual out-of-bounds task visibility and free scheduling. Add explicit boundary guides and synchronized, keyboard-accessible custom horizontal scrollbar. Direct click uses existing revision-checked schedule API. Update only Campaign feature and parallel campaign locales.

Date/column correction: repair open-ended range fallback; measure translated status labels with the current font; derive safe column widths, version local layout preferences; add truncated heading wrappers; retain one synchronized scroll control and horizontal wheel support. Test mock cases plus the user-provided local Campaign page without modifying Campaign data.


## Milestone drag — 2026-11-07
Extend TimelineMilestoneRail with pointer capture, drag threshold, local preview and click suppression. Reuse existing versioned milestone submit/error handling; no API/DB changes. Add campaign.timeline.moveMilestone in vi/en campaign.json and scoped cursor/touch CSS.


## Inclusive deadline display — 2026-11-07
Use inclusive day-cell width for scheduled and unscheduled previews; unscheduled drag stores the last selected day instead of an exclusive next day (retain existing API start<end requirement). Remove Task drag label/title and milestone drag date span, keep milestone create/editor day context. No DB migration.


## Compact timeline controls — 2026-11-07
Update CampaignTimelineGrid default scale/week and replace native Select with shared DropdownMenu radio group; remove Fit affordances. Render milestone date picker only when editing an existing milestone. No API/DB change.


### Scale selection highlight
Scope indicator hiding and compact left padding to timeline scale RadioItem classes; do not change shared DropdownMenu behavior.


## Compact multiple filters — 2026-11-07
Change TimelineFilters assignee/supervisor to string arrays; update EMPTY_FILTERS, matchesTimeline, Grid filtered flag and FilterBar toggles. Replace people single native select with checkbox choices, remove chips construction/rendering. Existing locale keys reused, semantic theme colors.


## Remove duplicate bottom information — 2026-11-07
Remove Grid anchor/footer markup and dead scrollToDay helper, remove scrollbar caption but preserve its grid inset, delete unused scoped anchor/caption CSS.


## Toolbar order — 2026-11-07
Reorder existing Grid toolbar JSX; remove filter rounded-top class since it is no longer the top row. No behavior/API/i18n changes.


## View controls in filter row — 2026-11-07
Add optional trailingControls ReactNode slot to TimelineFilterBar; pass existing Today/scale JSX from Grid. No control behavior/state/API changes.


## Personal-work dropdown styling — 2026-11-07
Reuse shared DropdownMenu components in TimelineFilterBar for mine filter only. Existing Select remains for other popover fields. Match scale menu styling, compact trigger and full option labels; no data/API changes.


## Filter checkbox layout — 2026-11-07
Set checkbox Input wrapperClassName w-auto shrink-0 and content span min-w-0 flex-1 break-words. Set popover right column minmax(0,1fr)/min-w-0. Keep native label-click/keyboard and multi-filter behavior.


## Deliverable choices and filter audit — 2026-11-07
Change TimelineFilters deliverable to string[], update defaults, matcher and Grid filtered flag. Replace FilterBar native deliverable Select with checkbox list and schedule Select with radio list; remove unused Select import. Wrap sidebar labels in variable-height buttons. Reuse vi/en strings and Input wrapper sizing.


## Compact popup width — 2026-11-07
Adjust FilterBar popup width/grid/sidebar button classes only. Category labels nowrap/truncate, accessible full text/title. Existing state and filter semantics unchanged.


## Optional strategy and selected-package navigation — 2026-11-07
Remove strategy predicate from MediaCampaignServiceImpl.validateApprovalPlan and DeploymentPanel conditions; derive readiness denominator from condition length. Change Sidebar/Layout navigation gate from approval to missing workspaceMediaPackageId. Check stored package selection updates existing store. No schema/API changes.


## Compact Campaign layout — 2026-11-08
Reuse CampaignPlanEditor in header with positioned disclosure; move DeploymentPanel into dates slot. Replace rail grid with full-width timeline. Reuse Radix Popover for feedback; maintain query and comment state outside panel, local viewed watermark and30s polling. Deployment hover/focus details plus explicit Popover toggle. Update parallel campaign locales and scoped CSS. No API/DB changes.


## Feedback conversation — 2026-11-08
Update MediaCampaignServiceImpl.addFeedback to authorize AGENCY via requireManager, retain CLIENT access and version locking. Adapt notification title by side. Enable Manager composer; handle Enter via form.requestSubmit with composition guard. Add localized Workspace chat link. Reuse existing tables/API. Extend existing service tests and ignored browser harness.


## Rich strategy — 2026-11-08
Add CampaignStrategyInput with StarterKit, safeChatLink and ChatComposerToolbar reuse without changing chat. Convert legacy plain text to paragraph JSON; parse supported HTML through Tiptap. Add field wrapper for dirty/version/error/blur region and explicit close flush; use readonly input for legacy detail and controlled input in form. Update VI/EN placeholder/length messages. Test nested list formatting, safe URLs, empty/legacy HTML, save/reopen/version error, permissions and full Web CI.

Rich strategy refinement: forward optional forceMount through shared Popover Portal (sole consumer is strategy), preserve mounted field across close; explicit close flush suppresses duplicate blur retry. Keep nested link popup above strategy overlay; Tiptap editable changes do not emit content updates. Read-only strategy uses compact spacing.


## Vietnamese and loading feedback — 2026-11-08
Normalize string values only in vi/campaign and vi/mediaPackage without modifying interpolation tokens. Add parallel loading/saving keys. Reuse TimelinePendingRange for both scheduled and unscheduled local commits with lock and finally cleanup. Keep mutation awaited through existing query invalidation. Add CampaignLoadingState and workspace/catalog Package skeleton exports. No backend/DB changes.


## Completion action implementation — 2026-11-08
Reuse CampaignClosureSection as a compact anchored popover in CampaignWorkspace and legacy CampaignDelivery. Fetch only when opened via React Query, show skeleton/error/retry, scroll content within viewport. Pin during interaction; protect active cancellation/confirmation from accidental dismissal. Reuse cancellation reasons/100-task limit and existing completion endpoints. Keep timeline visible and refresh task data after cancellation; apply returned Campaign after completion.
