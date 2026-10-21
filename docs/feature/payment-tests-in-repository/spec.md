# Spec — payment tests in the business repository

Move API/PostgreSQL TX-01..12 and Apache Bench AB-01..12 into brandhub-business-service. Selenium SEL-01..24 stays in qa/payment. This is test organization/integration, not a payment policy change; preserve existing monetary assertions and historical evidence. Existing in-repo Testcontainers regressions remain.

Maven default test must not send load/restart shared services. Explicit payment-api profile runs isolated API scenarios; load additionally requires qa.load=true, passing TX dependencies, and passing required Selenium smoke from the same owned stack/build. No bypass flag. Backend API compilation must not require Selenium dependencies. Shared Java fixtures/oracles have a single physical source under backend test support, also compiled by the Selenium module.

Apache Bench Python runner, safety monitors and stack lifecycle belong under backend src/test/payment. Runtime secrets/reports are ignored. Keep old reports and compatibility entry points readable, ownership checks, exact loopback/database allowlists and test-only provider/snapshot hooks. No test support enters the production artifact/classpath; QA launcher stages only support classes, never all test classes. No git commit/push.
