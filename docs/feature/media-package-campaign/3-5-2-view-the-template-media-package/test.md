# Test - FR 3.5.2

| Case | Expected result |
|---|---|
| Selected package read | Package, effective terms, and negotiation status are returned. |
| No selection | Documented no-selection response is returned. |
| Available catalogue | Only visible packages from the Workspace's Agency are returned; global templates are excluded. |
| Dashboard prompt | A Client without a selected package can navigate from the dashboard prompt to selection. |
| Non-member access | `403` and no data leakage. |
| Package types | Duration, budget, and full-delegation values map correctly. |
| Loading/error/retry | Skeleton is shown while loading; non-404 errors expose a retry action. |
| Effective terms | Terms version, negotiation status, and both approval states render correctly. |
| Language/theme | Vietnamese/English and light/dark modes preserve content and contrast. |
