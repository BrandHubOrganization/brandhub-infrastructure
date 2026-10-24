# Tests

Agora: absent/malformed credentials return not-configured, certificate never leaves
Backend; no token for RINGING/terminal/expired calls, wrong workspace or outsider.
Both current DM memberships rechecked. Derived channel and UID cannot be supplied
by client. Cache-Control no-store. No live token printed or committed. Renewal must
revalidate acceptance, membership and call lease. Free tier is provider-configured,
not enforced by the SDK; no paid proxy/recording invocation during tests.

Schema: default DRY_RUN writes nothing, repeat APPLY idempotent; invalid documents,
duplicate live participants, conflicting keys/options block before writes. Init and
migration validators/indexes equal. Two concurrent inserts sharing either participant
conflict; terminal history records may share participantIds. No historical backfill.

Lifecycle: caller/callee permissions, wrong Workspace, non-DM, archived DM, self-call,
idempotent create, concurrent accept/decline/cancel, expired ring, stale revision,
busy across Workspaces and cleanup after crash. No ACTIVE until actual media connects.

Signaling/UI: unauthorized subscribe/send/recipient, membership revoked, tab races,
Agora connection/token renewal errors, oversized payload, DND/mute retains inbox/no ring,
mic denied, autoplay restriction, network loss and reconnect, local tracks stopped
on every terminal path. Logout must end local media. vi/en, keyboard and 375/768/1440
light/dark. No paid AI/publish operations. Harnesses remain ignored keep-local-only.

Infrastructure: test Agora audio between two different networks, HTTPS/WSS,
credential expiry and firewall. Never claim same-machine fake-audio tests prove
real cross-network media quality.

## Executed checks (2026-10-23)

- Business compile passed. Existing tracked ChatChannelInterceptorTest extended
  with token/participant/state/CAS checks: 26 tests passed in the final targeted
  run. No new source test file introduced.
- Disposable Mongo 7: DRY_RUN, repeat APPLY, overlapping participant rejection,
  heartbeat and connected fields, terminal slot release and malformed document
  rejection passed. Fresh init succeeded and its call validator equals migration.
- Web TypeScript, targeted ESLint and production build passed; Agora is a separate
  lazy chunk. Build warns about the large SDK chunk; it is not loaded on idle chat.
- Playwright mocked API: start -> cancel and incoming -> decline passed, no page
  errors. Answer control visible with no horizontal overflow at 375/768/1440 in
  both themes. DND fixture did not auto-decline. No media/token/provider request.
- Actual microphone/Agora, token expiry under network loss, independent browser
  accounts and two-network media remain NOT VERIFIED. No shared DB APPLY.
