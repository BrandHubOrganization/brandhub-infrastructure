# Tasks

- [x] Auth tests RED, manager and callers GREEN.
- [x] Runtime installation, persistent-volume ownership, compose/deploy integration.
- [x] Session check and restart/recreate verification procedure.
- [x] Tests/lint/CLI-runtime build and evidence; document remaining live verification blocker.
- [ ] Deploy updated full AI-service image and bootstrap real provider sessions on EC2.
- [ ] Run authenticated lifecycle verification on EC2 after bootstrap.

Ruling: preserve current image streaming transport; supported CLI owns refresh only. User approved CLI-managed refresh, not replacement of the image workflow.
Discovery: production compose already declares agy profile, keyring and Codex volumes. Docker local has no AI-service image/container. graf-memory tools unavailable.

Review fixes: limit permission changes to volume roots and auth.json; preserve executable/runtime entries; support anonymous/short mount syntax; move compose migration into rollback-protected condition.
Build discovery: agy installer rejects the old --skip-path flag, previously swallowed by || true. Use --dir and fail build if agy is missing.
Container discovery: empty stdin does not create a usable login collection. Feed a newline to gnome-keyring-daemon --unlock; real Secret Service storage survives restart/recreate in the isolated test.
