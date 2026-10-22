# Verification

CPU dependency regression: resolve the pinned CPython 3.13 Linux CPU wheel and
check its metadata has no CUDA/NVIDIA/Triton requirements. CI and Docker must
assert torch.version.cuda is None after installing the application dependencies.
Confirm pip cache has a CPU-specific key and no fallback to GPU caches.

CPU fix results: pip dry-run resolved torch 2.14.1+cpu for cp313 /
manylinux_2_28_x86_64 from the official CPU index. Its metadata has no
NVIDIA/CUDA/Triton requirements. YAML assertions passed for cache isolation,
install order and Docker job gates; git diff --check passed.
This validates the selected wheel, not the complete fresh Linux installation.
Hosted install/tests and Docker build remain to be verified on GitHub Actions.
CPU installation reference: https://pytorch.org/get-started/locally/.

Regression: full tests/unit collection must no longer import the removed SDXL
benchmark runner. Run the remaining unit suite without ignore/skip additions.

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

Follow-up fix verification:

- Confirmed runner deletion in b8c7778 and absence of its SDXL endpoint/client/
  dataset dependencies. Removed only the orphaned benchmark test module and
  marked the SDXL setup guide historical, removing the invalid CLI instruction.
- PASS: full remaining tests/unit suite: 787 passed, 1 existing skip,
  91 warnings, 47.99 seconds on Python 3.13.13 (Windows).
- PASS: Flake8 app tests/unit. No workflow exclusions or new skips added.
- Local verification disabled dotenv loading and used the CI offline flags;
  coverage and JUnit reports were generated. Hosted Linux rerun remains pending.
