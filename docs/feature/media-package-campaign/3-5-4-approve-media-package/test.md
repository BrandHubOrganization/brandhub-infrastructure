# Test - FR 3.5.4

| Case | Expected result |
|---|---|
| Agency approves first | Agency timestamp only; package remains non-approved. |
| Client approves same version | Both timestamps exist; status becomes `APPROVED`. |
| Terms changed after approval | Both prior approvals are invalid for the new version. |
| Duplicate approve | Idempotent response, no invalid transition. |
