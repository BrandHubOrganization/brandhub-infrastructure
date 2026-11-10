# Chat extensions — confirmed scope, 2026-10-23

## Spec

Web first. Notify direct mentions, new DMs, invitations and missed calls; exclude
the sender, respect channel access. Add mute/DND. Upload JPEG/PNG/WebP/PDF only,
5 files per message, 10 MB per file; do not debit Agency storage quota. Presence
is session-based online/offline. Web Push requires opt-in and hides message text.
Voice calls are DM one-to-one first. Huddles (20 participants, Client may start),
video, screen sharing and external integrations are deferred. Media infrastructure
requires budget approval; do not provision services automatically.

## Plan

0. Align Mongo init validators with migration and preflight existing documents.
1. Persist identity-based mentions and durable notification events, then inbox.
2. Redis session TTL presence, including multiple tabs.
3. Private S3 uploads, type/size verification and abandoned-upload cleanup.
4. Opt-in Web Push with account/device isolation.
5. Approved media provider, voice invitation/call lifecycle and missed calls.

## Tasks

- [x] Align schema and verify locally without applying shared databases.
- [x] Confirm mute/DND inbox versus alert semantics and presence visibility.
- [ ] Complete mention UI and live delivery verification (backend foundation implemented in chat-mention-inbox).
- [ ] Implement presence, attachments and push in independent rollout steps.
- [ ] Approve voice infrastructure before enabling real calls.

## Test

Compare init/migration validators; reject invalid existing records before APPLY.
Exercise access revocation, duplicate sends/events, worker retry, multi-tab expiry,
private downloads, MIME/size spoofing, opt-out/logout and stale subscriptions.
Run authenticated multi-user integration checks separately from mocked UI tests.
No live notification, call or shared DB write is authorized by local verification.

## Confirmed clarification

Mute/DND retain inbox entries but suppress toast, sound, Web Push and ringing;
muting a channel also suppresses mention alerts there. Do not automatically decline
calls. Presence is Online/Offline visible within the same Workspace, no last seen,
Away or invisible mode; heartbeat expiry is not a read receipt.
