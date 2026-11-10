# One-to-one DM voice calls

Agora RTC audio only (Free project), authenticated STOMP call invitations/status.
Agora handles media negotiation/transport; do not implement custom SDP/ICE signaling.
Exactly two current DM members;
Client may call. Public/private group channels, video, recording and Huddles excluded.
No SDP, ICE candidates or audio stored in history. DND/mute suppress ringing but keep
inbox/history, do not auto-decline. Calls need explicit user acceptance and microphone
permission. No paid provider provisioning or shared database APPLY without approval.

State contract: RINGING -> CONNECTING after callee accepts -> ACTIVE only after
media connection confirmation. Terminal: DECLINED, CANCELLED, MISSED, ENDED, FAILED.
CAS transitions and revision prevent multi-tab races. One live call per user across
channels, enforced by unique partial multikey activeParticipantIds. Remove active
slots atomically on terminal transition. Expired ringing/heartbeat leases terminate
and release slots; busy is conflict, not fake answered/missed call.

Collection chat_calls: string UUID _id/workspaceId/channelId/callerId/calleeId,
participantIds[2], optional activeParticipantIds[2], state, revision, createdAt,
updatedAt, expiresAt, optional acceptedAt/connectedAt/endedAt/endedBy/endReason.
Persist no media or secret credentials. History accessed only by current authorized
DM participants; lost membership blocks signaling. Generic missed-call inbox uses
existing SQL notifications and durable idempotent delivery, no message preview.

Runtime lifecycle uses separate caller/callee heartbeat timestamps and connected
participant acknowledgements. Both media acknowledgements are required for ACTIVE.
Ring timeout is 45 seconds; accepted call lease is 60 seconds per participant,
renewed every 15 seconds. Expiry releases both busy slots atomically. Request UUID
makes creation idempotent; repeated decisions must not change a terminal result.
User-queue events contain only a generic invalidation, never credentials/content.
Runtime notifications, browser call UI and live audio acceptance are release gates.
UI will use vi/en chat.calls.* and existing semantic light/dark theme tokens.

Selected provider: Agora Free. Backend keeps App Certificate private and signs short-
lived AccessToken2 for a server-derived per-call channel and fixed participant UID
(caller=1, callee=2). No wildcard UID or client-selected channel. Tokens only after
acceptance and while authorized/live. No recording, proxy paid mode, auto-recharge or
paid subscription configuration. External project setup remains user-owned.
Schema and token foundation alone do not enable calls or prove real audio.
