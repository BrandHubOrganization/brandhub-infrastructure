# Test Specification — Mobile & Web Role-Based Navigation Parity

## 1. Traceability & Scope

| Field | Value |
| :--- | :--- |
| **Feature** | Role-Based Navigation Parity & Mobile Screens (`mobile-nav-role-parity`) |
| **Canonical Roles** | `Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin` |
| **Web Source of Truth** | `brandhub-web/src/routes/access.ts` (`70/70` Vitest tests passed) |
| **Mobile Source of Truth** | `brandhub-mobile-app/src/utils/navAccess.ts`, `navigation/withAccess.tsx` (`140/140` Jest tests passed) |
| **Overall Status** | **Passed (100%)** |

---

## 2. Unit & Component Test Case Matrix

| Test Case ID | Type | Role / Precondition | Target Route / Screen | Expected Result | Status |
| :--- | :---: | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | `Owner` authenticated in workspace | Campaigns, Media Packages, Social Accounts, Editor, Mail Templates, AI Studio, Clients, Members | Visible in sidebar/drawer; `withAccess` allows rendering | **Passed** |
| `UTCID02` | `N` | `Manager` authenticated in workspace | Calendar, Chat, Content Requests, Campaigns, Packages, Social, Editor, Mail Templates, AI Studio, Publishing, Library, Members | All workspace operational items visible and accessible | **Passed** |
| `UTCID03` | `N` | `Creator` authenticated in workspace | Calendar, Chat, Content Requests, Editor, Mail Templates, AI Studio, Publishing, Publishing Dashboard, Library | Visible and accessible; Campaigns/Packages/Members hidden | **Passed** |
| `UTCID04` | `N` | `Client` authenticated in workspace | Calendar, Chat, Content Requests, Campaigns, Media Packages, Social Accounts, Library | Visible and accessible; Editor/AI Studio/Publishing/Members hidden | **Passed** |
| `UTCID05` | `A` | `Creator` or `Client` deep-links to restricted screen | `/members` or `/agency/:id/stats` wrapped in `withAccess` | Blocked at screen guard with access-denied message (`403` equivalent) | **Passed** |
| `UTCID06` | `N` | `Owner` opens Agency Statistics on mobile | `GET /api/v1/agencies/{id}/stats` (`FR 3.4.2`) | Renders read-only horizontal KPI bars for workspaces, members, campaigns, credits | **Passed** |
| `UTCID07` | `N` | `Manager` or `Creator` opens Publishing Dashboard on mobile | `GET /api/v1/workspaces/{id}/posts/dashboard` (`FR 3.8.3`) | Renders KPI cards, 4-platform distribution (Facebook, Instagram, TikTok, Threads), and status filter | **Passed** |
| `UTCID08` | `N` | `Manager`, `Creator`, or `Client` opens Material Library on mobile | `GET /api/v1/workspaces/{id}/materials` (`FR 3.6.11`) | Lists workspace materials with keyword search and RAW/Retouched/Watermarked filter | **Passed** |
| `UTCID09` | `N` | `Client` or `Manager` opens Content Requests on mobile | `/api/v1/workspaces/{id}/content-requests` (`FR 3.5.10`–`3.5.13`) | Action buttons respect backend `can*` flags and `expectedVersion` optimistic locking | **Passed** |
| `UTCID10` | `B` | `Admin` authenticated | Admin sidebar routes (`/admin/statistics`, `/admin/health`, `/admin/moderation`, `/admin/users`, `/admin/revenue`) | All Admin routes accessible; non-Admin roles blocked | **Passed** |
