# Admin payment history

User requests /admin invoice list/detail/receipt/provider -> forbidden. DB admin authorization required even direct service call. Admin lists agencies, filters UUID, views receipts iff verified. Owner cannot use admin or see another agency; cached UI role paths distinct. Verify admin menu, filters, details and regression history suite.

## Results — 2026-10-21
- Backend: 18 tests, zero failures/errors/skips: AdminInvoiceHistoryControllerTest 3, InvoiceHistoryControllerTest 4, InvoiceHistoryPostgresTest 4, InvoiceProviderServiceTest 2, SePayTransactionClientTest 5.
- PostgreSQL fixture uses actual billing table migration definitions; agencies.name projected. New test uses real AdminAccountService.requireAdmin with role repository reads backed by fixture PostgreSQL user_system_roles. Role revocation blocks subsequent service reads; owner path remains scoped.
- mvn -q -Duser.timezone=UTC -Dtest=InvoiceHistoryPostgresTest,InvoiceHistoryControllerTest,AdminInvoiceHistoryControllerTest,InvoiceProviderServiceTest,SePayTransactionClientTest test with BRANDHUB_HISTORY_ISOLATED_TEST=true and loopback history_test URL.
- 18 Playwright subscription tests passed: new admin history flow checks global list, agency filter, admin-specific detail/provider endpoints and sidebar link; 17 previous subscription/history tests pass unchanged.
- Typecheck, scoped ESLint and production build passed. Existing Vite chunk warnings remain. VI/EN admin and subscription key parity passed; git diff --check passed.
- No migrations and no application payment data updates. Temporary history verification database removed. No new real SePay requests/payments initiated for this task.
- API: GET /api/v1/admin/billing/invoices?agencyId=...; GET /api/v1/admin/billing/agencies/{agencyId}/invoices/{orderId}[ /receipt | /sepay-transactions ].
- Restart Business/Web in the existing runner to load changes; then Admin sidebar Payment history, /admin/invoices. Agency filter currently accepts exact UUID; no agency autocomplete API introduced.
