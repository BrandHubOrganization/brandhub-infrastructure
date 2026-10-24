# Plan

Wire ThreadPanel's timeline to markRead, reuse channel cache invalidation after
server acknowledgement. Record successful read in timeline refs even across effect
cleanup/restart, avoiding lost acknowledgement state in StrictMode. Add You labels.

Keep composer subtree mounted but disabled during transient failures. Scope Chat
cooldown to current actor and use existing authenticated Axios client; no global
limiter removal. Retry reads once after cooldown, never queue writes. Test 429
draft retention and 403 revocation with isolated browser fixture before live reads.
Expose Retry-After/limit headers in Gateway CORS. Add scoped linked-message preview,
bounded read-ack recovery, role-gated Dashboard requests and seed image fallback.
Do not fabricate Analytics/Activity API data or relax Backend permissions.

For QA login mismatch, use VITE_DEV_LOGIN_{ADMIN,OWNER,MANAGER,CREATOR,CLIENT}_EMAIL
overrides. Keep dataset-specific values in ignored .env.development.local.

1. Add optional mention IDs and embedded pending-recipient intents to chat_messages.
   The same Mongo insert stores content and intents atomically, avoiding a second
   outbox collection/transaction. Keep internal delivery fields out of DTOs.
2. Worker claims messages with a fenced 60-second lease and a bounded recipient
   list. Recheck access, insert deterministic UUID notification in existing SQL
   inbox (separate transactional service), then acknowledge recipient in Mongo.
   Poll at most one message per tick; retries wait 30 seconds. Generic previews.
3. Add chat_notification_preferences: deterministic workspace:user identity, DND
   and muted channel set. Use $set/$addToSet/$pull; don't replace entire document.
4. Provide additive migration and matching fresh-init metadata/indexes. No APPLY
   on shared DB. Legacy messages without intents are not scanned for delivery.
5. Test DTO compatibility, idempotency, access failures and delivery retry. No real
   notification should be sent during unit checks. Do not commit new test files.
6. Extend central chat types/service, composer identity ranges and retry payload.
   Add notification menu with user/workspace/channel-scoped TanStack queries;
   no optimistic success on failed writes. Update vi/en chat.json in parallel.
7. Add ChatSampleSeeder to MongoDataSeeder, guard chat validators and indexes before
   writes, include chat collections in the empty-target check. Bounded PostgreSQL
   membership lookup; deterministic insert-only fixtures, no notification worker intents.
