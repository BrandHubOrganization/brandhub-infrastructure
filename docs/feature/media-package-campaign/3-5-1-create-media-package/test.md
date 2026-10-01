# Test - FR 3.5.1

| Case | Expected result |
|---|---|
| List templates | Only `is_template=true` records are returned. |
| Create custom package | `is_template=false` and the requested existing `agencyId` are persisted. |
| Invalid agency/non-permitted role | Request is rejected; no package is created. |
| Template constraint | A template cannot retain an `agencyId`. |
