# Cases

Regression: a single click opens the menu before network completes, Creator selection saves/closes and refreshes row/detail. Test assignment inside the actual Task Detail Dialog. Missing brief/deadline must show a reason in-menu; locked tasks stay readonly. No backend permissions weakened.

Follow-up acceptance: click the assignee once, wait for authorized options and verify the listbox opens without another click. Escape/outside click must not send assign. Detail and unrelated SelectMenu controls stay initially closed. Loading/error/locked/empty states must never open a list of unauthorized choices.

## Verification 2026-10-17

- Persistent dropdown correction: isolated Playwright browser/API mocks verified one-click opening in list and actual Task Detail Dialog, selecting Lan in detail, changing to Minh in list, auto-save/close and synchronized assignee display. Mock assign checks expectedRevision on each write. Escape closes without selection; console errors 0. Focused ESLint passed. No live data writes. User confirmed changes visible.

- One-click follow-up: ESLint passed for SelectMenu, InlineTaskField and TaskInlineAssignment; diff whitespace check passed. Browser interaction remains unverified.

- Backend: TaskWorkflowServiceTest (37), TaskWorkflowMembersTest (2), TaskWorkflowControllerTest (4): 43 passed, no failures/errors.
- ESLint: TaskTable, TaskRowActions, TaskInlineAssignment, InlineTaskField passed.
- git diff --check passed.
- Whole-Web type-check blocked by existing errors in Content Writing, editor, Workspace dashboard and AppRoutes; no errors reported in the assignment components. Those unrelated files were not changed for this task.
- Browser interaction/live assignment not verified; no live data writes or schema changes performed. Cases below remain the manual acceptance checklist.

Manager opens assignee cell without opening detail; workflow/options load lazily. Active same-Workspace Creator appears; inactive/non-Creator excluded. Detail shows selector without extra edit step. Selection saves assigneeId/requiresClientApproval/expectedRevision, not QC; list/detail update. TODO remains TODO; Creator explicit Start locks subsequent assignment. Missing brief/deadline/legacy start evidence/completed Campaign/other role blocks assignment. No selectable unassign entry for an assigned Task. Missing Creators and option request failure have clear feedback/retry. Save failure retains selection; retry/discard guards unchanged. Test keyboard, dialog selector portal and narrow table viewport; no writes against live data.
