# Verification plan

Executable QA lives only in ignored keep-local-only folders; no new tests in src.

1. Migration: missing baseline, mismatched named index/validator, invalid existing
   schedule, duplicates and non-replica topology block safely. DRY_RUN has no writes;
   APPLY twice is safe. Fresh-init and migrated validators/index definitions match.
2. Create: plain/rich content, mention, DM/channel/thread/context; reject malformed,
   unsafe content, past/too-close/too-far dates, invalid zone and missing permissions.
   Same retry key/payload returns the original; changed payload returns conflict.
3. Privacy: other users/Workspaces cannot list/read/edit/cancel someone else's items.
   No message, unread, mention, websocket event or push is produced during scheduling.
4. Worker: not early; sends overdue once; current permissions/context/root checked;
   suspended/deactivated/deleted sender cannot deliver even with active membership;
   channel archive/removal/recipient removal fails safely. Temporary/rate-limit errors
   retry, capped attempts become FAILED. Restart/expired lease recovers pending work.
5. Race real Mongo workers, claim versus cancel/reschedule, expired-owner writes and
   rollback/uncertain commit. Exactly one stored message; SENT and notification intent
   commit atomically. STOMP happens only after commit and never on rollback.
   Unknown commit/broker outage leaves a durable broadcast intent; retry emits the
   existing message event and never inserts new messages/notification intents.
6. Web: quick presets/custom time and zone, retain failed draft, no double submit,
   closed idempotent responses preserve the draft and acknowledge already-sent work;
   Enter sends immediately, Shift+Enter/list/mention behavior preserved. Pending
   list/pagination/status, private ownership, time change/cancel and conflict refresh.
7. vi/en, light/dark, keyboard/focus and 375/768/1440 layouts. No native confirmations,
   no console errors, no accidental real message sends during browser QA.
8. Run Business compile/existing chat tests and Web type-check/build/targeted lint.
   Do not run sample seed, migration or scheduled delivery against shared Atlas.

9. Conversation notice: only the current user's PENDING/SENDING items in the
   selected channel/DM qualify, including its thread replies. Empty/FAILED/SENT/
   CANCELLED do not display. Another conversation/user/workspace must not leak into
   the notice, even when more than 20 earlier items exist elsewhere. Use the earliest
   due item; pending overdue work says waiting and SENDING says sending. A keyboard
   or pointer activation opens the existing private schedule panel in one action.
   Create/change/cancel and background polling refresh the banner; query errors
   hide stale results. Check vi/en, light/dark and widths 375/768/1440 without overflow.

## Results — 27 October 2026

| Check | Result |
| --- | --- |
| Business compile and existing test compilation | PASS: 739 main sources and 215 test sources |
| Existing chat regression tests | PASS: 36 tests |
| Service/worker smoke on disposable Mongo 7 replica set | PASS: 122 assertions |
| Migration DRY_RUN, repeated APPLY and negative preflights | PASS: 14 checks |
| Web scheduling utilities, locale keys and init/migration parity | PASS: 15 checks |
| Browser scheduling flows and layout checks | PASS: 31 checks |
| Additional keyboard menu/dialog checks | PASS: 5 checks |
| Web production build and targeted ESLint | PASS |

The Mongo smoke uses the real transaction/lease/index implementation with mocked
SQL membership/account lookups, rate limiter and event broker. It covers atomic
delivery/notification persistence, rollback, ambiguous commit and broadcast retry,
expired owners (including an in-flight stale transaction), cancel/reschedule races,
account eligibility and insert-only cancelled sample fixtures.

The browser uses mocked HTTP/STOMP in a separate QA session, not a logged-in user
profile. It covers DM/channel/thread, rich mentions, failed/closed retry draft
preservation, stable request identity, reschedule/cancel, privacy, history and stale
revision recovery. Layout checks cover English/Vietnamese, light/dark and widths
375/768/1440; panels stay inside the viewport without horizontal overflow. No
unexpected console/JavaScript errors or native dialogs were observed. Enter opens
the menu, End selects the custom-time item, and Escape restores focus/preserves
the draft without sending. QA waits for Radix's asynchronous focus navigation.

All database creation/APPLY/seed was confined to a labelled disposable QA replica
set on local port 27029. No Atlas, business PostgreSQL data or paid AI was used.
Executable QA, logs and screenshots remain excluded from Git under keep-local-only;
no executable test files were added under src. This verification does not replace
the real-user smoke after an operator applies the migration to the target database.

## Conversation notice follow-up — 27 October 2026

- Business compilation and 29 selected existing chat/security regression tests pass.
- Real Mongo replica-set smoke now passes 136 assertions (the previous 122 plus
  14 upcoming-projection checks). These cover own-author/channel/workspace scope,
  private-channel denial, thread inclusion beyond the first 20 workspace items,
  earliest ordering, closed-state exclusions, cancellation, sending and a response
  containing only the three declared metadata fields. Timestamp comparisons use
  Mongo's millisecond precision; state fixtures satisfy the existing validator.
- Browser follow-up passes 27 checks: compact notice, one-action keyboard access,
  actual reschedule/cancel mutation invalidation, DM switching, waiting/sending,
  hidden stale data on failure, recovery, background polling, no sent messages or
  unexpected console/native-dialog errors. Twelve layout combinations pass:
  English/Vietnamese, light/dark, 375/768/1440; mobile banner is about 48px high.
- Web production build and targeted ESLint pass; all 15 existing scheduling utility,
  i18n and schema-parity checks pass. Parity compares evaluated validator/index
  definitions, allowing formatting differences between migration and init.

Only the disposable local QA database was initialized/seeded. This extension adds
no collection, field, index or migration, so init/seeder need no further change.
Restart Business to expose the additive upcoming endpoint; refresh Web. Existing
scheduling metadata is still required. The real-user deployment smoke remains an
operator step. QA scripts/logs stay ignored; reviewed screenshots and the owned
QA container/browser/dev server are removed/stopped after verification.
