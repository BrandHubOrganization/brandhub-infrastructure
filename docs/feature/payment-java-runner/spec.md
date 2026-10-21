# Spec — Java payment API/ACID/Apache Bench runner

Use Java21 for payment QA orchestration and all12TX+12AB scenarios. Apache Bench remains the actual external binary invoked through ProcessBuilder, native or Docker. Selenium/browser/frontend/Python are not required or started. Optional historical SEL sources/reports are outside the active workflow. No product logic/schema changes or Git commit/push.

Java tests/runner belong under business-service/src/test/java; approved fixture manifest remains in src/test/resources/payment. Remove src/test/payment entirely. Generated config/keys/logs/reports belong in target/payment; mvn clean may remove them, so archive evidence before cleaning.

Default Maven test must not start API/load runners. Explicit payment-api profile enables isolated API scenarios; qa.load=true and same-run financial TX prerequisites additionally gate AB/race. Preserve every monetary SQL/API assertion, case ID, workload and threshold. No UI-proof gate.

Runner CLI supports up/down/restart_business/restart_postgres/preflight/probe/bench/report. Up refuses occupied QA ports. Down/restart require matching PID creation identity and Docker ownership, fail closed on verification failure, and never touch developer services. No project .env reads. App QA classpath stages only support classes, never all tests/runner/configurations. Production artifact contains no test code.

Observer checks business response identity/amount/schema beyond HTTP status. Monitor stops on excessive pool wait/locks/deadlocks/5xx, fails when unavailable during load, and waits for recovery. Intentional sampler cancellation after workload completion must not be misclassified as an outage. Reports preserve actual PASS/FAIL/BLOCKED/NOT RUN and provenance; suitePassed means all24 backend cases, while legacy releaseReady represents48-case scope.

Done: Maven/harness checks pass, relocated backend-only stack and affected real AB workloads pass, source folder stays absent, generated outputs preserved during relocation, owned stack cleaned, honest evidence recorded.
