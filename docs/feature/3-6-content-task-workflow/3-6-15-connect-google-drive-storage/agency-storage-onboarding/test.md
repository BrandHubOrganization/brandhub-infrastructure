# Verification
Ordinary dashboard URL and old preview URL both show the real management card for Owner/Manager. No fake account chooser, sample capacity, prototype bar or scenario control remains. GET status drives connected email, and enabled=false shows disabled connect with setup guidance. Errors show retry. Authorize opens only accounts.google.com after actor/workspace recheck. Callback accepts only a matching actor, consumes context once and returns to a whitelisted same-workspace dashboard/library path with code removed from history. Disconnect confirmation explains agency-wide impact; successful mutation invalidates all agency workspace material/detail caches. Context switches/unmount do not redirect or toast for another actor/workspace. No client management request. Expanded usage reads real S3 counts; no inferred fallback state without provider evidence. Keyboard/light/dark/mobile remain usable. No production migration or Google connection without real configuration.

Readiness test: missing key/config or required tables yields enabled=false and authorize returns MATERIAL_STORAGE_UNAVAILABLE without making a Google request.

## Final verification — 2026-10-26
- Business full Maven suite:1289 tests,0 failures/errors,93 existing conditional skips. Focused CustomerDrive integration now includes10 passing real disposable database cases plus policy/API/capability tests.
- Web:15 unit tests,33 repository Playwright cases passed, TypeScript and changed-source ESLint passed, production build passed (existing chunk-size advisory only).
- Independent Spec review found no actionable correctness/ACL issue. Standards review found no blocking runtime issue; long card/hook functions remain a low-priority extraction opportunity.
- Verified the actual signed-in in-app browser tab on the normal workspace dashboard: real storage card visible, no prototype controls/query; live backend reported disabled and connect button was disabled with setup guidance. Captured proof in .scratch/agency-storage-live.png.
- No secret values printed. Dedicated Drive keys were absent in local .env files inspected; only .env.example gained safe placeholders. No live Google authorization, production/local-runtime migration or feature activation was attempted.
- User asked for instructions to create the missing Google OAuth client. Activation remains pending that manual credential/configuration step. All source remains uncommitted as requested.

Activation checks: client settings present without printing values; expected local DB confirmed; schema backup exists; old billing catalog unchanged; new tables exist; key decodes to32 bytes; Runtime status enabled=true; authorize redirects to Google with correct redirect URI and drive.file. No grant is approved or test folder invented by the agent.

## Local activation result — 2026-10-27
- User supplied Client ID/Secret in ignored business-service/.env. Values were never printed or changed.
- Verified runtime target is local PostgreSQL brandhub in container brandhub-postgres. All9 required storage/Drive tables were absent.
- Saved schema-only backup in .scratch/drive-activation-20261027/brandhub-schema-before.sql. Applied reviewed foundation + Trash + Drive expansion as one bounded transaction; omitted only the foundation BASIC catalog UPDATE. An in-transaction catalog signature check proved existing plan storage values unchanged.
- New agency storage rows remain inventory-unverified (4 agencies,0 verified). No false reconciliation, upload/purge enablement or Google grant was performed.
- Added exact frontend callback, local Gateway URL and a newly generated persistent256-bit encryption key to ignored local config. Enabled customer-drive connection only; existing write/purge flags remained unchanged.
- User restarted Business through Runner. Verified new8081 listener and actuator/info HTTP200. Gateway media with an invalid capability returned403, preserving the private media boundary.
- Reloaded the actual authenticated dashboard: live API enabled the real Connect Google Drive button and removed the unconfigured warning. Screenshot .scratch/agency-storage-enabled.png captures this result.
- Current grant count is0. User must select their intended Google account and approve consent in Chrome/Edge. Google client-secret validity at token exchange, encrypted grant persistence and remote folder creation are not claimed verified until that callback completes.
- No source changes in this activation step; no additional unit suite rerun for .env/operational SQL only. No secrets or database backup were staged/committed. All project changes remain uncommitted per user preference.
