# Plan

Add .github/workflows/ci.yml in the standalone ai-service repository.
Use independent lint and test jobs, then a Docker Buildx job needing both.
Use .python-version and pip caching; keep CI tools in requirements-ci.txt.
Upload pytest JUnit and coverage reports even on test failure.
Build the existing Dockerfile with push disabled and GitHub Actions layer cache.
Exclude local virtual environments and generated reports from Docker context.
Existing dependency or test failures must remain visible, not bypassed.
