# Apply Hashtag to a Post Draft

| | |
|---|---|
| FR Code | 3.6.17 |
| Feature | Apply Hashtag to Post |
| Status | Approved implementation scope for the existing Post draft editor |
| Roles | Creator using the Post draft editor |

## Objective

Let a Creator apply active hashtags from the current workspace collection to a Post draft. A hashtag created while editing must first be saved to that workspace collection with an explicit purpose. Applying or removing a hashtag in the draft must not alter other posts or rewrite old snapshots.

## Scope and decisions

- The target is the Content Creator Post draft editor at `/workspaces/{workspaceId}/editor`, which persists through the existing Post draft API. This feature does not write to the separate collaborative Task editor or its Yjs document.
- A hashtag selected from the collection is copied into the editor's Post hashtag list. The existing `SavePostRequest.hashtags` field and `PostDocument.hashtags` list are the persisted snapshot; no new Post-to-collection reference is stored.
- The Hashtag Collection page offers “Apply to Post”; it opens a new Post draft with the chosen hashtag prefilled. It does not select or edit an existing Post because the current Post editor has no existing-draft loading flow.
- A newly typed hashtag opens the existing Add dialog, requires the Creator to choose a non-required purpose, and is added to the collection before it is applied to the editor state. Add and Post draft save are separate operations; PostgreSQL and MongoDB do not share a transaction. If the later Post save fails, the added collection entry remains available for retry.
- The current Post draft has no campaign link. Event-specific, required hashtags remain visible with their scope but cannot be applied to an unscoped draft.
- Applying updates the draft editor and preview. Existing autosave/submit behavior persists the resulting string snapshot. It does not approve, publish, schedule, or bulk-apply to other Posts.

## Acceptance criteria

1. The editor loads active hashtags from the current workspace and lets the Creator select multiple entries.
2. Search is workspace-scoped; removed or other-workspace entries cannot be selected.
3. Applying a selected entry immediately updates the editor preview and includes its display tag in the next saved Post draft.
4. Typing a new tag and pressing Enter opens Add Hashtag with the typed value and a purpose choice. Successful creation adds the entry to the collection and the Post editor; cancellation or failed creation does not add it to the editor.
5. A normalized duplicate is reused from the current collection and is not added twice to the Post.
6. “Apply to Post” on an ordinary collection entry opens a new draft editor with that tag prefilled.
7. Hashtag text saved on a Post remains unchanged if its collection entry is later removed or edited.
8. Event-specific required entries are not selectable without a campaign-linked Post; their campaign scope is explained in the UI.
9. Existing Creator/Manager Post draft save authorization and existing auto-save/submit flows remain in force. The collection-Apply controls are shown only for Creator members.
10. New labels are present in Vietnamese and English, and controls use existing theme tokens in light/dark mode.

## Existing interfaces

- `GET /api/v1/workspaces/{workspaceId}/hashtags` supplies active collection entries.
- `POST /api/v1/workspaces/{workspaceId}/hashtags` creates a newly typed entry with its chosen purpose.
- `POST /api/v1/workspaces/{workspaceId}/posts` and `PATCH /api/v1/workspaces/{workspaceId}/posts/{postId}` persist the Post hashtag string snapshot through `SavePostRequest.hashtags`.

No separate Apply endpoint or database migration is needed for this scope. Invalid or removed collection entries cannot be selected. The editor's existing draft save errors remain visible through its existing save/submit behavior.

## UI and accessibility

The editor's hashtag area includes a searchable workspace collection picker, selected-tag chips, and the existing type-to-add interaction. The Add dialog shows purpose and errors. The collection entry action has an accessible label naming the hashtag. Loading, empty, failed, and campaign-scoped states are announced to assistive technology. All new copy is localized; controls remain keyboard operable and use light/dark semantic tokens.

## Test seam

The agreed public test seam is the visible collection/editor UI through the existing Post draft API. Tests verify selection, new-tag creation with purpose, and the hashtags submitted in the saved Post request; they do not assert private hook state.

## Out of scope

- Applying hashtags to the collaborative Yjs Task editor.
- Selecting an existing Post from the collection, campaign association, required-tag validation, or changing Post save authorization.
- Atomic commit or compensation across the independent PostgreSQL collection and MongoDB Post stores.
- AI suggestions, approval, publishing, scheduling, and cross-Post application.
