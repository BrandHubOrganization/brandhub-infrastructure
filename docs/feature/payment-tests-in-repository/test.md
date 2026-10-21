# Test plan

Seams remain approved API + actual isolated PostgreSQL, browser UI and real Apache Bench with private observer. No new public product seam.

- UI proof accepts required PASS cases only when metadata source matches the active stack/build; missing/failed/NOT RUN/wrong-source evidence blocks load.
- Registry:24 SEL +12 TX +12 AB, disjoint and matches canonical spec. API code has no Browser/Selenium imports; backend dependency tree contains no Selenium.
- Default backend mvn test does not start API/load runners. Explicit profile initializes only isolated allowlisted runtime. qa.load=false never emits AB or TX06 race traffic.
- Shared source compiled in both modules, no duplicate mutable fixture implementations. Provider initializer present only in staged QA support jar, not production jar or other test configurations.
- Python safety/response-contract/identity/aggregation regressions pass after root change; old report paths readable.
- Actual Selenium smoke then backend transactions and representative read/mutation AB via new commands; preserve thresholds and SQL assertions. Invalid/missing preconditions BLOCKED rather than false PASS.
- Record actual commands/statuses; historical reports retained. Cleanup only owned stack, no commit/push.

Results (migration verification in progress):
- Default backend:1103 registered,1029 executed PASS,74 gated skips; BUILD SUCCESS.
- Selenium selected11 cases PASS; independent registry test PASS (12 JUnit executions).
- Production application JAR:0 paymentqa/testcontainers/Selenium leakage. Staged support jar:20 support entries,0 unrelated test classes.
- Read-only Standards review found sibling research-file dependency in registry test; replaced with approved classpath manifest sourced from canonical48-case spec. Spec review found no lost assertions/workloads/thresholds.
- Full migrated backend TX/AB:24 PASS, suitePassed=true, releaseReady=false. Owned stack cleaned. Portable manifest verified. Runner is subsequently replaced by Java; see payment-java-runner feature for current tooling/evidence.

