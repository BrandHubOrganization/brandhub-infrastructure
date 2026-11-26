# Creator Task Creation Policy — Plan

## Backend (`brandhub-business-service`)
- `CreatorTaskCreation` enum; `WorkspaceSettings.creatorTaskCreation` (JSON in `workspaces.settings`, no migration).
- `UpdateWorkspaceSettingsRequest.creatorTaskCreation` (PATCH `/workspaces/{id}/settings`, null keeps the value).
- `CreatorTaskCreationGate.requiresApproval(role, workspace)` used by `createTask` and `createStandaloneTask`.
- `TaskDocument.creationApproval` (state, requestedBy/At, decidedBy/At, note). The Mongo `tasks` validator allows extra fields, so no migration.
- `TaskWorkflowPolicy.lockReason` returns `TASK_CREATION_PENDING` while pending.
- `TaskCreationApprovalService` + `POST /workspaces/{ws}/tasks/{task}/creation-approval/{approve|reject}` (Owner/Manager).
- `TaskListItemResponse.creationApproval` for list badges.
- Error codes: `TASK_CREATION_PENDING`, `TASK_CREATION_NOT_PENDING`, `CREATOR_TASK_CREATION_DISABLED`.

## Web (`brandhub-web`)
- `useCreatorTaskPolicy` / `useCanCreateTask` in `postEditorHandoff.ts` replace the role-only create gates (calendar, content calendar, publish dashboard, tasks page, post-editor task picker).
- `QuickCreateTaskDialog`: APPROVAL mode shows a notice and a single "Send proposal" button and does not open the editor.
- `TaskCreationApprovalBanner` in Task detail (approve / reject with note); `CreationPendingBadge` in the table and board.
- `CreatorTaskCreationCard` on the Workspace detail page.
