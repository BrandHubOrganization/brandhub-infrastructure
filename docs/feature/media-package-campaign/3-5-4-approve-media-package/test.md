# Test - FR 3.5.4

| Case | Expected result |
|---|---|
| Agency approves first | Agency timestamp only; package remains non-approved. |
| Client approves same version | Both timestamps exist; status becomes `APPROVED`. |
| Terms changed after approval | Both prior approvals are invalid for the new version. |
| Duplicate approve | Idempotent response, no invalid transition. |
| Missing version | HTTP 400, no approval |
| Old version after counter-offer / DRAFT switch | 409, cannot approve newer/different terms |
| Repeat same-side approval before the other side | Original timestamp unchanged |
| Retry old version after APPROVED | 409 rather than silently approving different terms |

Phase-5 unit/HTTP/isolated DB and browser evidence lives in
[FR 3.5.3 test evidence](../3-5-3-request-media-package/test.md). Live JWT/Gateway
two-party approval after operator migration is still pending, not Jira Done.
