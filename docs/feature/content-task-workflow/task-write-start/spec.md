# Write post starts the assigned task

## Objective / user story

Creator selects “Viết bài” once to start an assigned TODO POST task and enter
Editor, without a separate start confirmation or a second navigation click.
User confirmed this interaction on 2026-10-21.

## Acceptance criteria / UI states

- Assigned Creator + TODO: the explicit Write post click calls the existing Start
  API. Navigate to the linked Editor only after successful IN_PROGRESS response.
- Assigned Creator + IN_PROGRESS: open Editor directly; do not start again.
- Non-assignees/unassigned tasks do not gain write/start permission. Keep readonly
  navigation neutrally labeled. Review/final/cancelled states never restart.
- Both list and Task Detail use the same start action implementation.
- Pending: spinner and disabled button; synchronous duplicate-click guard.
- Failure: accessible inline error, remain on the current page, allow retry.
- Opening a URL alone does not start work. Preserve revision checking, required
  brief/deadline, campaign restrictions, and backend authorization.
- i18n: add parallel `tasks.workflow.writePost` in vi/en, update existing startHint
  to explain that Write post also explicitly starts a POST task; reuse existing
  `tasks.review.openEditor`, workflow errors/success.
- Light/dark: reuse Button and TaskWorkflowError semantic tokens; no new palette.

## API / errors / edge cases

Existing POST `/api/v1/workspaces/{workspaceId}/tasks/{taskId}/start` with
`expectedRevision`; existing workflow query supplies the revision. A failed
request must not navigate or locally fake IN_PROGRESS. Keep other task types'
Start work behavior. Double clicks must not duplicate the command.

## Definition of done / out of scope

Check API-before-navigation ordering, failure/retry, direct open, permissions,
keyboard, locales/themes, typecheck/lint. No migration, assignment change,
automatic start on page load, billing/AI call, publish or approval changes.
