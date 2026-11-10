# Plan — Apply Hashtag to a Post Draft

## Module and seam

Use the existing Post editor as the feature module's interface. The web picker reads and creates collection entries through the already implemented Hashtag API, then changes the editor's hashtag state. Existing Post draft create/update APIs persist the selected display strings in Mongo as Post snapshots. There is no new Business endpoint, JPA entity, Mongo field, or migration.

The collection's entry action navigates to the workspace Post editor with the selected display tag in location state. The editor's current `useEditorForm` already accepts `prefilledHashtags`, so the route can reuse this path without inventing a Post identifier or existing-draft lookup.

## Flow

1. Resolve the workspace from the editor route/current workspace and the authenticated user.
2. Query active workspace hashtags through `useHashtagCollection`; include workspace and user in the query key.
3. Search the collection from the existing hashtag input; selecting entries adds their display tag to editor state, deduplicated by normalized tag.
4. Keep campaign-required entries visible but disabled because `PostDocument` has no campaign ID.
5. For an unmatched typed tag, open `AddHashtagDialog` with the typed value. Create it with the chosen non-required purpose; after success, add its display tag to editor state. Reuse the existing create mutation and query invalidation.
6. On “Apply to Post” from the collection page, navigate to `/workspaces/{workspaceId}/editor` with the selected hashtag prefilled.
7. Let the existing Post auto-save or submit flow persist `hashtags` as immutable display text on the Post snapshot.

## Files

- Modify `brandhub-web/src/pages/editor/components/HashtagInputWithSuggestions.tsx` to load/search/select workspace entries, open the Add dialog for unmatched tags, and report loading/empty/error/scope states.
- Modify `brandhub-web/src/pages/editor/index.tsx` to provide workspace/user/role context to the picker.
- Modify `brandhub-web/src/pages/editor/hooks/useEditorForm.ts` only if needed to make location-prefilled tags merge/deduplicate consistently.
- Modify `brandhub-web/src/pages/hashtag-groups/components/HashtagCollection.tsx` to show a Creator-only Apply-to-Post action for ordinary entries.
- Keep `HashtagCollection.tsx` as the collection orchestrator; render filters and entry cards through `HashtagCollectionFilters.tsx` and `HashtagEntryGrid.tsx` so each module stays focused and the page JSX remains below the repository guideline.
- Keep the card's navigation in `ApplyHashtagToPostButton.tsx` and pagination in `HashtagCollectionPagination.tsx`, each behind a small prop interface.
- Modify `brandhub-web/src/pages/hashtag-groups/components/AddHashtagDialog.tsx` to accept an optional initial tag while retaining explicit purpose selection.
- Reuse `brandhub-web/src/pages/hashtag-groups/hooks/useHashtagCollection.ts`, `services/hashtagService.ts`, and the existing Add dialog; avoid duplicating collection queries or mutations.
- Add editor labels in `src/i18n/locales/{en,vi}/editor.json` and collection action labels in `src/i18n/locales/{en,vi}/hashtagGroups.json`.
- Add the agreed browser-flow coverage in `brandhub-web/tests/e2e/editor/content-creator-studio.spec.ts`; add a collection navigation case in `tests/e2e/hashtags/collection.spec.ts`.

## Data and risks

- Post snapshot is the hashtag text copied into existing `PostDocument.hashtags`; later collection edits/removal do not rewrite Posts.
- Collection creation commits to PostgreSQL separately from a later Post save in Mongo. The UI reports creation and keeps the tag available if saving the draft later fails; it does not claim a distributed transaction.
- Required `EVENT_SPECIFIC` tags remain unavailable until a Post-to-campaign link exists.
- Existing editor save/submit error behavior and permission enforcement remain unchanged. Collection-Apply controls are Creator-only.
- No new AI/provider, gateway route, publisher/mobile change, or database migration.

## Verification

- `npm run build` in `brandhub-web`.
- Targeted Playwright coverage for collection selection, purpose-based creation, snapshot request payload, and Apply-to-Post prefill.
- `git diff --check` in each changed repository.
