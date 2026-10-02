# Test - FR 3.5.8

| Case | Expected result |
|---|---|
| Valid Manager transition | State changes as specified. |
| Client transition | `403`. |
| First acceptance | Exactly one backlog task is created with `campaignId=null`. |
| Repeat acceptance | No second task is created. |
| Terminal state reopen | Rejected. |
