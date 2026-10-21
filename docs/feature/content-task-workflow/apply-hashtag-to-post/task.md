# Tasks — Apply Hashtag to a Post Draft

- [x] Resolve scope: existing Post draft editor and current Post save API, separate from collaborative Yjs Tasks.
- [x] Agree on the browser UI → Post draft API test seam.
- [x] Add browser flow coverage for selecting a workspace hashtag and asserting the saved Post snapshot.
- [x] Add coverage for typing a new hashtag, choosing purpose, and adding it to the collection before applying it.
- [x] Add a collection-page Apply-to-Post navigation test.
- [x] Connect the editor picker to active workspace collection query and Add dialog; merge tags without normalized duplicates.
- [x] Add a Creator-only Apply-to-Post action for ordinary collection entries; explain disabled campaign-required entries.
- [x] Add matching English/Vietnamese locale keys for picker, errors, scope, and collection action.
- [x] Use shared UI components, screen-reader status for loading/empty states, and page objects for new E2E interactions.
- [x] Split collection filters and hashtag cards out of the collection orchestrator; keep each UI module below 300 lines and the orchestrator JSX below the 150-line guideline.
- [ ] Verify light/dark appearance and keyboard operation in a running browser.
- [x] Production web build passes; targeted Playwright tests are discovered but cannot reach the browser because localhost sockets are denied in this environment.
- [x] Run `git diff --check` and two-axis code review; addressed the review's accessibility and convention findings.
