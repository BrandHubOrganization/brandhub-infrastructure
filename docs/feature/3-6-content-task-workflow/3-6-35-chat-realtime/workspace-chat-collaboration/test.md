# Verification scenarios

| ID | Scenario | Expected result | Status |
| --- | --- | --- | --- |
| C01 | Load chat with authenticated fixture workspace | History and channel directory come from authenticated API responses | Passed with isolated fixtures, including production bundle |
| C02 | Open package/campaign context links, reject missing context ID and switch context during a pending send | Sends retain exact context; optimistic/failed rows stay in that context; filtered view does not mark messages read | Passed after fixing optimistic context filtering; persisted Mongo filtering not exercised in browser |
| C03 | Search saved channel history, including no matches; clear search and filter pins | Requests scoped to selected channel; empty feedback; clear restores history | Passed with fixture API; live search not exercised |
| C04 | Retry history errors and load older messages | Stable deduplication/order; loaded history survives pagination errors | Passed; real connection loss/reconnect remains unexecuted |
| C05 | Failed send, retry, then canonical acknowledgement | Same client ID reused; one visible message remains | Passed with simulated HTTP 503 and REST/STOMP acknowledgement |
| C06 | Switch conversation while history response is delayed | No late response appears in the new conversation | Passed for channel switching; account/workspace A→B→A scenarios remain unexecuted |
| C07 | View filtered history or hide browser tab | Unseen messages are not marked read merely on receipt; visible bottom view advances read state | Passed: context filter, simulated document visibility and visible read request |
| C08 | Copy message; simulate clipboard denial | Success only on completed copy; useful error otherwise | Passed using in-page clipboard mock; OS clipboard untouched |
| C09 | Open/close details and mobile navigation with keyboard; transfer navigation to create-channel sheet | Focus returns to visible opener; transfer retains focus in new sheet | Passed after fixing controlled-sheet focus restoration; repeated on production bundle |
| C10 | Vietnamese/English | Parallel keys; no raw keys or broken layout | Passed: 102 matching leaf keys; VI/EN browser checks |
| C11 | Light/dark at 375, 768 and 1440px | No horizontal overflow; composer above bottom navigation | Passed in both themes at all three widths; screenshots inspected |
| C12 | Typecheck, changed-file lint and production build | Pass or clearly attributable existing failures | Passed after both final fixes; unrelated media-library dynamic-import warning remains |

Browser fixture results establish frontend behavior only. Real Mongo/STOMP multi-user behavior requires the running backend and authorized test accounts.

## Executed collaboration workflows

- Create a PRIVATE channel with invited member; automatically select the returned channel and send a message.
- Add/remove a member, save managers-only setting, archive the channel, observe read-only composer, then restore it.
- Create a DIRECT conversation and send; simulate failed send and retry with the same client ID, leaving one canonical row.
- Open a thread and send a reply; root reply count increments and reply stays out of the top-level timeline.
- Add reaction, pin a message, filter pins, search with no match and clear search.
- Insert an authorized member as plain-text `@name`; focus returns to composer. Shift+Enter inserts a newline.

These checks verify frontend requests, state and rendering against an isolated fixture. They do not prove backend concurrency, channel creation idempotency or actual user-to-user delivery.

## Confirmed backend scope cases

- B01: Outsider/removed workspace member cannot list/read/send/subscribe; private channel and DIRECT additionally require membership, including for managers.
- B02: CLIENT discovers general and invited channels only; internal PUBLIC access does not grant private access.
- B03: Same request creates one channel/DM; repeated send creates one message; conflicting client ID reuse is rejected.
- B04: Legacy history/read/unread never includes new non-general messages. Existing general history survives.
- B05: Cross-workspace or cross-channel root/message is rejected for thread, reaction, pin and read APIs.
- B06: Archived channel rejects sends/reactions/pins/member writes; allowed manager can restore. General/DM invariant changes are rejected.
- B07: Atomic reaction add/remove and member updates do not overwrite unrelated fields; failed persistence emits no content event.
- B08: Channel search escapes regex metacharacters, pages stably and scopes every query to authorized channel/root.
- B09: Both inbound subscription and outbound delivery reject revoked channel membership; legacy topic receives general only.
- B10: Browser fixture exercises create channel, settings, invite/remove, DM, thread, reaction, pin, server search and reconnect without fake production state.

## Backend verification results — 2026-10-22

Executed `mvn -o -q "-Dtest=ChatChannelAccessTest,ChatChannelMessagesTest,ChatChannelQueriesTest,ChatChannelInterceptorTest,ChatServiceImplTest,WorkspaceAccessServiceTest" test`: **30 tests passed, 0 failures/errors/skipped**.

| Suite | Tests | Evidence |
| --- | ---: | --- |
| ChatChannelAccessTest | 6 | Private/DM membership even for managers, client public-channel invitation, archived/restricted posting, general/DM management invariants, no owner fallback |
| ChatChannelMessagesTest | 7 | Client-ID reuse, cross-channel conflict, foreign root, revoked access, reaction allowlist, failed-save event suppression and private channel-only publication |
| ChatChannelQueriesTest | 4 | Legacy/general query isolation, channel-scoped escaped search and invalid cursor rejection |
| ChatChannelInterceptorTest | 5 | Bearer authentication, destination validation, active workspace subscription, revoked outbound delivery and existing task role checks |
| ChatServiceImplTest | 6 | Existing general message validation, normalization, duplicate reuse, history limit and cross-workspace package rejection |
| WorkspaceAccessServiceTest | 2 | Active client membership resolution and outsider denial |

These unit regressions cover portions of B01–B09. Full live coverage remains pending for DM/channel creation races, concurrent member/reaction updates, legacy read/unread against Mongo, channel-specific revocation on an actual broker, and failure/reconnect across multiple authenticated clients. B10's UI workflows passed except actual connection loss/reconnect.

`mvn -o -q -DskipTests package` also passed. Produced `brandhub-business-service/target/brandhub-business-service-0.0.1-SNAPSHOT.jar`.

## Final frontend/build results — 2026-10-22

- `npm run type-check`: passed.
- `npm exec -- eslint src/pages/chat src/types/chatCollaboration.ts src/services/chatCollaborationService.ts src/components/layout/Layout.tsx`: passed.
- `npm run build`: passed, 4,374 modules transformed; output in `brandhub-web/dist`.
- Existing warning: `mockContentLibraryService.ts` is imported both statically and dynamically in media library, so its dynamic import does not split a separate chunk. No build error.
- Opened the built app using `vite preview` at `http://127.0.0.1:4173`, with isolated HTTP/STOMP fixtures. History, thread and sheet focus regressions passed; no JavaScript runtime errors in this production smoke run.
- Six English theme/viewport checks measured document width equal to viewport width; composer remained within the viewport. At 375px, textarea bottom was 683px and bottom navigation began at 748px in an 812px viewport.
- Expected HTTP 503 console entries came only from deliberate send/history failure simulations. No unexpected JavaScript exception or dialog accessibility warning was observed.

Local verification artifacts are in workspace `output/playwright/`, outside application source and commits:

- `chat-production-thread-desktop-vi.png`: production desktop with thread.
- `chat-production-mobile-light-vi.png`, `chat-production-mobile-dark-vi.png`: production mobile themes.
- `chat-final-{light,dark}-{375,768,1440}-en.png`: English responsive/theme matrix.
- `final-web-build.log`: final production build output.

Mongo migration/index scripts were syntax-checked only. They were not applied to shared databases. No deployment or live multi-user end-to-end test was performed.
