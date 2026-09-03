# BrandHub — SEP490 Document Plan & Task Details

> Kế hoạch viết 3 capstone reports cho SEP490 Fall 2026.
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
| Total Tasks | ~207 document tasks (135 FR per-function + 72 non-FR) |

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
| Diagram Team | Tuấn, Lộc, Phước | Vẽ 16 diagrams trước khi team viết nội dung |
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

## MILESTONES

| Milestone | Deliverable |
|---|---|
| M1 — Diagrams Done | 16 diagrams reviewed & approved |
| M2 — Draft v1 | All text sections written |
| M3 — Review Complete | Cross-review done, feedback collected |
| M4 — Final v2 | All feedback addressed |
| M5 — Merged | 3 reports merged, formatted, TOC updated |
| M6 — Submit | Submit to exam committee |

---

## PHASE 1 — Diagrams

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
| [DA-D02-01](#da-d02-01) | **[R3 §2.2.1]** Draw Use Case Overview Diagram — 60 use cases × 6 roles | Tuấn | 🔴 |
| [DA-D02-02](#da-d02-02) | **[R3 §3.1.5]** Draw ERD — 12 MongoDB collections + 5 PostgreSQL tables + relationships | Tuấn | 🔴 |
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
| [DA-D03-07](#da-d03-07) | **[R3 §3.1.3]** Draw Screen Authorization Matrix — all screens × 6 roles (X/—) | Lộc | 🟡 |
| [DA-D03-08](#da-d03-08) | **[R3 §3.1.1]** Export Screen Mockups from Figma — all 10 main screens with annotations | Lộc | 🟡 |

---

### EPIC D04 — Diagram Review

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| [DA-D04-01](#da-d04-01) | Review all 16 diagrams for consistency: notation, color, font, naming, cross-reference accuracy | Trung | 🔴 |

---

## PHASE 2 — Report 1: Project Introduction

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

## PHASE 3 — Report 2: Project Management Plan

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

## PHASE 4 — Report 3: Software Requirement Specification

> ~180 trang — report nặng nhất.

---

### EPIC D12 — R3 §1: Product Overview & System Context

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| [DA-D12-01](#da-d12-01) | **[R3 §1]** Write Product Overview — BrandHub description, 6 roles, tech stack, core capabilities | Trung | 🔴 |
| [DA-D12-02](#da-d12-02) | **[R3 §1]** Write Context Diagram Description — system boundary, 6 external services, data flows | Trung | 🟡 |
| [DA-D12-03](#da-d12-03) | **[R3 §3.1.5]** Write ERD Description — 12 MongoDB collections + 5 PostgreSQL tables, entity descriptions | Trung | 🟡 |

---

### EPIC D13 — R3 §2: User Requirements (Actors & Use Cases)

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| [DA-D13-01](#da-d13-01) | **[R3 §2.1]** Write Actors Description — 6 roles: ADMIN, AGENCY_OWNER, ACCOUNT_MANAGER, CONTENT_CREATOR, BRAND_CLIENT, GUEST | Tuấn | 🔴 |
| [DA-D13-02](#da-d13-02) | **[R3 §2.2.2]** Write Use Case Descriptions — ADMIN + AGENCY_OWNER (~20 UCs): ID, Actor, Description, Main/Alternative Flows | Lộc | 🔴 |
| [DA-D13-03](#da-d13-03) | **[R3 §2.2.2]** Write Use Case Descriptions — ACCOUNT_MANAGER + CONTENT_CREATOR + BRAND_CLIENT + GUEST (~40 UCs) | Tuấn | 🔴 |

---

### EPIC D14 — R3 §3.1: System Functional Overview (Screens)

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| [DA-D14-01](#da-d14-01) | **[R3 §3.1.2]** Write Screen Descriptions — ADMIN + AGENCY_OWNER screens (#, Feature, Screen, Description) | Lộc | 🟡 |
| [DA-D14-02](#da-d14-02) | **[R3 §3.1.2]** Write Screen Descriptions — ACCOUNT_MANAGER + CONTENT_CREATOR screens | Phước | 🟡 |
| [DA-D14-03](#da-d14-03) | **[R3 §3.1.2]** Write Screen Descriptions — BRAND_CLIENT + GUEST screens | Tuấn | 🟡 |
| [DA-D14-04](#da-d14-04) | **[R3 §3.1.4]** Write Non-Screen Functions — background jobs, callbacks, cron schedules (~12-15 functions) | Tuấn | 🟡 |

---

### EPIC D15 — R3 §3.2-3.5: FR — Auth & Core Business (27 per-function tasks)

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| [DA-D15-01](#da-d15-01) | **[R3 §3.2.1]** Write FR — Register (Email) | Trung | 🔴 |
| [DA-D15-02](#da-d15-02) | **[R3 §3.2.2]** Write FR — Login (Email + Password) | Trung | 🔴 |
| [DA-D15-03](#da-d15-03) | **[R3 §3.2.3]** Write FR — Login (Google OAuth) | Trung | 🔴 |
| [DA-D15-04](#da-d15-04) | **[R3 §3.2.4]** Write FR — Social OAuth Connect (Facebook, TikTok, Instagram, Zalo) | Trung | 🔴 |
| [DA-D15-05](#da-d15-05) | **[R3 §3.2.5]** Write FR — Two-Factor Authentication (2FA, TOTP) | Trung | 🔴 |
| [DA-D15-06](#da-d15-06) | **[R3 §3.2.6]** Write FR — Forgot Password | Trung | 🔴 |
| [DA-D15-07](#da-d15-07) | **[R3 §3.2.7]** Write FR — Reset Password | Lộc | 🔴 |
| [DA-D15-08](#da-d15-08) | **[R3 §3.2.8]** Write FR — Change Password | Lộc | 🔴 |
| [DA-D15-09](#da-d15-09) | **[R3 §3.2.9]** Write FR — OTP Verification | Lộc | 🔴 |
| [DA-D15-10](#da-d15-10) | **[R3 §3.2.10]** Write FR — Token Refresh (JWT RS256) | Lộc | 🔴 |
| [DA-D15-11](#da-d15-11) | **[R3 §3.2.11]** Write FR — Sign Out (Token Blacklist) | Lộc | 🔴 |
| [DA-D15-12](#da-d15-12) | **[R3 §3.3.1]** Write FR — View Profile | Trung | 🟡 |
| [DA-D15-13](#da-d15-13) | **[R3 §3.3.2]** Write FR — Update Profile | Trung | 🟡 |
| [DA-D15-14](#da-d15-14) | **[R3 §3.3.3]** Write FR — Avatar Upload | Trung | 🟡 |
| [DA-D15-15](#da-d15-15) | **[R3 §3.3.4]** Write FR — Identity Verification | Trung | 🟡 |
| [DA-D15-16](#da-d15-16) | **[R3 §3.3.5]** Write FR — Account Deactivation | Trung | 🟡 |
| [DA-D15-17](#da-d15-17) | **[R3 §3.4.1]** Write FR — Create Workspace | Trung | 🟡 |
| [DA-D15-18](#da-d15-18) | **[R3 §3.4.2]** Write FR — Update Workspace | Trung | 🟡 |
| [DA-D15-19](#da-d15-19) | **[R3 §3.4.3]** Write FR — Delete Workspace | Trung | 🟡 |
| [DA-D15-20](#da-d15-20) | **[R3 §3.4.4]** Write FR — View Members | Trung | 🟡 |
| [DA-D15-21](#da-d15-21) | **[R3 §3.4.5]** Write FR — Invite Member | Trung | 🟡 |
| [DA-D15-22](#da-d15-22) | **[R3 §3.4.6]** Write FR — Remove Member | Trung | 🟡 |
| [DA-D15-23](#da-d15-23) | **[R3 §3.4.7]** Write FR — Multi-tenancy Data Isolation | Trung | 🟡 |
| [DA-D15-24](#da-d15-24) | **[R3 §3.5.1]** Write FR — Assign Role | Trung | 🟡 |
| [DA-D15-25](#da-d15-25) | **[R3 §3.5.2]** Write FR — Revoke Role | Trung | 🟡 |
| [DA-D15-26](#da-d15-26) | **[R3 §3.5.3]** Write FR — View Permissions | Trung | 🟡 |
| [DA-D15-27](#da-d15-27) | **[R3 §3.5.4]** Write FR — Permission Check Enforcement | Trung | 🟡 |

---

### EPIC D16 — R3 §3.6-3.10: FR — Content & Workflow (26 per-function tasks)

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| [DA-D16-01](#da-d16-01) | **[R3 §3.6.1]** Write FR — Create Content Request | Lộc | 🟡 |
| [DA-D16-02](#da-d16-02) | **[R3 §3.6.2]** Write FR — Assign Task to Creator | Lộc | 🟡 |
| [DA-D16-03](#da-d16-03) | **[R3 §3.6.3]** Write FR — Track Request Status | Lộc | 🟡 |
| [DA-D16-04](#da-d16-04) | **[R3 §3.6.4]** Write FR — Revise Request | Lộc | 🟡 |
| [DA-D16-05](#da-d16-05) | **[R3 §3.6.5]** Write FR — Cancel Request | Lộc | 🟡 |
| [DA-D16-06](#da-d16-06) | **[R3 §3.7.1]** Write FR — Calendar View (Day/Week/Month) | Lộc | 🟡 |
| [DA-D16-07](#da-d16-07) | **[R3 §3.7.2]** Write FR — Drag-drop Schedule Post | Lộc | 🟡 |
| [DA-D16-08](#da-d16-08) | **[R3 §3.7.3]** Write FR — Recurring Posts | Lộc | 🟡 |
| [DA-D16-09](#da-d16-09) | **[R3 §3.7.4]** Write FR — Timezone Configuration | Lộc | 🟡 |
| [DA-D16-10](#da-d16-10) | **[R3 §3.7.5]** Write FR — Calendar Filter by Platform/Status | Lộc | 🟡 |
| [DA-D16-11](#da-d16-11) | **[R3 §3.8.1]** Write FR — Submit Content for Review | Lộc | 🟡 |
| [DA-D16-12](#da-d16-12) | **[R3 §3.8.2]** Write FR — Approve Content | Lộc | 🟡 |
| [DA-D16-13](#da-d16-13) | **[R3 §3.8.3]** Write FR — Reject with Comments | Lộc | 🟡 |
| [DA-D16-14](#da-d16-14) | **[R3 §3.8.4]** Write FR — Revision Loop | Lộc | 🟡 |
| [DA-D16-15](#da-d16-15) | **[R3 §3.8.5]** Write FR — Approval Chain (Creator → Manager → Client) | Lộc | 🟡 |
| [DA-D16-16](#da-d16-16) | **[R3 §3.9.1]** Write FR — Client Login | Lộc | 🟡 |
| [DA-D16-17](#da-d16-17) | **[R3 §3.9.2]** Write FR — View Content Calendar | Lộc | 🟡 |
| [DA-D16-18](#da-d16-18) | **[R3 §3.9.3]** Write FR — Approve/Reject Content | Lộc | 🟡 |
| [DA-D16-19](#da-d16-19) | **[R3 §3.9.4]** Write FR — View Analytics Dashboard | Lộc | 🟡 |
| [DA-D16-20](#da-d16-20) | **[R3 §3.9.5]** Write FR — Add Comments on Content | Lộc | 🟡 |
| [DA-D16-21](#da-d16-21) | **[R3 §3.10.1]** Write FR — Create Client | Lộc | 🟡 |
| [DA-D16-22](#da-d16-22) | **[R3 §3.10.2]** Write FR — Update Client Info | Lộc | 🟡 |
| [DA-D16-23](#da-d16-23) | **[R3 §3.10.3]** Write FR — Delete/Archive Client | Lộc | 🟡 |
| [DA-D16-24](#da-d16-24) | **[R3 §3.10.4]** Write FR — Assign Account Manager | Lộc | 🟡 |
| [DA-D16-25](#da-d16-25) | **[R3 §3.10.5]** Write FR — Client Onboarding Flow | Lộc | 🟡 |
| [DA-D16-26](#da-d16-26) | **[R3 §3.10.6]** Write FR — Client Settings/Preferences | Lộc | 🟡 |

---

### EPIC D17 — R3 §3.11-3.16: FR — AI Features (28 per-function tasks)

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| [DA-D17-01](#da-d17-01) | **[R3 §3.11.1]** Write FR — Text Generation (Caption) | Tuấn | 🟡 |
| [DA-D17-02](#da-d17-02) | **[R3 §3.11.2]** Write FR — Text Generation (Blog/Article) | Tuấn | 🟡 |
| [DA-D17-03](#da-d17-03) | **[R3 §3.11.3]** Write FR — Text Generation (Ad Copy) | Tuấn | 🟡 |
| [DA-D17-04](#da-d17-04) | **[R3 §3.11.4]** Write FR — Tone/Brand Voice Selection | Tuấn | 🟡 |
| [DA-D17-05](#da-d17-05) | **[R3 §3.11.5]** Write FR — Anti-Hallucination Guard | Tuấn | 🟡 |
| [DA-D17-06](#da-d17-06) | **[R3 §3.11.6]** Write FR — Content History & Reuse | Tuấn | 🟡 |
| [DA-D17-07](#da-d17-07) | **[R3 §3.12.1]** Write FR — Text-to-Image Generation | Tuấn | 🟡 |
| [DA-D17-08](#da-d17-08) | **[R3 §3.12.2]** Write FR — Style Presets | Tuấn | 🟡 |
| [DA-D17-09](#da-d17-09) | **[R3 §3.12.3]** Write FR — Brand Asset Upload for Reference | Tuấn | 🟡 |
| [DA-D17-10](#da-d17-10) | **[R3 §3.12.4]** Write FR — Image Variations | Tuấn | 🟡 |
| [DA-D17-11](#da-d17-11) | **[R3 §3.12.5]** Write FR — Background Removal | Tuấn | 🟡 |
| [DA-D17-12](#da-d17-12) | **[R3 §3.13.1]** Write FR — Script-to-Video Generation | Tuấn | 🟡 |
| [DA-D17-13](#da-d17-13) | **[R3 §3.13.2]** Write FR — Template Selection | Tuấn | 🟡 |
| [DA-D17-14](#da-d17-14) | **[R3 §3.13.3]** Write FR — Scene Mapping | Tuấn | 🟡 |
| [DA-D17-15](#da-d17-15) | **[R3 §3.13.4]** Write FR — Export Format Selection (MP4/GIF/WebM) | Tuấn | 🟡 |
| [DA-D17-16](#da-d17-16) | **[R3 §3.14.1]** Write FR — Face Upload for Ambassador | Tuấn | 🟡 |
| [DA-D17-17](#da-d17-17) | **[R3 §3.14.2]** Write FR — InstantID Model Setup | Tuấn | 🟡 |
| [DA-D17-18](#da-d17-18) | **[R3 §3.14.3]** Write FR — Ambassador Video Generation | Tuấn | 🟡 |
| [DA-D17-19](#da-d17-19) | **[R3 §3.14.4]** Write FR — Ambassador Management (Create/Edit/Delete) | Tuấn | 🟡 |
| [DA-D17-20](#da-d17-20) | **[R3 §3.15.1]** Write FR — Document Upload (PDF/DOCX/TXT) | Tuấn | 🟡 |
| [DA-D17-21](#da-d17-21) | **[R3 §3.15.2]** Write FR — Document Chunking | Tuấn | 🟡 |
| [DA-D17-22](#da-d17-22) | **[R3 §3.15.3]** Write FR — Embedding Generation (ChromaDB) | Tuấn | 🟡 |
| [DA-D17-23](#da-d17-23) | **[R3 §3.15.4]** Write FR — Brand Voice Training | Tuấn | 🟡 |
| [DA-D17-24](#da-d17-24) | **[R3 §3.15.5]** Write FR — Knowledge Base Search (Semantic) | Tuấn | 🟡 |
| [DA-D17-25](#da-d17-25) | **[R3 §3.16.1]** Write FR — Keyword Configuration | Tuấn | 🟡 |
| [DA-D17-26](#da-d17-26) | **[R3 §3.16.2]** Write FR — Auto-Crawl Schedule | Tuấn | 🟡 |
| [DA-D17-27](#da-d17-27) | **[R3 §3.16.3]** Write FR — Trending Topics Dashboard | Tuấn | 🟡 |
| [DA-D17-28](#da-d17-28) | **[R3 §3.16.4]** Write FR — Trend-to-Content Suggestions | Tuấn | 🟡 |

---

### EPIC D18 — R3 §3.17-3.23: FR — Publishing & Social (33 per-function tasks)

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| [DA-D18-01](#da-d18-01) | **[R3 §3.17.1]** Write FR — Connect Social Account (OAuth) | Phước | 🟡 |
| [DA-D18-02](#da-d18-02) | **[R3 §3.17.2]** Write FR — Disconnect Account | Phước | 🟡 |
| [DA-D18-03](#da-d18-03) | **[R3 §3.17.3]** Write FR — View Token Status | Phước | 🟡 |
| [DA-D18-04](#da-d18-04) | **[R3 §3.17.4]** Write FR — Refresh Token | Phước | 🟡 |
| [DA-D18-05](#da-d18-05) | **[R3 §3.17.5]** Write FR — Platform Rate Limit Display | Phước | 🟡 |
| [DA-D18-06](#da-d18-06) | **[R3 §3.18.1]** Write FR — Text Post to Facebook Page | Phước | 🔴 |
| [DA-D18-07](#da-d18-07) | **[R3 §3.18.2]** Write FR — Image Post | Phước | 🔴 |
| [DA-D18-08](#da-d18-08) | **[R3 §3.18.3]** Write FR — Video Post | Phước | 🔴 |
| [DA-D18-09](#da-d18-09) | **[R3 §3.18.4]** Write FR — Carousel Post | Phước | 🔴 |
| [DA-D18-10](#da-d18-10) | **[R3 §3.18.5]** Write FR — Schedule Post | Phước | 🔴 |
| [DA-D18-11](#da-d18-11) | **[R3 §3.18.6]** Write FR — Post Preview | Phước | 🔴 |
| [DA-D18-12](#da-d18-12) | **[R3 §3.18.7]** Write FR — Publish Status Tracking | Phước | 🔴 |
| [DA-D18-13](#da-d18-13) | **[R3 §3.19.1]** Write FR — Video Upload to TikTok | Phước | 🟡 |
| [DA-D18-14](#da-d18-14) | **[R3 §3.19.2]** Write FR — Caption + Hashtags | Phước | 🟡 |
| [DA-D18-15](#da-d18-15) | **[R3 §3.19.3]** Write FR — Schedule Post | Phước | 🟡 |
| [DA-D18-16](#da-d18-16) | **[R3 §3.19.4]** Write FR — Publish Status Tracking | Phước | 🟡 |
| [DA-D18-17](#da-d18-17) | **[R3 §3.20.1]** Write FR — Image/Reel Post to Instagram | Phước | 🟡 |
| [DA-D18-18](#da-d18-18) | **[R3 §3.20.2]** Write FR — Carousel Post | Phước | 🟡 |
| [DA-D18-19](#da-d18-19) | **[R3 §3.20.3]** Write FR — Instagram Story | Phước | 🟡 |
| [DA-D18-20](#da-d18-20) | **[R3 §3.20.4]** Write FR — Threads Post | Phước | 🟡 |
| [DA-D18-21](#da-d18-21) | **[R3 §3.21.1]** Write FR — Text Broadcast to Zalo OA | Phước | 🟡 |
| [DA-D18-22](#da-d18-22) | **[R3 §3.21.2]** Write FR — Image Broadcast | Phước | 🟡 |
| [DA-D18-23](#da-d18-23) | **[R3 §3.21.3]** Write FR — Template Message | Phước | 🟡 |
| [DA-D18-24](#da-d18-24) | **[R3 §3.21.4]** Write FR — Schedule Broadcast | Phước | 🟡 |
| [DA-D18-25](#da-d18-25) | **[R3 §3.22.1]** Write FR — Retry Logic (3x Exponential Backoff) | Phước | 🟡 |
| [DA-D18-26](#da-d18-26) | **[R3 §3.22.2]** Write FR — Dead Letter Queue (RabbitMQ) | Phước | 🟡 |
| [DA-D18-27](#da-d18-27) | **[R3 §3.22.3]** Write FR — Error Notification to User | Phước | 🟡 |
| [DA-D18-28](#da-d18-28) | **[R3 §3.22.4]** Write FR — Manual Retry from Dashboard | Phước | 🟡 |
| [DA-D18-29](#da-d18-29) | **[R3 §3.23.1]** Write FR — In-App Notification | Phước | 🟡 |
| [DA-D18-30](#da-d18-30) | **[R3 §3.23.2]** Write FR — Email Notification | Phước | 🟡 |
| [DA-D18-31](#da-d18-31) | **[R3 §3.23.3]** Write FR — Push Notification (FCM) | Phước | 🟡 |
| [DA-D18-32](#da-d18-32) | **[R3 §3.23.4]** Write FR — Notification Preferences | Phước | 🟡 |
| [DA-D18-33](#da-d18-33) | **[R3 §3.23.5]** Write FR — Notification Center (Bell Icon UI) | Phước | 🟡 |

---

### EPIC D19 — R3 §3.24-3.27: FR — Subscription, Analytics, Admin, Mobile (21 per-function tasks)

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| [DA-D19-01](#da-d19-01) | **[R3 §3.24.1]** Write FR — Plan Selection (Free/Basic/Pro/Enterprise) | Ân | 🟡 |
| [DA-D19-02](#da-d19-02) | **[R3 §3.24.2]** Write FR — Payment Integration (VNPay/Momo) | Ân | 🟡 |
| [DA-D19-03](#da-d19-03) | **[R3 §3.24.3]** Write FR — Invoice History | Ân | 🟡 |
| [DA-D19-04](#da-d19-04) | **[R3 §3.24.4]** Write FR — AI Credit Tracking | Ân | 🟡 |
| [DA-D19-05](#da-d19-05) | **[R3 §3.24.5]** Write FR — Upgrade/Downgrade Plan | Ân | 🟡 |
| [DA-D19-06](#da-d19-06) | **[R3 §3.25.1]** Write FR — Content Performance Dashboard | Ân | 🟡 |
| [DA-D19-07](#da-d19-07) | **[R3 §3.25.2]** Write FR — Platform Analytics (per platform) | Ân | 🟡 |
| [DA-D19-08](#da-d19-08) | **[R3 §3.25.3]** Write FR — Team Productivity Report | Ân | 🟡 |
| [DA-D19-09](#da-d19-09) | **[R3 §3.25.4]** Write FR — Export as PDF | Ân | 🟡 |
| [DA-D19-10](#da-d19-10) | **[R3 §3.25.5]** Write FR — Export as Excel | Ân | 🟡 |
| [DA-D19-11](#da-d19-11) | **[R3 §3.25.6]** Write FR — Scheduled Reports | Ân | 🟡 |
| [DA-D19-12](#da-d19-12) | **[R3 §3.26.1]** Write FR — User Management (Verify/Disable/Delete) | Ân | 🟡 |
| [DA-D19-13](#da-d19-13) | **[R3 §3.26.2]** Write FR — Content Moderation Queue | Ân | 🟡 |
| [DA-D19-14](#da-d19-14) | **[R3 §3.26.3]** Write FR — System Health Monitoring | Ân | 🟡 |
| [DA-D19-15](#da-d19-15) | **[R3 §3.26.4]** Write FR — Platform Statistics Overview | Ân | 🟡 |
| [DA-D19-16](#da-d19-16) | **[R3 §3.27.1]** Write FR — Mobile Authentication | Ân | 🟡 |
| [DA-D19-17](#da-d19-17) | **[R3 §3.27.2]** Write FR — Mobile Dashboard | Ân | 🟡 |
| [DA-D19-18](#da-d19-18) | **[R3 §3.27.3]** Write FR — Content Calendar (Mobile) | Ân | 🟡 |
| [DA-D19-19](#da-d19-19) | **[R3 §3.27.4]** Write FR — Push Notification Handling | Ân | 🟡 |
| [DA-D19-20](#da-d19-20) | **[R3 §3.27.5]** Write FR — Approve/Reject on Mobile | Ân | 🟡 |
| [DA-D19-21](#da-d19-21) | **[R3 §3.27.6]** Write FR — Content Preview (Mobile) | Ân | 🟡 |

---

### EPIC D20 — R3 §4-5: NFR & Appendices

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| [DA-D20-01](#da-d20-01) | **[R3 §4.2]** Write Non-Functional Requirements — §4.1 External Interfaces (Payment, OAuth, Maps, FCM, Email/SMS), §4.2 Quality Attributes (4.2.1 Usability, 4.2.2 Reliability, 4.2.3 Performance, 4.2.4 Security/Compatibility/Maintainability/Legal) | Trung | 🔴 |
| [DA-D20-02](#da-d20-02) | **[R3 §5.1]** Compile Business Rules Appendix — BR-01 through BR-NN from all FR sections | Ân | 🟡 |
| [DA-D20-03](#da-d20-03) | **[R3 §5.3]** Compile Message Lists Appendix — MSG01 through MSG-NN (Code, Type, Context, Content) | Ân | 🟡 |
| [DA-D20-04](#da-d20-04) | **[R3 §5.2]** Compile Common Requirements — shared FR rules, common constraints, cross-cutting conventions | Ân | 🟢 |
| [DA-D20-05](#da-d20-05) | **[R3 §5.4]** Compile Other Requirements Appendix — additional requirements not covered in §5.1-5.3 | Ân | 🟢 |

---

## PHASE 5 — Review, Merge & Submit

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
| [DA-D23-02](#da-d23-02) | Prepare Presentation Summary — key points from each report for exam presentation | Trung | 🟡 |

---

## SPRINT SUMMARY TABLE

| Phase | Key Deliverables |
|---|---|
| Phase 1 — Diagrams | 16 diagrams (Context, Architecture, Use Case, ERD, 6 Screen Flows, Auth Matrix, WBS Tree, Scrum Timeline, Branch Strategy, Folder Structure, Mockups) |
| Phase 2 — R1 Writing | Report 1 Draft: §1 Overview → §2 Product Background → §3 Existing Systems → §4 Business Opportunity → §5 Product Vision → §6 Scope & Limitations → §7 References |
| Phase 3 — R2 Writing | Report 2 Draft: §1 Overview (WBS, Objectives, Risks) → §2 Mgmt Approach (Process, Quality, Training) → §3 Deliverables → §4 Responsibility → §5 Communications → §6 Config Mgmt |
| Phase 4 — R3 Writing | Report 3 Draft: §1 Product Overview → §2 User Requirements → §3 Functional Requirements (§3.1-§3.27) → §4 NFR → §5 Appendix |
| Phase 5 — Review & Merge | Cross-review (13 individual review tasks + 5 fix tasks), 3 reports merged & formatted, final PDF package |
| Submit | Submit to exam committee, presentation |

---

## WORKLOAD DISTRIBUTION TABLE

| Member | Tasks | Breakdown |
|---|---|---|
| Trung | ~40 | Diagram review (1), WBS + Objectives + Risks (3), Product Overview + Context + ERD (3), Auth FR §3.2.1-3.2.6 (6), User/Workspace/RBAC FR §3.3-3.5 (16), NFR (1), Merge 3 reports + Format (4), Review R1/R2/R3 (3), Feedback coord (1), Final package + Presentation (2) |
| Lộc | ~44 | Branch Strategy + Folder Structure (2), Screen Flow Admin + Agency Owner (2), Auth Matrix + Mockups (2), Product Background + Existing Systems (2), UC Admin/Agency (1), Screen Desc Admin/Agency (1), Content/Calendar/Approval/Client/Agency FR §3.6-3.10 (26), Auth FR §3.2.7-3.2.11 (5), Review R1/R3 (2), Fix feedback (1) |
| Phước | ~47 | Architecture + WBS Tree + Scrum Timeline (3), Screen Flow AM + CC (2), Mgmt Approach + Quality (2), Deliverables + Communications + Config Mgmt (3), Screen Desc AM/CC (1), Publishing/Social/Notifications FR §3.17-3.23 (33), Review R2/R3 (2), Fix feedback (1) |
| Tuấn | ~44 | Context + UC Overview + ERD + Screen Flow Brand/Guest (5), Business Opportunity + Product Vision (2), Training Plan (1), Actors (1), UC AC/CC/BC/Guest (1), Screen Desc Brand/Guest + Non-Screen (2), AI Features FR §3.11-3.16 (28), Review R1/R2/R3 (3), Fix feedback (1) |
| Ân | ~32 | Scope + Limitations + References (3), Responsibility + Tools (2), Subscription/Analytics/Admin/Mobile FR §3.24-3.27 (21), Business Rules + Messages (2), Review R1/R2/R3 (3), Fix feedback (1) |

> **Tổng:** ~207 individual tasks (135 FR per-function + 72 non-FR). Mỗi task 1 assignee duy nhất.

---

## NOTES

- Tất cả nội dung report viết bằng **English** (SEP490 requirement).
- Mỗi task có **1 assignee duy nhất** — không còn task gán nhiều người.
- Mỗi task ghi rõ **[Report § Section]** để biết chính xác vị trí trong report.
- Diagram team (Tuấn, Lộc, Phước) vẽ Phase 1 trước. Sau khi diagram duyệt, toàn team viết song song Phase 2-4.
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

### DA-D02-01 — [R3 §2.2.1] Draw Use Case Overview Diagram

- **Goal:** 60 use cases, 6 actors. Dùng cho R3 §2.2.1 (Use Case Diagram).

- **Acceptance Criteria:**
  - 6 actor stick figures, 60 use case ovals grouped by functional area
  - <<include>>, <<extend>> relationships
  - System boundary box

- **Source References:** `docs/plan/sprints/sprint_02/PLAN.md#epic-e03`, `docs/api/endpoints/`

- **Dependencies:** DA-D01-01

---

### DA-D02-02 — [R3 §3.1.5] Draw ERD

- **Goal:** 12 MongoDB collections + 5 PostgreSQL tables. Dùng cho R3 §3.1.5.

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

### DA-D03-07 — [R3 §3.1.3] Draw Screen Authorization Matrix

- **Goal:** Ma trận screens × roles. Dùng cho R3 §3.1.3.

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
  - Feedback documented, fixed trước khi team viết nội dung

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

### DA-D12-03 — [R3 §3.1.5] Write ERD Description

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

### DA-D13-02 — [R3 §2.2.2] Write Use Case Descriptions — Admin & Agency Owner

- **Goal:** ~20 UCs: ADMIN + AGENCY_OWNER.

- **Acceptance Criteria:**
  - Mỗi UC: ID, Use Case, Actors, Description
  - Format theo sample Table 3

- **Source References:** `docs/plan/sprints/sprint_02/PLAN.md#epic-e03`, `docs/feature/*/spec.md`

- **Dependencies:** DA-D13-01, DA-D02-01

---

### DA-D13-03 — [R3 §2.2.2] Write Use Case Descriptions — AC, CC, BC, Guest

- **Goal:** ~40 UCs: ACCOUNT_MANAGER + CONTENT_CREATOR + BRAND_CLIENT + GUEST.

- **Acceptance Criteria:**
  - Format theo sample Table 3

- **Source References:** `docs/plan/sprints/sprint_02/PLAN.md#epic-e03`, `docs/api/endpoints/`

- **Dependencies:** DA-D13-01, DA-D02-01

---

### DA-D14-01 — [R3 §3.1.2] Write Screen Descriptions — Admin & Agency Owner

- **Goal:** Screen Description table cho ADMIN + AGENCY_OWNER (~35 screens).

- **Acceptance Criteria:**
  - Format: #, Feature, Screen, Description
  - Khớp Screen Flow diagrams

- **Source References:** DA-D03-01, DA-D03-02, Figma

- **Dependencies:** DA-D03-01, DA-D03-02

---

### DA-D14-02 — [R3 §3.1.2] Write Screen Descriptions — Account Manager & Content Creator

- **Goal:** Screen Description table cho ACCOUNT_MANAGER + CONTENT_CREATOR (~30 screens).

- **Acceptance Criteria:**
  - Format: #, Feature, Screen, Description
  - Khớp Screen Flow diagrams

- **Source References:** DA-D03-03, DA-D03-04, Figma

- **Dependencies:** DA-D03-03, DA-D03-04

---

### DA-D14-03 — [R3 §3.1.2] Write Screen Descriptions — Brand Client & Guest

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

### DA-D15-01 — [R3 §3.2.1] Write FR — Register (Email)

- **Goal:** Mô tả chức năng đăng ký tài khoản bằng email.
- **Format:** Function Trigger → Description (Actors, Purpose, Interface, Data Processing) → Screen Layout → Data → Business Rules → Normal Flow → Abnormal Cases → Post-Conditions
- **Business Rules:** email unique, bcrypt cost=12, role mặc định theo flow, welcome email.
- **Source References:** `docs/feature/auth/*/spec.md`, `docs/api/endpoints/01_auth.md`, `docs/plan/sprints/sprint_05/PLAN.md`
- **Dependencies:** DA-D14-01 through DA-D14-04

---

### DA-D15-02 — [R3 §3.2.2] Write FR — Login (Email + Password)

- **Goal:** Mô tả đăng nhập bằng email + mật khẩu, cấp JWT access token (15 min) + refresh token (30 days).
- **Business Rules:** verify password (bcrypt), isActive check, JWT RS256.
- **Source References:** `docs/feature/auth/*/spec.md`, `docs/api/endpoints/01_auth.md`, `docs/plan/sprints/sprint_05/PLAN.md`
- **Dependencies:** DA-D14-01 through DA-D14-04

---

### DA-D15-03 — [R3 §3.2.3] Write FR — Login (Google OAuth)

- **Goal:** Mô tả đăng nhập bằng Google OAuth — redirect consent screen, callback handler, tạo user nếu chưa tồn tại.
- **Business Rules:** scope `openid email profile`, tạo user role AGENCY_OWNER nếu mới.
- **Source References:** `docs/feature/auth/oauth-social-login/spec.md`, `docs/api/endpoints/01_auth.md`, `docs/plan/sprints/sprint_05/PLAN.md`
- **Dependencies:** DA-D14-01 through DA-D14-04

---

### DA-D15-04 — [R3 §3.2.4] Write FR — Social OAuth Connect (Facebook, TikTok, Instagram, Zalo)

- **Goal:** Mô tả liên kết tài khoản social (FB, TikTok, Instagram, Zalo) vào tài khoản BrandHub.
- **Business Rules:** OAuth 2.0 flow mỗi platform, lưu token status, refresh.
- **Source References:** `docs/api/endpoints/01_auth.md`, `docs/plan/sprints/sprint_05/PLAN.md`
- **Dependencies:** DA-D14-01 through DA-D14-04

---

### DA-D15-05 — [R3 §3.2.5] Write FR — Two-Factor Authentication (2FA, TOTP)

- **Goal:** Mô tả bật/tắt 2FA bằng TOTP qua Email hoặc Authenticator App.
- **Business Rules:** TOTP secret, backup codes, verify trên mỗi login bật 2FA.
- **Source References:** `docs/feature/auth/*/spec.md`, `docs/plan/sprints/sprint_05/PLAN.md`
- **Dependencies:** DA-D14-01 through DA-D14-04

---

### DA-D15-06 — [R3 §3.2.6] Write FR — Forgot Password

- **Goal:** Mô tả gửi email đặt lại mật khẩu khi người dùng quên mật khẩu.
- **Business Rules:** reset token UUID TTL 1h, lưu Redis `pwd:reset:{token}`, gửi email.
- **Source References:** `docs/api/endpoints/01_auth.md`, `docs/plan/sprints/sprint_05/PLAN.md`
- **Dependencies:** DA-D14-01 through DA-D14-04

---

### DA-D15-07 — [R3 §3.2.7] Write FR — Reset Password

- **Goal:** Mô tả đặt lại mật khẩu mới qua link hợp lệ trong email (trong 1h).
- **Business Rules:** verify token, đổi password, xoá token sau khi dùng.
- **Source References:** `docs/api/endpoints/01_auth.md`, `docs/plan/sprints/sprint_05/PLAN.md`
- **Dependencies:** DA-D14-01 through DA-D14-04

---

### DA-D15-08 — [R3 §3.2.8] Write FR — Change Password

- **Goal:** Mô tả đổi mật khẩu khi đã đăng nhập (yêu cầu mật khẩu hiện tại).
- **Business Rules:** verify old password, bcrypt cost=12, đăng xuất session cũ nếu cần.
- **Source References:** `docs/api/endpoints/01_auth.md`, `docs/plan/sprints/sprint_05/PLAN.md`
- **Dependencies:** DA-D14-01 through DA-D14-04

---

### DA-D15-09 — [R3 §3.2.9] Write FR — OTP Verification

- **Goal:** Mô tả xác minh mã OTP trong các flow (2FA, reset password, verify email).
- **Business Rules:** OTP TTL, max retry, mark used.
- **Source References:** `docs/api/endpoints/01_auth.md`, `docs/plan/sprints/sprint_05/PLAN.md`
- **Dependencies:** DA-D14-01 through DA-D14-04

---

### DA-D15-10 — [R3 §3.2.10] Write FR — Token Refresh (JWT RS256)

- **Goal:** Mô tả làm mới access token bằng refresh token.
- **Business Rules:** refresh token 30d TTL, HttpOnly cookie + MongoDB `users.refreshTokens[]`, rotate.
- **Source References:** `docs/api/endpoints/01_auth.md`, `docs/plan/sprints/sprint_05/PLAN.md`
- **Dependencies:** DA-D14-01 through DA-D14-04

---

### DA-D15-11 — [R3 §3.2.11] Write FR — Sign Out (Token Blacklist)

- **Goal:** Mô tả đăng xuất — thu hồi refresh token / blacklist access token.
- **Business Rules:** token blacklist, xoá refresh token khỏi DB.
- **Source References:** `docs/api/endpoints/01_auth.md`, `docs/plan/sprints/sprint_05/PLAN.md`
- **Dependencies:** DA-D14-01 through DA-D14-04

---

### EPIC D15 — R3 §3.3-3.5: FR — User/Workspace/RBAC (16 tasks)

<a id="da-d15-12"></a><a id="da-d15-13"></a><a id="da-d15-14"></a><a id="da-d15-15"></a><a id="da-d15-16"></a><a id="da-d15-17"></a><a id="da-d15-18"></a><a id="da-d15-19"></a><a id="da-d15-20"></a><a id="da-d15-21"></a><a id="da-d15-22"></a><a id="da-d15-23"></a><a id="da-d15-24"></a><a id="da-d15-25"></a><a id="da-d15-26"></a><a id="da-d15-27"></a>

Mỗi task = 1 function trong §3.3-3.5. Format chung mỗi function: Function Trigger → Description (Actors, Purpose, Interface, Data Processing) → Screen Layout → Data → Business Rules → Normal Flow → Abnormal Cases → Post-Conditions. (Các task §3.2: DA-D15-01..11 ở trên.)

| Task ID | §Section | Function | Assignee |
|---|---|---|---|
| DA-D15-12 | §3.3.1 | View Profile | Trung |
| DA-D15-13 | §3.3.2 | Update Profile | Trung |
| DA-D15-14 | §3.3.3 | Avatar Upload | Trung |
| DA-D15-15 | §3.3.4 | Identity Verification | Trung |
| DA-D15-16 | §3.3.5 | Account Deactivation | Trung |
| DA-D15-17 | §3.4.1 | Create Workspace | Trung |
| DA-D15-18 | §3.4.2 | Update Workspace | Trung |
| DA-D15-19 | §3.4.3 | Delete Workspace | Trung |
| DA-D15-20 | §3.4.4 | View Members | Trung |
| DA-D15-21 | §3.4.5 | Invite Member | Trung |
| DA-D15-22 | §3.4.6 | Remove Member | Trung |
| DA-D15-23 | §3.4.7 | Multi-tenancy Data Isolation | Trung |
| DA-D15-24 | §3.5.1 | Assign Role | Trung |
| DA-D15-25 | §3.5.2 | Revoke Role | Trung |
| DA-D15-26 | §3.5.3 | View Permissions | Trung |
| DA-D15-27 | §3.5.4 | Permission Check Enforcement | Trung |

- **Source References:** `docs/plan/sprints/sprint_06/PLAN.md`, `docs/database/DA-E06-08_Database_Access_Rules.md`, `docs/api/endpoints/`

- **Dependencies:** DA-D14-01 through DA-D14-04

---

### EPIC D16 — R3 §3.6-3.10: FR — Content & Workflow (26 tasks)

<a id="da-d16-01"></a><a id="da-d16-02"></a><a id="da-d16-03"></a><a id="da-d16-04"></a><a id="da-d16-05"></a><a id="da-d16-06"></a><a id="da-d16-07"></a><a id="da-d16-08"></a><a id="da-d16-09"></a><a id="da-d16-10"></a><a id="da-d16-11"></a><a id="da-d16-12"></a><a id="da-d16-13"></a><a id="da-d16-14"></a><a id="da-d16-15"></a><a id="da-d16-16"></a><a id="da-d16-17"></a><a id="da-d16-18"></a><a id="da-d16-19"></a><a id="da-d16-20"></a><a id="da-d16-21"></a><a id="da-d16-22"></a><a id="da-d16-23"></a><a id="da-d16-24"></a><a id="da-d16-25"></a><a id="da-d16-26"></a>

Mỗi task = 1 function. Format chung mỗi function: Function Trigger → Description (Actors, Purpose, Interface, Data Processing) → Screen Layout → Data → Business Rules → Normal Flow → Abnormal Cases → Post-Conditions.

| Task ID | §Section | Function | Assignee |
|---|---|---|---|
| DA-D16-01 | §3.6.1 | Create Content Request | Lộc |
| DA-D16-02 | §3.6.2 | Assign Task to Creator | Lộc |
| DA-D16-03 | §3.6.3 | Track Request Status | Lộc |
| DA-D16-04 | §3.6.4 | Revise Request | Lộc |
| DA-D16-05 | §3.6.5 | Cancel Request | Lộc |
| DA-D16-06 | §3.7.1 | Calendar View (Day/Week/Month) | Lộc |
| DA-D16-07 | §3.7.2 | Drag-drop Schedule Post | Lộc |
| DA-D16-08 | §3.7.3 | Recurring Posts | Lộc |
| DA-D16-09 | §3.7.4 | Timezone Configuration | Lộc |
| DA-D16-10 | §3.7.5 | Calendar Filter by Platform/Status | Lộc |
| DA-D16-11 | §3.8.1 | Submit Content for Review | Lộc |
| DA-D16-12 | §3.8.2 | Approve Content | Lộc |
| DA-D16-13 | §3.8.3 | Reject with Comments | Lộc |
| DA-D16-14 | §3.8.4 | Revision Loop | Lộc |
| DA-D16-15 | §3.8.5 | Approval Chain (Creator → Manager → Client) | Lộc |
| DA-D16-16 | §3.9.1 | Client Login | Lộc |
| DA-D16-17 | §3.9.2 | View Content Calendar | Lộc |
| DA-D16-18 | §3.9.3 | Approve/Reject Content | Lộc |
| DA-D16-19 | §3.9.4 | View Analytics Dashboard | Lộc |
| DA-D16-20 | §3.9.5 | Add Comments on Content | Lộc |
| DA-D16-21 | §3.10.1 | Create Client | Lộc |
| DA-D16-22 | §3.10.2 | Update Client Info | Lộc |
| DA-D16-23 | §3.10.3 | Delete/Archive Client | Lộc |
| DA-D16-24 | §3.10.4 | Assign Account Manager | Lộc |
| DA-D16-25 | §3.10.5 | Client Onboarding Flow | Lộc |
| DA-D16-26 | §3.10.6 | Client Settings/Preferences | Lộc |

- **Source References:** `docs/plan/sprints/sprint_10/PLAN.md`, `docs/plan/sprints/sprint_11/PLAN.md`, `docs/plan/sprints/sprint_13/PLAN.md`, `docs/api/endpoints/`

- **Dependencies:** DA-D14-01 through DA-D14-04

---

### EPIC D17 — R3 §3.11-3.16: FR — AI Features (28 tasks)

<a id="da-d17-01"></a><a id="da-d17-02"></a><a id="da-d17-03"></a><a id="da-d17-04"></a><a id="da-d17-05"></a><a id="da-d17-06"></a><a id="da-d17-07"></a><a id="da-d17-08"></a><a id="da-d17-09"></a><a id="da-d17-10"></a><a id="da-d17-11"></a><a id="da-d17-12"></a><a id="da-d17-13"></a><a id="da-d17-14"></a><a id="da-d17-15"></a><a id="da-d17-16"></a><a id="da-d17-17"></a><a id="da-d17-18"></a><a id="da-d17-19"></a><a id="da-d17-20"></a><a id="da-d17-21"></a><a id="da-d17-22"></a><a id="da-d17-23"></a><a id="da-d17-24"></a><a id="da-d17-25"></a><a id="da-d17-26"></a><a id="da-d17-27"></a><a id="da-d17-28"></a>

Mỗi task = 1 function. Format chung mỗi function: Function Trigger → Description (Actors, Purpose, Interface, Data Processing) → Screen Layout → Data → Business Rules → Normal Flow → Abnormal Cases → Post-Conditions.

| Task ID | §Section | Function | Assignee |
|---|---|---|---|
| DA-D17-01 | §3.11.1 | Text Generation (Caption) | Tuấn |
| DA-D17-02 | §3.11.2 | Text Generation (Blog/Article) | Tuấn |
| DA-D17-03 | §3.11.3 | Text Generation (Ad Copy) | Tuấn |
| DA-D17-04 | §3.11.4 | Tone/Brand Voice Selection | Tuấn |
| DA-D17-05 | §3.11.5 | Anti-Hallucination Guard | Tuấn |
| DA-D17-06 | §3.11.6 | Content History & Reuse | Tuấn |
| DA-D17-07 | §3.12.1 | Text-to-Image Generation | Tuấn |
| DA-D17-08 | §3.12.2 | Style Presets | Tuấn |
| DA-D17-09 | §3.12.3 | Brand Asset Upload for Reference | Tuấn |
| DA-D17-10 | §3.12.4 | Image Variations | Tuấn |
| DA-D17-11 | §3.12.5 | Background Removal | Tuấn |
| DA-D17-12 | §3.13.1 | Script-to-Video Generation | Tuấn |
| DA-D17-13 | §3.13.2 | Template Selection | Tuấn |
| DA-D17-14 | §3.13.3 | Scene Mapping | Tuấn |
| DA-D17-15 | §3.13.4 | Export Format Selection (MP4/GIF/WebM) | Tuấn |
| DA-D17-16 | §3.14.1 | Face Upload for Ambassador | Tuấn |
| DA-D17-17 | §3.14.2 | InstantID Model Setup | Tuấn |
| DA-D17-18 | §3.14.3 | Ambassador Video Generation | Tuấn |
| DA-D17-19 | §3.14.4 | Ambassador Management (Create/Edit/Delete) | Tuấn |
| DA-D17-20 | §3.15.1 | Document Upload (PDF/DOCX/TXT) | Tuấn |
| DA-D17-21 | §3.15.2 | Document Chunking | Tuấn |
| DA-D17-22 | §3.15.3 | Embedding Generation (ChromaDB) | Tuấn |
| DA-D17-23 | §3.15.4 | Brand Voice Training | Tuấn |
| DA-D17-24 | §3.15.5 | Knowledge Base Search (Semantic) | Tuấn |
| DA-D17-25 | §3.16.1 | Keyword Configuration | Tuấn |
| DA-D17-26 | §3.16.2 | Auto-Crawl Schedule | Tuấn |
| DA-D17-27 | §3.16.3 | Trending Topics Dashboard | Tuấn |
| DA-D17-28 | §3.16.4 | Trend-to-Content Suggestions | Tuấn |

- **Source References:** `docs/iterations/README.md`, `docs/plan/BrandHub_Master_Plan.md` (AI01-AI11), `docs/plan/sprints/sprint_09/PLAN.md`

- **Dependencies:** DA-D14-01 through DA-D14-04

---

### EPIC D18 — R3 §3.17-3.23: FR — Publishing & Social (33 tasks)

<a id="da-d18-01"></a><a id="da-d18-02"></a><a id="da-d18-03"></a><a id="da-d18-04"></a><a id="da-d18-05"></a><a id="da-d18-06"></a><a id="da-d18-07"></a><a id="da-d18-08"></a><a id="da-d18-09"></a><a id="da-d18-10"></a><a id="da-d18-11"></a><a id="da-d18-12"></a><a id="da-d18-13"></a><a id="da-d18-14"></a><a id="da-d18-15"></a><a id="da-d18-16"></a><a id="da-d18-17"></a><a id="da-d18-18"></a><a id="da-d18-19"></a><a id="da-d18-20"></a><a id="da-d18-21"></a><a id="da-d18-22"></a><a id="da-d18-23"></a><a id="da-d18-24"></a><a id="da-d18-25"></a><a id="da-d18-26"></a><a id="da-d18-27"></a><a id="da-d18-28"></a><a id="da-d18-29"></a><a id="da-d18-30"></a><a id="da-d18-31"></a><a id="da-d18-32"></a><a id="da-d18-33"></a>

Mỗi task = 1 function. Format chung mỗi function: Function Trigger → Description (Actors, Purpose, Interface, Data Processing) → Screen Layout → Data → Business Rules → Normal Flow → Abnormal Cases → Post-Conditions.

| Task ID | §Section | Function | Assignee |
|---|---|---|---|
| DA-D18-01 | §3.17.1 | Connect Social Account (OAuth) | Phước |
| DA-D18-02 | §3.17.2 | Disconnect Account | Phước |
| DA-D18-03 | §3.17.3 | View Token Status | Phước |
| DA-D18-04 | §3.17.4 | Refresh Token | Phước |
| DA-D18-05 | §3.17.5 | Platform Rate Limit Display | Phước |
| DA-D18-06 | §3.18.1 | Text Post to Facebook Page | Phước |
| DA-D18-07 | §3.18.2 | Image Post | Phước |
| DA-D18-08 | §3.18.3 | Video Post | Phước |
| DA-D18-09 | §3.18.4 | Carousel Post | Phước |
| DA-D18-10 | §3.18.5 | Schedule Post | Phước |
| DA-D18-11 | §3.18.6 | Post Preview | Phước |
| DA-D18-12 | §3.18.7 | Publish Status Tracking | Phước |
| DA-D18-13 | §3.19.1 | Video Upload to TikTok | Phước |
| DA-D18-14 | §3.19.2 | Caption + Hashtags | Phước |
| DA-D18-15 | §3.19.3 | Schedule Post | Phước |
| DA-D18-16 | §3.19.4 | Publish Status Tracking | Phước |
| DA-D18-17 | §3.20.1 | Image/Reel Post to Instagram | Phước |
| DA-D18-18 | §3.20.2 | Carousel Post | Phước |
| DA-D18-19 | §3.20.3 | Instagram Story | Phước |
| DA-D18-20 | §3.20.4 | Threads Post | Phước |
| DA-D18-21 | §3.21.1 | Text Broadcast to Zalo OA | Phước |
| DA-D18-22 | §3.21.2 | Image Broadcast | Phước |
| DA-D18-23 | §3.21.3 | Template Message | Phước |
| DA-D18-24 | §3.21.4 | Schedule Broadcast | Phước |
| DA-D18-25 | §3.22.1 | Retry Logic (3x Exponential Backoff) | Phước |
| DA-D18-26 | §3.22.2 | Dead Letter Queue (RabbitMQ) | Phước |
| DA-D18-27 | §3.22.3 | Error Notification to User | Phước |
| DA-D18-28 | §3.22.4 | Manual Retry from Dashboard | Phước |
| DA-D18-29 | §3.23.1 | In-App Notification | Phước |
| DA-D18-30 | §3.23.2 | Email Notification | Phước |
| DA-D18-31 | §3.23.3 | Push Notification (FCM) | Phước |
| DA-D18-32 | §3.23.4 | Notification Preferences | Phước |
| DA-D18-33 | §3.23.5 | Notification Center (Bell Icon UI) | Phước |

- **Source References:** `docs/plan/sprints/sprint_07/PLAN.md`, `docs/plan/sprints/sprint_08/PLAN.md`, `docs/plan/sprints/sprint_11/PLAN.md`, `docs/plan/sprints/sprint_13/PLAN.md`, `docs/api/endpoints/`

- **Dependencies:** DA-D14-01 through DA-D14-04

---

### EPIC D19 — R3 §3.24-3.27: FR — Subscription, Analytics, Admin, Mobile (21 tasks)

<a id="da-d19-01"></a><a id="da-d19-02"></a><a id="da-d19-03"></a><a id="da-d19-04"></a><a id="da-d19-05"></a><a id="da-d19-06"></a><a id="da-d19-07"></a><a id="da-d19-08"></a><a id="da-d19-09"></a><a id="da-d19-10"></a><a id="da-d19-11"></a><a id="da-d19-12"></a><a id="da-d19-13"></a><a id="da-d19-14"></a><a id="da-d19-15"></a><a id="da-d19-16"></a><a id="da-d19-17"></a><a id="da-d19-18"></a><a id="da-d19-19"></a><a id="da-d19-20"></a><a id="da-d19-21"></a>

Mỗi task = 1 function. Format chung mỗi function: Function Trigger → Description (Actors, Purpose, Interface, Data Processing) → Screen Layout → Data → Business Rules → Normal Flow → Abnormal Cases → Post-Conditions.

| Task ID | §Section | Function | Assignee |
|---|---|---|---|
| DA-D19-01 | §3.24.1 | Plan Selection (Free/Basic/Pro/Enterprise) | Ân |
| DA-D19-02 | §3.24.2 | Payment Integration (VNPay/Momo) | Ân |
| DA-D19-03 | §3.24.3 | Invoice History | Ân |
| DA-D19-04 | §3.24.4 | AI Credit Tracking | Ân |
| DA-D19-05 | §3.24.5 | Upgrade/Downgrade Plan | Ân |
| DA-D19-06 | §3.25.1 | Content Performance Dashboard | Ân |
| DA-D19-07 | §3.25.2 | Platform Analytics (per platform) | Ân |
| DA-D19-08 | §3.25.3 | Team Productivity Report | Ân |
| DA-D19-09 | §3.25.4 | Export as PDF | Ân |
| DA-D19-10 | §3.25.5 | Export as Excel | Ân |
| DA-D19-11 | §3.25.6 | Scheduled Reports | Ân |
| DA-D19-12 | §3.26.1 | User Management (Verify/Disable/Delete) | Ân |
| DA-D19-13 | §3.26.2 | Content Moderation Queue | Ân |
| DA-D19-14 | §3.26.3 | System Health Monitoring | Ân |
| DA-D19-15 | §3.26.4 | Platform Statistics Overview | Ân |
| DA-D19-16 | §3.27.1 | Mobile Authentication | Ân |
| DA-D19-17 | §3.27.2 | Mobile Dashboard | Ân |
| DA-D19-18 | §3.27.3 | Content Calendar (Mobile) | Ân |
| DA-D19-19 | §3.27.4 | Push Notification Handling | Ân |
| DA-D19-20 | §3.27.5 | Approve/Reject on Mobile | Ân |
| DA-D19-21 | §3.27.6 | Content Preview (Mobile) | Ân |

- **Source References:** `docs/plan/sprints/sprint_06/PLAN.md`, `docs/plan/sprints/sprint_13/PLAN.md`, `docs/plan/sprints/sprint_14/PLAN.md`, `docs/api/endpoints/`

- **Dependencies:** DA-D14-01 through DA-D14-04

---

### DA-D20-01 — [R3 §4.2] Write Non-Functional Requirements

- **Goal:** §4.1 External Interfaces + §4.2 Quality Attributes.

- **Acceptance Criteria:**
  - §4.1: Payment Gateway, OAuth, Maps, FCM, Email/SMS (với performance thresholds)
  - §4.2 chia theo attribute trong form mới:
    - 4.2.1 Usability: ≤5 steps, ≤15 min onboarding, WCAG 2.1 AA
    - 4.2.2 Reliability: 99.5%, MTTR ≤2h
    - 4.2.3 Performance: <2s page, <1s search, 1000 concurrent
    - 4.2.4 Security / Compatibility / Maintainability / Legal: Security (JWT RS256, BCrypt=12, AES-256, RBAC, 2FA, audit logs), Compatibility, Maintainability (≥80% coverage), Legal (VN data privacy, PCI DSS)

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

### DA-D20-04 — [R3 §5.2] Compile Common Requirements

- **Goal:** Tổng hợp Common Requirements cho R3 §5.2 — các yêu cầu dùng chung xuyên suốt hệ thống.

- **Acceptance Criteria:**
  - Shared functional rules áp dụng nhiều feature (login-session, pagination, audit, format chuẩn)
  - Cross-cutting constraints: timezone, permission enforcement pattern, error message convention
  - Không trùng lặp với BR/FR từng section, không mâu thuẫn

- **Source References:** `docs/rule/feature-workflow.md`, `docs/database/DA-E06-08_Database_Access_Rules.md`

- **Dependencies:** Tất cả FR sections

---

### DA-D20-05 — [R3 §5.4] Compile Other Requirements

- **Goal:** Tổng hợp Other Requirements cho R3 §5.4 — các yêu cầu bổ sung chưa nằm trong §5.1-5.3.

- **Acceptance Criteria:**
  - Các requirement phụ: localization, accessibility, data retention, backup, monitoring
  - Format nhất quán với các appendix khác
  - English, mỗi item rõ ràng, actionable

- **Source References:** `docs/architecture/`, `docs/plan/BrandHub_Master_Plan.md`

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

- **Goal:** Key points từ mỗi report cho buổi trình bày.

- **Acceptance Criteria:**
  - 1-2 slides/report: R1 (Problem→Solution→Vision), R2 (Timeline→Team→Methodology), R3 (Key features→Architecture→Tech highlights)

- **Dependencies:** DA-D23-01
