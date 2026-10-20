# Verification cases

1. Package agreements for all negotiation states: campaign exists only for APPROVED, has matching terms/version and positive deliverable allocations, and starts DRAFT. Fresh seeded agreements contain nonempty offeringDetails.deliverables.
2. DataSeeder against PostgreSQL: a deferred FK violation appears only at commit; demo rows roll back and marker is failed. A normal run completes; rerun adds nothing. A concurrent second attempt cannot claim the same dataset.
3. Compact dataset with shuffled users: user59@demo.brandhub.test is CLIENT in both first workspaces; existing manager/owner fixture identities remain consistent.
4. Billing sample across the seeded 90-day range: no ACTIVE period has expired and elapsed periods are EXPIRED. Baseline plans remain read-only.
5. Full schema initialized in a throwaway PostgreSQL database: actual JPA seed succeeds, rerun skips, persisted counts/relationships/markers satisfy the above. No connection to the working database.

## Results — 2026-10-19

- Red-capable regressions observed before fixes: four campaigns instead of one approved agreement; core and admin deferred commit failures left running markers; reordered Client became MANAGER; all billing periods were ACTIVE.
- After fixes, 33 seed tests passed, including four non-skipped PostgreSQL 16 integration cases: fresh/rerun with edited plan/profile preservation, concurrent marker claim, core deferred commit rollback, admin deferred commit rollback preserving the core dataset.
- Full `mvn test` after review cleanup: BUILD SUCCESS at 2026-10-19 16:11 +07:00; 1,052 tests, 0 failures, 0 errors, 57 skipped. All four PostgreSQL integration cases executed without skips. Log: `brandhub-business-service/target/seed-integrity-full-test.log` (local verification artifact, not committed).
- The real init SQL passed both fresh application and reapplication after a plan-price edit. Each integration case used its own randomly named disposable database.
- Independent Standards review: method length and naming findings were corrected; final recheck found no introduced actionable violations. Spec review and recheck found no correctness gaps against the four acceptance criteria.
- Existing completed dataset version 2 remains unchanged; old running/failed markers still require inspection. No cleanup or migration of working databases was performed. MongoDB integration is outside this regression scope.
