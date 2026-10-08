# Local Media Package demo data

> **Superseded isolated-fixture workflow:** use the existing feature-test accounts
> on the login page. The user withdrew creation of `offering.*@example.test`
> accounts, Agencies and Workspaces. Do not execute the historical commands below.

## Current demo workflow (2026-10-08)

- Use `docs/database/seeds/2026-10-07-refresh-admin-media-templates.sql` only for an
  explicit local catalogue refresh. It updates ten known Admin template IDs in place;
  it does not insert accounts/packages or change Workspace negotiation snapshots.
- These IDs are specific to the original local database. Other databases may update
  zero rows. Inspect the target rows and preserve local catalogue edits before running:
  the script intentionally overwrites the matching template fields.
- Apply the offering-model and proposal migrations first. Do not rerun the full
  application seed or use this data refresh on shared/production databases.
- Existing Owner: view/copy a template in the Agency catalogue. Existing Client:
  select the Agency package in their Workspace, propose changes and inspect the diff.
  Existing Manager: check notification and approve the same terms with the Client.
- Check the Client-only proposal counter and approval reset on changes.
- The Campaign draft panel is an earlier allocation prototype, pending adaptation
  to one approved agreement/one Campaign. It is not the completed Campaign feature.
- No database write is performed as part of the 2026-10-08 commit checkpoint.

## Historical isolated fixtures (withdrawn; do not run)

Do not run this seed on production/shared staging. The script uses fixed IDs and a transaction;
reruns do not overwrite passwords, negotiated terms or test actions. Any error rolls back all inserts.

## Run after starting PostgreSQL

From `brandhub-infrastructure`, PowerShell:

```powershell
Get-Content -Raw docs/database/migrations/2026-10-06-media-package-offering-model.sql |
  docker exec -i brandhub-postgres psql -v ON_ERROR_STOP=1 -U brandhub -d brandhub

# Choose a local test-only password; never reuse a real password.
Get-Content -Raw docs/database/seeds/2026-10-06-media-package-offering-demo.sql |
  docker exec -i brandhub-postgres psql -v ON_ERROR_STOP=1 -v demo_password=YOUR_LOCAL_TEST_PASSWORD -U brandhub -d brandhub
```

Restart Business Service with the new code after applying migration; run the current Web branch.
Gateway already forwards `/api/v1/**`, so this slice needs no gateway routing change.

## Accounts

| Account | Purpose |
|---|---|
| offering.owner@example.test | Owns the test Agency; creates/hides catalogue packages |
| offering.manager@example.test | Active Manager of four test Workspaces; negotiates and creates drafts |
| offering.client@example.test | ClientProfile member of four test Workspaces; selects and approves |

Password is the `demo_password` supplied on the first successful seed. Rerunning does not reset it.
Agency ID: `e5000000-0000-4000-8000-000000000010`.

| Workspace ID suffix | State and scenario |
|---|---|
| 000000000101 | No selection: Client chooses package; both parties negotiate/approve |
| 000000000102 | Approved CAMPAIGN: suggest all quantities in one draft |
| 000000000103 | Approved RETAINER: compare different months, no rollover |
| 000000000104 | Approved BUNDLE: split quantities across drafts; reject over-allocation |

Workspace IDs share prefix `e5000000-0000-4000-8000-`.
Open `/workspaces/{id}/media-package` for the negotiation and Campaign draft panel.
Approved fixtures are explicitly test-only; real users must approve through the API/UI.
No Campaign or Task is pre-generated; users create drafts themselves.

## Safety and outstanding validation

Before implementation, local DB contained 13 packages, 115 campaigns and 155 workspaces.
The additive migration was applied successfully. Initial seed attempts rolled back on membership
constraints; the script was corrected to use one Manager per Workspace, Client via profile and
Owner at Agency level. The corrected seed still needs execution/verification when Docker is running.
Existing business rows and specialist modules are not modified by the seed.
