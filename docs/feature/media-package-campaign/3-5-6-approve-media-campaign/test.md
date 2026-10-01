# Test - FR 3.5.6

| Case | Expected result |
|---|---|
| One approval | Campaign remains unapproved. |
| Both approvals | Campaign becomes deployable. |
| Deploy | One backlog task per work item with `campaignId`. |
| Retry/double deploy | Same task count and identities; no duplicates. |
| Partial Mongo failure | Retry completes remaining work safely. |
