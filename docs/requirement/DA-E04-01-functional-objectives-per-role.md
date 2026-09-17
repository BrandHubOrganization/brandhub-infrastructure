# DA-E04-01: Functional Objectives Per Role (6 Roles x Features)

> **Document ID:** `DA-E04-01`  
> **Epic:** `E04 — Functional & Non-Functional Requirements`  
> **Sprint:** `Sprint 2 — Requirements & Architecture`  
> **Source of Truth:** [`docs/ba/00-overview.md`](file:///d:/FPT/Capstone/brandhub-infrastructure/docs/ba/00-overview.md), [`docs/ba/10-roles-permissions-matrix.md`](file:///d:/FPT/Capstone/brandhub-infrastructure/docs/ba/10-roles-permissions-matrix.md), [`docs/Các FR của hệ thống  - Feature_Function Requirement.csv`](file:///d:/FPT/Capstone/brandhub-infrastructure/docs/Các%20FR%20của%20hệ%20thống%20%20-%20Feature_Function%20Requirement.csv).

---

## 1. Executive Summary & Role Scope

This document specifies the testable **Functional Objectives** for the BrandHub multi-channel media campaign platform, structured strictly around the **6 core roles** defined in the JWT authorization claims and system architecture:

```
+-----------------------------------------------------------------------------------+
|                                     BRANDHUB                                      |
+-----------------------------------------------------------------------------------+
  |
  +---> [GUEST]     : Unauthenticated visitors (Landing page, Sign-up, Sign-in, OAuth)
  |
  +---> [ADMIN]     : System platform administrators (Platform health, Users, AI crawlers)
  |
  +---> [OWNER]     : Agency owner & creator (Billing, Agency Profile, Workspaces, Templates)
  |
  +---> [MANAGER]   : Workspace manager (Campaigns, Task Backlog, Assigning, Approvals)
  |
  +---> [CREATOR]   : Content creator & Member (Content editor, AI tools, Social publishing)
  |
  +---> [CLIENT]    : External brand client (Social connect, Content requests, Approvals, Analytics)
```

> **Naming Standard:** All requirements use strict `"The system shall [action] for the [ROLE]..."` syntax with explicit traceability to functional requirement IDs (`FR-X.Y.Z`).

---

## 2. Functional Objectives: GUEST

**Actor Scope:** Anonymous/unauthenticated visitors on public endpoints and onboarding pages.

### 2.1 Authentication & Onboarding

- **FO-GUEST-01** `[FR-3.2.1]`: The system shall allow the `GUEST` to register an account by providing email, password, and verifying via a 6-digit OTP sent to their email.
- **FO-GUEST-02** `[FR-3.2.1]`: The system shall normalize email inputs (case-insensitive deduplication) so that capitalized and lowercase emails resolve to the same account entity.
- **FO-GUEST-03** `[FR-3.2.2]`: The system shall allow the `GUEST` to authenticate using registered email and password credentials without requiring email OTP verification on standard logins.
- **FO-GUEST-04** `[FR-3.2.3]`: The system shall allow the `GUEST` to authenticate using Google OAuth 2.0 single sign-on (SSO).
- **FO-GUEST-05** `[FR-3.2.4]`: The system shall allow the `GUEST` to initiate a password reset request via email containing a secure one-time verification link or OTP code.
- **FO-GUEST-06** `[FR-3.2.6]`: The system shall validate OTP input within a 3-minute validity window and throttle failed attempts after 5 consecutive errors.

---

## 3. Functional Objectives: ADMIN

**Actor Scope:** Platform administrators with global root privileges across the entire BrandHub platform.

### 3.1 User & Agency Governance

- **FO-ADMIN-01** `[FR-3.10.6]`: The system shall allow the `ADMIN` to view a paginated, filterable, and searchable list of all registered users and their account statuses.
- **FO-ADMIN-02** `[FR-3.10.7]`: The system shall allow the `ADMIN` to create new user accounts directly through the administrative console.
- **FO-ADMIN-03** `[FR-3.10.8]`: The system shall allow the `ADMIN` to update user profile information and administrative flags.
- **FO-ADMIN-04** `[FR-3.10.9]`: The system shall allow the `ADMIN` to temporarily deactivate/suspend any user account across the system.
- **FO-ADMIN-05** `[FR-3.10.5]`: The system shall allow the `ADMIN` to execute user verification, disabling, and soft deletion operations.

### 3.2 Platform Monitoring & Metrics

- **FO-ADMIN-06** `[FR-3.10.2]`: The system shall provide the `ADMIN` with an overview dashboard showing active user count, active agencies, workspace metrics, and system throughput.
- **FO-ADMIN-07** `[FR-3.10.3]`: The system shall provide the `ADMIN` with a real-time microservice health monitoring view displaying CPU/RAM consumption, uptime, and dead-service alerts.
- **FO-ADMIN-08** `[FR-3.10.11]`: The system shall provide the `ADMIN` with a revenue dashboard displaying aggregate income from subscription plans and AI credit purchases.
- **FO-ADMIN-09** `[FR-3.10.12]`: The system shall allow the `ADMIN` to export administrative data, revenue statistics, and user reports into structured PDF documents.

### 3.3 System-Wide Communications & AI Operations

- **FO-ADMIN-10** `[FR-3.10.1]`: The system shall allow the `ADMIN` to broadcast global system push notifications and targeted segment announcements.
- **FO-ADMIN-11** `[FR-3.10.4]`: The system shall provide the `ADMIN` with a content moderation queue to review and override automated system flags on potentially violating user content.
- **FO-ADMIN-12** `[FR-3.7.9]`: The system shall allow the `ADMIN` to configure scheduled crawler jobs for viral topic discovery (specifying target platforms, crawling cadence, and batch volume limits).

---

## 4. Functional Objectives: OWNER

**Actor Scope:** Agency creators and organization owners with commercial, financial, and workspace administration privileges.

### 4.1 Agency Management & Profile

- **FO-OWNER-01** `[FR-3.4.1]`: The system shall allow the `OWNER` to list and switch between all Agencies under their ownership.
- **FO-OWNER-02** `[FR-3.4.2]`: The system shall provide the `OWNER` with an Agency-level aggregate dashboard showing campaign workload, productivity analytics, and member activities.
- **FO-OWNER-03** `[FR-3.4.3]`: The system shall allow an authenticated `USER` to create a new Agency entity, automatically assigning them the `OWNER` role.
- **FO-OWNER-04** `[FR-3.4.4]`: The system shall allow the `OWNER` to view the public and internal profile of their Agency.
- **FO-OWNER-05** `[FR-3.4.5]`: The system shall allow the `OWNER` to update the Agency profile (branding, description, contact details, tax info).
- **FO-OWNER-06** `[FR-3.4.6]`: The system shall allow the `OWNER` to soft-delete the Agency with a 30-day recovery window.

### 4.2 Member Invitations & Agency Governance

- **FO-OWNER-07** `[FR-3.4.7]`: The system shall allow the `OWNER` to send Agency email invitation links to prospective team members.
- **FO-OWNER-08** `[FR-3.4.8]`: The system shall allow the `OWNER` to track pending invitation statuses with an automatic 3-day expiration lifecycle.
- **FO-OWNER-09** `[FR-3.4.9]`: The system shall allow the `OWNER` to remove members from the Agency while retaining historical workspace assets.

### 4.3 Workspace Management & Templates

- **FO-OWNER-10** `[FR-3.4.10]`: The system shall allow the `OWNER` to list and access all Workspaces established under their Agency.
- **FO-OWNER-11** `[FR-3.4.11]`: The system shall provide the `OWNER` with cross-workspace performance dashboards.
- **FO-OWNER-12** `[FR-3.4.12]`: The system shall allow the `OWNER` to create a Workspace and assign at least one initial Workspace `MANAGER`.
- **FO-OWNER-13** `[FR-3.4.13]`: The system shall allow the `OWNER` to view Workspace configuration, including localized Timezone settings (UTC offset).
- **FO-OWNER-14** `[FR-3.4.14]`: The system shall allow the `OWNER` to update Workspace settings and metadata.
- **FO-OWNER-15** `[FR-3.4.15]`: The system shall allow the `OWNER` to soft-delete a Workspace with a 30-day restoration period.
- **FO-OWNER-16** `[FR-3.4.17]`: The system shall allow the `OWNER` to save an existing Workspace setup as a reusable template.
- **FO-OWNER-17** `[FR-3.4.19]`: The system shall allow the `OWNER` to assign Agency members into a Workspace with specific workspace roles.

### 4.4 Financial, Subscriptions & Credit Quotas

- **FO-OWNER-18** `[FR-3.9.1]`: The system shall allow the `OWNER` to upgrade the Agency plan (Basic to Pro/Enterprise) to expand workspace and member limits.
- **FO-OWNER-19** `[FR-3.9.2]`: The system shall allow the `OWNER` to cancel or downgrade subscription plans.
- **FO-OWNER-20** `[FR-3.9.3]`: The system shall allow the `OWNER` to execute transactions via PayOS payment gateway with ACID compliance.
- **FO-OWNER-21** `[FR-3.9.4]`: The system shall provide the `OWNER` with historical invoice records and transaction receipts.
- **FO-OWNER-22** `[FR-3.9.5]`: The system shall provide the `OWNER` with real-time AI credit consumption tracking across all workspaces.
- **FO-OWNER-23** `[FR-3.9.6]`: The system shall allow the `OWNER` to purchase supplementary AI credit packages.
- **FO-OWNER-24** `[FR-3.9.7]`: The system shall allow the `OWNER` to set AI credit spending quotas per Workspace.

---

## 5. Functional Objectives: MANAGER

**Actor Scope:** Workspace-level managers responsible for campaign execution, task assignment, quality assurance, and client collaboration.

### 5.1 Workspace Operations

- **FO-MANAGER-01** `[FR-3.4.11]`: The system shall provide the `MANAGER` with the Workspace dashboard displaying pending approvals, timeline health, and member workload.
- **FO-MANAGER-02** `[FR-3.4.14]`: The system shall allow the `MANAGER` to update Workspace operational settings and timezone definitions.
- **FO-MANAGER-03** `[FR-3.4.18]`: The system shall allow the `MANAGER` to inspect the list of members and clients attached to the Workspace.
- **FO-MANAGER-04** `[FR-3.4.19]`: The system shall allow the `MANAGER` to add Agency members to the Workspace.
- **FO-MANAGER-05** `[FR-3.4.20]`: The system shall allow the `MANAGER` to adjust workspace-level roles (`MANAGER` or `CREATOR/MEMBER`).
- **FO-MANAGER-06** `[FR-3.4.21]`: The system shall allow the `MANAGER` to remove a member from the Workspace.

### 5.2 Media Package & Media Campaign Management

- **FO-MANAGER-07** `[FR-3.5.1]`: The system shall allow the `MANAGER` to create custom Media Package templates for the workspace.
- **FO-MANAGER-08** `[FR-3.5.2]`: The system shall allow the `MANAGER` to view active Media Package structures and deliverables.
- **FO-MANAGER-09** `[FR-3.5.4]`: The system shall allow the `MANAGER` to approve or counter-propose Media Package negotiation terms.
- **FO-MANAGER-10** `[FR-3.5.5]`: The system shall allow the `MANAGER` to construct a detailed Media Campaign plan based on the finalized Media Package.
- **FO-MANAGER-11** `[FR-3.5.6]`: The system shall allow the `MANAGER` to approve and launch a Media Campaign, automatically converting campaign milestones into the task backlog.

### 5.3 Client Content Request Handling

- **FO-MANAGER-12** `[FR-3.5.7]`: The system shall allow the `MANAGER` to submit additional content requests on behalf of the client.
- **FO-MANAGER-13** `[FR-3.5.8]`: The system shall allow the `MANAGER` to transition client requests across statuses: `PENDING` -> `IN_PROGRESS` -> `ACCEPTED` (transfers to backlog) or `DENIED`.
- **FO-MANAGER-14** `[FR-3.5.9]`: The system shall allow the `MANAGER` to modify request specifications while in `PENDING` status.
- **FO-MANAGER-15** `[FR-3.5.10]`: The system shall allow the `MANAGER` to cancel pending content requests.

### 5.4 Task Dispatching & Multi-View Oversight

- **FO-MANAGER-16** `[FR-3.6.1]`: The system shall allow the `MANAGER` to enrich backlog tasks with full execution details, acceptance criteria, target publish channels, and due dates.
- **FO-MANAGER-17** `[FR-3.6.2]`: The system shall allow the `MANAGER` to assign tasks to specific `CREATOR` members and designate optional peer-review QC creators.
- **FO-MANAGER-18** `[FR-3.6.3]`: The system shall allow the `MANAGER` to post threaded feedback comments on tasks.
- **FO-MANAGER-19** `[FR-3.6.4]`: The system shall provide the `MANAGER` with a List task view with multi-column sorting.
- **FO-MANAGER-20** `[FR-3.6.5]`: The system shall provide the `MANAGER` with an interactive Calendar task view supporting drag-and-drop rescheduling.
- **FO-MANAGER-21** `[FR-3.6.6]`: The system shall provide the `MANAGER` with a Gantt/Timeline view showing dependency waterfalls.
- **FO-MANAGER-22** `[FR-3.6.7]`: The system shall provide the `MANAGER` with Kanban boards supporting customizable status columns.
- **FO-MANAGER-23** `[FR-3.6.8]`: The system shall provide the `MANAGER` with advanced filtering by assignee, status, channel, tag, priority, and date range.
- **FO-MANAGER-24** `[FR-3.6.9]`: The system shall allow the `MANAGER` to approve creator task deliverables or reject them back to `CREATOR` with revision notes.

---

## 6. Functional Objectives: CREATOR

**Actor Scope:** Content creators, copywriters, graphic designers, and video producers delivering creative output.

### 6.1 Content Authoring & Editor Suite

- **FO-CREATOR-01** `[FR-3.6.10]`: The system shall provide the `CREATOR` with a rich text editor supporting font styling, typography conversion, and full revision version history.
- **FO-CREATOR-02** `[FR-3.6.11]`: The system shall provide the `CREATOR` access to the Workspace Material Repository (raw vs. retouched assets, client brand guidelines).
- **FO-CREATOR-03** `[FR-3.6.12]`: The system shall allow the `CREATOR` to upload creative assets (images, videos, documents) to the Material Repository.
- **FO-CREATOR-04** `[FR-3.6.13]`: The system shall allow the `CREATOR` to update metadata, tags, and retouch statuses of stored materials.
- **FO-CREATOR-05** `[FR-3.6.14]`: The system shall allow the `CREATOR` to remove materials they own or have permission over.
- **FO-CREATOR-06** `[FR-3.6.15]`: The system shall allow the `CREATOR` to apply client brand watermarks to edited graphics and images.
- **FO-CREATOR-07** `[FR-3.6.16]`: The system shall allow the `CREATOR` to download workspace materials to their local environment.
- **FO-CREATOR-08** `[FR-3.6.17]`: The system shall allow the `CREATOR` to apply relevant hashtags to content drafts.
- **FO-CREATOR-09** `[FR-3.6.18]`: The system shall allow the `CREATOR` to view curated hashtag collections.
- **FO-CREATOR-10** `[FR-3.6.19]`: The system shall allow the `CREATOR` to create and tag new hashtag groupings.
- **FO-CREATOR-11** `[FR-3.6.20]`: The system shall allow the `CREATOR` to update hashtag collections.
- **FO-CREATOR-12** `[FR-3.6.21]`: The system shall allow the `CREATOR` to soft-delete unused hashtag collections.

### 6.2 Campaign Formats & Workshop Utilities

- **FO-CREATOR-13** `[FR-3.6.22]`: The system shall provide the `CREATOR` with a structured template to draft livestream ideas and strategic objectives.
- **FO-CREATOR-14** `[FR-3.6.23]`: The system shall allow the `CREATOR` to write timestamped, multi-segment livestream scripts.
- **FO-CREATOR-15** `[FR-3.6.24]`: The system shall allow the `CREATOR` to track live stream preparation milestones.
- **FO-CREATOR-16** `[FR-3.6.25]`: The system shall allow the `CREATOR` to create audience surveys for workshop events.
- **FO-CREATOR-17** `[FR-3.6.26]`: The system shall allow the `CREATOR` to inspect aggregated survey responses and analysis.
- **FO-CREATOR-18** `[FR-3.6.27]`: The system shall allow the `CREATOR` to automatically generate Google Meet session links for planning meetings.
- **FO-CREATOR-19** `[FR-3.6.28-3.6.32]`: The system shall allow the `CREATOR` to create, update, delete, view, and dispatch email templates.
- **FO-CREATOR-20** `[FR-3.6.33]`: The system shall allow the `CREATOR` to run automated compliance checks (plagiarism, policy violations, profanity) on drafted content.
- **FO-CREATOR-21** `[FR-3.6.34]`: The system shall allow the `CREATOR` to scan images and text for potential trademark/copyright conflicts.
- **FO-CREATOR-22** `[FR-3.6.35]`: The system shall allow the `CREATOR` to view version diffs without deducting AI credits when inspecting prior iterations.
- **FO-CREATOR-23** `[FR-3.6.36]`: The system shall provide the `CREATOR` with real-time in-app chat for team collaboration.

### 6.3 AI Generation & Creative Tools

- **FO-CREATOR-24** `[FR-3.7.1]`: The system shall provide the `CREATOR` with trending keyword and topic suggestions derived from automated platform crawlers.
- **FO-CREATOR-25** `[FR-3.7.2]`: The system shall allow the `CREATOR` to generate multi-tone captions using LLM prompts conditioned on brand persona.
- **FO-CREATOR-26** `[FR-3.7.3]`: The system shall allow the `CREATOR` to generate virtual Brand Ambassador models for recurring visual identity.
- **FO-CREATOR-27** `[FR-3.7.4]`: The system shall provide the `CREATOR` with pre-defined visual style templates (e.g., editorial, 3D, anime, cinematic).
- **FO-CREATOR-28** `[FR-3.7.5]`: The system shall allow the `CREATOR` to generate social media imagery using fine-tuned LoRA models and prompt engineering.
- **FO-CREATOR-29** `[FR-3.7.6]`: The system shall provide the `CREATOR` with video style templates.
- **FO-CREATOR-30** `[FR-3.7.7]`: The system shall allow the `CREATOR` to generate video reels and promotional clips via integrated third-party AI video APIs.
- **FO-CREATOR-31** `[FR-3.7.8]`: The system shall allow the `CREATOR` to export generated media assets in multiple standard formats (`MP4`, `WebM`, `PNG`, `JPEG`).
- **FO-CREATOR-32** `[FR-3.7.10]`: The system shall automatically recommend context-aware trending hashtags during content drafting.
- **FO-CREATOR-33** `[FR-3.7.11]`: The system shall generate full livestream script outlines with AI prompts.
- **FO-CREATOR-34** `[FR-3.7.12]`: The system shall recommend 3rd-party media collaborators (electronic press, banner networks) suitable for the campaign.

### 6.4 Multi-Channel Publishing

- **FO-CREATOR-35** `[FR-3.8.5]`: The system shall provide the `CREATOR` with realistic multi-channel post previews (Facebook, Instagram, TikTok, Threads).
- **FO-CREATOR-36** `[FR-3.8.6]`: The system shall allow the `CREATOR` to schedule automated publication times.
- **FO-CREATOR-37** `[FR-3.8.7]`: The system shall allow the `CREATOR` to track execution states (`PENDING`, `IN_PROGRESS`, `DONE`, `FAILED`).
- **FO-CREATOR-38** `[FR-3.8.8-3.8.10]`: The system shall publish finalized posts, stories, and reels to connected Facebook Pages.
- **FO-CREATOR-39** `[FR-3.8.11-3.8.13]`: The system shall publish finalized posts, reels, and stories to connected Instagram Professional accounts.
- **FO-CREATOR-40** `[FR-3.8.14]`: The system shall publish formatted video posts to connected TikTok accounts.
- **FO-CREATOR-41** `[FR-3.8.15]`: The system shall publish text and image threads to connected Threads accounts.

---

## 7. Functional Objectives: CLIENT

**Actor Scope:** External Brand Clients collaborating within the Workspace environment.

### 7.1 Client Profile & Workspace Access

- **FO-CLIENT-01** `[FR-3.3.3]`: The system shall allow the `CLIENT` to view their unified Client Profile reusable across multiple agency workspaces.
- **FO-CLIENT-02** `[FR-3.3.4]`: The system shall allow the `CLIENT` to update their profile details (company name, brand identity, phone, address) while locking the primary email to preserve authentication integrity.
- **FO-CLIENT-03** `[FR-3.4.13]`: The system shall allow the `CLIENT` to inspect Workspace details, branding parameters, and operational timezone.
- **FO-CLIENT-04** `[FR-3.4.18]`: The system shall allow the `CLIENT` to view the designated agency team members assigned to their Workspace.
- **FO-CLIENT-05** `[FR-3.4.16]`: The system shall allow the `CLIENT` to leave a Workspace when collaboration terminates.

### 7.2 Media Package, Campaign Approval & Requests

- **FO-CLIENT-06** `[FR-3.5.2]`: The system shall allow the `CLIENT` to review proposed Media Package templates with scope, timeline, and pricing breakdown.
- **FO-CLIENT-07** `[FR-3.5.3]`: The system shall allow the `CLIENT` to request revisions, negotiate deliverables, and adjust package scope.
- **FO-CLIENT-08** `[FR-3.5.4]`: The system shall allow the `CLIENT` to formally approve the agreed Media Package.
- **FO-CLIENT-09** `[FR-3.5.6]`: The system shall allow the `CLIENT` to review and approve the detailed Media Campaign strategy before task generation.
- **FO-CLIENT-10** `[FR-3.5.7]`: The system shall allow the `CLIENT` to create ad-hoc Content Requests directly from the client portal.
- **FO-CLIENT-11** `[FR-3.5.8]`: The system shall allow the `CLIENT` to track real-time processing status of their submitted requests.
- **FO-CLIENT-12** `[FR-3.5.9]`: The system shall allow the `CLIENT` to edit request details while in `PENDING` status.
- **FO-CLIENT-13** `[FR-3.5.10]`: The system shall allow the `CLIENT` to cancel pending content requests.

### 7.3 Task Review, Comments & Approval Chain

- **FO-CLIENT-14** `[FR-3.6.3]`: The system shall allow the `CLIENT` to post comments and attach feedback on completed deliverables.
- **FO-CLIENT-15** `[FR-3.6.4-3.6.7]`: The system shall provide the `CLIENT` with read-only views of the Task List, Calendar, Gantt timeline, and Kanban boards.
- **FO-CLIENT-16** `[FR-3.6.9]`: The system shall allow the `CLIENT` to perform final client approval or reject content with specific feedback before scheduled publication.
- **FO-CLIENT-17** `[FR-3.6.11]`: The system shall allow the `CLIENT` to upload official Brand Assets and Guidelines into the Workspace repository.

### 7.4 Social Account Integration & Analytics

- **FO-CLIENT-18** `[FR-3.8.1]`: The system shall allow the `CLIENT` to authenticate and authorize social media accounts (Facebook Pages, Instagram Business, TikTok, Threads) via OAuth 2.0.
- **FO-CLIENT-19** `[FR-3.8.2]`: The system shall allow the `CLIENT` to revoke and disconnect authorized social media channels at any time.
- **FO-CLIENT-20** `[FR-3.8.3]`: The system shall provide the `CLIENT` with a real-time post monitoring dashboard inside the workspace.
- **FO-CLIENT-21** `[FR-3.8.4]`: The system shall provide the `CLIENT` with comprehensive post performance metrics (reactions, comments, shares, video views).

---

## 8. Requirements Traceability Matrix Summary

| Role      | Core Functional Modules Covered                                                  | Total Objectives | Primary Output Artifacts                            |
| --------- | -------------------------------------------------------------------------------- | :--------------: | --------------------------------------------------- |
| `GUEST`   | Authentication, Sign Up, Sign In, Google OAuth, Password Recovery                |        6         | JWT Auth Endpoints, Login/Register UI               |
| `ADMIN`   | User Management, Health Monitor, Revenue, Content Moderation, Crawlers           |        12        | Admin Dashboard, System Crawlers, PDF Reports       |
| `OWNER`   | Agency Profile, Members, Workspaces, PayOS Billing, AI Credit Quotas             |        24        | Agency Portal, PayOS Integration, Invoice History   |
| `MANAGER` | Workspace Admin, Package/Campaign, Backlog, Task Assign, Multi-view              |        24        | Campaign Backlog, 4-View Task Board, Approval Gates |
| `CREATOR` | Rich Text Editor, Material Repo, AI LLM/LoRA/Video, Auto-Publishing              |        41        | Content Studio, AI Microservice, RabbitMQ Publisher |
| `CLIENT`  | Client Profile, Social OAuth Connect, Request Intake, Client Approval, Analytics |        21        | Client Portal, Social OAuth Tokens, Metrics View    |
| **Total** | **All 10 Feature Domains (3.2 – 3.10)**                                          |     **128**      | **Comprehensive Feature Baseline**                  |

---
