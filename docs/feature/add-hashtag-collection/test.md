# Acceptance tests

Public seams: authenticated Add/List HTTP API and visible web UI. Provider calls are absent.
1. Add #ThươngHiệu then GET returns one normalized display tag, purpose and server creator.
2. Case/NFC-equivalent duplicate and concurrent duplicate return 409, leaving one entry.
3. Another workspace can hold the same tag; users cannot read/write another workspace.
4. CLIENT profile membership, CREATOR and MANAGER succeed; inactive/revoked/no membership fail.
5. Invalid characters, length, purpose and page bounds return 400; no partial persistence.
6. GET filters and bounded paging exclude deleted rows and preserve deterministic ordering.
7. EVENT_SPECIFIC is CLIENT-only, required, and linked to a MediaCampaign in the same workspace.
8. Browser Add -> refreshed View -> reload; cancellation creates nothing; duplicate retains form.
9. Browser handles empty/search-empty, fetch failure/retry, access loss and workspace switches.
10. Vietnamese/English labels and light/dark screenshots at mobile/tablet/desktop widths.

Verification: production web build and backend test compilation passed. API and Playwright
runs stalled during local test startup without reports; PostgreSQL migration verification is
pending. These checks must pass before treating this contract as fully verified.
