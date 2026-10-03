# Test - FR 3.5.1

| Case | Expected result |
|---|---|
| List templates | Only `is_template=true` records are returned. |
| Create Agency package | `is_template=false`, the path `agencyId`, optional `sourceTemplateId`, and default availability are persisted. |
| Invalid agency/non-permitted role | Request is rejected; no package is created. |
| Template constraint | A template cannot retain an `agencyId`. |
| Client package selection UI | Client can select an available same-Agency package; global templates, hidden packages, and cross-Agency packages are rejected. |
| Owner Agency management | Owner opens `/agency/{agencyId}/media-packages`, reloads persisted packages, reviews global templates, and controls availability. |
| Owner custom form | A valid standalone or template-derived package creates an Agency-scoped package; invalid values show inline errors. |
| Existing selection after hide | A selected package remains readable and negotiable after the Owner hides it from future selections. |
| Dashboard missing-package state | Client sees a selection action; Agency roles see a non-blocking informational message. |
| Role visibility | Workspace selection is Client-only; the Agency management route is Owner-only. |
| Responsive and theme | Cards/dialog remain usable at 375px, 768px, and 1440px in light and dark mode. |
| Language switch | Vietnamese and English render from parallel `mediaPackage` keys without layout breakage. |
