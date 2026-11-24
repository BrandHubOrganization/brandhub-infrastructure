> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.8.1 — Connect Social Account

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.8.1` |
| **Use Case ID** | `UC-107` |
| **Feature** | Connect Social Account |
| **Domain** | Publishing & Social (`3.8`) |
| **Canonical Actors / Roles** | `Owner, Manager, Client` |
| **Business Rules** | `BR-20, BR-52, BR-53` |
| **Message Codes** | `MSG01, MSG02, MSG03, MSG07, MSG42` |
| **Status** | Implemented — Production Verified |

## 1. Objective & Business Value

Authorize and bind a Workspace's official social publishing accounts across the 4 supported platforms (**Facebook Page**, **Instagram Business/Creator**, **TikTok**, and **Threads**) via OAuth 2.0 + CSRF cookie binding (`bh_oauth_state`) + PKCE (`TikTok`), encrypting access/refresh tokens with AES-256-GCM (`CryptoUtils`) and synchronizing Workspace account metadata into MongoDB `social_accounts`.

## 2. User Story

As an authorized member holding `Owner, Manager, Client` in a Workspace, I want to execute **Connect Social Account** reliably across BrandHub's supported social publishing pipeline (**Facebook, Instagram, TikTok, Threads**) so that approved brand content is delivered, previewed, scheduled, and audited safely with full tenant isolation (`BR-20, BR-52, BR-53`).

## 3. Acceptance Criteria

1. **Canonical Role & Workspace Scope (`BR-20`):** Only authenticated Workspace members with role in `Owner, Manager, Client` may invoke the public REST endpoints for `Connect Social Account`; unauthorized roles or cross-workspace requests fail deterministically with `403 FORBIDDEN` (`MSG07`).
2. **Four-Platform Scope Discipline:** Strictly supports **Facebook**, **Instagram**, **TikTok**, and **Threads** — legacy/de-scoped platforms (such as Zalo OA or LinkedIn) are rejected at validation boundaries (`MSG02`).
3. **Production Pipeline & Idempotency:**
- **1. Pre-Authorization & Ticket Issuance:** `SocialOAuthController` validates that `X-User-Id` holds `Owner`, `Manager`, or `Client` permission on `workspaceId` via `BusinessServiceClient`. Generates a cryptographic `state` bound to HttpOnly cookie `bh_oauth_state` and a `60,000 ms` single-use ticket (`pendingConnectTickets`) so Bearer JWTs never leak in browser URL query strings.
- **2. Provider-Specific OAuth Handshake:** Meta Graph API `v19.0` exchanges short-lived user tokens for long-lived Page/IG Business tokens; TikTok OAuth v2 (`https://open.tiktokapis.com/v2/oauth/token/`) validates PKCE `code_verifier` and retrieves creator profile (`https://open.tiktokapis.com/v2/user/info/`); Threads OAuth (`https://graph.threads.net/oauth/access_token` -> `/access_token`) upgrades to 60-day long-lived token.
- **3. AES-256-GCM Encryption & Idempotent Reactivation:** Tokens are encrypted with `CryptoUtils` (`publisher.token-decryption-key`) and synced to `brandhub-business-service` (`SocialAccountDocument` in MongoDB `social_accounts`). Reconnecting a previously disconnected external `platformAccountId` in the same Workspace reactivates the existing document (`status = CONNECTED`) so historical post analytics stay linked.
- **4. Proactive Token Refresh (`TokenRefreshScheduler`):** Queries `GET /api/v1/internal/social-accounts/expiring?days=7` and refreshes expiring TikTok/Threads/Meta tokens automatically, or flags `TOKEN_EXPIRED` via `POST /api/v1/internal/social-accounts/token-refresh-failed`.
4. **Token & Credential Security:** Raw OAuth access/refresh tokens are encrypted at rest via AES-256-GCM (`CryptoUtils`) and never returned in client-facing `ApiResponse<T>` DTOs or written to application logs.
5. **Internationalization (`vi.json` + `en.json`):** All buttons, platform badges, status pills, validation alerts, and modal copy use synchronized key-parallel entries (`connections.platforms.*`, `connections.actions.connect`, `connections.status.*`, `connections.errors.oauthCancelled` in `src/i18n/locales/{vi,en}/connections.json`) on `brandhub-web` and `tr()` on `brandhub-mobile-app` — zero hardcoded Vietnamese or English strings in JSX/TSX.
6. **Light & Dark Mode Compliance:** All surfaces (`pages/connections/index.tsx`, `pages/client/components/ClientSocialAccounts.tsx`, `components/common/SocialPlatformBadge.tsx` on Web and `src/screens/more/SocialAccountsScreen.tsx` (`expo-web-browser` OAuth flow), `src/services/socialAccountService.ts` on Mobile) use semantic CSS variables / Tailwind `dark:` variants and `useAppPreferences().palette` tokens with WCAG AA contrast in both Light and Dark themes.

## 4. UI / UX & Screen States

- **Web Surfaces (`brandhub-web`):** `pages/connections/index.tsx`, `pages/client/components/ClientSocialAccounts.tsx`, `components/common/SocialPlatformBadge.tsx`
- **Mobile Surfaces (`brandhub-mobile-app`):** `src/screens/more/SocialAccountsScreen.tsx` (`expo-web-browser` OAuth flow), `src/services/socialAccountService.ts`
- **UI States:**
  - **Loading / In-Flight:** Skeleton placeholders on read views; spinner + disabled action button on mutations to prevent duplicate submissions.
  - **Empty:** Contextual guidance card (e.g., prompt to connect social account via FR 3.8.1 or create/schedule a post via FR 3.8.6) with localized CTA.
  - **Success:** Immediate `TanStack Query` cache invalidation, live status badge update, and localized toast notification.
  - **Error / Retryable Failure:** Structured inline banner displaying localized error reason mapped from `MSG01, MSG02, MSG03, MSG07, MSG42` without losing draft edits.

## 5. API & Messaging Contract

| Endpoint / Upstream Route | Auth / Security | Controller / Service Handler |
| :--- | :--- | :--- |
| `POST /api/v1/social/{platform}/connect-url?workspaceId={id}&clientId={cid}` | Bearer (`Owner, Manager, Client`) | `SocialOAuthController.createConnectUrl()` (`publisher-service`) -> verifies workspace caller via `GET /api/v1/internal/social-accounts/authorize-connect`, sets `bh_oauth_state` cookie, issues 60s single-use connect ticket |
| `GET /api/v1/social/{platform}/authorize?ticket={ticket}` | Single-use 60s Browser Ticket | `SocialOAuthController` -> consumes ticket and redirects 302 to Meta / TikTok (PKCE S256) / Threads OAuth consent screen |
| `GET /api/v1/social/{platform}/callback?code={code}&state={state}` | OAuth Provider Redirect + `bh_oauth_state` | `MetaOAuthServiceImpl` / `TikTokOAuthServiceImpl` / `ThreadsOAuthServiceImpl` -> exchanges code, encrypts token via AES-256-GCM, syncs via `POST /api/v1/internal/social-accounts/sync` (`X-Internal-Service-Key`) |
| `GET /api/v1/social-accounts?workspaceId={workspaceId}` | Bearer (`Owner, Manager, Creator, Client`) | `SocialAccountController` (`business-service`) -> lists connected Workspace accounts without exposing encrypted token material |

## 6. Error Handling & Edge Cases

- `UNSUPPORTED_PLATFORM` (`400`, `MSG02`): Any platform outside `facebook`, `instagram`, `tiktok`, `threads` (e.g., Zalo OA or LinkedIn) is rejected.
- `OAUTH_STATE_MISMATCH` (`400`, `MSG42`): Missing/expired `bh_oauth_state` cookie or replayed connect ticket.
- `PROVIDER_ACCESS_DENIED` (`302 -> ?status=cancelled`): User cancels consent on Meta/TikTok/Threads; redirects cleanly to `/workspaces/:id/connections` with localized warning toast.
- **Duplicate Delivery / Network Retry:** `PublishJobConsumer` enforces Redis lock `processingPostIds:{postId}:{platform}` (`30m` TTL) and `DefaultClassMapper` cross-service `PublishJobMessage` compatibility so broker redeliveries never double-post to a Client's live social feed.

## 7. Related Specifications & References

- **Domain Index & Sibling FRs:** [3.8 Publishing & Social Index](../README.md) · [FR 3.8.1 — Connect Social Account](../3-8-1-connect-social-account/spec.md) · [FR 3.8.7 — Track Post Status](../3-8-7-track-post-status/spec.md)
- **Consolidated Extension Module:** [`social-publisher-resilience`](../../../modules/07-billing-publisher-and-observability/social-publisher-resilience/spec.md)
- **BA Domain Baseline:** [BA 3.8 Publishing & Social](../../../../ba/07-publishing-social.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Verified across `brandhub-business-service` and `brandhub-publisher-service` JUnit suites, RabbitMQ + Redis lock integration checks, Web & Mobile UI integration, `vi.json`/`en.json` parity, and Light/Dark mode verification ([test.md](./test.md)).
- **Out of Scope:** De-scoped platforms (Zalo OA), livestream broadcasting, or automated paid ad-spend boosting.
