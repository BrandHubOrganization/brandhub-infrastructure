# DA-1013 tasks

- [x] 01 Host heartbeat ingestion, current ADMIN reads, resource agent and Servers tab.
- [x] 02 Collector heartbeat, locked result ingestion, HTTP adapter, health tab.
- [x] 03 Docker runtime adapter with source/error distinction (controlled runtime fixture).
- [x] 04 Authenticated PostgreSQL and Redis adapters (isolated databases).
- [x] 05 MongoDB and Neo4j adapters; nullable managed host (isolated databases).
- [ ] 06 Runtime-verified per-instance contracts: repo evidence documented; actual deployment/credentials still needed.
- [ ] 07 Actual read-only business/frontend targets: adapter implemented; operator endpoint and credential selection still needed.
- [x] 08 Filters, instance details, independent errors and revoked-access cleanup.
- [x] Update Vietnamese and English locale keys in parallel.
- [x] Check light/dark and mobile/tablet/desktop.
- [x] Operator packaging, provisioning and rollback instructions; isolated test evidence.
- [ ] 09 Complete real worker → API → ADMIN deployment smoke and outage/restart scenarios.
- [x] Standards/spec review and scoped fixes; required checks recorded with baseline failures.

Checked items above describe implementation and the explicitly stated test seam; they do not certify every deployment acceptance criterion of the corresponding source issue. See evidence.md for the remaining acceptance scope.
