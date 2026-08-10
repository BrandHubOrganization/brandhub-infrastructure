# BrandHub — SEP490 Document Plan & Task Details

> Kế hoạch viết 3 capstone reports cho SEP490 Fall 2026.
> **Deadline:** August 28, 2026.
> Mỗi task ghi rõ: Report → Section → Mục. Click **Task ID** để nhảy tới chi tiết Phần 2.

## Mục lục

- [Phần 1 — Tổng quan & Bảng Task](#phần-1--tổng-quan--bảng-task)
- [Phần 2 — Chi tiết Task](#phần-2--chi-tiết-task)

---

# PHẦN 1 — TỔNG QUAN & BẢNG TASK

---

## TEAM & PROJECT INFO

| Field | Detail |
|---|---|
| Project | BrandHub — AI-Powered Multi-Channel Content Platform |
| Course | SEP490 — Capstone Project, FPT University |
| Team | Trung (Leader), Lộc (AI Sub-lead), Tuấn (AI), Ân (AI), Phước (Publisher) |
| Reports | Report 1 (Project Introduction), Report 2 (Project Management Plan), Report 3 (Software Requirement Specification) |
| Language | English (mandatory) |
| Deadline | August 28, 2026 |
| Total Tasks | ~75 document tasks |

---

## REPORT OVERVIEW

| Report | Title | Pages | Key Content |
|---|---|---|---|
| R1 | Project Introduction | ~15 | §1 Overview → §2 Product Background → §3 Existing Systems → §4 Business Opportunity → §5 Product Vision → §6 Scope & Limitations → §7 References |
| R2 | Project Management Plan | ~25 | §1 Overview (WBS, Objectives, Risks) → §2 Mgmt Approach (Process, Quality, Training) → §3 Deliverables → §4 Responsibility → §5 Communications → §6 Config Mgmt (Docs, Source, Tools) |
| R3 | Software Requirement Specification | ~180 | §1 Product Overview → §2 User Requirements (Actors, Use Cases) → §3 Functional Requirements (3.1 System Overview → 3.2-3.27 Feature Groups) → §4 NFR → §5 Appendix (Business Rules, Messages) |

---

## ROLES

| Role | Assignee | Description |
|---|---|---|
| Diagram Team | Tuấn, Lộc, Phước | Vẽ 16 diagrams trước Aug 18 |
| Diagram Reviewer | Trung | Review consistency toàn bộ diagram |
| Content Writers | All 5 members | Viết nội dung sau khi diagram duyệt |
| Report 1 Reviewer | Trung (lead), Lộc, Tuấn, Ân | Cross-review R1, mỗi người 1 task riêng |
| Report 2 Reviewer | Trung (lead), Phước, Tuấn, Ân | Cross-review R2, mỗi người 1 task riêng |
| Report 3 Reviewer | Trung (lead), all members | Cross-review R3, mỗi người 1 task riêng |
| Final Merge | Trung | Merge 3 reports, format consistency |

---

## PRIORITY LEGEND

| Symbol | Meaning |
|---|---|
| 🔴 Critical | Blocking, core diagrams (Context, UC, ERD), must finish first |
| 🟡 High | Important sections, functional requirements, screen descriptions |
| 🟢 Medium | Supporting sections, appendices |

---

## TIMELINE

| Milestone | Date | Deliverable |
|---|---|---|
| M1 — Diagrams Done | Aug 18 | 16 diagrams reviewed & approved |
| M2 — Draft v1 | Aug 21 | All text sections written |
| M3 — Review Complete | Aug 23 | Cross-review done, feedback collected |
| M4 — Final v2 | Aug 25 | All feedback addressed |
| M5 — Merged | Aug 27 | 3 reports merged, formatted, TOC updated |
| M6 — Submit | Aug 28 | Submit to exam committee |

---

## PHASE 1 — Diagrams (Aug 9 → Aug 18)

> Đội vẽ: Tuấn (5), Lộc (6), Phước (5). Trung review toàn bộ.

---

### EPIC D01 — Context & Architecture Diagrams

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| [DA-D01-01](#da-d01-01) | **[R3 §1]** Draw Context Diagram — BrandHub + 6 external services (Groq API, Stability AI, Google Veo, Facebook Graph, TikTok, Zalo OA) | Tuấn | 🔴 |
| [DA-D01-02](#da-d01-02) | **[R3 §1]** Draw System Architecture Diagram — 6 services + 5 DBs + message queue + AWS S3 | Phước | 🔴 |
| [DA-D01-03](#da-d01-03) | **[R2 §1.1]** Draw WBS Tree — hierarchical breakdown of 16 sprints + 4 AI iterations | Phước | 🔴 |
| [DA-D01-04](#da-d01-04) | **[R2 §2.1]** Draw Scrum Sprint Timeline — 16 sprints × 2 weeks + 4 AI iterations, Gantt-style | Phước | 🔴 |

---

### EPIC D02 — Use Case & ERD Diagrams

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| [DA-D02-01](#da-d02-01) | **[R3 §2.2]** Draw Use Case Overview Diagram — 60 use cases × 6 roles | Tuấn | 🔴 |
| [DA-D02-02](#da-d02-02) | **[R3 §3.1.3]** Draw ERD — 12 MongoDB collections + 5 PostgreSQL tables + relationships | Tuấn | 🔴 |
| [DA-D02-03](#da-d02-03) | **[R2 §6.2]** Draw Git Branch Strategy — polyrepo, main/develop/feature/release | Lộc | 🟢 |
| [DA-D02-04](#da-d02-04) | **[R2 §6.1]** Draw Repository & Folder Structure — 7 repos + Google Drive structure | Lộc | 🟢 |

---

### EPIC D03 — Screen Flows & Mockups

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| [DA-D03-01](#da-d03-01) | **[R3 §3.1.1]** Draw Screen Flow — ADMIN (Dashboard → User Mgmt → Content Moderation → Analytics → System Config) | Lộc | 🔴 |
| [DA-D03-02](#da-d03-02) | **[R3 §3.1.1]** Draw Screen Flow — AGENCY_OWNER (Workspace Setup → Team Mgmt → Client Mgmt → Billing → Analytics) | Lộc | 🔴 |
| [DA-D03-03](#da-d03-03) | **[R3 §3.1.1]** Draw Screen Flow — ACCOUNT_MANAGER (Client List → Content Review → Approval → Reports) | Phước | 🔴 |
| [DA-D03-04](#da-d03-04) | **[R3 §3.1.1]** Draw Screen Flow — CONTENT_CREATOR (Content Editor → AI Generate → Calendar → Knowledge Base → Posts) | Phước | 🔴 |
| [DA-D03-05](#da-d03-05) | **[R3 §3.1.1]** Draw Screen Flow — BRAND_CLIENT (Client Portal → Calendar → Approve/Reject → Analytics View) | Tuấn | 🔴 |
| [DA-D03-06](#da-d03-06) | **[R3 §3.1.1]** Draw Screen Flow — GUEST (Landing Page → Register → Login) | Tuấn | 🔴 |
| [DA-D03-07](#da-d03-07) | **[R3 §3.1.2]** Draw Screen Authorization Matrix — all screens × 6 roles (X/—) | Lộc | 🟡 |
| [DA-D03-08](#da-d03-08) | **[R3 §3.1.1]** Export Screen Mockups from Figma — all 10 main screens with annotations | Lộc | 🟡 |

---

### EPIC D04 — Diagram Review

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| [DA-D04-01](#da-d04-01) | Review all 16 diagrams for consistency: notation, color, font, naming, cross-reference accuracy | Trung | 🔴 |

---

## PHASE 2 — Report 1: Project Introduction (Aug 18 → Aug 21)

> ~15 trang. Viết sau khi diagram duyệt.

---

### EPIC D05 — R1 §2-3: Product Background & Existing Systems

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| [DA-D05-01](#da-d05-01) | **[R1 §2]** Write Product Background — marketing agency pain points, multi-channel content fragmentation | Lộc | 🟡 |
| [DA-D05-02](#da-d05-02) | **[R1 §3]** Analyze 2 Existing Systems — competitors pros/cons table, BrandHub differentiators | Lộc | 🟡 |

---

### EPIC D06 — R1 §4-5: Business Opportunity & Vision

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| [DA-D06-01](#da-d06-01) | **[R1 §4]** Write Business Opportunity — Vietnam marketing agency market, digital transformation, AI adoption trends | Tuấn | 🟡 |
| [DA-D06-02](#da-d06-02) | **[R1 §5]** Write Software Product Vision — "For marketing agencies who need multi-channel content at scale..." | Tuấn | 🟡 |

---

### EPIC D07 — R1 §6-7: Scope, Limitations & References

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| [DA-D07-01](#da-d07-01) | **[R1 §6.1]** Write Project Scope & Major Features — FE-01 to FE-NN feature groups with sub-features | Ân | 🟡 |
| [DA-D07-02](#da-d07-02) | **[R1 §6.2]** Write Limitations & Exclusions — what BrandHub does NOT do (5-7 items: LI-01 to LI-07) | Ân | 🟡 |
| [DA-D07-03](#da-d07-03) | **[R1 §7]** Compile References — FPT materials, external API docs, tech stack references | Ân | 🟢 |

---

## PHASE 3 — Report 2: Project Management Plan (Aug 18 → Aug 21)

> ~25 trang. Viết sau khi diagram duyệt.

---

### EPIC D08 — R2 §1: Overview (WBS, Objectives, Risks)

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| [DA-D08-01](#da-d08-01) | **[R2 §1.1]** Write WBS with Complexity & Man-days — 16 sprints + 46 epics, complexity (S/M/C), estimated man-days, grand total | Trung | 🔴 |
| [DA-D08-02](#da-d08-02) | **[R2 §1.2]** Write Project Objectives — 7 objectives with priority levels, quality metrics | Trung | 🟡 |
| [DA-D08-03](#da-d08-03) | **[R2 §1.3]** Write Project Risks — 8-10 risks with Impact, Possibility, Response Plans | Trung | 🟡 |

---

### EPIC D09 — R2 §2: Management Approach & Quality

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| [DA-D09-01](#da-d09-01) | **[R2 §2.1]** Write Management Approach — Scrum, 16 sprints + 4 AI iterations, sprint activities & deliverables | Phước | 🔴 |
| [DA-D09-02](#da-d09-02) | **[R2 §2.2]** Write Quality Management — 5 levels: Defect Prevention, Code Review, Unit/Integration/System/UAT Testing | Phước | 🟡 |

---

### EPIC D10 — R2 §3, §5, §6: Deliverables, Communications, Config

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| [DA-D10-01](#da-d10-01) | **[R2 §3]** Write Project Deliverables — 21+ deliverables with due dates | Phước | 🟡 |
| [DA-D10-02](#da-d10-02) | **[R2 §5]** Write Project Communications — matrix: who, purpose, frequency, tool | Phước | 🟢 |
| [DA-D10-03](#da-d10-03) | **[R2 §6]** Write Configuration Management — §6.1 Document Mgmt (Google Drive), §6.2 Source Code Mgmt (branching, PR rules), §6.3 Tools & Infrastructures | Phước | 🟢 |

---

### EPIC D11 — R2 §2.3, §4, §6.3: Training, Responsibility, Tools

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| [DA-D11-01](#da-d11-01) | **[R2 §2.3]** Write Training Plan — training areas, participants, duration, waiver criteria | Tuấn | 🟢 |
| [DA-D11-02](#da-d11-02) | **[R2 §4]** Write Responsibility Assignments — D/R/S/I matrix (5 members × N work items) | Ân | 🟡 |
| [DA-D11-03](#da-d11-03) | **[R2 §6.3]** Write Tools & Infrastructures table — Technology, Database, IDEs, Diagramming, Documentation, Version Control, Deployment, PM | Ân | 🟢 |

---

## PHASE 4 — Report 3: Software Requirement Specification (Aug 18 → Aug 21)

> ~180 trang — report nặng nhất.

---

### EPIC D12 — R3 §1: Product Overview & System Context

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| [DA-D12-01](#da-d12-01) | **[R3 §1]** Write Product Overview — BrandHub description, 6 roles, tech stack, core capabilities | Trung | 🔴 |
| [DA-D12-02](#da-d12-02) | **[R3 §1]** Write Context Diagram Description — system boundary, 6 external services, data flows | Trung | 🟡 |
| [DA-D12-03](#da-d12-03) | **[R3 §3.1.3]** Write ERD Description — 12 MongoDB collections + 5 PostgreSQL tables, entity descriptions | Trung | 🟡 |

---

### EPIC D13 — R3 §2: User Requirements (Actors & Use Cases)

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| [DA-D13-01](#da-d13-01) | **[R3 §2.1]** Write Actors Description — 6 roles: ADMIN, AGENCY_OWNER, ACCOUNT_MANAGER, CONTENT_CREATOR, BRAND_CLIENT, GUEST | Tuấn | 🔴 |
| [DA-D13-02](#da-d13-02) | **[R3 §2.2]** Write Use Case Descriptions — ADMIN + AGENCY_OWNER (~20 UCs): ID, Actor, Description, Main/Alternative Flows | Lộc | 🔴 |
| [DA-D13-03](#da-d13-03) | **[R3 §2.2]** Write Use Case Descriptions — ACCOUNT_MANAGER + CONTENT_CREATOR + BRAND_CLIENT + GUEST (~40 UCs) | Tuấn | 🔴 |

---

### EPIC D14 — R3 §3.1: System Functional Overview (Screens)

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| [DA-D14-01](#da-d14-01) | **[R3 §3.1.1]** Write Screen Descriptions — ADMIN + AGENCY_OWNER screens (#, Feature, Screen, Description) | Lộc | 🟡 |
| [DA-D14-02](#da-d14-02) | **[R3 §3.1.1]** Write Screen Descriptions — ACCOUNT_MANAGER + CONTENT_CREATOR screens | Phước | 🟡 |
| [DA-D14-03](#da-d14-03) | **[R3 §3.1.1]** Write Screen Descriptions — BRAND_CLIENT + GUEST screens | Tuấn | 🟡 |
| [DA-D14-04](#da-d14-04) | **[R3 §3.1.4]** Write Non-Screen Functions — background jobs, callbacks, cron schedules (~12-15 functions) | Tuấn | 🟡 |

---

### EPIC D15 — R3 §3.2-3.5: FR — Auth & Core Business

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| [DA-D15-01](#da-d15-01) | **[R3 §3.2]** Write FR — Authentication & Authorization: Register, Login (Email+Google), OAuth (5 platforms), 2FA, Forgot/Reset/Change Password, OTP, Token Refresh, Sign Out (~10 functions) | Trung | 🔴 |
| [DA-D15-02](#da-d15-02) | **[R3 §3.3]** Write FR — User & Profile Management: View/Update Profile, Avatar Upload, Identity Verification, Account Deactivation (~5 functions) | Trung | 🟡 |
| [DA-D15-03](#da-d15-03) | **[R3 §3.4]** Write FR — Workspace Management: Create/Update/Delete Workspace, Manage Members, Multi-tenancy Data Isolation (~6 functions) | Trung | 🟡 |
| [DA-D15-04](#da-d15-04) | **[R3 §3.5]** Write FR — RBAC: Role Assignment, Permission Matrix, Access Control Enforcement (~4 functions) | Trung | 🟡 |

---

### EPIC D16 — R3 §3.6-3.10: FR — Content & Workflow

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| [DA-D16-01](#da-d16-01) | **[R3 §3.6]** Write FR — Content Request Management: Create Request, Assign Task, Track Status, Revise, Cancel (~6 functions) | Lộc | 🟡 |
| [DA-D16-02](#da-d16-02) | **[R3 §3.7]** Write FR — Content Calendar & Scheduling: Day/Week/Month View, Drag-drop Schedule, Recurring Posts, Timezone (~5 functions) | Lộc | 🟡 |
| [DA-D16-03](#da-d16-03) | **[R3 §3.8]** Write FR — Approval Workflow: Submit for Review, Approve/Reject with Comments, Revision Loop, Approval Chain (~5 functions) | Lộc | 🟡 |
| [DA-D16-04](#da-d16-04) | **[R3 §3.9]** Write FR — Client Portal: Client Login, View Calendar, Approve/Reject Content, View Analytics, Comments (~5 functions) | Lộc | 🟡 |
| [DA-D16-05](#da-d16-05) | **[R3 §3.10]** Write FR — Agency & Client Management: CRUD Clients, Assign Account Manager, Client Onboarding, Settings (~6 functions) | Lộc | 🟡 |

---

### EPIC D17 — R3 §3.11-3.16: FR — AI Features

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| [DA-D17-01](#da-d17-01) | **[R3 §3.11]** Write FR — AI Content Generation: Text Gen (caption, blog, ad copy), Tone/Brand Voice, Anti-Hallucination, History (~4 functions) | Tuấn | 🟡 |
| [DA-D17-02](#da-d17-02) | **[R3 §3.12]** Write FR — AI Image Generation: Text-to-Image, Style Presets, Brand Assets, Variations, Background Removal (~4 functions) | Tuấn | 🟡 |
| [DA-D17-03](#da-d17-03) | **[R3 §3.13]** Write FR — AI Video Generation: Script-to-Video, Template Selection, Scene Mapping, Export Formats (~4 functions) | Tuấn | 🟡 |
| [DA-D17-04](#da-d17-04) | **[R3 §3.14]** Write FR — Virtual Brand Ambassador: Face Upload, InstantID Setup, Ambassador Video Gen, Management (~4 functions) | Tuấn | 🟡 |
| [DA-D17-05](#da-d17-05) | **[R3 §3.15]** Write FR — RAG Knowledge Base: Document Upload, Chunking, Embedding, Brand Voice Training, Knowledge Search (~5 functions) | Tuấn | 🟡 |
| [DA-D17-06](#da-d17-06) | **[R3 §3.16]** Write FR — Trend Crawler: Keyword Config, Auto-crawl Schedule, Trending Topics Dashboard, Trend-to-Content (~4 functions) | Tuấn | 🟡 |

---

### EPIC D18 — R3 §3.17-3.23: FR — Publishing & Social

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| [DA-D18-01](#da-d18-01) | **[R3 §3.17]** Write FR — Social Account Management: Connect (OAuth), Disconnect, Token Status, Refresh, Platform Limits (~5 functions) | Phước | 🟡 |
| [DA-D18-02](#da-d18-02) | **[R3 §3.18]** Write FR — Facebook Publishing: Text/Image/Video Post, Carousel, Schedule, Preview, Publish Status (~4 functions) | Phước | 🔴 |
| [DA-D18-03](#da-d18-03) | **[R3 §3.19]** Write FR — TikTok Publishing: Video Upload, Caption, Hashtags, Schedule, Status Tracking (~3 functions) | Phước | 🟡 |
| [DA-D18-04](#da-d18-04) | **[R3 §3.20]** Write FR — Instagram & Threads Publishing: Image/Reel Post, Carousel, Story, Thread (~4 functions) | Phước | 🟡 |
| [DA-D18-05](#da-d18-05) | **[R3 §3.21]** Write FR — Zalo OA Publishing: Text/Image Broadcast, Template Message, Schedule, Rate Limit Handling (~3 functions) | Phước | 🟡 |
| [DA-D18-06](#da-d18-06) | **[R3 §3.22]** Write FR — Publish Error Handling: Retry Logic (3x exponential backoff), Dead Letter Queue, Error Notifications, Manual Retry (~4 functions) | Phước | 🟡 |
| [DA-D18-07](#da-d18-07) | **[R3 §3.23]** Write FR — Notifications: In-App, Email, Push (FCM), Preferences, Notification Center UI (~5 functions) | Phước | 🟡 |

---

### EPIC D19 — R3 §3.24-3.27: FR — Subscription, Analytics, Admin, Mobile

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| [DA-D19-01](#da-d19-01) | **[R3 §3.24]** Write FR — Subscription & Billing: Plan Selection (Free/Basic/Pro/Enterprise), Payment Integration, Invoice History, AI Credit Tracking, Upgrade/Downgrade (~5 functions) | Ân | 🟡 |
| [DA-D19-02](#da-d19-02) | **[R3 §3.25]** Write FR — Analytics & Reporting: Content Performance, Platform Analytics, Team Productivity, Export PDF/Excel, Scheduled Reports (~5 functions) | Ân | 🟡 |
| [DA-D19-03](#da-d19-03) | **[R3 §3.26]** Write FR — Admin Dashboard: User Management, Content Moderation, System Health, Platform Stats (~5 functions) | Ân | 🟡 |
| [DA-D19-04](#da-d19-04) | **[R3 §3.27]** Write FR — Mobile App Features: Mobile Auth, Dashboard, Calendar, Push Notifications, Approval on Mobile, Content Preview (~6 functions) | Ân | 🟡 |

---

### EPIC D20 — R3 §4-5: NFR & Appendices

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| [DA-D20-01](#da-d20-01) | **[R3 §4]** Write Non-Functional Requirements — §4.1 External Interfaces (Payment, OAuth, Maps, FCM, Email/SMS), §4.2 Quality Attributes (Usability, Reliability 99.5%, Performance <2s, Security, Compatibility, Maintainability, Legal) | Trung | 🔴 |
| [DA-D20-02](#da-d20-02) | **[R3 §5.1]** Compile Business Rules Appendix — BR-01 through BR-NN from all FR sections | Ân | 🟡 |
| [DA-D20-03](#da-d20-03) | **[R3 §5.3]** Compile Message Lists Appendix — MSG01 through MSG-NN (Code, Type, Context, Content) | Ân | 🟡 |

---

## PHASE 5 — Review, Merge & Submit (Aug 21 → Aug 28)

---

### EPIC D21 — Review & Feedback (mỗi reviewer 1 task riêng)

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| [DA-D21-01](#da-d21-01) | **[R1]** Review Report 1 — cross-check content accuracy against docs repo | Trung | 🔴 |
| [DA-D21-02](#da-d21-02) | **[R1]** Review Report 1 — cross-check content accuracy against docs repo | Lộc | 🔴 |
| [DA-D21-03](#da-d21-03) | **[R1]** Review Report 1 — cross-check content accuracy against docs repo | Tuấn | 🔴 |
| [DA-D21-04](#da-d21-04) | **[R1]** Review Report 1 — cross-check content accuracy against docs repo | Ân | 🔴 |
| [DA-D21-05](#da-d21-05) | **[R2]** Review Report 2 — check WBS consistency with Jira, man-days realistic | Trung | 🔴 |
| [DA-D21-06](#da-d21-06) | **[R2]** Review Report 2 — check WBS consistency with Jira, man-days realistic | Phước | 🔴 |
| [DA-D21-07](#da-d21-07) | **[R2]** Review Report 2 — check WBS consistency with Jira, man-days realistic | Tuấn | 🔴 |
| [DA-D21-08](#da-d21-08) | **[R2]** Review Report 2 — check WBS consistency with Jira, man-days realistic | Ân | 🔴 |
| [DA-D21-09](#da-d21-09) | **[R3]** Review Report 3 — check FR matches implementation, UC descriptions match flows, screen flows consistent with Figma | Trung | 🔴 |
| [DA-D21-10](#da-d21-10) | **[R3]** Review Report 3 — check FR matches implementation, UC descriptions match flows, screen flows consistent with Figma | Lộc | 🔴 |
| [DA-D21-11](#da-d21-11) | **[R3]** Review Report 3 — check FR matches implementation, UC descriptions match flows, screen flows consistent with Figma | Phước | 🔴 |
| [DA-D21-12](#da-d21-12) | **[R3]** Review Report 3 — check FR matches implementation, UC descriptions match flows, screen flows consistent with Figma | Tuấn | 🔴 |
| [DA-D21-13](#da-d21-13) | **[R3]** Review Report 3 — check FR matches implementation, UC descriptions match flows, screen flows consistent with Figma | Ân | 🔴 |
| [DA-D21-14](#da-d21-14) | Address Review Feedback — Trung tổng hợp feedback, phân công fix theo từng section | Trung | 🔴 |
| [DA-D21-15](#da-d21-15) | Address Review Feedback — fix các section mình phụ trách theo feedback | Lộc | 🔴 |
| [DA-D21-16](#da-d21-16) | Address Review Feedback — fix các section mình phụ trách theo feedback | Phước | 🔴 |
| [DA-D21-17](#da-d21-17) | Address Review Feedback — fix các section mình phụ trách theo feedback | Tuấn | 🔴 |
| [DA-D21-18](#da-d21-18) | Address Review Feedback — fix các section mình phụ trách theo feedback | Ân | 🔴 |

---

### EPIC D22 — Merge & Format

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| [DA-D22-01](#da-d22-01) | **[R1]** Merge Report 1 — combine sections, update TOC, add Record of Changes, consistent formatting | Trung | 🔴 |
| [DA-D22-02](#da-d22-02) | **[R2]** Merge Report 2 — combine sections, update TOC, add Record of Changes, consistent formatting | Trung | 🔴 |
| [DA-D22-03](#da-d22-03) | **[R3]** Merge Report 3 — combine sections, update TOC, add Record of Changes, consistent formatting (~180 pages) | Trung | 🔴 |
| [DA-D22-04](#da-d22-04) | Final Format Check — page numbers, header/footer, figure/table numbering, cross-references, English spelling/grammar, font consistency | Trung | 🔴 |

---

### EPIC D23 — Final Package & Submission

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| [DA-D23-01](#da-d23-01) | Prepare Final Submission Package — 3 PDFs + source docx, upload to Google Drive | Trung | 🔴 |
| [DA-D23-02](#da-d23-02) | Prepare Presentation Summary — key points from each report for Aug 28 presentation | Trung | 🟡 |

---

## SPRINT SUMMARY TABLE

| Phase | Timeline | Key Deliverables |
|---|---|---|
| Phase 1 — Diagrams | Aug 9 → Aug 18 | 16 diagrams (Context, Architecture, Use Case, ERD, 6 Screen Flows, Auth Matrix, WBS Tree, Scrum Timeline, Branch Strategy, Folder Structure, Mockups) |
| Phase 2 — R1 Writing | Aug 18 → Aug 21 | Report 1 Draft: §1 Overview → §2 Product Background → §3 Existing Systems → §4 Business Opportunity → §5 Product Vision → §6 Scope & Limitations → §7 References |
| Phase 3 — R2 Writing | Aug 18 → Aug 21 | Report 2 Draft: §1 Overview (WBS, Objectives, Risks) → §2 Mgmt Approach (Process, Quality, Training) → §3 Deliverables → §4 Responsibility → §5 Communications → §6 Config Mgmt |
| Phase 4 — R3 Writing | Aug 18 → Aug 21 | Report 3 Draft: §1 Product Overview → §2 User Requirements → §3 Functional Requirements (§3.1-§3.27) → §4 NFR → §5 Appendix |
| Phase 5 — Review & Merge | Aug 21 → Aug 27 | Cross-review (13 individual review tasks + 5 fix tasks), 3 reports merged & formatted, final PDF package |
| Submit | Aug 28 | Submit to exam committee, presentation |

---

## WORKLOAD DISTRIBUTION TABLE

| Member | Tasks | Breakdown |
|---|---|---|
| Trung | ~20 | Diagram review (1), WBS + Objectives + Risks (3), Product Overview + Context + ERD (3), Auth/User/Workspace/RBAC FR (4), NFR (1), Merge 3 reports + Format (4), Review R1/R2/R3 (3), Feedback coord (1), Final package + Presentation (2) |
| Lộc | ~12 | Branch Strategy + Folder Structure (2), Screen Flow Admin + Agency Owner (2), Auth Matrix + Mockups (2), Product Background + Existing Systems (2), UC Admin/Agency (1), Screen Desc Admin/Agency (1), Content/Calendar/Approval/Client/Agency FR (5), Review R1/R3 (2), Fix feedback (1) — _total counted once_ |
| Phước | ~15 | Architecture + WBS Tree + Scrum Timeline (3), Screen Flow AM + CC (2), Mgmt Approach + Quality (2), Deliverables + Communications + Config Mgmt (3), Screen Desc AM/CC (1), Publishing/Social/Notifications FR (7), Review R2/R3 (2), Fix feedback (1) |
| Tuấn | ~16 | Context + UC Overview + ERD + Screen Flow Brand/Guest (5), Business Opportunity + Product Vision (2), Training Plan (1), Actors (1), UC AC/CC/BC/Guest (1), Screen Desc Brand/Guest + Non-Screen (2), AI Features FR (6), Review R1/R2/R3 (3), Fix feedback (1) |
| Ân | ~13 | Scope + Limitations + References (3), Responsibility + Tools (2), Subscription/Analytics/Admin/Mobile FR (4), Business Rules + Messages (2), Review R1/R2/R3 (3), Fix feedback (1) |

> **Tổng:** ~66 individual tasks (đã tách review thành task cá nhân). Mỗi task 1 assignee duy nhất.

---

## NOTES

- Tất cả nội dung report viết bằng **English** (SEP490 requirement).
- Mỗi task có **1 assignee duy nhất** — không còn task gán nhiều người.
- Mỗi task ghi rõ **[Report § Section]** để biết chính xác vị trí trong report.
- Diagram team (Tuấn, Lộc, Phước) vẽ Phase 1 trước. Sau khi diagram duyệt Aug 18, toàn team viết song song Phase 2-4.
- Functional Requirements format theo sample: Function Trigger → Description → Screen Layout → Data → Business Rules → Normal Flow → Abnormal Cases → Post-Conditions.
- Source mọi technical facts từ `brandhub-infrastructure/docs/`. Không tự bịa.
- Task ID format: `DA-D{EPIC}-{SEQ}`.
- Record of Changes table phải update trước khi submit mỗi report.

---

# PHẦN 2 — CHI TIẾT TASK

> Mỗi task: Goal, Acceptance Criteria, Source References, Dependencies.

---

## PHASE 1 — Diagrams

---

### DA-D01-01 — [R3 §1] Draw Context Diagram

- **Goal:** Vẽ context diagram: BrandHub center + 6 external services. Dùng cho R3 §1 (Product Overview). Diagram đầu tiên — set style chuẩn.

- **Acceptance Criteria:**
  - BrandHub system boundary rõ ràng
  - 6 external services: Groq API, Stability AI, Google Veo, Facebook Graph API, TikTok Content API, Zalo OA API
  - 6 actors: ADMIN, AGENCY_OWNER, ACCOUNT_MANAGER, CONTENT_CREATOR, BRAND_CLIENT, GUEST
  - Data flow arrows có label (REST API, RabbitMQ, OAuth 2.0, File Upload)
  - Style thống nhất (màu, font, kích thước)
  - Format: PNG + editable source (draw.io/StarUML)

- **Source References:** `docs/architecture/`, `docs/plan/BrandHub_Master_Plan.md#system-architecture`

- **Dependencies:** None

---

### DA-D01-02 — [R3 §1] Draw System Architecture Diagram

- **Goal:** Kiến trúc microservices 3D/layer. Dùng cho R3 §1.

- **Acceptance Criteria:**
  - 3 tầng: Client → Gateway → Services
  - 5 databases: MongoDB, PostgreSQL, Redis, ChromaDB, RabbitMQ, AWS S3
  - Communication protocols labeled
  - 7 GitHub repos, port numbers

- **Source References:** `docs/plan/BrandHub_Master_Plan.md#system-architecture`, `docs/architecture/`

- **Dependencies:** DA-D01-01 (shared style)

---

### DA-D01-03 — [R2 §1.1] Draw WBS Tree

- **Goal:** WBS phân cấp: Project → Phase → Sprint → Epic. Dùng cho R2 §1.1.

- **Acceptance Criteria:**
  - 3-4 cấp: BrandHub → 3 Phases → 16 Sprints + 4 AI Iterations → 46 Epics
  - Mỗi node có label + man-days
  - Complexity màu: Simple (xanh), Medium (vàng), Complex (đỏ)
  - Tổng ~860-900 man-days

- **Source References:** `docs/plan/BrandHub_Master_Plan.md`, `docs/plan/sprints/README.md`

- **Dependencies:** DA-D01-04 (sync timeline)

---

### DA-D01-04 — [R2 §2.1] Draw Scrum Sprint Timeline

- **Goal:** Gantt timeline 16 sprints + 4 AI iterations. Dùng cho R2 §2.1.

- **Acceptance Criteria:**
  - Trục X: Week 1 → Week 32
  - 16 sprint bars (2 tuần/sprint), 4 AI iteration bars song song
  - Milestone markers, key deliverables trên mỗi bar
  - Legend: Sprint (xanh), AI (cam), Milestone (đỏ)

- **Source References:** `docs/plan/sprints/README.md`, `docs/iterations/README.md`

- **Dependencies:** DA-D01-03

---

### DA-D02-01 — [R3 §2.2] Draw Use Case Overview Diagram

- **Goal:** 60 use cases, 6 actors. Dùng cho R3 §2.2.

- **Acceptance Criteria:**
  - 6 actor stick figures, 60 use case ovals grouped by functional area
  - <<include>>, <<extend>> relationships
  - System boundary box

- **Source References:** `docs/plan/sprints/sprint_02/PLAN.md#epic-e03`, `docs/api/endpoints/`

- **Dependencies:** DA-D01-01

---

### DA-D02-02 — [R3 §3.1.3] Draw ERD

- **Goal:** 12 MongoDB collections + 5 PostgreSQL tables. Dùng cho R3 §3.1.3.

- **Acceptance Criteria:**
  - Field names, types, required/optional
  - Relationships: crow's foot notation
  - Color: MongoDB (xanh), PostgreSQL (tím)
  - Entity description table

- **Source References:** `docs/plan/sprints/sprint_03/PLAN.md#epic-e06`, `docs/database/`

- **Dependencies:** DA-D01-02

---

### DA-D02-03 — [R2 §6.2] Draw Git Branch Strategy

- **Goal:** Branching strategy polyrepo. Dùng cho R2 §6.2.

- **Acceptance Criteria:**
  - main, develop, feature/<service>/<desc>, release/<ver>, hotfix/<desc>
  - PR workflow: feature → develop → main

- **Dependencies:** None

---

### DA-D02-04 — [R2 §6.1] Draw Repo/Folder Structure

- **Goal:** 7 GitHub repos + Google Drive structure. Dùng cho R2 §6.1.

- **Acceptance Criteria:**
  - 7 repos trong group box
  - Google Drive tree: Capstone Reports → R1-R7, Weekly Reports, Meeting Minutes
  - Access permissions ghi chú

- **Dependencies:** DA-D02-03

---

### DA-D03-01 to DA-D03-06 — [R3 §3.1.1] Draw Screen Flows (6 tasks)

- **Goal:** Screen flow per role. Dùng cho R3 §3.1.1.

- **Acceptance Criteria (chung):**
  - Mỗi screen = rectangle node
  - Navigation arrows
  - Start point marked
  - Phân biệt: public, authenticated, role-specific screens

| Role | Screens | Task ID | Assignee |
|---|---|---|---|
| ADMIN | ~15 | DA-D03-01 | Lộc |
| AGENCY_OWNER | ~20 | DA-D03-02 | Lộc |
| ACCOUNT_MANAGER | ~12 | DA-D03-03 | Phước |
| CONTENT_CREATOR | ~18 | DA-D03-04 | Phước |
| BRAND_CLIENT | ~8 | DA-D03-05 | Tuấn |
| GUEST | ~5 | DA-D03-06 | Tuấn |

- **Source References:** Figma wireframes, `docs/feature/*/spec.md`

- **Dependencies:** DA-D02-01

---

### DA-D03-07 — [R3 §3.1.2] Draw Screen Authorization Matrix

- **Goal:** Ma trận screens × roles. Dùng cho R3 §3.1.2.

- **Acceptance Criteria:**
  - ~80+ rows × 6 columns
  - X = access, — = no access, (view only) = read-only
  - Sắp xếp theo feature group

- **Dependencies:** DA-D03-01 through DA-D03-06

---

### DA-D03-08 — [R3 §3.1.1] Export Screen Mockups from Figma

- **Goal:** Export Figma wireframes với annotation. Dùng cho R3 §3.1.1.

- **Acceptance Criteria:**
  - 10+ main screens, có annotation
  - Resolution đủ đọc khi in A4

- **Dependencies:** Figma wireframes (Sprint 3)

---

### DA-D04-01 — Review All Diagrams for Consistency

- **Goal:** Trung kiểm tra 16 diagrams trước khi team viết.

- **Acceptance Criteria:**
  - Chung bộ màu, font, notation
  - Cross-reference khớp: screen flow → UC → FR
  - Mỗi diagram có title + figure number
  - Feedback documented, fixed trước Aug 18

- **Dependencies:** DA-D01-01 through DA-D03-08

---

## PHASE 2 — Report 1

---

### DA-D05-01 — [R1 §2] Write Product Background

- **Goal:** Problem Statement — tại sao marketing agencies cần AI-powered multi-channel content platform.

- **Acceptance Criteria:**
  - ~1 trang, English
  - 5-6 pain points: multi-platform fragmentation, high manual cost, inconsistent brand voice, complex approval workflows, difficulty tracking performance, lack of AI-assisted ideation
  - Số liệu thị trường VN nếu có

- **Source References:** `docs/plan/BrandHub_Master_Plan.md`, `docs/architecture/`

- **Dependencies:** Đọc R1 sample để khớp format

---

### DA-D05-02 — [R1 §3] Analyze 2 Existing Systems

- **Goal:** Phân tích 2 competitors (Buffer, Hootsuite hoặc local VN).

- **Acceptance Criteria:**
  - 2 systems: Description, Target Users, Features, Pros (3-4), Cons (3-4)
  - Screenshot website
  - Kết luận: BrandHub advantages

- **Source References:** Web research, `docs/plan/BrandHub_Master_Plan.md#tech-stack-summary`

- **Dependencies:** DA-D05-01

---

### DA-D06-01 — [R1 §4] Write Business Opportunity

- **Goal:** Market opportunity — quy mô, xu hướng, gap analysis.

- **Acceptance Criteria:**
  - ~1 trang
  - VN marketing agency market size
  - Digital transformation + AI adoption trends
  - Multi-channel social media growth
  - Gap: thiếu platform tích hợp AI + multi-channel cho SMB agencies

- **Dependencies:** DA-D05-01, DA-D05-02

---

### DA-D06-02 — [R1 §5] Write Software Product Vision

- **Goal:** Vision statement: "For [target] who [need], BrandHub is a [category] that [benefit]."

- **Acceptance Criteria:**
  - ~0.5-1 trang
  - Core differentiators: AI content gen, multi-platform publishing, RAG brand voice, virtual ambassador
  - Target: marketing agencies SMB Vietnam

- **Dependencies:** DA-D06-01

---

### DA-D07-01 — [R1 §6.1] Write Project Scope & Major Features

- **Goal:** Liệt kê feature groups với sub-features (FE-01 to FE-NN).

- **Acceptance Criteria:**
  - ~22 feature groups: Auth, User/Profile, Workspace, RBAC, Client/Agency, Social Accounts, AI Content, AI Image, AI Video, Ambassador, RAG, Trends, Content Request, Calendar, Approval, Publishing (5 platforms), Client Portal, Analytics, Subscription, Notifications, Admin, Mobile
  - Format: FE-XX: Name → sub-list

- **Source References:** `docs/plan/BrandHub_Master_Plan.md` (46 epics)

- **Dependencies:** DA-D02-01

---

### DA-D07-02 — [R1 §6.2] Write Limitations & Exclusions

- **Goal:** BrandHub scope boundary (LI-01 to LI-07).

- **Acceptance Criteria:**
  - 5-7 limitations: web app (mobile limited), no in-house AI training, VN market focus, 5 platforms only, no offline payment, no real-time collaborative editing

- **Dependencies:** DA-D07-01

---

### DA-D07-03 — [R1 §7] Compile References

- **Goal:** Tổng hợp references/citations.

- **Acceptance Criteria:**
  - 5-10 references: FPT SEP490 materials, external API docs (Facebook, TikTok, Groq, Stability AI, Google Veo), tech stack official docs, market research

- **Dependencies:** DA-D05-01 through DA-D07-02

---

## PHASE 3 — Report 2

---

### DA-D08-01 — [R2 §1.1] Write WBS with Complexity & Man-days

- **Goal:** WBS table: work items, complexity, man-days. Dùng cho R2 §1.1.

- **Acceptance Criteria:**
  - 16 sprints + 4 AI iterations → ~46 epics
  - Mỗi item: WBS Item, Complexity (S/M/C), Est. Effort (man-days)
  - Sub-totals per sprint, grand total ~860-900 man-days

- **Source References:** `docs/plan/BrandHub_Master_Plan.md`, `docs/plan/Jira_Status_Audit_2026-07-11.md`

- **Dependencies:** DA-D01-03, DA-D01-04

---

### DA-D08-02 — [R2 §1.2] Write Project Objectives

- **Goal:** 7 objectives với priority + quality metrics.

- **Acceptance Criteria:**
  - 7 objectives: Description + Priority (Very High/High/Medium)
  - Quality metrics table
  - Milestone timeliness target 95%

- **Dependencies:** DA-D08-01

---

### DA-D08-03 — [R2 §1.3] Write Project Risks

- **Goal:** 8-10 risks với Impact, Possibility, Response.

- **Acceptance Criteria:**
  - 8-10 risks: AI API downtime, social platform policy changes, OAuth failures, data inconsistency, multi-tenancy leakage, team skill gap, scope creep, cloud cost, microservice integration, ChromaDB performance
  - Mỗi risk: #, Description, Impact (H/M/L), Possibility, Response

- **Dependencies:** DA-D08-01, DA-D08-02

---

### DA-D09-01 — [R2 §2.1] Write Management Approach (Scrum)

- **Goal:** Scrum process: 16 sprints, activities + deliverables per sprint.

- **Acceptance Criteria:**
  - Scrum roles, ceremonies, artifacts
  - Sprint 0 → Sprint 1-15 → Sprint 16
  - Mỗi sprint: Time, Activities, Deliverables
  - AI Parallel Track alignment
  - Nhúng Scrum Timeline figure (DA-D01-04)

- **Source References:** `docs/plan/sprints/README.md`, `docs/plan/sprints/sprint_*/PLAN.md`

- **Dependencies:** DA-D01-04

---

### DA-D09-02 — [R2 §2.2] Write Quality Management

- **Goal:** 5 levels of testing + defect prevention.

- **Acceptance Criteria:**
  - Defect Prevention: coding standards, SonarQube, knowledge sharing
  - 5 levels: Code Review → Unit → Integration → System → UAT
  - Mỗi level: coverage %, tools, defect targets

- **Source References:** `docs/plan/sprints/sprint_15/PLAN.md`, `docs/plan/sprints/sprint_04/PLAN.md#epic-e10`

- **Dependencies:** DA-D08-02

---

### DA-D10-01 — [R2 §3] Write Project Deliverables

- **Goal:** 21+ deliverables với due dates.

- **Acceptance Criteria:**
  - #, Deliverable, Due Date, Notes
  - Timeline khớp Sprint Timeline

- **Dependencies:** DA-D09-01

---

### DA-D10-02 — [R2 §5] Write Project Communications

- **Goal:** Communication matrix.

- **Acceptance Criteria:**
  - Table: Item, Who/Target, Purpose, When/Frequency, Type/Tool
  - Daily: Slack, Bi-weekly: team meeting, Weekly: mentor meeting

- **Dependencies:** None

---

### DA-D10-03 — [R2 §6] Write Configuration Management

- **Goal:** Document Mgmt (§6.1) + Source Code Mgmt (§6.2) + Tools (§6.3).

- **Acceptance Criteria:**
  - §6.1: Google Drive structure (figure from DA-D02-04), backup policy
  - §6.2: Git branching (figure from DA-D02-03), PR rules, CI/CD
  - §6.3: Tools & Infrastructures table

- **Dependencies:** DA-D02-03, DA-D02-04

---

### DA-D11-01 — [R2 §2.3] Write Training Plan

- **Goal:** Training Plan table.

- **Acceptance Criteria:**
  - 5-6 areas: Java Spring Boot, MongoDB/PostgreSQL, React/Next.js, Testing, Git/GitHub, Docker
  - Participants, Duration, Waiver Criteria

- **Dependencies:** None

---

### DA-D11-02 — [R2 §4] Write Responsibility Assignments

- **Goal:** D/R/S/I matrix: 5 members × N work items.

- **Acceptance Criteria:**
  - D=Do, R=Review, S=Support, I=Informed
  - 15-20 work items × 5 members

- **Source References:** `docs/plan/BrandHub_Master_Plan.md#workload-distribution-table`

- **Dependencies:** DA-D08-01

---

### DA-D11-03 — [R2 §6.3] Write Tools & Infrastructures Table

- **Goal:** Bảng công cụ & hạ tầng. Dùng cho R2 §6.3.

- **Acceptance Criteria:**
  - Categories: Technology, Database, IDEs, Diagramming, Documentation, Version Control, Deployment, PM, AI/ML

- **Dependencies:** None

---

## PHASE 4 — Report 3

---

### DA-D12-01 — [R3 §1] Write Product Overview

- **Goal:** Product Overview cho R3 §1.

- **Acceptance Criteria:**
  - ~1 trang
  - BrandHub summary, 6 roles, core capabilities, tech stack
  - Nhúng Context Diagram (DA-D01-01), Architecture Diagram (DA-D01-02)

- **Dependencies:** DA-D01-01, DA-D01-02

---

### DA-D12-02 — [R3 §1] Write Context Diagram Description

- **Goal:** Mô tả chi tiết Context Diagram.

- **Acceptance Criteria:**
  - System boundary, từng external service interaction
  - Data flows: REST API, RabbitMQ, OAuth

- **Dependencies:** DA-D12-01

---

### DA-D12-03 — [R3 §3.1.3] Write ERD Description

- **Goal:** Entity Descriptions table cho ERD.

- **Acceptance Criteria:**
  - ~17 entity rows (12 MongoDB + 5 PostgreSQL)
  - Format: #, Entity, Description
  - Nhúng ERD figure (DA-D02-02)

- **Source References:** `docs/plan/sprints/sprint_03/PLAN.md#epic-e06`

- **Dependencies:** DA-D02-02

---

### DA-D13-01 — [R3 §2.1] Write Actors Description

- **Goal:** Mô tả 6 actors.

- **Acceptance Criteria:**
  - 6 actors detailed: GUEST, BRAND_CLIENT, CONTENT_CREATOR, ACCOUNT_MANAGER, AGENCY_OWNER, ADMIN

- **Source References:** `docs/plan/BrandHub_Master_Plan.md#roles`, `docs/database/DA-E06-08_Database_Access_Rules.md`

- **Dependencies:** DA-D02-01

---

### DA-D13-02 — [R3 §2.2] Write Use Case Descriptions — Admin & Agency Owner

- **Goal:** ~20 UCs: ADMIN + AGENCY_OWNER.

- **Acceptance Criteria:**
  - Mỗi UC: ID, Use Case, Actors, Description
  - Format theo sample Table 3

- **Source References:** `docs/plan/sprints/sprint_02/PLAN.md#epic-e03`, `docs/feature/*/spec.md`

- **Dependencies:** DA-D13-01, DA-D02-01

---

### DA-D13-03 — [R3 §2.2] Write Use Case Descriptions — AC, CC, BC, Guest

- **Goal:** ~40 UCs: ACCOUNT_MANAGER + CONTENT_CREATOR + BRAND_CLIENT + GUEST.

- **Acceptance Criteria:**
  - Format theo sample Table 3

- **Source References:** `docs/plan/sprints/sprint_02/PLAN.md#epic-e03`, `docs/api/endpoints/`

- **Dependencies:** DA-D13-01, DA-D02-01

---

### DA-D14-01 — [R3 §3.1.1] Write Screen Descriptions — Admin & Agency Owner

- **Goal:** Screen Description table cho ADMIN + AGENCY_OWNER (~35 screens).

- **Acceptance Criteria:**
  - Format: #, Feature, Screen, Description
  - Khớp Screen Flow diagrams

- **Source References:** DA-D03-01, DA-D03-02, Figma

- **Dependencies:** DA-D03-01, DA-D03-02

---

### DA-D14-02 — [R3 §3.1.1] Write Screen Descriptions — Account Manager & Content Creator

- **Goal:** Screen Description table cho ACCOUNT_MANAGER + CONTENT_CREATOR (~30 screens).

- **Acceptance Criteria:**
  - Format: #, Feature, Screen, Description
  - Khớp Screen Flow diagrams

- **Source References:** DA-D03-03, DA-D03-04, Figma

- **Dependencies:** DA-D03-03, DA-D03-04

---

### DA-D14-03 — [R3 §3.1.1] Write Screen Descriptions — Brand Client & Guest

- **Goal:** Screen Description table cho BRAND_CLIENT + GUEST (~13 screens).

- **Acceptance Criteria:**
  - Format: #, Feature, Screen, Description
  - Khớp Screen Flow diagrams

- **Source References:** DA-D03-05, DA-D03-06, Figma

- **Dependencies:** DA-D03-05, DA-D03-06

---

### DA-D14-04 — [R3 §3.1.4] Write Non-Screen Functions

- **Goal:** Background jobs, callbacks, cron schedules (~12-15 functions).

- **Acceptance Criteria:**
  - Format: #, Feature, System Function, Description
  - Functions: Welcome Email, Password Reset, JWT Cleanup, OAuth Token Refresh, Publishing Job, Publish Callback, Payment Confirmation, Contract Expiry, Trend Crawl, AI Usage Archive, Notification Delivery, Content Auto-Archive

- **Source References:** `docs/plan/sprints/sprint_04/PLAN.md#epic-e11`, `docs/api/endpoints/`

- **Dependencies:** DA-D14-01 through DA-D14-03

---

### DA-D15-01 — [R3 §3.2] Write FR — Authentication & Authorization

- **Goal:** ~10 functions: Register, Login (Email+Google), OAuth (5 platforms), 2FA, Forgot/Reset/Change Password, OTP Verify, Token Refresh, Sign Out.

- **Format mỗi function:** Function Trigger → Description (Actors, Purpose, Interface, Data Processing) → Screen Layout → Data → Business Rules → Normal Flow → Abnormal Cases → Post-Conditions

- **Source References:** `docs/feature/auth/*/spec.md`, `docs/plan/sprints/sprint_05/PLAN.md`, `docs/api/endpoints/`

- **Dependencies:** DA-D14-01 through DA-D14-04

---

### DA-D15-02 — [R3 §3.3] Write FR — User & Profile Management

- **Goal:** ~5 functions: View/Update Profile, Avatar Upload, Identity Verification, Account Deactivation.

- **Source References:** `docs/plan/sprints/sprint_06/PLAN.md`, `docs/api/endpoints/`

- **Dependencies:** DA-D14-01 through DA-D14-04

---

### DA-D15-03 — [R3 §3.4] Write FR — Workspace Management

- **Goal:** ~6 functions: Create/Update/Delete Workspace, View/Invite/Remove Members, Multi-tenancy Data Isolation.

- **Source References:** `docs/plan/sprints/sprint_06/PLAN.md`, `docs/database/DA-E06-08_Database_Access_Rules.md`

- **Dependencies:** DA-D14-01 through DA-D14-04

---

### DA-D15-04 — [R3 §3.5] Write FR — RBAC

- **Goal:** ~4 functions: Assign/Revoke Role, View Permissions, Permission Check.

- **Source References:** `docs/database/DA-E06-08_Database_Access_Rules.md`, `docs/plan/sprints/sprint_06/PLAN.md`

- **Dependencies:** DA-D14-01 through DA-D14-04

---

### DA-D16-01 — [R3 §3.6] Write FR — Content Request Management

- **Goal:** ~6 functions: Create Request, Assign Task, Track Status, Revise, Cancel.

- **Source References:** `docs/plan/sprints/sprint_10/PLAN.md`, `docs/api/endpoints/`

- **Dependencies:** DA-D14-01 through DA-D14-04

---

### DA-D16-02 — [R3 §3.7] Write FR — Content Calendar & Scheduling

- **Goal:** ~5 functions: Day/Week/Month View, Drag-drop Schedule, Recurring Posts, Timezone.

- **Source References:** `docs/plan/sprints/sprint_10/PLAN.md`, `docs/api/endpoints/`

- **Dependencies:** DA-D14-01 through DA-D14-04

---

### DA-D16-03 — [R3 §3.8] Write FR — Approval Workflow

- **Goal:** ~5 functions: Submit for Review, Approve/Reject with Comments, Revision Loop, Approval Chain.

- **Source References:** `docs/plan/sprints/sprint_11/PLAN.md`, `docs/api/endpoints/`

- **Dependencies:** DA-D14-01 through DA-D14-04

---

### DA-D16-04 — [R3 §3.9] Write FR — Client Portal

- **Goal:** ~5 functions: Client Login, View Calendar, Approve/Reject Content, View Analytics, Comments.

- **Source References:** `docs/plan/sprints/sprint_13/PLAN.md`, `docs/api/endpoints/`

- **Dependencies:** DA-D14-01 through DA-D14-04

---

### DA-D16-05 — [R3 §3.10] Write FR — Agency & Client Management

- **Goal:** ~6 functions: CRUD Clients, Assign Account Manager, Client Onboarding, Settings.

- **Source References:** `docs/plan/sprints/sprint_10/PLAN.md`, `docs/api/endpoints/`

- **Dependencies:** DA-D14-01 through DA-D14-04

---

### DA-D17-01 — [R3 §3.11] Write FR — AI Content Generation

- **Goal:** ~4 functions: Text Gen (caption, blog, ad copy), Tone/Brand Voice, Anti-Hallucination, History.

- **Source References:** `docs/iterations/README.md`, `docs/plan/BrandHub_Master_Plan.md` (AI01-AI11)

- **Dependencies:** DA-D14-01 through DA-D14-04

---

### DA-D17-02 — [R3 §3.12] Write FR — AI Image Generation

- **Goal:** ~4 functions: Text-to-Image, Style Presets, Brand Assets, Variations, Background Removal.

- **Source References:** `docs/iterations/README.md`

- **Dependencies:** DA-D14-01 through DA-D14-04

---

### DA-D17-03 — [R3 §3.13] Write FR — AI Video Generation

- **Goal:** ~4 functions: Script-to-Video, Template Selection, Scene Mapping, Export Formats.

- **Source References:** `docs/iterations/README.md`

- **Dependencies:** DA-D14-01 through DA-D14-04

---

### DA-D17-04 — [R3 §3.14] Write FR — Virtual Brand Ambassador

- **Goal:** ~4 functions: Face Upload, InstantID Setup, Ambassador Video Gen, Management.

- **Source References:** `docs/iterations/README.md`

- **Dependencies:** DA-D14-01 through DA-D14-04

---

### DA-D17-05 — [R3 §3.15] Write FR — RAG Knowledge Base

- **Goal:** ~5 functions: Document Upload, Chunking, Embedding, Brand Voice Training, Knowledge Search.

- **Source References:** `docs/iterations/README.md`, `docs/plan/sprints/sprint_09/PLAN.md`

- **Dependencies:** DA-D14-01 through DA-D14-04

---

### DA-D17-06 — [R3 §3.16] Write FR — Trend Crawler

- **Goal:** ~4 functions: Keyword Config, Auto-crawl Schedule, Trending Topics Dashboard, Trend-to-Content.

- **Source References:** `docs/iterations/README.md`

- **Dependencies:** DA-D14-01 through DA-D14-04

---

### DA-D18-01 — [R3 §3.17] Write FR — Social Account Management

- **Goal:** ~5 functions: Connect (OAuth), Disconnect, Token Status, Refresh, Platform Limits.

- **Source References:** `docs/plan/sprints/sprint_07/PLAN.md`, `docs/api/endpoints/`

- **Dependencies:** DA-D14-01 through DA-D14-04

---

### DA-D18-02 — [R3 §3.18] Write FR — Facebook Publishing

- **Goal:** ~4 functions: Text/Image/Video Post, Carousel, Schedule, Preview, Publish Status.

- **Source References:** `docs/plan/sprints/sprint_08/PLAN.md`, `docs/api/endpoints/`

- **Dependencies:** DA-D14-01 through DA-D14-04

---

### DA-D18-03 — [R3 §3.19] Write FR — TikTok Publishing

- **Goal:** ~3 functions: Video Upload, Caption, Hashtags, Schedule, Status Tracking.

- **Source References:** `docs/plan/sprints/sprint_08/PLAN.md`, `docs/api/endpoints/`

- **Dependencies:** DA-D14-01 through DA-D14-04

---

### DA-D18-04 — [R3 §3.20] Write FR — Instagram & Threads Publishing

- **Goal:** ~4 functions: Image/Reel Post, Carousel, Story, Thread.

- **Source References:** `docs/plan/sprints/sprint_08/PLAN.md`, `docs/api/endpoints/`

- **Dependencies:** DA-D14-01 through DA-D14-04

---

### DA-D18-05 — [R3 §3.21] Write FR — Zalo OA Publishing

- **Goal:** ~3 functions: Text/Image Broadcast, Template Message, Schedule, Rate Limit Handling.

- **Source References:** `docs/plan/sprints/sprint_08/PLAN.md`, `docs/api/endpoints/`

- **Dependencies:** DA-D14-01 through DA-D14-04

---

### DA-D18-06 — [R3 §3.22] Write FR — Publish Error Handling

- **Goal:** ~4 functions: Retry Logic (3x exponential backoff), Dead Letter Queue, Error Notifications, Manual Retry.

- **Source References:** `docs/plan/sprints/sprint_11/PLAN.md`, `docs/api/endpoints/`

- **Dependencies:** DA-D14-01 through DA-D14-04

---

### DA-D18-07 — [R3 §3.23] Write FR — Notifications

- **Goal:** ~5 functions: In-App, Email, Push (FCM), Preferences, Notification Center UI.

- **Source References:** `docs/plan/sprints/sprint_13/PLAN.md`, `docs/api/endpoints/`

- **Dependencies:** DA-D14-01 through DA-D14-04

---

### DA-D19-01 — [R3 §3.24] Write FR — Subscription & Billing

- **Goal:** ~5 functions: Plan Selection (Free/Basic/Pro/Enterprise), Payment, Invoice History, AI Credit Tracking, Upgrade/Downgrade.

- **Source References:** `docs/plan/sprints/sprint_06/PLAN.md`, `docs/api/endpoints/`

- **Dependencies:** DA-D14-01 through DA-D14-04

---

### DA-D19-02 — [R3 §3.25] Write FR — Analytics & Reporting

- **Goal:** ~5 functions: Content Performance, Platform Analytics, Team Productivity, Export PDF/Excel, Scheduled Reports.

- **Source References:** `docs/plan/sprints/sprint_13/PLAN.md`, `docs/api/endpoints/`

- **Dependencies:** DA-D14-01 through DA-D14-04

---

### DA-D19-03 — [R3 §3.26] Write FR — Admin Dashboard

- **Goal:** ~5 functions: User Management, Content Moderation, System Health, Platform Stats.

- **Source References:** `docs/plan/sprints/sprint_14/PLAN.md`, `docs/api/endpoints/`

- **Dependencies:** DA-D14-01 through DA-D14-04

---

### DA-D19-04 — [R3 §3.27] Write FR — Mobile App Features

- **Goal:** ~6 functions: Mobile Auth, Dashboard, Calendar, Push Notifications, Approval on Mobile, Content Preview.

- **Source References:** `docs/plan/sprints/sprint_14/PLAN.md`, `docs/api/endpoints/`

- **Dependencies:** DA-D14-01 through DA-D14-04

---

### DA-D20-01 — [R3 §4] Write Non-Functional Requirements

- **Goal:** §4.1 External Interfaces + §4.2 Quality Attributes.

- **Acceptance Criteria:**
  - §4.1: Payment Gateway, OAuth, Maps, FCM, Email/SMS (với performance thresholds)
  - §4.2: Usability (≤5 steps, ≤15 min onboarding, WCAG 2.1 AA), Reliability (99.5%, MTTR ≤2h), Performance (<2s page, <1s search, 1000 concurrent), Security (JWT RS256, BCrypt=12, AES-256, RBAC, 2FA, audit logs), Compatibility, Maintainability (≥80% coverage), Legal (VN data privacy, PCI DSS)

- **Source References:** `docs/architecture/`, `docs/database/DA-E06-08_Database_Access_Rules.md`

- **Dependencies:** Tất cả FR sections

---

### DA-D20-02 — [R3 §5.1] Compile Business Rules Appendix

- **Goal:** Tổng hợp BR-01 through BR-NN (~70-80 rules).

- **Acceptance Criteria:**
  - Format: BR-XX, Rule Definition
  - Gom theo feature, không trùng, không mâu thuẫn

- **Dependencies:** Tất cả FR sections

---

### DA-D20-03 — [R3 §5.3] Compile Message Lists Appendix

- **Goal:** Tổng hợp MSG01 through MSG-NN (~100-120 messages).

- **Acceptance Criteria:**
  - Format: Code, Type (In line/Toast/In red), Context, Content
  - English, professional, actionable

- **Dependencies:** Tất cả FR sections

---

## PHASE 5 — Review, Merge & Submit

---

### DA-D21-01 to DA-D21-13 — Review Tasks (13 individual tasks)

- **Goal:** Mỗi reviewer có 1 task riêng, trách nhiệm rõ ràng.

| Task ID | Report | Reviewer |
|---|---|---|
| DA-D21-01 | R1 | Trung |
| DA-D21-02 | R1 | Lộc |
| DA-D21-03 | R1 | Tuấn |
| DA-D21-04 | R1 | Ân |
| DA-D21-05 | R2 | Trung |
| DA-D21-06 | R2 | Phước |
| DA-D21-07 | R2 | Tuấn |
| DA-D21-08 | R2 | Ân |
| DA-D21-09 | R3 | Trung |
| DA-D21-10 | R3 | Lộc |
| DA-D21-11 | R3 | Phước |
| DA-D21-12 | R3 | Tuấn |
| DA-D21-13 | R3 | Ân |

- **Acceptance Criteria (chung):**
  - Đọc toàn bộ report được assign
  - Feedback: accuracy (khớp docs), consistency (thuật ngữ, format), completeness
  - Ghi feedback vào tracking sheet
  - Critical: sai technical facts, thiếu feature
  - Minor: typo, format, wording

- **Dependencies:** Tất cả writing tasks hoàn thành

---

### DA-D21-14 to DA-D21-18 — Address Review Feedback (5 individual tasks)

- **Goal:** Mỗi member fix section mình phụ trách.

| Task ID | Assignee | Role |
|---|---|---|
| DA-D21-14 | Trung | Tổng hợp feedback, phân công fix, theo dõi progress |
| DA-D21-15 | Lộc | Fix section Lộc phụ trách |
| DA-D21-16 | Phước | Fix section Phước phụ trách |
| DA-D21-17 | Tuấn | Fix section Tuấn phụ trách |
| DA-D21-18 | Ân | Fix section Ân phụ trách |

- **Acceptance Criteria:**
  - Tất cả critical issues resolved
  - Minor issues resolved hoặc documented với lý do
  - Tracking sheet updated

- **Dependencies:** DA-D21-01 through DA-D21-13

---

### DA-D22-01 to DA-D22-03 — Merge Reports

| Task ID | Report | Assignee |
|---|---|---|
| DA-D22-01 | R1 | Trung |
| DA-D22-02 | R2 | Trung |
| DA-D22-03 | R3 | Trung |

- **Acceptance Criteria:**
  - Combine sections đúng thứ tự
  - Generate Table of Contents
  - Fill Record of Changes
  - Đánh số figure, table tuần tự
  - Cross-reference check
  - Page numbers, header/footer

- **Dependencies:** DA-D21-14 through DA-D21-18

---

### DA-D22-04 — Final Format Check

- **Goal:** Format consistency toàn bộ 3 reports.

- **Acceptance Criteria:**
  - Font, size, line spacing, margins thống nhất
  - Figure/table captions đúng format
  - English spelling & grammar check
  - All cross-references correct
  - PDF: bookmark, clickable TOC

- **Dependencies:** DA-D22-01 through DA-D22-03

---

### DA-D23-01 — Prepare Final Submission Package

- **Goal:** Đóng gói 3 reports → final submission.

- **Acceptance Criteria:**
  - 3 PDFs + source docx
  - Upload Google Drive "Final Submission"
  - File naming theo FPT format

- **Dependencies:** DA-D22-04

---

### DA-D23-02 — Prepare Presentation Summary

- **Goal:** Key points từ mỗi report cho buổi trình bày Aug 28.

- **Acceptance Criteria:**
  - 1-2 slides/report: R1 (Problem→Solution→Vision), R2 (Timeline→Team→Methodology), R3 (Key features→Architecture→Tech highlights)

- **Dependencies:** DA-D23-01
