# DA-1013 implementation plan

Implement the accepted nine issues from `tuan-research/.scratch/brandhub-system-health/issues`.

1. Business: JPA models matching monitoring SQL, bounded repositories, machine credential verification, transactional ingestion with target locks, current ADMIN authorization, safe read DTOs and clock-based freshness. Public seams: POST ingestion then GET admin, using isolated PostgreSQL and controlled time.
2. Gateway: exact POST machine routes without JWT filter, GET admin routes with JWT. Backend remains authoritative for machine credentials and ADMIN role. Document public paths.
3. Infrastructure: independent host heartbeat and probe scheduler, allowlisted configuration, read-only HTTP/Docker/database adapters, bounded response/time/concurrency, no backlog. Provision through operator tooling, not public registration. Test adapters through fixtures.
4. Web: lazy system-health feature, shared API service, typed snapshots, separate polling/error state, auth failures clear both snapshots. Add locales/vi/monitoring.json and locales/en/monitoring.json and register them in i18n/index.ts. Use semantic UI primitives.
5. Validate Maven builds/tests, worker tests, TypeScript/build and Playwright admin flow including themes/viewports. Review standards and spec separately, then commit each repo with DA-1013. Keep pre-existing unrelated edits out of commits.

Existing branches are retained as requested by implement skill; baseline commits: business 7470469, gateway acd76c2, web 92d3016, infrastructure 06d1ffa. No production probes or database writes. Missing runtime/credential evidence remains explicitly unverified.
