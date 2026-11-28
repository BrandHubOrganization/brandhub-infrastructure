# Creator Task Creation Policy — Tests

## Automated
- `CreatorTaskCreationPolicyTest` (business-service): gate per role/policy; approve starts the Task and creates the draft post; reject cancels it with the note; Creator cannot decide; a decided proposal cannot be decided again.

## Manual (browser)
1. Owner sets the policy to **Not allowed** → log in as Creator: no "Create post" on the calendar, tasks page or publish dashboard; calling the API returns `CREATOR_TASK_CREATION_DISABLED`.
2. **Free** → Creator quick-creates a post → opens the editor right away (old behaviour).
3. **Needs approval** → Creator sees the notice and "Send proposal"; the Task shows the "Pending approval" badge; opening it shows the waiting banner, and Start/edit are locked.
4. Manager receives an inbox notification → opens the Task → Approve → status `IN_PROGRESS`, draft post exists, Creator is notified and can open the editor.
5. Another proposal → Reject with a reason → Task `CANCELLED`, Creator notified with the reason.
6. Owner and Manager can still create freely under every policy.
