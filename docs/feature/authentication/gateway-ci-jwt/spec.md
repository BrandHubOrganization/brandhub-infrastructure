# Gateway CI JWT configuration

The context smoke tests must run without JWT_PUBLIC_KEY from a developer or CI
environment. Reuse the existing test RSA public key; production key loading and
JWT verification must remain unchanged.
Route tests must not require live Redis. Logging order expectations must match
the deliberate LOWEST_PRECEDENCE change in commit 6738630.
Invalid-signature tests must deterministically alter signature bytes.
