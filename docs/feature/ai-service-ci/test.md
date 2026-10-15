# Verification

- Parse YAML; confirm push/PR main/develop and manual triggers.
- Confirm Docker needs both lint/test; no continue-on-error or registry push.
- Run Flake8 on app and tests/unit; errors must fail the job.
- Run all unit tests with coverage/JUnit; failures must fail the job.
- Build existing Dockerfile on Linux; confirm pip/layer cache configuration.
- Confirm reports upload on test failure and no production credentials are used.

Execution results (2026-10-15):

- PASS: YAML parsed with PyYAML; triggers and Docker dependencies asserted.
- PASS: python -m flake8 app tests/unit with the committed correctness baseline.
- FAIL (existing source issue): unit collection cannot import
  scripts.run_commercial_benchmark from tests/unit/test_benchmark_runner.py.
  The referenced module is absent. No tests were bypassed in the workflow.
- Local unit verification disabled dotenv loading to avoid developer credentials,
  used offline model flags, and emitted JUnit/coverage reports.
- NOT VERIFIED: Docker build; sandbox cannot access the local Docker daemon.
- NOT VERIFIED: fresh Linux dependency install and hosted GitHub Actions execution.

References: https://github.com/actions/setup-python and
https://github.com/docker/build-push-action for pip and Buildx cache inputs.
