# Verification

Before: the supplied hosted log confirms missing JWT_PUBLIC_KEY. The first local
attempt was blocked earlier by sandbox loopback permissions, not the JWT error.
After: the same test and the full Maven test suite must pass without an
environment JWT_PUBLIC_KEY. Preserve real JwtUtil initialization and existing
signature verification tests; do not mock JWT validation to hide the failure.

Final verification (2026-10-16): mvn -B test succeeded, 41 tests, zero failures,
errors or skips (46.720 seconds). git diff --check passed. Hosted rerun pending.
The invalid-signature test now flips a decoded signature byte; replacing the last
base64url character did not reliably alter the signature bytes.

The first unrestricted full run exposed three further failures: two monitoring
route tests attempted live Redis, and a logging assertion expected the order from
before commit 6738630. Both were addressed in test configuration/expectations.
