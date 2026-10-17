> Checkpoint 2026-10-17: restored specification and historical verification for retained Media Package/Campaign UI. Task UI changes described as rolled back remain out of this UX scope. API/classification changes after this checkpoint are governed by the Media Package package-simplification spec; historical fixture test results are not a new verification run.

# Campaign and task usability

> Scope update: the user requested rollback of all UI changes outside Media Package and Media Campaign. The Task criteria below are historical and no longer describe the active implementation. The four changed Task source files and two Task locale files were restored to their pre-session HEAD; the newly added WorkspaceTaskView.tsx was removed. Campaign improvements remain.

## Objective and user story
Managers and clients need to understand the next campaign step. Task users need to find and open work without misleading controls or excessive loading.

## Acceptance criteria
- Preserve BrandHub's existing typography, theme tokens, orange CTA, spacing and shared UI components. Support light/dark themes; add no palette or dependencies.
- Campaign prerequisites include a link to the workspace media package. Existing campaigns show contextual guidance and links to plan/review/delivery sections and tasks. Do not change approval, deployment or role rules.
- Task search waits 300 ms after typing; Enter submits immediately. Reset clears search and filters even when there are no results. Request sequencing still prevents stale results.
- Task titles and sorting are keyboard accessible. Remove selection controls with no bulk action and dropdown affordances on read-only status badges.
- Task view is preserved in the URL, retaining the selected task parameter.
- Empty tasks explain their source; campaign links appear only for roles allowed to access campaigns.
- All new strings use `campaign.ux.*` and `tasks.ux.*`, added in parallel to `src/i18n/locales/{vi,en}/{campaign,tasks}.json`.

## UI states and errors
Loading and failure must not show campaign guidance based on an assumed draft. Preserve retry, unsaved task guards, campaign discard confirmation, loading feedback and API errors. Empty and filtered-empty task states have distinct recovery actions.

## API contract and scope
Existing APIs and role checks remain authoritative. No backend/schema changes, automatic approval/deployment, mobile changes or redesign.

## Definition of done
Type check, build, lint changed files, existing relevant checks and browser checks with controlled fixtures; record actual validation and limits in test.md.
