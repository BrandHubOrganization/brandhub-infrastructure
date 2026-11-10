# Test plan and current commands

Approved active seams: API + actual isolated PostgreSQL, real Apache Bench with private Java observer. No Selenium/UI/browser gate.

Checks: reject foreign/external billing targets and malformed/foreign-agency/money responses; transport statistics distinguish expected401 from success; median requires3independent repeats and excludes warmups. Ownership rejects reused PID/foreign listener/container. Staging excludes test/runner classes. Resource manifest is portable without sibling research repo. Default Maven does not trigger API/load; qa.load=false and missing same-run TX prerequisites remain BLOCKED.

Monitor shutdown regression: a controlled external sampler throws SQLException when interrupted during deliberate stop. RED reproduced1failure, then GREEN must show no false unavailable stop reason. A real sampler outage during active load still fails closed. Do not relax monetary or performance thresholds.

Relocation: target/payment resolves to business-service, Maven prepares it before runner/tests, src/test/payment stays absent, fixture resources remain readable. Existing runtime/reports/logs preserved. Fresh stack owns only business/gateway processes; preflight and actual API/AB execute without qa.uiReport/frontend. Down removes only owned resources.

## Commands from business-service

```powershell
mvn test '-Dtest=MonitorShutdownTest,RunnerContractTest,RunnerStatisticsTest,RunnerReportTest,RunnerStackTest,PaymentCaseRegistryTest,SafetyTest,ReportTest,RedactorTest'
mvn test-compile exec:exec@payment-runner '-Dqa.action=up'
mvn exec:exec@payment-runner '-Dqa.action=preflight'
mvn exec:exec@payment-runner '-Dqa.action=probe'
mvn -Ppayment-api test '-DrunId=api-local'
mvn -Ppayment-api test '-Dcases=ALL' '-Dqa.load=true' '-DrunId=api-load-all'
mvn exec:exec@payment-runner '-Dqa.action=report' '-Dqa.input=reports/api-load-all/summary.json'
mvn exec:exec@payment-runner '-Dqa.action=down'
```

CLI inputs are relative to target/payment. Archive reports before mvn clean. BUILD SUCCESS may include skipped/BLOCKED cases; inspect actual summary. Existing48-case historical evidence remains unchanged; scope api requires24cases for suitePassed and does not imply full48 releaseReady.

## Verification

Before relocation: default1109registered/1035executedPASS/74gatedskips; harness15PASS; Java stack/preflight/20request probe PASS. Real full24 backend run:23PASS/1FAIL (AB-03 sampler-unavailable during teardown). Preserve original report in target/payment/reports/java-runner-api-load; do not rewrite failed history.

After removing UI gate and relocating: verification in progress; see target/payment runtime logs and fresh reports. Source folder absence confirmed.

Final verification:
- src/test/payment absent after test/package; generated evidence retained under target/payment. Classpath fixture retained in src/test/resources.
- Harness15PASS, including deterministic shutdown-cancellation regression and genuine monitor-outage rejection.
- Fresh backend-only stack/preflight PASS, no frontend/Selenium/UI proof. Selected13API/ACID/AB cases PASS: TX02/03/04/05/09/01/07/11/10, AB03/06/11, TX06. AB03 passed all unchanged9profiles plus warmup.11unselected cases remain NOT RUN in that summary; this is not a fresh full24 run.
- Default backend1109registered,1035executedPASS,74gatedskips; package BUILD SUCCESS. Owned QA stack down completed, Docker QA list empty. No Git commit/push.
- Earlier full24run23PASS/1FAIL is preserved. The sampler shutdown defect it exposed is covered by RED/GREEN regression and the fresh affected-workload pass; old failed evidence is not overwritten.
- Stop QA with down before mvn clean, and archive desired reports first: target contains generated ownership/configuration/evidence.
