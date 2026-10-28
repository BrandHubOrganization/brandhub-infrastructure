# Plan

1. Add additive DRY_RUN-first chat_calls migration with full schema/index preflight;
   align fresh Mongo init and Java document. No seed calls or pending invitations.
2. Implement CAS call lifecycle, bounded expiry worker and idempotent inbox intents.
   Caller/callee access revalidated; do not use JVM-only locks. Enforce busy via DB.
3. Add Agora's official Java authentication library; server-scoped token endpoint,
   private AGORA_APP_CERTIFICATE, short TTL, no-cache response. Existing call metadata
   is provider-independent. STOMP only invitations and call-state updates.
4. Browser Agora RTC controller: mic permission, remote audio, accept/reject, mute,
   timeout, cleanup and unload; recover active call across channel navigation.
   Shared call provider, not channel component, owns lifetime. i18n vi/en chat.json.
5. Configure user-owned Agora Free project; two-device/two-network real audio test.
   Existing accounts/membership/seeder not rewritten. No custom coturn needed.

Lifecycle endpoints: POST /calls (channelId, clientRequestId), GET /calls/current,
GET /calls/{id}, POST /calls/{id}/{accept|decline|cancel|end|connected|heartbeat}.
CAS uses revision internally; per-party lease prevents one surviving browser from
keeping a disconnected peer alive forever. Token renewal remains membership-gated.
Extend init and migration with optional connectedParticipantIds and per-party dates.
