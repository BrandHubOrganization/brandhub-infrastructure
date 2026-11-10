# DA-1013 acceptance tests

Agreed seams are monitoring HTTP API with isolated persistence, collector adapters with controlled fixtures, and one Playwright ADMIN flow. Tests must not require production credentials.

- API: missing JWT 401, non-ADMIN 403, revoked ADMIN 403, machine token cannot read; invalid machine token cannot update.
- Host: initial NO_DATA, nullable readings, exact 60 seconds ONLINE, >60 OFFLINE, recovery, invalid/missing fields rejected.
- Health: target exists before samples; PASS/FAIL/ERROR; exact 90 seconds fresh, >90 UNKNOWN; collector age independent; old/conflicting sample 409; duplicates do not change receipt time; ownership 403; database unavailability 503; no secrets in response.
- Adapters: HTTP wrong body/status, auth failure, timeout, redirect refusal, 64 KiB limit; runtime missing/unhealthy/no-healthcheck; authenticated database query vs auth failure. Scheduler does not block heartbeat or overlap probes.
- UI: separate tables, filter, details, stale and null states; one API failure retains old snapshot, 401/403 clears all protected state; polling stops on unmount; vi/en keys and light/dark at 375/768/1440.
- Deployment: isolated smoke only. Record actual commands/results and missing dependencies. Never infer runtime success from a fixture or static check.
