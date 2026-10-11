# UI refresh — implementation plan

1. Use existing Inter/type scale, semantic background/card/foreground/border and
   brand-orange tokens. Quiet panels, left-aligned content, one primary action per
   section; no new font, global style or library. Desktop negotiation uses a wide
   terms panel plus approval sidebar; mobile stacks the same sections.
2. Change only pages/media-package, pages/campaign and pages/chat. Add local
   presentation helpers as needed. Preserve existing service requests and hooks.
   Keep partner links; do not edit partner pages or shared navigation.
3. Catalogue: local search and availability filter; detail dialog; grouped form,
   pending/dirty-dismiss protection. Negotiation: reusable labelled term comparison,
   responsive old/new columns, approval summary and Campaign link.
4. Campaign: plan/read/review/delivery panels, snapshot context, structured version
   comparison, readable state/Task labels and existing deployment/completion actions.
5. Chat: header, connection notice, scroll area/day groups, message roles/timestamps,
   sending/error feedback and composer hint; keep realtime transport untouched.
6. Locale files: src/i18n/locales/{vi,en}/{mediaPackage,campaign,chat}.json. Preserve
   current partner keys and unrelated translations.
7. Run existing media-package and partner regression tests (no generated test-spec
   rewrite), type-check, lint and build. Use Playwright CLI for screenshots/flows
   against a local or isolated mock session, never seed or mutate shared data.
8. Verify git diff excludes shared UI/routes/services/hooks and existing unrelated
   edits. Document evidence and limitations in test.md/task.md.

Main risks: snapshot terms versus mutable catalogue, accidental loss of approvals,
dirty forms, long content/mobile overflow and accidentally widening role permissions.
UI work must not change any of those business rules.

## Correction plan — 2026-10-11

Milestone/work-item clarification: group all milestone controls in their own
section in CampaignForm, name the separate WorkItemsEditor section, and replace
the shared itemName key with milestoneName/workItemName in vi/en campaign.json.
Preserve independent add/remove handlers, timeline serialization and workItems.

1. Catalogue: use Input.iconPrefix rather than an external overlay; size the Select
   wrapper via wrapperClassName and allow toolbar wrapping. Keep result count nowrap.
2. Update Vietnamese approval copy in mediaPackage/campaign; keep English keys and
   add campaign.ui.editLocked to both vi/en.
3. Campaign page: prefer URL Workspace role from workspaceList; only fall back to
   currentWorkspace/currentMemberRole when its ID matches. Expose a disabled edit
   action and lock explanation for Manager non-draft plans; preserve existing APIs.
4. CLI fixture audit: Owner search/filter bounding boxes, responsive themes,
   Vietnamese approval labels, Manager draft edit/save and immutable-state lock;
   Client must still have no edit control. Run type-check/scoped lint/build.
5. With explicit user approval, transactionally restore the single identified draft's
   empty deliverable_plan from its own frozen snapshot. Require matching Workspace,
   DRAFT, no allocation period, matching approved v3 snapshot, 2 source deliverables
   and DELIVERABLE_BUNDLE model. Abort if target predicates no longer match.
   Advance only the internal row_version lock token to invalidate stale in-flight
   JPA writes; content_version remains 1. Normal updated_at trigger may run.
