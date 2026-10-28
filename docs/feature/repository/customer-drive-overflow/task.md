# Tasks
- [x] Record Drive-first, paid S3 overflow requirements before code.
- [x] Stage schema and disabled-by-default configuration gates.
- [x] Implement OAuth connection, folder provisioning and private object adapter.
- [x] Implement account-wide atomic reservations and separated S3 accounting.
- [x] Add Owner/Manager repository access and sharing; restrict Creator audience changes.
- [x] Add storage UI and parallel vi/en translations.
- [x] Verify light/dark, keyboard, narrow layout and error recovery.
- [x] Run focused/full verification and review both axes; resolve high-impact findings.
- [x] User explicitly requested keeping all changes uncommitted for later consolidation. Do not stage or commit this work.

No live migration, OAuth account connection, feature activation or object migration was performed.

2026-10-27 local activation: user-supplied OAuth config, backed-up additive schema, persistent encryption key and user-performed Business restart completed. Connect button verified enabled. Write/purge gates and inventory verification remain unchanged; no Google consent submitted by the agent. See ../agency-storage-onboarding/test.md.

- [x] 2026-10-27: Replace non-destructive disconnect with confirmed destructive cleanup and account switching; implementation/verification in ../../customer-drive-disconnect/.

- [x] Use workspace names for new folders and rename old mapped folders in place; verify API rename and integration identity.
