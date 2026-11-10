# Admin payment history

Extend history projection with guarded admin methods reusing private SQL readers. AdminAccountService.requireAdmin verifies current DB role. Add AdminInvoiceHistoryController and admin provider entry. Reuse UI table/detail via explicit admin mode and distinct query keys and API paths. Admin page has agency UUID filter resetting cursors/detail. No schema migration.
