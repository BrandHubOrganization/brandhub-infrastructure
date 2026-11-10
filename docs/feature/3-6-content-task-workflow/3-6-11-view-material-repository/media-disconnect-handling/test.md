Test expected disconnect yields no JSON body and no ERROR; genuine server error remains 500; genuine committed media failure is logged with no JSON. Browser polling for 60 seconds must not issue a fresh video GET for an unchanged material. Existing light/dark tokens and language text remain unchanged.

Verified 2026-11-04:
- Before fix: MediaDisconnectHandlingTest 3 tests, 1 failure (expected disconnect incorrectly logged ERROR), 1 error (JSON attempted after committed video response).
- After fix: MediaDisconnectHandlingTest 3, RepositoryEncryptedMediaTest 6, RepositoryEncryptedStorageTest 1: all 10 pass.
- Changed thumbnail/card eslint passes. Frontend npm run build passes (existing large bundle warning).
- User restarted BUSINESS through runner; health 200.
- Chrome: three real media requests explicitly aborted after receiving a chunk. New Business ERROR count is zero; no secondary JSON converter exception.
- Chrome: invalidating materials query three times (real API/refetch) retains the exact video DOM node and source URL on all three refreshes, readyState 4.
- Existing UI markup, semantic colors and translations unchanged.
