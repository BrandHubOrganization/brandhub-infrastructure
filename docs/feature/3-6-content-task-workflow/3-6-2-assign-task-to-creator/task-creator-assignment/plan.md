# Plan

Correction: TaskAssigneePicker owns the persistent dropdown and lazy workflow/member reads, reuses revision-guarded assign and draft feedback. TaskRowActions delegates assignee only; TaskInlineAssignment uses the same picker for detail. Remove the defaultOpen workaround from shared SelectMenu. Other row actions and modules unchanged.

Follow-up: add opt-in defaultOpen passthrough to SelectMenu and InlineTaskField. Only the list's TaskInlineAssignment opts in, so the dropdown opens when its authorized options become available; no effects or simulated clicks. Other SelectMenu consumers retain existing behavior.

Wire TaskRowActions(field=assignee) into TaskTable's assignee cell. Reuse backend role/allowedActions checks and lazy workflow load; no per-row eager member fetch. Add alwaysEditing mode to the Task-only InlineTaskField, use it for TaskInlineAssignment; omit empty option once assigned. Add no-Creator and member-query retry feedback. Keep same TaskEditSession/QueryClient and assignment contract. Verify render/interaction tests and existing focused Backend assignment tests; no Content Writing/editor changes.
