> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.8.2 — Disconnect Account

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.8.2` |
| **Use Case ID** | `UC-108` |
| **Feature** | Disconnect Account |
| **Domain** | Publishing & Social (`3.8`) |
| **Canonical Actors / Roles** | `Owner, Manager, Client` |
| **Business Rules** | `BR-20, BR-52, BR-54` |
| **Message Codes** | `MSG01, MSG03, MSG07, MSG43` |
| **Status** | Implemented — Production Verified |

## 1. Objective & Business Value

Allow authorized `Owner`, `Manager`, and `Client` members of a Workspace to safely disconnect a linked Facebook, Instagram, TikTok, or Threads account, revoking upstream OAuth grants best-effort, purging encrypted token material in MongoDB `social_accounts`, and preventing orphaned scheduled publish jobs while preserving historical `PUBLISHED` post records.

## 2. User Story

As an authorized member holding `Owner, Manager, Client` in a Workspace, I want to execute **Disconnect Account** reliably across BrandHub's supported social publishing pipeline (**Facebook, Instagram, TikTok, Threads**) so that approved brand content is delivered, previewed, scheduled, and audited safely with full tenant isolation (`BR-20, BR-52, BR-54`).

## 3. Acceptance Criteria

1. **Canonical Role & Workspace Scope (`BR-20`):** Only authenticated Workspace members with role in `Owner, Manager, Client` may invoke the public REST endpoints for `Disconnect Account`; unauthorized roles or cross-workspace requests fail deterministically with `403 FORBIDDEN` (`MSG07`).
2. **Four-Platform Scope Discipline:** Strictly supports **Facebook**, **Instagram**, **TikTok**, and **Threads** — legacy/de-scoped platforms (such as Zalo OA or LinkedIn) are rejected at validation boundaries (`MSG02`).
3. **Production Pipeline & Idempotency:**
- **1. Workspace Ownership & Role Verification:** Verifies caller holds `Owner`, `Manager`, or `Client` in the Workspace owning `SocialAccountDocument` `{id}` (`Creator` is rejected with `403 FORBIDDEN`).
- **2. Scheduled Post Guard (`BR-54`):** Checks MongoDB `posts` for `SCHEDULED` or `PUBLISHING` entries targeting `{id}`. Active `PUBLISHING` jobs block immediate disconnect (`409 CONFLICT`) or require confirmation; future `SCHEDULED` targets on that account transition to `PAUSED_ACCOUNT_DISCONNECTED` so `PublishJobConsumer` never dispatches wiped credentials.
- **3. Upstream Revocation & Token Wipe:** Calls `publisher-service` `/api/v1/social/tokens/revoke` with bounded timeout; regardless of upstream provider HTTP error (e.g. already revoked externally), clears `encryptedAccessToken` / `encryptedRefreshToken`, sets `status = DISCONNECTED` and `disconnectedAt = now()`, and preserves `platformAccountId` + display metadata for past `PUBLISHED` post detail views (FR 3.8.4).
4. **Token & Credential Security:** Raw OAuth access/refresh tokens are encrypted at rest via AES-256-GCM (`CryptoUtils`) and never returned in client-facing `ApiResponse<T>` DTOs or written to application logs.
5. **Internationalization (`vi.json` + `en.json`):** All buttons, platform badges, status pills, validation alerts, and modal copy use synchronized key-parallel entries (`connections.disconnect.title`, `connections.disconnect.scheduledWarning`, `connections.disconnect.confirm`, `connections.status.disconnected` in `vi.json` & `en.json`) on `brandhub-web` and `tr()` on `brandhub-mobile-app` — zero hardcoded Vietnamese or English strings in JSX/TSX.
6. **Light & Dark Mode Compliance:** All surfaces (`pages/connections/index.tsx` (Disconnect confirmation modal with scheduled-post impact count), `pages/client/components/ClientSocialAccounts.tsx` on Web and `src/screens/more/SocialAccountsScreen.tsx` (destructive confirmation dialog), `src/services/socialAccountService.ts` on Mobile) use semantic CSS variables / Tailwind `dark:` variants and `useAppPreferences().palette` tokens with WCAG AA contrast in both Light and Dark themes.

## 4. UI / UX & Screen States

- **Web Surfaces (`brandhub-web`):** `pages/connections/index.tsx` (Disconnect confirmation modal with scheduled-post impact count), `pages/client/components/ClientSocialAccounts.tsx`
- **Mobile Surfaces (`brandhub-mobile-app`):** `src/screens/more/SocialAccountsScreen.tsx` (destructive confirmation dialog), `src/services/socialAccountService.ts`
- **UI States:**
  - **Loading / In-Flight:** Skeleton placeholders on read views; spinner + disabled action button on mutations to prevent duplicate submissions.
  - **Empty:** Contextual guidance card (e.g., prompt to connect social account via FR 3.8.1 or create/schedule a post via FR 3.8.6) with localized CTA.
  - **Success:** Immediate `TanStack Query` cache invalidation, live status badge update, and localized toast notification.
  - **Error / Retryable Failure:** Structured inline banner displaying localized error reason mapped from `MSG01, MSG03, MSG07, MSG43` without losing draft edits.

## 5. API & Messaging Contract

| Endpoint / Upstream Route | Auth / Security | Controller / Service Handler |
| :--- | :--- | :--- |
| `DELETE /api/v1/social-accounts/{id}?workspaceId={workspaceId}` | Bearer (`Owner, Manager, Client`) | `SocialAccountController.disconnect()` (`business-service`) -> validates Workspace scope, revokes token, marks `DISCONNECTED` |
| `POST /api/v1/social/tokens/revoke` | `X-Internal-Service-Key` | `SocialOAuthController.revokeToken()` (`publisher-service`) -> calls Meta/TikTok/Threads token revocation endpoint best-effort |

## 6. Error Handling & Edge Cases

- `SOCIAL_ACCOUNT_NOT_FOUND` (`404`, `MSG01`): Account ID does not exist or belongs to another Workspace.
- `POST_CURRENTLY_PUBLISHING` (`409`, `MSG43`): A publish job for this account currently holds Redis lock `processingPostIds:{postId}:{platform}`.
- `FORBIDDEN` (`403`, `MSG07`): `Creator` or cross-workspace actor attempts to disconnect account.
- **Duplicate Delivery / Network Retry:** `PublishJobConsumer` enforces Redis lock `processingPostIds:{postId}:{platform}` (`30m` TTL) and `DefaultClassMapper` cross-service `PublishJobMessage` compatibility so broker redeliveries never double-post to a Client's live social feed.

## 7. Related Specifications & References

- **Domain Index & Sibling FRs:** [3.8 Publishing & Social Index](../README.md) · [FR 3.8.1 — Connect Social Account](../3-8-1-connect-social-account/spec.md) · [FR 3.8.7 — Track Post Status](../3-8-7-track-post-status/spec.md)
- **Consolidated Extension Module:** [`social-publisher-resilience`](../../../modules/07-billing-publisher-and-observability/social-publisher-resilience/spec.md)
- **BA Domain Baseline:** [BA 3.8 Publishing & Social](../../../../ba/07-publishing-social.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Verified across `brandhub-business-service` and `brandhub-publisher-service` JUnit suites, RabbitMQ + Redis lock integration checks, Web & Mobile UI integration, `vi.json`/`en.json` parity, and Light/Dark mode verification ([test.md](./test.md)).
- **Out of Scope:** De-scoped platforms (Zalo OA), livestream broadcasting, or automated paid ad-spend boosting.
