# Tests — Apply Hashtag to a Post Draft

Public seam: visible collection/editor UI through the existing Post draft API. Browser tests may stub the API responses but assert user-visible behavior and the actual Post save request payload.

1. Open a workspace Post editor with active collection entries; choose two and verify both appear in the editor and preview.
2. Submit the draft; assert `POST /api/v1/workspaces/{workspaceId}/posts` contains the selected display strings in `hashtags`.
3. Type a new hashtag; verify Add dialog is prefilled, purpose is required, and cancel leaves editor state unchanged.
4. Create the typed hashtag with a purpose; verify the collection POST occurs once, the new tag is selected, and the later Post save contains its display string.
5. Type a normalized duplicate; reuse the active entry and ensure it appears once in the saved Post payload.
6. Verify a removed or other-workspace entry is never offered by the picker.
7. Verify EVENT_SPECIFIC required entries show their campaign scope and cannot be applied to an unscoped Post draft.
8. Click Apply to Post from an ordinary collection entry; verify navigation to the same workspace editor and the tag appears prefilled.
9. Verify English/Vietnamese labels, keyboard controls, and light/dark theme rendering.

Run targeted Playwright tests and `npm run build`. Do not claim collection creation and Mongo Post persistence are one atomic transaction; a failed Post save must leave the independently created collection entry available for retry.

## Verification record

- `npm run build`: passed after implementation.
- Targeted ESLint on changed source and E2E files: passed.
- Playwright `--list`: discovered all 16 tests across the editor and collection suites, including both Apply Hashtag flows.
- Browser execution: blocked in this environment. The Playwright web server emitted no ready URL before timeout; a manual localhost request returned a socket-access-permissions error. No browser assertions ran.
- `git diff --check`: passed.
