# Test - FR 3.5.3

| Case | Expected result |
|---|---|
| Client request change | New immutable event; status becomes client-requested-change. |
| Agency counter-offer | New immutable event; status becomes agency-countered. |
| Multiple rounds | Earlier events remain readable in order. |
| Terms-changing event | Version increments and both prior approvals become invalid. |
| Replace package after first event | Rejected. |
| Approved package change | Rejected. |
