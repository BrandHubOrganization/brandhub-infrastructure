# Sprint 7 — Social OAuth & Token Management

**Timeline:** Weeks 13–14 (Aug 12–25, 2026)
**Jira:** DA Sprint 7
**Phase:** Phase 4 — Social Integration & AI Pipeline
**Goal:** Implement OAuth connection flows for all 5 social platforms (Facebook, Instagram, TikTok, Threads, Zalo OA), encrypt and store tokens securely, and set up automated token lifecycle management.

> **AI Parallel:** AI Iteration 2 runs concurrently this sprint.

---

## Overview

| Epic | Title | Owner |
|---|---|---|
| E18 | Meta OAuth (Facebook + Instagram) | Phước, Trung |
| E19 | TikTok, Threads & Zalo OA OAuth | Phước, Trung |
| E20 | Token Lifecycle Management | Trung, Phước |

**Deliverables by end of Sprint 7:**
- All 5 platform OAuth flows working (FB, IG, TikTok, Threads, Zalo OA)
- All tokens AES-256 encrypted before storage
- Token status dashboard API working
- Scheduled token refresh job running at 2:00 AM daily
- Alert notifications on token refresh failure

---

## EPIC E18 — Meta OAuth (Facebook + Instagram)

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E18-01 | Implement Facebook Fanpage OAuth flow (redirect → callback → token exchange) | Phước (Publisher) | 🔴 Critical |
| DA-E18-02 | Implement Instagram Business account connection (linked via Facebook Business) | Phước (Publisher) | 🔴 Critical |
| DA-E18-03 | Implement AES-256 encryption for access token + refresh token before saving to MongoDB | Trung (Leader) | 🔴 Critical |
| DA-E18-04 | Implement disconnect flow (revoke token at Meta, remove from MongoDB) | Phước (Publisher) | 🟡 High |

**Facebook OAuth flow (DA-E18-01):**
1. Frontend redirects to `https://www.facebook.com/dialog/oauth?client_id=...&scope=pages_manage_posts,pages_read_engagement`
2. Meta redirects back to `/api/v1/social/facebook/callback?code=...`
3. Exchange code for user access token → exchange for long-lived page access token (60 days)
4. Encrypt token with AES-256 → store in `social_accounts` collection

**Instagram (DA-E18-02):** Instagram Business requires a linked Facebook Page. Reuse FB page token + call `/me/accounts` → get IG business account ID.

**AES-256 encryption (DA-E18-03):**
- Key: 256-bit key from environment variable `SOCIAL_TOKEN_ENCRYPTION_KEY`
- Algorithm: AES-256-GCM (provides authentication)
- Store: encrypted bytes + IV in MongoDB. Decrypt only when needed for publishing.

---

## EPIC E19 — TikTok, Threads & Zalo OA OAuth

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E19-01 | Implement TikTok for Business OAuth (Client Credentials Flow) | Phước (Publisher) | 🔴 Critical |
| DA-E19-02 | Implement Threads OAuth (using Meta Graph API, scope: threads_basic + threads_content_publish) | Phước (Publisher) | 🔴 Critical |
| DA-E19-03 | Implement Zalo Official Account OAuth | Phước (Publisher) | 🔴 Critical |
| DA-E19-04 | Implement token status dashboard API (view ACTIVE/EXPIRED/REVOKED status for all accounts) | Trung (Leader) | 🟡 High |

**TikTok OAuth (DA-E19-01):**
- Use TikTok for Business API — requires app review for `video.publish` scope
- OAuth 2.0 Authorization Code flow
- Token lifetime: access token 24h, refresh token 365 days

**Zalo OA (DA-E19-03):**
- Zalo OA SDK / REST API
- Requires registered Zalo Official Account (not personal)
- Token lifetime: access token 1h, refresh token 90 days — most aggressive refresh schedule

**Token status API (DA-E19-04):**
```
GET /api/v1/social/accounts
Response: [{platform, accountName, status: ACTIVE|EXPIRING_SOON|EXPIRED|REVOKED, expiresAt}]
```

---

## EPIC E20 — Token Lifecycle Management

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E20-01 | Implement scheduled token refresh job (runs at 2:00 AM daily, refresh tokens expiring within 7 days) | Trung (Leader) | 🔴 Critical |
| DA-E20-02 | Implement alert notification when token refresh fails (notify Account Manager) | Trung (Leader) | 🔴 Critical |
| DA-E20-03 | Implement manual token refresh API (Account Manager triggers refresh manually) | Phước (Publisher) | 🟡 High |

**Token refresh schedule (DA-E20-01):**
- Run at 2:00 AM workspace local timezone (use workspace.timezone setting)
- Query `social_accounts` where `tokenExpiresAt < now + 7 days`
- Per platform refresh logic:
  - Facebook: exchange long-lived token for new one (if < 60 days remaining)
  - TikTok: use refresh token to get new access token
  - Threads: same as Facebook (Meta API)
  - Zalo OA: must refresh every 1h — use a separate 45-min job
  - Instagram: tied to Facebook

**Notes:**
- Zalo OA 1-hour token TTL means a separate 45-minute refresh interval job is needed. Consider storing the refresh token separately with its own 90-day expiry check.
- DA-E20-02 alert: create a notification record + send FCM push (if mobile) + in-app notification. Email optional.

---

## Sprint 7 Checklist

- [ ] Facebook Fanpage OAuth: connect → page access token encrypted → stored
- [ ] Instagram Business: connected via Facebook Business page
- [ ] AES-256-GCM encryption: tokens encrypted at rest, decrypt only for publish
- [ ] Facebook disconnect: token revoked at Meta, removed from DB
- [ ] TikTok OAuth: access token + refresh token stored
- [ ] Threads OAuth: connected via Meta Graph API
- [ ] Zalo OA OAuth: access token stored, 45-min refresh job configured
- [ ] Token status dashboard: all 5 platforms show correct status
- [ ] Daily 2:00 AM refresh job runs, refreshes tokens expiring within 7 days
- [ ] Failed refresh: Account Manager receives in-app alert
- [ ] Manual refresh API: Account Manager can trigger on demand
