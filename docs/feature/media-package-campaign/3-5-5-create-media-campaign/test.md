# Test - FR 3.5.5

| Case | Expected result |
|---|---|
| Approved package | Campaign is created as `DRAFT`. |
| Unapproved package | `409 PACKAGE_NOT_APPROVED`. |
| Work items | Stable IDs and required task fields are validated. |
| Duplicate campaign / concurrent creates | At most one Campaign exists for an agreement, including DRAFT. |
| Multiple rounds | Different approved agreements can each have one Campaign in the same Workspace. |
| Next-round negotiation | Existing Campaign/Task/chat access is retained; old agreement unchanged. |
| New agreement from the same catalogue package | New ID, own snapshot/counter/approvals; no reused approval. |
| Stale draft update | Conflict; current version and approvals are not overwritten. |
| Existing duplicate Campaigns before migration | Report specific conflicting IDs; do not delete or relink history automatically. |
| Locale/theme/mobile | vi/en, light/dark and narrow layouts remain usable. |

New lifecycle tests: **not run**; implementation has not started. RETAINER boundary,
service-to-work-item and cancellation cases require the decisions listed in the delivery plan.
