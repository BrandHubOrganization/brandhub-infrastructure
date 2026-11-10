# Plan

Java runner package: paymentqa/runner. Use JDK HttpClient/HttpServer/ProcessHandle/ProcessBuilder, Jackson, JDBC, existing generated test config and single-source support helpers. No additional runtime language or browser dependency.

Maven exec:exec@payment-runner uses test classpath and target/payment cwd. Antrun creates this output during generate-test-resources; initial up command includes test-compile. Surefire payment-api profile has the same cwd. RunnerPaths resolves business-service from target/payment. Unit staging tests assert correct root and prohibit unrelated test/runner class leakage.

Start PostgreSQL/Redis/Mongo/Rabbit on fixed private ports, import isolated schema and synthetic5k plan, stage support-only jar, launch business/gateway. Do not launch Vite or require frontend repo. Preflight checks backend/DB only. PID creation identity, listener ancestry and Docker label JSON prevent cross-process/container cleanup. No .env reads.

LoadCases invokes Java BenchmarkRunner and AcidCases invokes Java StackRunner directly. Preserve workload loops, money/credit SQL oracles, opt-in load and TX dependency gates. Drop UiPrerequisites and qa.uiReport. Java monitor can inject an external metric sampler for deterministic cancellation/outage regression tests. Real monitor uses bounded HTTP/JDBC calls.

ReportRunner retains case outcomes and historical provenance, computes separate three-run medians and incomplete flags. Runtime/report/log files relocated only after stopping owned resources. Documentation is repository README and this feature's test.md; target outputs are disposable under clean.
