# Verification

Actual browser: starting 1, select/delete leaves blank, type 3 displays 3; paste 003 normalizes 3; paste 00012 normalizes 12. Empty/0, negative/fraction cannot submit; positive integer can. Other row and field values stay intact. No parent/API type change; quantity payload is numeric. Verify creation and client negotiation variant, vi/en, light/dark and 375px. No live saves/DB writes. Executable QA only in ignored keep-local-only.

## Results — 2026-10-30

Real browser with the actual OfferingEditor passed clear/retype, 003 and 00012
normalization, native required/min/step blocking, numeric parent value and sibling
row isolation. Both normal and Client negotiation modes tested. vi/en, both themes
and 375px checked; screenshot inspected. No API calls or DB writes. Local fixture,
browser script, screenshots and logs remain ignored under keep-local-only.

Web npm run ci passed: lint (0 errors; existing repository warnings), TypeScript
and production build. No API/DB/schema changes; only OfferingEditor source changed.
