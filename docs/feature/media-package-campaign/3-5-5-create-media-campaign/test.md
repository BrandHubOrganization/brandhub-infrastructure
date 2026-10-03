# Test - FR 3.5.5

| Case | Expected result |
|---|---|
| Approved package | Campaign is created as `DRAFT`. |
| Unapproved package | `409 PACKAGE_NOT_APPROVED`. |
| Work items | Stable IDs and required task fields are validated. |
| Multiple campaigns | Allowed for one workspace. |
