# Plan

Install pinned torch CPU from its official index before application dependencies;
reuse constraints-cpu.txt during the second install to prevent GPU replacement.
Use a dedicated pip-cpu cache key without fallback to previous GPU caches.
Apply the same install order and CPU assertion in Docker; version its layer cache.

Add .github/workflows/ci.yml in the standalone ai-service repository.
Use independent lint and test jobs, then a Docker Buildx job needing both.
Use .python-version and pip caching; keep CI tools in requirements-ci.txt.
Upload pytest JUnit and coverage reports even on test failure.
Build the existing Dockerfile with push disabled and GitHub Actions layer cache.
Exclude local virtual environments and generated reports from Docker context.
Existing dependency or test failures must remain visible, not bypassed.
Remove the orphaned test_benchmark_runner.py: its runner was deleted in b8c7778
and its SDXL endpoint/client/dataset dependencies are also absent. Mark the old
SDXL setup guide as historical and remove its nonfunctional benchmark command.
