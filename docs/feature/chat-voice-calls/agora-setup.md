# Agora setup (audio 1:1)

## Account configuration

Create a user-owned Agora project with App ID + App Certificate authentication.
Use the free allowance; review the current account billing controls and do not
enable auto-recharge, recording or paid proxy features for this implementation.
Free usage is a provider allowance, not a guarantee enforced by application code.

Set these only in the Business Service local environment, never in Web VITE_*:

```dotenv
AGORA_APP_ID=<project App ID>
AGORA_APP_CERTIFICATE=<project App Certificate>
```

Do not commit credentials, paste them into tickets, or use Console temporary tokens
as a production implementation. Restart Business after changing its environment.

## Implemented runtime

POST `/api/v1/workspaces/{workspaceId}/chat/calls/{callId}/token` uses the authenticated
actor, verifies both current DM memberships and an accepted, live call lease.
The server derives the media channel and participant UID. Tokens expire after at
most five minutes and never beyond the current call lease. Response is no-store.
App Certificate never leaves Business. Tokens are not persisted in chat_calls.

Lifecycle APIs now support start/current/get/accept/decline/cancel/end plus connected
and heartbeat acknowledgements. Call metadata uses compare-and-swap revisions and
a unique active-participant index. Both participants must acknowledge media before
ACTIVE. Ring timeout is 45 seconds; accepted lease is 60 seconds per participant.

Web DM header has a voice action; the workspace call bar supports answer/decline,
hangup, microphone mute and explicit audio playback recovery. SDK is lazy-loaded
after start/accept, creates microphone tracks only, and renews authorized tokens.
Same-browser tabs coordinate microphone ownership using Web Locks. Calls are
received while the Chat page is open; channel navigation preserves the session.
Leaving Chat/logout releases local audio, and server lease expiry releases slots.

The publisher role supports SDK media publishing: the audio-only Web UI must only
create microphone tracks. This token alone does not claim a provider-enforced
video prohibition. Ending a call prevents renewal but does not instantly revoke
an already issued token at Agora; short expiry limits this window.

## Remaining release gates

Do not manually insert accepted call documents to bypass the lifecycle. Real Agora
audio between two devices/networks has NOT been verified yet. Durable missed-call
inbox, audible ringing/DND alert delivery and invitations outside the Chat route
remain pending; no claim that the full notification scope is complete.

## Migration and manual test

The user chose to apply `docs/database/migrations/2026-10-23-chat-voice-calls.js`
manually. No Atlas writes were performed by this implementation.

In VS Code Playground, prepend `globalThis.BRANDHUB_CHAT_CALLS_APPLY = false;`
to the complete migration script and execute the WHOLE script. Expect DRY_RUN,
blocked=false. Then change false to true and execute the WHOLE script again.
Do not run just the assignment: that only returns a boolean, not migration results.
The script uses the explicit brandhub database and requires chat_channels baseline.
Existing chat_calls metadata may need the updated validator reapplied for heartbeat
fields. No calls are seeded; ChatSampleSeeder must never create live invitations.

Restart Business and refresh Web after migration. Use two accounts that belong to
the same Workspace DIRECT channel, in separate browser profiles/devices. Open Chat
on both sides. Call, answer, allow microphones and confirm two-way audio, mute,
hangup and busy/timeout. Use headsets. For non-localhost deployment use HTTPS/WSS;
an HTTP LAN IP does not satisfy microphone secure-context requirements.

Apply the reviewed chat_calls migration only after isolated validation and normal
rollout approval. Existing chat messages must not be reset or reseeded for calls.
After UI integration, verify two real accounts on separate networks, microphone
permissions, DND/mute, expired tokens, busy state, disconnect and logout cleanup.

Official references:
- https://docs.agora.io/en/realtime-media/rtc/voice-quickstart/web
- https://github.com/AgoraIO/Tools/tree/master/DynamicKey/AgoraDynamicKey/java
- https://www.agora.io/en/pricing/voice-calling/
