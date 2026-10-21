# Plan

1. Move shared helpers to src/test/java/com/brandhub/business/paymentqa/support. Separate API scenarios (webhook, lifecycle, access, ACID, race and load) under paymentqa; keep files under400 lines. Default disabled integration factory, explicit payment-api Surefire profile and working directory src/test/payment.
2. Move Python runner to src/test/payment/scripts, adjust workspace roots and create a support-only staging jar for the owned QA Business process. Do not put all test-classes on application classpath.
3. Selenium module adds the single backend support source directory via build-helper; only Browser and24 UI scenarios stay local. Delete active duplicate TX/AB implementations, preserve old reports and thin script shims.
4. Split load gates across suites: current-run backend TX outcomes plus immutable-source-matched Selenium report (required SEL IDs PASS). Reject stale/wrong-build/missing/UI-failed evidence. Preserve workload sizes/thresholds/monitor/SQL oracles.
5. Add regression for gate semantics before implementation; verify Java/Python compilation, default test safety, backend API without Selenium, Selenium smoke and gated real Apache Bench in owned stack. Update docs/commands and actual report scope.
