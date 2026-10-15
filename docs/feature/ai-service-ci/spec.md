# AI service CI — DA-E10-03

Automate lint, unit tests and Docker build for brandhub-ai-service.
Current user scope supersedes the older master plan: no registry push or deployment;
Python follows .python-version (3.13), matching the Dockerfile, rather than 3.11.

Acceptance: run on pushes and pull requests to main/develop, and manual dispatch.
Flake8 checks application and unit-test code for syntax/undefined-name errors as an
initial baseline; style enforcement is deferred. Run all tests/unit with coverage.
Any failed check blocks Docker build. Cache pip and Docker layers. No secrets required.
Live integration/manual/model benchmarks are outside this CI scope.
UI and API contracts are unchanged. Completion requires a validated workflow;
a successful hosted run must be verified separately if local execution is unavailable.
