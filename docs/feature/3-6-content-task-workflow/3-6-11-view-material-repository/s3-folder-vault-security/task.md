# Implementation tasks — repository S3/folders/vault/security

Execution: Native (Inline), 2026-11-04. Source: plan.md and spec.md in this directory; original references under root docs/superpowers. Existing plan tests define the authorized seams: access policy, quota service, folder browser/mutations, upload/version service, Drive import, vault sharing, REST boundary and web build. Work on one failing behavior at a time.

- [x] 1. Remove system-admin/support authorization; preserve valid operational membership and Agency ownership. Test outsider/admin denial before any signing. Configure KMS signing/writes and validate existing Terraform stack. No AWS apply.
- [x] 2. Route new reservations exclusively to S3, free 5 GiB, disable Drive polling; migrate agency/client quota and paid storage add-ons using existing billing/verified payment flow.
- [x] 3. Add folder scope, tree mutations, cycle/depth checks, recursive trash/restore, Vietnamese sort and tiered browser.
- [x] 4. Add duplicate decisions and verified SHA-256; archive/restore/delete versions with idempotent quota accounting and concurrency safety.
- [x] 5. One-time Drive folder import using bounded streaming, file validation, quota and durable authorized job status. Tokens stay transient/redacted.
- [x] 6. Personal Client vault quota/ownership; explicit zero-copy workspace shares; scope every read/sign/mutation; legacy migration with reviewable reconciliation.
- [x] 7. Integrate web folder/file sections, sort, duplicate/version UI, import, vault/share and add-on checkout. Update vi/en materials locale keys together; verify both themes, keyboard and responsive UI.
- [x] 8. Run backend regression checks, web npm run ci, Terraform fmt/validate; record live-cloud and migration verification separately. Mark only actually passed checks.

Implementation corrections: spec is authoritative over illustrative plan snippets. Default ASK applies even without client hash. Compute/verify content hash server-side. Client ownership is determined by workspace membership, not visibility alone. Sort names by Vietnamese sort_key, not normalized_name alone. No automatic billing activation from unverified checkout. No guarantee against cloud administrators who can alter policy/assume runtime role; document the trust boundary and protect administration separately. Code generation of infrastructure is authorized; cloud apply and live data migration remain separate operational steps.


## Correction — legacy Drive connection retirement
- [x] Remove all legacy dashboard/connect/reconnect/disconnect UI and callback.
- [x] Return 410 for legacy storage connection endpoints without invoking destructive cleanup.
- [x] Verify live dashboard and retirement endpoints; retain one-time import.
