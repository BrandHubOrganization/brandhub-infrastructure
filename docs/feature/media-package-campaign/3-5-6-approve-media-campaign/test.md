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

Status: **not run** for the new implementation. Concurrent Campaign launches and
completion of non-Task-only Campaigns await BA decisions in the delivery plan.
