# Test - FR 3.5.6

| Case | Expected result |
|---|---|
| One approval | Campaign remains unapproved. |
| Both approvals | Campaign becomes deployable. |
| Deploy | One backlog task per work item with `campaignId`. |
| Retry/double deploy | Same task count and identities; no duplicates. |
| Partial Mongo failure | Retry completes remaining work safely. |
| Edit after one party approved | Version increments and both prior approvals become invalid. |
| Approve with stale version | Conflict; no approval granted to unseen content. |
| Same actor attempts to approve both sides | Cannot satisfy two-party consent. |
| Edit fully approved content | Rejected; operational progress remains separately updateable. |
| Service restart during deployment | Durable progress permits retry; no missing/duplicate tasks. |
| Retry after Creator edited a generated Task | Existing Task content/status/assignee remain intact. |
| Cross-Workspace ID substitution | Access denied; no approval, deployment or notification leakage. |
| Generated Post task opened in Content Writing | Resolves the same agreed Task identity and existing editor works. |
| Locale/theme/mobile | Approval, error and retry states render in vi/en and both themes. |
| Client feedback then Manager edit | Feedback does not directly change terms; Manager edit resets both approvals. |
| Complete without Manager action | No automatic completion solely from aggregate Task status. |
| Manager complete action | Authorization and actor/time recorded; child tasks are not implicitly completed. |
| Complete with unfinished Tasks | Blank reason rejected; valid reason completes Campaign without changing Task states. |
| Task continues after Campaign completed | Existing permissions/workflow still apply; Campaign completion does not implicitly lock Task. |
| Editor WebSocket SEND/SUBSCRIBE to foreign Task | Rejected despite valid login token. |
| Mongo unavailable while completing | Campaign stays IN_PROGRESS; no zero-task assumption. |
| Existing PostgreSQL Task before cutover | Migration aborts until ID/content has been reconciled. |

Stage 3 targeted service tests cover stale version, two-sided approval, feedback
without version change, edit reset, no-op edit and immutable approved content.
Stage 4 unit tests cover deterministic Task ID, insert-only retry, storage failure,
completion reason and missing Task detection. PostgreSQL migration passed locally
with preflight counts 0/0/0; Atlas `brandhub` preflight found no `tasks` collection.
The initial Mongo migration attempt was rejected by automatic approval review.
Migration and verification instructions were subsequently supplied to the user;
the resulting Atlas schema has not yet been independently verified. Authenticated
end-to-end deploy/editor tests remain pending.
See [phase-1 test matrix](../phase-1-design/test.md).

2026-10-10 review: full Business Service suite passed (416 passed, 31 skipped,
zero failures/errors); Web lint/type-check/production build passed. This review
did not run migrations or change live data. Approval UI and duplicate/deployment
flows still require authenticated browser/API verification beyond mocked draft tests.
