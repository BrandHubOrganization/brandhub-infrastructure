# Application UI Screenshots & SRS Screen Evidence (`D15` – `D19`)

> Navigation: [← Knowledge Base Hub](../index.md) · [Wireframes & UI Architecture](../wireframe/README.md) · [BA Specifications](../ba/README.md) · [Feature Specifications](../feature/README.md)

This directory archives **136 verified production UI screenshots** organized across 5 milestone deliverable batches (`D15` through `D19`), capturing the live `brandhub-web` (React `19.2` + Tailwind CSS `4.3`) and `brandhub-mobile-app` (Expo SDK `58` / React Native `0.88`) interfaces used as visual evidence in **Report 3 — SRS (`brandhub-final_report/report3/report3_official.docx`)**.

---

## 1. Deliverable Batch Inventory (`136` PNGs)

| Batch Folder | File Range on Disk | PNG Count | SRS Domain & Epic Coverage |
| :--- | :--- | :---: | :--- |
| `D15/` | `DA-D15-01.png` – `DA-D15-27.png` *(excluding `DA-D15-10`)* | **26** | **`3.2` Authentication & Authorization** (`Sign Up`, `Sign In`, Google OAuth, `Reset/Change Password`, `OTP`, `2FA TOTP`), **`3.3` User & Client Profile**, and **`3.4` Agency & Workspace** (`Agency List/Dashboard`, Invitations, Workspace Settings, Templates, Members) |
| `D16/` | `DA-D16-01.png` – `DA-D16-26.png` | **26** | **`3.5` Media Package & Media Campaign** (`Template Packages`, 2-Party Negotiation, `CampaignTimelineGrid`, `Content Requests`) and **`3.6` Content & Workflow** (`List`, `Calendar`, `Gantt`, `Kanban`, 3-Tier `Approval Sequence`, `TaskSection` Unicode Editor, Material Repository, Google Drive Sync, Watermark, Hashtags, Surveys, Mail Templates, Realtime Chat) |
| `D17/` | `DA-D17-01.png` – `DA-D17-28.png` | **28** | **`3.7` AI Features**: Vietnam Trend Suggestions, Interactive `Neo4j Trend Knowledge Graph`, Brand Knowledge RAG Upload/Index Status, AI Caption Generator & Variants, Virtual Brand Ambassador, Commercial Image Studio, Wan 2.2 VACE Product Video Studio, and Third-Party Collaborator Directory / AI Recommendation |
| `D18/` | `DA-D18-01.png` – `DA-D18-33.png` | **33** | **`3.8` Publishing & Social** (OAuth Account Connect, Desktop/Mobile Mockup Previews, Scheduling, Queue/DLQ Tracking, and Publishing across **Facebook, Instagram, TikTok, Threads**) + **`3.9` Subscription & Billing** (`STUDIO_*` / `BASIC..ENTERPRISE` Upgrade Plans, **SePay VietQR** Checkout, Invoices, `agency_credit_wallets`, and Workspace Credit Caps) |
| `D19/` | `DA-D19-01.png` – `DA-D19-23.png` | **23** | **`3.10` Admin Functions** (`Push Notification`, `Platform Statistics`, 5-Host `System Health Monitoring`, `Content Moderation Queue`, `User Directory & Violation Strikes`, `AI Credit Price List & CSV Import`, `SePay Revenue Dashboard`, `PDF Report Export`) + **`brandhub-mobile-app`** companion screens (`DA-D19-16`–`DA-D19-21`) |
| **Total** | **`DA-D15` – `DA-D19`** | **136 PNGs** | Complete visual baseline across all 9 SRS domains |

---

## 2. Non-UI Deliverable IDs & Backfill Verification Ledger

Across the `DA-D15`–`DA-D19` numbering sequence (`137` allocated deliverable slots), **136 PNGs** exist on disk and exactly **1 ID (`DA-D15-10`)** intentionally has no screenshot because it represents a headless backend-only token endpoint:

| Deliverable ID | Disk Status | Verification / Architectural Explanation |
| :--- | :---: | :--- |
| **`DA-D15-10`** | **No PNG (Expected)** | Headless backend JWT Refresh Token rotation endpoint (`POST /api/v1/auth/refresh` with HttpOnly cookie + Redis `jwt:blacklist:{jti}`) — zero standalone UI screen. |
| `DA-D15-23`, `DA-D15-27` | **Present** (`D15/`) | Verified multi-tenant workspace isolation & permission guard screens. |
| `DA-D17-05`, `DA-D17-21`, `DA-D17-22` | **Present** (`D17/`) | Verified Brand Knowledge RAG document chunking/indexing status & semantic preview screens. |
| `DA-D18-25`, `DA-D18-26` | **Present** (`D18/`) | Verified RabbitMQ Publishing Queue Retry (`1m` / `5m` / `15m`) & Dead-Letter Queue (`DLQ`) status UI at `/workspaces/:id/publishing/queue`. |
| `DA-D19-16` – `DA-D19-21` | **Present** (`D19/`) | Verified `brandhub-mobile-app` (Expo 58) companion captures for mobile approval, notifications, calendar, and post preview. |

---

## 3. SRS Report 3 (`report3_official.docx`) Integration Standards

When capturing or updating screenshots for SRS `Screen Layout` subsections (see [Team Workflow Guide](../guides/team-workflow-guide.md)):
1. **Sequential Captioning**: Every embedded `Screen Layout` image in `brandhub-final_report/report3/report3_official.docx` MUST carry a centered italic caption `Figure X - <Function Name>` numbered sequentially (`Figure 1`–`Figure 150`).
2. **Canonical Terminology in UI**: Captured screens must display only the **6 canonical roles** (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`), the **4 supported social platforms** (**Facebook, Instagram, TikTok, Threads**), and **SePay (VietQR)** for billing checkouts.
3. **Theme & Locale Consistency**: Capture clean `1440px` desktop viewports (`375px`/`390px` for mobile views) with complete `i18next` (`vi`/`en`) translations and zero raw translation keys or placeholder stack traces.
