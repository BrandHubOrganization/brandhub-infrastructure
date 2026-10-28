# Implementation plan

1. Add one schedule document and guarded schema/index contract. Fields hold sender/
   Workspace/channel, immutable message/context/thread/mentions, request/delivery
   identities, schedule/time zone, state/revision, attempts, lease and outcome times.
   Index creation identity, own ordered queue, due items and expired leases.
2. Add create/list/reschedule/cancel REST service. Reuse ChatChannelMessages payload
   validation; enforce own-user scope and revision CAS. No JPA/entity changes.
3. Add leased worker and feature-local MongoTransactionManager (not a global bean).
   Reuse normal send in the same Mongo transaction as SENT; defer its STOMP publish
   until commit. On transient failures release/retry with backoff; on permanent
   failures record a safe code. Existing notification outbox remains unchanged.
   Revalidate account status with the existing AccountAccessPolicy/UserRepository,
   since background delivery does not pass through the JWT authentication filter.
   Commit broadcastPending with SENT, then flush events outside the transaction;
   recover pending broadcasts independently of message delivery, without reposting.
4. Add Web feature-scoped types/service/query hook. Integrate split scheduling in
   the rich composer, retaining draft/retry identity. Reuse it for thread replies.
   Inspect returned state on idempotent retries; closed intents never clear a draft.
   Put the private paged schedule view in the existing Workspace panel/navigation.
5. Update `src/i18n/locales/vi/chat.json` and `en/chat.json` in parallel. Match existing
   theme, keyboard/focus and mobile/desktop panel behavior. Reuse dependencies.
6. Add additive migration `2026-10-26-chat-scheduled-messages.js`, fresh init block and
   optional cancelled-only sample; do not APPLY to shared Atlas as part of coding.
7. Verify on disposable Mongo replica set and mocks, keeping executable QA outside
   src in keep-local-only. Build/lint Web, compile Business, test existing chat.
8. Add an own-user/channel upcoming projection in ChatScheduledMessages and its
   controller, reusing the existing ownership/sort index. Expose only time/zone/state,
   not draft content; do not derive it from a partial page of the workspace queue.
   Add a cached useQuery under the existing chat-scheduled user/workspace prefix,
   so create/reschedule/cancel invalidation also refreshes the notice. Poll at the
   existing ten-second cadence. Render ChatChannelScheduleNotice before the composer
   and route its action through ChatWorkspace's existing scheduled-panel opener.
   Update src/i18n/locales/vi/chat.json and en/chat.json together. No migration or
   sample-data change is required for this read-only extension.

Mongo transaction support follows MongoDB's multi-document transaction contract:
https://www.mongodb.com/docs/manual/core/transactions/
Use Spring MongoTransactionManager/TransactionTemplate with the same factory as
MongoTemplate, without replacing the application's JPA transaction manager.
