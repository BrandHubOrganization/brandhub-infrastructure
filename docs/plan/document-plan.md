# BrandHub — SEP490 Document Plan & Task Details (V2)

> Kế hoạch viết 3 capstone reports cho SEP490 Fall 2026.
> Mỗi task ghi rõ: Report → Section → Mục. Click **Task ID** để nhảy tới chi tiết Phần 2.
> **Version 2.0 (2026-09-15)** — re-scope theo nghiệp vụ mới: cấu trúc Agency → Workspace → Media Package → Media Campaign → Task, 125 FR (thay 135 FR cũ), 6 role (ADMIN/OWNER/MANAGER/CREATOR/CLIENT/GUEST — bỏ `WORKSPACE_MANAGER` trùng lặp cũ), bỏ Zalo OA khỏi scope publishing. Nguồn sự thật: `docs/ba/00-overview.md`.

## Mục lục

- [Phần 1 — Tổng quan & Bảng Task](#phần-1--tổng-quan--bảng-task)
- [Phần 2 — Chi tiết Task](#phần-2--chi-tiết-task)

---

# PHẦN 1 — TỔNG QUAN & BẢNG TASK

---

## TEAM & PROJECT INFO

| Field | Detail |
|---|---|
| Project | BrandHub — AI-Powered Multi-Channel Media Campaign Platform |
| Course | SEP490 — Capstone Project, FPT University |
| Team | Trung (Leader), Lộc (AI Sub-lead), Tuấn (AI), Ân (AI), Phước (Publisher) |
| Reports | Report 1 (Project Introduction), Report 2 (Project Management Plan), Report 3 (Software Requirement Specification) |
| Language | English (mandatory) |
| Total Tasks | ~207 document tasks (125 FR per-function + 82 non-FR) |

---

## REPORT OVERVIEW

| Report | Title | Pages | Key Content |
|---|---|---|---|
| R1 | Project Introduction | ~15 | §1 Overview → §2 Product Background → §3 Existing Systems → §4 Business Opportunity → §5 Product Vision → §6 Scope & Limitations → §7 References |
| R2 | Project Management Plan | ~25 | §1 Overview (WBS, Objectives, Risks) → §2 Mgmt Approach (Process, Quality, Training) → §3 Deliverables → §4 Responsibility → §5 Communications → §6 Config Mgmt (Docs, Source, Tools) |
| R3 | Software Requirement Specification | ~190 | §1 Product Overview → §2 User Requirements (Actors, Use Cases) → §3 Functional Requirements (3.1 System Overview → 3.2-3.10 Feature Groups theo `docs/ba/`) → §4 NFR → §5 Appendix (Business Rules, Messages) |

---

## ROLES

| Role | Assignee | Description |
|---|---|---|
| Diagram Team | Tuấn, Lộc, Phước | Vẽ 17 diagrams trước khi team viết nội dung (thêm 1 diagram Agency-Workspace so với V1) |
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
| 🔴 Critical | Blocking, core diagrams (Context, UC, ERD, Agency-Workspace, State Machine), must finish first |
| 🟡 High | Important sections, functional requirements, screen descriptions |
| 🟢 Medium | Supporting sections, appendices |

---

## MILESTONES

| Milestone | Deliverable |
|---|---|
| M1 — Diagrams Done | 17 diagrams reviewed & approved |
| M2 — Draft v1 | All text sections written |
| M3 — Review Complete | Cross-review done, feedback collected |
| M4 — Final v2 | All feedback addressed |
| M5 — Merged | 3 reports merged, formatted, TOC updated |
| M6 — Submit | Submit to exam committee |

---

## PHASE 1 — Diagrams

> Đội vẽ: Tuấn (5), Lộc (6), Phước (6). Trung review toàn bộ.

---

### EPIC D01 — Context & Architecture Diagrams

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| [DA-D01-01](#da-d01-01) | **[R3 §1]** Draw Context Diagram — BrandHub + 5 external services (Groq API, Stability AI, Google Veo, Facebook Graph, TikTok Content API — Zalo OA loại khỏi scope) | Tuấn | 🔴 |
| [DA-D01-02](#da-d01-02) | **[R3 §1]** Draw System Architecture Diagram — 6 services + 5 DBs + message queue + AWS S3 | Phước | 🔴 |
| [DA-D01-03](#da-d01-03) | **[R2 §1.1]** Draw WBS Tree — hierarchical breakdown of sprints + AI iterations, re-scope theo 125 FR | Phước | 🔴 |
| [DA-D01-04](#da-d01-04) | **[R2 §2.1]** Draw Scrum Sprint Timeline — sprints + AI iterations, Gantt-style | Phước | 🔴 |
| [DA-D01-05](#da-d01-05) | **[R3 §1]** Draw Agency-Workspace-Package-Campaign-Task Flow Diagram (MỚI) — luồng nghiệp vụ lõi V2, thay cho khái niệm "Workspace phẳng" cũ | Tuấn | 🔴 |

---

### EPIC D02 — Use Case & ERD Diagrams

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| [DA-D02-01](#da-d02-01) | **[R3 §2.2.1]** Draw Use Case Overview Diagram — 125 FR, 6 actors | Tuấn | 🔴 |
| [DA-D02-02](#da-d02-02) | **[R3 §3.1.5]** Draw ERD — entity mới theo `docs/ba/11-data-entities-glossary.md` (Agency, Workspace, MediaPackage, MediaCampaign, Task, TaskApproval, ThirdPartyCollaborator, CampaignCollaborator...) | Tuấn | 🔴 |
| [DA-D02-03](#da-d02-03) | **[R2 §6.2]** Draw Git Branch Strategy — polyrepo, main/develop/feature/release | Lộc | 🟢 |
| [DA-D02-04](#da-d02-04) | **[R2 §6.1]** Draw Repository & Folder Structure — repos + Google Drive structure | Lộc | 🟢 |

---

### EPIC D03 — Screen Flows & Mockups

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| [DA-D03-01](#da-d03-01) | **[R3 §3.1.1]** Draw Screen Flow — ADMIN (Admin Console: User Mgmt → Content Moderation → Analytics → System Config) | Lộc | 🔴 |
| [DA-D03-02](#da-d03-02) | **[R3 §3.1.1]** Draw Screen Flow — OWNER (Agency List → Agency Dashboard → Workspace → Package/Campaign → Billing) | Lộc | 🔴 |
| [DA-D03-03](#da-d03-03) | **[R3 §3.1.1]** Draw Screen Flow — MANAGER (Workspace Dashboard → Package/Campaign Negotiation → Task Board → Collaborator) | Phước | 🔴 |
| [DA-D03-04](#da-d03-04) | **[R3 §3.1.1]** Draw Screen Flow — CREATOR (Task Board → Task Detail → AI Generate → Calendar) | Phước | 🔴 |
| [DA-D03-05](#da-d03-05) | **[R3 §3.1.1]** Draw Screen Flow — CLIENT (Client Portal → Package/Campaign Approve → Content Request → Task Review) | Tuấn | 🔴 |
| [DA-D03-06](#da-d03-06) | **[R3 §3.1.1]** Draw Screen Flow — GUEST (Landing Page → Register → Login) | Tuấn | 🔴 |
| [DA-D03-07](#da-d03-07) | **[R3 §3.1.3]** Draw Screen Authorization Matrix — all screens × 6 roles (X/—), lưu ý role gán theo Workspace không cố định | Lộc | 🟡 |
| [DA-D03-08](#da-d03-08) | **[R3 §3.1.1]** Export Screen Mockups from Figma — theo `docs/wireframe/wireframe-blueprint.md` V2 (11 màn hình) | Lộc | 🟡 |

---

### EPIC D04 — Diagram Review

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| [DA-D04-01](#da-d04-01) | Review all 17 diagrams for consistency: notation, color, font, naming, cross-reference accuracy | Trung | 🔴 |

---

## PHASE 2 — Report 1: Project Introduction

> ~15 trang. Viết sau khi diagram duyệt.

---

### EPIC D05 — R1 §2-3: Product Background & Existing Systems

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| [DA-D05-01](#da-d05-01) | **[R1 §2]** Write Product Background — agency pain points: quản lý đa kênh (social + báo/banner/TV), thiếu công cụ theo dõi campaign xuyên kênh | Lộc | 🟡 |
| [DA-D05-02](#da-d05-02) | **[R1 §3]** Analyze 2 Existing Systems — competitors pros/cons table, BrandHub differentiators (đặc biệt: multi-channel ngoài social, Media Package/Campaign model) | Lộc | 🟡 |

---

### EPIC D06 — R1 §4-5: Business Opportunity & Vision

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| [DA-D06-01](#da-d06-01) | **[R1 §4]** Write Business Opportunity — Vietnam marketing agency market, digital transformation, nhu cầu quản lý chiến dịch đa kênh (không chỉ social) | Tuấn | 🟡 |
| [DA-D06-02](#da-d06-02) | **[R1 §5]** Write Software Product Vision — "For marketing agencies who need to run multi-channel media campaigns (social + traditional media) at scale..." | Tuấn | 🟡 |

---

### EPIC D07 — R1 §6-7: Scope, Limitations & References

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| [DA-D07-01](#da-d07-01) | **[R1 §6.1]** Write Project Scope & Major Features — 9 feature groups theo `docs/ba/` (Authentication, Profile, Agency & Workspace, Media Package & Campaign, Content & Task Workflow, AI Features, Publishing & Collaborator, Subscription, Admin) | Ân | 🟡 |
| [DA-D07-02](#da-d07-02) | **[R1 §6.2]** Write Limitations & Exclusions — thêm rõ: Zalo OA out of scope, Third-party Collaborator là tracking thủ công (không tự động hoá), Package/Campaign amendment sau approve không hỗ trợ | Ân | 🟡 |
| [DA-D07-03](#da-d07-03) | **[R1 §7]** Compile References — FPT materials, external API docs, tech stack references | Ân | 🟢 |

---

## PHASE 3 — Report 2: Project Management Plan

> ~25 trang. Viết sau khi diagram duyệt.

---

### EPIC D08 — R2 §1: Overview (WBS, Objectives, Risks)

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| [DA-D08-01](#da-d08-01) | **[R2 §1.1]** Write WBS with Complexity & Man-days — re-scope theo 125 FR, 9 epic domain, complexity (S/M/C), estimated man-days, grand total | Trung | 🔴 |
| [DA-D08-02](#da-d08-02) | **[R2 §1.2]** Write Project Objectives — 7 objectives with priority levels, quality metrics | Trung | 🟡 |
| [DA-D08-03](#da-d08-03) | **[R2 §1.3]** Write Project Risks — 8-10 risks, thêm risk mới: "negotiation loop Package/Campaign không hội tụ", "reject-giữ-approval-cũ tính sai trong code" | Trung | 🟡 |

---

### EPIC D09 — R2 §2: Management Approach & Quality

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| [DA-D09-01](#da-d09-01) | **[R2 §2.1]** Write Management Approach — Scrum, sprint activities & deliverables re-scope theo 9 domain V2 | Phước | 🔴 |
| [DA-D09-02](#da-d09-02) | **[R2 §2.2]** Write Quality Management — 5 levels: Defect Prevention, Code Review, Unit/Integration/System/UAT Testing | Phước | 🟡 |

---

### EPIC D10 — R2 §3, §5, §6: Deliverables, Communications, Config

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| [DA-D10-01](#da-d10-01) | **[R2 §3]** Write Project Deliverables — deliverables with due dates | Phước | 🟡 |
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

> ~190 trang — report nặng nhất, tăng so với V1 do domain Content & Task Workflow mở rộng (35 FR).

---

### EPIC D12 — R3 §1: Product Overview & System Context

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| [DA-D12-01](#da-d12-01) | **[R3 §1]** Write Product Overview — BrandHub description, 6 role, tech stack, core capabilities (media campaign đa kênh, không chỉ social) | Trung | 🔴 |
| [DA-D12-02](#da-d12-02) | **[R3 §1]** Write Context Diagram Description — system boundary, 5 external services, data flows | Trung | 🟡 |
| [DA-D12-03](#da-d12-03) | **[R3 §3.1.5]** Write ERD Description — entity theo `docs/ba/11-data-entities-glossary.md`, entity descriptions | Trung | 🟡 |
| [DA-D12-04](#da-d12-04) | **[R3 §1]** Write Agency-Workspace-Package-Campaign-Task Flow Description (MỚI) — giải thích luồng nghiệp vụ lõi, dẫn chiếu `docs/ba/01-organization-structure.md`, `docs/ba/04-media-package-campaign.md` | Trung | 🔴 |

---

### EPIC D13 — R3 §2: User Requirements (Actors & Use Cases)

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| [DA-D13-01](#da-d13-01) | **[R3 §2.1]** Write Actors Description — 6 role: ADMIN, OWNER, MANAGER, CREATOR, CLIENT, GUEST — nhấn mạnh role gán theo Workspace, không cố định toàn cục | Tuấn | 🔴 |
| [DA-D13-02](#da-d13-02) | **[R3 §2.2.2]** Write Use Case Descriptions — Authentication + Profile + Agency & Workspace (FR 3.2–3.4, 31 UC — UC-01–31, see `docs/ba/use-cases/01`, `02`) | Lộc | 🔴 |
| [DA-D13-03](#da-d13-03) | **[R3 §2.2.2]** Write Use Case Descriptions — Media Package & Campaign + Content & Task Workflow (FR 3.5–3.6, 42 UC — UC-32–73, see `docs/ba/use-cases/03`, `04`) | Tuấn | 🔴 |
| [DA-D13-04](#da-d13-04) | **[R3 §2.2.2]** Write Use Case Descriptions — AI Features + Publishing & Collaborator + Subscription + Admin (FR 3.7–3.10, 32 UC — UC-74–106, see `docs/ba/use-cases/05`–`08`) | Ân | 🔴 |

---

### EPIC D14 — R3 §3.1: System Functional Overview (Screens)

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| [DA-D14-01](#da-d14-01) | **[R3 §3.1.2]** Write Screen Descriptions — ADMIN + OWNER screens (Agency List, Agency Dashboard, Admin Console...) | Lộc | 🟡 |
| [DA-D14-02](#da-d14-02) | **[R3 §3.1.2]** Write Screen Descriptions — MANAGER + CREATOR screens (Package/Campaign Negotiation, Task Board, Task Detail) | Phước | 🟡 |
| [DA-D14-03](#da-d14-03) | **[R3 §3.1.2]** Write Screen Descriptions — CLIENT + GUEST screens (Client Portal, Content Request) | Tuấn | 🟡 |
| [DA-D14-04](#da-d14-04) | **[R3 §3.1.4]** Write Non-Screen Functions — background jobs, callbacks, cron schedules (Task auto-gen từ Campaign approved, Content Request accepted → Task, AI Credit monthly reset không rollover) | Tuấn | 🟡 |

---

### EPIC D15 — R3 §3.2-3.4: FR — Authentication, Profile, Agency & Workspace (34 per-function tasks)

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| [DA-D15-01](#da-d15-01) | **[R3 §3.2]** Write FR — Authentication group (FR 3.2.1–3.2.9: Sign Up, Sign In Email, Sign In Google OAuth, Verify OTP, Forgot/Reset/Change Password, Multi-method Login, Account Deactivation) | Trung | 🔴 |
| [DA-D15-02](#da-d15-02) | **[R3 §3.3]** Write FR — Profile group (FR 3.3.1–3.3.4: View/Update Profile, Client Profile reuse xuyên Agency, Avatar Upload) | Trung | 🟡 |
| [DA-D15-03](#da-d15-03) | **[R3 §3.4]** Write FR — Agency Management (FR 3.4.1–3.4.9: List/Create/View/Update/Delete Agency, Invite/View Invitation/Remove Member) | Trung | 🟡 |
| [DA-D15-04](#da-d15-04) | **[R3 §3.4]** Write FR — Workspace Management (FR 3.4.10–3.4.21: List/Create/View/Update/Delete Workspace, Leave, Template, Member management, Timezone Config) | Trung | 🟡 |

---

### EPIC D16 — R3 §3.5-3.6: FR — Media Package/Campaign & Content Task Workflow (45 per-function tasks)

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| [DA-D16-01](#da-d16-01) | **[R3 §3.5]** Write FR — Media Package group (FR 3.5.1–3.5.6: chọn Template/Custom, đàm phán, Approve 2-bên, xem `docs/ba/13` mục 3) | Lộc | 🟡 |
| [DA-D16-02](#da-d16-02) | **[R3 §3.5]** Write FR — Media Campaign group (FR 3.5.6 cont.: Approve → auto-gen backlog, immutable sau approve, xem `docs/ba/13` mục 6) | Lộc | 🟡 |
| [DA-D16-03](#da-d16-03) | **[R3 §3.5]** Write FR — Content Request group (FR 3.5.7–3.5.10: Create/Track/Accept/Denied-terminal) | Lộc | 🟡 |
| [DA-D16-04](#da-d16-04) | **[R3 §3.6]** Write FR — Task Core (FR 3.6.1–3.6.10: Backlog, Identify Detail, Assign, Approval Sequence 4-bước, reject giữ approval cũ — `docs/ba/13` mục 4) | Lộc | 🟡 |
| [DA-D16-05](#da-d16-05) | **[R3 §3.6]** Write FR — Livestream & Material (FR 3.6.11–3.6.27: Material Repository, Brand/Hashtag Collection, Livestream sub-states PRE_LIVE→LIVE→POST_LIVE) | Phước | 🟡 |
| [DA-D16-06](#da-d16-06) | **[R3 §3.6]** Write FR — Mail Template & Compliance (FR 3.6.28–3.6.35: mail template group role TBD, Copyright check cần làm rõ thêm) | Phước | 🟡 |

---

### EPIC D17 — R3 §3.7: FR — AI Features (12 per-function tasks)

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| [DA-D17-01](#da-d17-01) | **[R3 §3.7]** Write FR — Text/Caption Generation (FR 3.7.1–3.7.3) | Tuấn | 🟡 |
| [DA-D17-02](#da-d17-02) | **[R3 §3.7]** Write FR — Image Generation (FR 3.7.4–3.7.6) | Tuấn | 🟡 |
| [DA-D17-03](#da-d17-03) | **[R3 §3.7]** Write FR — Video Generation & Virtual Ambassador (FR 3.7.7–3.7.9) | Tuấn | 🟡 |
| [DA-D17-04](#da-d17-04) | **[R3 §3.7]** Write FR — RAG Knowledge Base & Trend (FR 3.7.10–3.7.11) | Tuấn | 🟡 |
| [DA-D17-05](#da-d17-05) | **[R3 §3.7]** Write FR — Recommend Collaborator (FR 3.7.12 — gợi ý đối tác báo/banner/TV, không tự động liên hệ) | Tuấn | 🟡 |

---

### EPIC D18 — R3 §3.8: FR — Publishing & Third-party Collaborator (16 per-function tasks)

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| [DA-D18-01](#da-d18-01) | **[R3 §3.8]** Write FR — Social Account Connection (FR 3.8.1–3.8.2: Connect/Disconnect, chỉ FB/IG/TikTok/Threads — không Zalo) | Phước | 🟡 |
| [DA-D18-02](#da-d18-02) | **[R3 §3.8]** Write FR — Post Dashboard & Tracking (FR 3.8.3–3.8.8: Dashboard, Track Detail, Comment List, Preview, Schedule, Status Tracking) | Phước | 🟡 |
| [DA-D18-03](#da-d18-03) | **[R3 §3.8]** Write FR — Platform-specific Publish (FR 3.8.9–3.8.16: Facebook Post/Story/Reels, Instagram Post/Reels/Story, TikTok Video, Threads Post) | Phước | 🔴 |

---

### EPIC D19 — R3 §3.9-3.10: FR — Subscription & Admin Management (18 per-function tasks)

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| [DA-D19-01](#da-d19-01) | **[R3 §3.9]** Write FR — Plan & Payment (FR 3.9.1–3.9.4: Upgrade/Downgrade Plan, Make Payment PayOS, Invoice History) | Ân | 🟡 |
| [DA-D19-02](#da-d19-02) | **[R3 §3.9]** Write FR — AI Credit (FR 3.9.5–3.9.7: View Tracking, Buy Credit, Set Credit — reset hàng tháng, không rollover) | Ân | 🟡 |
| [DA-D19-03](#da-d19-03) | **[R3 §3.10]** Write FR — Admin User & Content Management (FR 3.10.1–3.10.6) | Ân | 🟡 |
| [DA-D19-04](#da-d19-04) | **[R3 §3.10]** Write FR — Admin System Management (FR 3.10.7–3.10.9, 3.10.11–3.10.12 — lưu ý gap 3.10.10 trong đánh số gốc CSV, và câu hỏi mở "Admin xoá Admin") | Ân | 🟡 |

---

### EPIC D20 — R3 §4-5: NFR & Appendices

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| [DA-D20-01](#da-d20-01) | **[R3 §4.2]** Write Non-Functional Requirements — §4.1 External Interfaces (Payment PayOS, OAuth, FCM, Email/SMS), §4.2 Quality Attributes (Usability, Reliability, Performance, Security/Compatibility/Maintainability/Legal) | Trung | 🔴 |
| [DA-D20-02](#da-d20-02) | **[R3 §5.1]** Compile Business Rules Appendix — BR-01 through BR-NN từ toàn bộ `docs/ba/*.md`, bao gồm rule mới confirmed 2026-09-15 (`docs/ba/13_Confirmations_Round2_2026-09-15.md`) | Ân | 🟡 |
| [DA-D20-03](#da-d20-03) | **[R3 §5.3]** Compile Message Lists Appendix — MSG01 through MSG-NN | Ân | 🟡 |
| [DA-D20-04](#da-d20-04) | **[R3 §5.2]** Compile Common Requirements — shared FR rules, common constraints | Ân | 🟢 |
| [DA-D20-05](#da-d20-05) | **[R3 §5.4]** Compile Other Requirements Appendix | Ân | 🟢 |

---

## PHASE 5 — Review, Merge & Submit

---

### EPIC D21 — Review & Feedback (mỗi reviewer 1 task riêng)

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| [DA-D21-01](#da-d21-01) | **[R1]** Review Report 1 — cross-check content accuracy against `docs/ba/` | Trung | 🔴 |
| [DA-D21-02](#da-d21-02) | **[R1]** Review Report 1 — cross-check content accuracy | Lộc | 🔴 |
| [DA-D21-03](#da-d21-03) | **[R1]** Review Report 1 — cross-check content accuracy | Tuấn | 🔴 |
| [DA-D21-04](#da-d21-04) | **[R1]** Review Report 1 — cross-check content accuracy | Ân | 🔴 |
| [DA-D21-05](#da-d21-05) | **[R2]** Review Report 2 — check WBS consistency với Jira, man-days realistic | Trung | 🔴 |
| [DA-D21-06](#da-d21-06) | **[R2]** Review Report 2 — check WBS consistency | Phước | 🔴 |
| [DA-D21-07](#da-d21-07) | **[R2]** Review Report 2 — check WBS consistency | Tuấn | 🔴 |
| [DA-D21-08](#da-d21-08) | **[R2]** Review Report 2 — check WBS consistency | Ân | 🔴 |
| [DA-D21-09](#da-d21-09) | **[R3]** Review Report 3 — check FR khớp `docs/feature/*/spec.md`, UC descriptions khớp flow, screen flows khớp wireframe V2 | Trung | 🔴 |
| [DA-D21-10](#da-d21-10) | **[R3]** Review Report 3 — cross-check | Lộc | 🔴 |
| [DA-D21-11](#da-d21-11) | **[R3]** Review Report 3 — cross-check | Phước | 🔴 |
| [DA-D21-12](#da-d21-12) | **[R3]** Review Report 3 — cross-check | Tuấn | 🔴 |
| [DA-D21-13](#da-d21-13) | **[R3]** Review Report 3 — cross-check | Ân | 🔴 |
| [DA-D21-14](#da-d21-14) | Address Review Feedback — Trung tổng hợp feedback, phân công fix theo từng section | Trung | 🔴 |
| [DA-D21-15](#da-d21-15) | Address Review Feedback — fix section phụ trách | Lộc | 🔴 |
| [DA-D21-16](#da-d21-16) | Address Review Feedback — fix section phụ trách | Phước | 🔴 |
| [DA-D21-17](#da-d21-17) | Address Review Feedback — fix section phụ trách | Tuấn | 🔴 |
| [DA-D21-18](#da-d21-18) | Address Review Feedback — fix section phụ trách | Ân | 🔴 |

---

### EPIC D22 — Merge & Format

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| [DA-D22-01](#da-d22-01) | **[R1]** Merge Report 1 — combine sections, update TOC, add Record of Changes | Trung | 🔴 |
| [DA-D22-02](#da-d22-02) | **[R2]** Merge Report 2 — combine sections, update TOC, add Record of Changes | Trung | 🔴 |
| [DA-D22-03](#da-d22-03) | **[R3]** Merge Report 3 — combine sections, update TOC, add Record of Changes (~190 pages) | Trung | 🔴 |
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
| Phase 1 — Diagrams | 17 diagrams (Context, Architecture, Use Case, ERD, Agency-Workspace-Package-Campaign-Task Flow [MỚI], 6 Screen Flows, Auth Matrix, WBS Tree, Scrum Timeline, Branch Strategy, Folder Structure, Mockups) |
| Phase 2 — R1 Writing | Report 1 Draft: §1 Overview → §2 Product Background → §3 Existing Systems → §4 Business Opportunity → §5 Product Vision → §6 Scope & Limitations → §7 References |
| Phase 3 — R2 Writing | Report 2 Draft: §1 Overview (WBS, Objectives, Risks) → §2 Mgmt Approach (Process, Quality, Training) → §3 Deliverables → §4 Responsibility → §5 Communications → §6 Config Mgmt |
| Phase 4 — R3 Writing | Report 3 Draft: §1 Product Overview → §2 User Requirements → §3 Functional Requirements (§3.1-§3.10, theo `docs/ba/`) → §4 NFR → §5 Appendix |
| Phase 5 — Review & Merge | Cross-review (13 individual review tasks + 5 fix tasks), 3 reports merged & formatted, final PDF package |
| Submit | Submit to exam committee, presentation |

---

## WORKLOAD DISTRIBUTION TABLE

| Member | Tasks | Breakdown |
|---|---|---|
| Trung | ~40 | Diagram review (1), WBS + Objectives + Risks (3), Product Overview + Context + ERD + Agency-Workspace Flow Desc (4), Auth FR §3.2 (1), Profile + Agency + Workspace FR §3.3-3.4 (3), NFR (1), Merge 3 reports + Format (4), Review R1/R2/R3 (3), Feedback coord (1), Final package + Presentation (2) |
| Lộc | ~40 | Branch Strategy + Folder Structure (2), Screen Flow Admin + Owner (2), Auth Matrix + Mockups (2), Product Background + Existing Systems (2), UC Auth/Profile/Agency-Workspace (1), Screen Desc Admin/Owner (1), Package/Campaign/Content Request FR §3.5 (3), Review R1/R3 (2), Fix feedback (1) |
| Phước | ~40 | Architecture + WBS Tree + Scrum Timeline (3), Screen Flow Manager + Creator (2), Mgmt Approach + Quality (2), Deliverables + Communications + Config Mgmt (3), Screen Desc Manager/Creator (1), Task Livestream/Material FR §3.6 (1), Mail/Compliance FR §3.6 (1), Publishing FR §3.8 (3), Review R2/R3 (2), Fix feedback (1) |
| Tuấn | ~44 | Context + UC Overview + ERD + Screen Flow Client/Guest + Agency-Workspace Flow Diagram (5), Business Opportunity + Product Vision (2), Training Plan (1), Actors (1), UC Package-Campaign/Task Workflow (1), UC AI/Publishing/Sub/Admin (1), Screen Desc Client/Guest + Non-Screen (2), Task Core FR §3.6 (1), AI Features FR §3.7 (5), Review R1/R2/R3 (3), Fix feedback (1) |
| Ân | ~40 | Scope + Limitations + References (3), Responsibility + Tools (2), Subscription FR §3.9 (2), Admin FR §3.10 (2), Business Rules + Messages + Common + Other (4), Review R1/R2/R3 (3), Fix feedback (1) |

> **Tổng:** ~207 individual tasks (125 FR per-function + 82 non-FR). Mỗi task 1 assignee duy nhất.

---

## NOTES

- Tất cả nội dung report viết bằng **English** (SEP490 requirement).
- Mỗi task có **1 assignee duy nhất** — không còn task gán nhiều người.
- Mỗi task ghi rõ **[Report § Section]** để biết chính xác vị trí trong report.
- Diagram team (Tuấn, Lộc, Phước) vẽ Phase 1 trước. Sau khi diagram duyệt, toàn team viết song song Phase 2-4.
- Functional Requirements format theo sample: Function Trigger → Description → Screen Layout → Data → Business Rules → Normal Flow → Abnormal Cases → Post-Conditions.
- Source mọi technical facts từ `brandhub-infrastructure/docs/ba/` (nghiệp vụ) và `docs/feature/*/spec.md` (đặc tả FR chi tiết). Không tự bịa — mọi câu hỏi mở (field User Profile FR 3.3.1, Mail Template role FR 3.6.28-32, Copyright check FR 3.6.34, Admin xoá Admin FR 3.10.9) phải ghi rõ **[OPEN QUESTION]** trong report, không tự quyết định thay BA.
- Task ID format: `DA-D{EPIC}-{SEQ}`.
- Record of Changes table phải update trước khi submit mỗi report — ghi rõ "re-scoped to V2 business model 2026-09-15" trong lần merge đầu tiên sau khi áp dụng version này.

---

# PHẦN 2 — CHI TIẾT TASK

> Mỗi task: Goal, Acceptance Criteria, Source References, Dependencies.

---

## PHASE 1 — Diagrams

---

### DA-D01-01 — [R3 §1] Draw Context Diagram

- **Goal:** Vẽ context diagram: BrandHub center + 5 external services. Dùng cho R3 §1 (Product Overview). Diagram đầu tiên — set style chuẩn.

- **Acceptance Criteria:**
  - BrandHub system boundary rõ ràng
  - 5 external services: Groq API, Stability AI, Google Veo, Facebook Graph API, TikTok Content API (Zalo OA đã loại khỏi scope, KHÔNG vẽ)
  - 6 actors: ADMIN, OWNER, MANAGER, CREATOR, CLIENT, GUEST
  - Data flow arrows có label (REST API, RabbitMQ, OAuth 2.0, File Upload)
  - Style thống nhất (màu, font, kích thước)
  - Format: PNG + editable source (draw.io/StarUML)

- **Source References:** `docs/architecture/`, `docs/ba/06-ai-features.md`, `docs/ba/07-publishing-social-collaborator.md`

- **Dependencies:** None

---

### DA-D01-02 — [R3 §1] Draw System Architecture Diagram

- **Goal:** Kiến trúc microservices 3D/layer. Dùng cho R3 §1.

- **Acceptance Criteria:**
  - 3 tầng: Client → Gateway → Services
  - 5 databases: MongoDB, PostgreSQL, Redis, ChromaDB, RabbitMQ, AWS S3
  - Communication protocols labeled
  - 7 GitHub repos, port numbers

- **Source References:** `docs/architecture/`

- **Dependencies:** DA-D01-01 (shared style)

---

### DA-D01-03 — [R2 §1.1] Draw WBS Tree

- **Goal:** WBS phân cấp: Project → Phase → Sprint → Epic, re-scope theo 125 FR / 9 domain. Dùng cho R2 §1.1.

- **Acceptance Criteria:**
  - 3-4 cấp: BrandHub → Phases → Sprints + AI Iterations → Epics theo 9 domain V2 (Authentication, Profile, Agency & Workspace, Media Package & Campaign, Content & Task Workflow, AI Features, Publishing & Collaborator, Subscription, Admin)
  - Mỗi node có label + man-days
  - Complexity màu: Simple (xanh), Medium (vàng), Complex (đỏ) — lưu ý domain Content & Task Workflow (35 FR) phức tạp nhất, cần breakdown kỹ hơn các domain khác
  - Tổng man-days re-tính lại (không copy số cũ vì scope đổi)

- **Source References:** `docs/feature/` (9 thư mục domain, 125 spec.md)

- **Dependencies:** DA-D01-04 (sync timeline)

---

### DA-D01-04 — [R2 §2.1] Draw Scrum Sprint Timeline

- **Goal:** Gantt timeline sprints + AI iterations. Dùng cho R2 §2.1.

- **Acceptance Criteria:**
  - Trục X: tuần theo deadline mục tiêu cuối tháng 11/2026
  - Sprint bars (2 tuần/sprint), AI iteration bars song song
  - Milestone markers, key deliverables trên mỗi bar
  - Legend: Sprint (xanh), AI (cam), Milestone (đỏ)

- **Source References:** `docs/plan/sprints/README.md` (lịch sử sprint — KHÔNG sửa, chỉ tham chiếu tiến độ đã qua)

- **Dependencies:** DA-D01-03

---

### DA-D01-05 — [R3 §1] Draw Agency-Workspace-Package-Campaign-Task Flow Diagram (MỚI)

- **Goal:** Diagram MỚI không có ở V1 — minh hoạ luồng nghiệp vụ lõi: User → Agency (1 Owner) → Workspace (1 Manager, gán lúc tạo) → mời Client vào Workspace → đàm phán Media Package (2 bên approve) → Media Campaign (2 bên approve, immutable sau đó) → auto-gen Task Backlog → Task Approval Sequence.

- **Acceptance Criteria:**
  - Thể hiện đúng thứ tự: Workspace tạo TRƯỚC, Package/Campaign đàm phán SAU, bên trong Workspace (không phải ngược lại)
  - Có nhánh phụ: Content Request (kênh bổ sung, độc lập với Campaign chính)
  - Có chú thích rule "Campaign immutable sau approve"
  - Format: PNG + editable source

- **Source References:** `docs/ba/01-organization-structure.md`, `docs/ba/04-media-package-campaign.md`, `docs/ba/13_Confirmations_Round2_2026-09-15.md`

- **Dependencies:** DA-D01-01

---

### DA-D02-01 — [R3 §2.2.1] Draw Use Case Overview Diagram

- **Goal:** 125 FR mapped thành use case, 6 actors. Dùng cho R3 §2.2.1 (Use Case Diagram).

- **Acceptance Criteria:**
  - 6 actor stick figures, use case ovals grouped theo 9 domain (không group theo epic cũ)
  - `<<include>>`, `<<extend>>` relationships — đặc biệt highlight: Task use case `<<include>>` Approval Sequence, Campaign Approve `<<include>>` Auto-gen Backlog
  - System boundary box

- **Source References:** `docs/feature/` (125 spec.md, mỗi spec có mục User Story dùng làm nguồn UC)

- **Dependencies:** DA-D01-01

---

### DA-D02-02 — [R3 §3.1.5] Draw ERD

- **Goal:** Entity theo model V2. Dùng cho R3 §3.1.5.

- **Acceptance Criteria:**
  - Field names, types, required/optional
  - Relationships: crow's foot notation
  - Bao gồm entity MỚI: `Agency`, `AgencyMember`, `AgencyInvitation`, `Workspace`, `WorkspaceMember`, `WorkspaceTemplate`, `ClientProfile`, `MediaPackageTemplate`/`MediaPackageCustom`, `WorkspaceMediaPackage`, `MediaCampaign`, `ContentRequest`, `Task`, `TaskApproval` (lưu theo từng step, không chỉ 1 status field — xem `docs/ba/13` mục 4), `ThirdPartyCollaborator`, `CampaignCollaborator` (N-N, xem `docs/ba/13` mục 8)
  - Color: MongoDB (xanh), PostgreSQL (tím)
  - Entity description table
  - 5 câu hỏi thiết kế DB còn mở trong `docs/ba/11-data-entities-glossary.md` phải ghi chú rõ trong report là "pending technical design decision", không tự chốt

- **Source References:** `docs/ba/11-data-entities-glossary.md`

- **Dependencies:** DA-D01-02

---

### DA-D02-03 — [R2 §6.2] Draw Git Branch Strategy

- **Goal:** Branching strategy polyrepo. Dùng cho R2 §6.2. (Không đổi so với V1 — quy trình kỹ thuật, không phụ thuộc nghiệp vụ.)

- **Acceptance Criteria:**
  - main, develop, feature/<service>/<desc>, release/<ver>, hotfix/<desc>
  - PR workflow: feature → develop → main

- **Dependencies:** None

---

### DA-D02-04 — [R2 §6.1] Draw Repo/Folder Structure

- **Goal:** GitHub repos + Google Drive structure. Dùng cho R2 §6.1.

- **Acceptance Criteria:**
  - Repos trong group box
  - Google Drive tree: Capstone Reports → R1-R3, Weekly Reports, Meeting Minutes
  - Access permissions ghi chú

- **Dependencies:** DA-D02-03

---

### DA-D03-01 to DA-D03-06 — [R3 §3.1.1] Draw Screen Flows (6 tasks)

- **Goal:** Screen flow per role, theo 11 màn hình wireframe V2. Dùng cho R3 §3.1.1.

- **Acceptance Criteria (chung):**
  - Mỗi screen = rectangle node, đặt tên khớp `docs/wireframe/wireframe-blueprint.md` (Agency List, Workspace Dashboard, Package/Campaign Negotiation, Task Board, Task Detail, Calendar, Client Portal, Collaborator, Analytics, Admin Console)
  - Navigation arrows
  - Start point marked
  - Phân biệt: public, authenticated, role-specific screens
  - **Lưu ý quan trọng:** vì role gán theo Workspace (không cố định), screen flow của OWNER/MANAGER/CREATOR phải bắt đầu từ Agency List/Workspace Switcher, không vào thẳng 1 role cố định như V1

| Role | Task ID | Assignee |
|---|---|---|
| ADMIN | DA-D03-01 | Lộc |
| OWNER | DA-D03-02 | Lộc |
| MANAGER | DA-D03-03 | Phước |
| CREATOR | DA-D03-04 | Phước |
| CLIENT | DA-D03-05 | Tuấn |
| GUEST | DA-D03-06 | Tuấn |

- **Source References:** `docs/wireframe/wireframe-blueprint.md` (V2), `docs/feature/*/spec.md`

- **Dependencies:** DA-D02-01

---

### DA-D03-07 — [R3 §3.1.3] Draw Screen Authorization Matrix

- **Goal:** Ma trận screens × roles. Dùng cho R3 §3.1.3.

- **Acceptance Criteria:**
  - Rows theo 11 màn hình V2 × 6 columns (role)
  - X = access, — = no access, (view only) = read-only
  - Sắp xếp theo feature group, khớp bảng role-matrix ở `docs/wireframe/wireframe-blueprint.md` mục I.2

- **Dependencies:** DA-D03-01 through DA-D03-06

---

### DA-D03-08 — [R3 §3.1.1] Export Screen Mockups from Figma

- **Goal:** Export Figma wireframes với annotation, dựng theo `docs/wireframe/wireframe-blueprint.md` V2 (11 màn hình, không phải 7 màn hình V1).

- **Acceptance Criteria:**
  - Toàn bộ 11 màn hình chính, có annotation
  - Resolution đủ đọc khi in A4
  - Không còn tab/preview Zalo OA trong bất kỳ mockup nào

- **Dependencies:** Figma wireframes dựng lại theo blueprint V2

---

### DA-D04-01 — Review All Diagrams for Consistency

- **Goal:** Trung kiểm tra 17 diagrams trước khi team viết.

- **Acceptance Criteria:**
  - Chung bộ màu, font, notation
  - Cross-reference khớp: screen flow → UC → FR → `docs/ba/`
  - Mỗi diagram có title + figure number
  - Feedback documented, fixed trước khi team viết nội dung

- **Dependencies:** DA-D01-01 through DA-D03-08

---

## PHASE 2 — Report 1

---

### DA-D05-01 — [R1 §2] Write Product Background

- **Goal:** Problem Statement — tại sao marketing agency cần platform quản lý chiến dịch truyền thông đa kênh (không chỉ social media).

- **Acceptance Criteria:**
  - ~1 trang, English
  - 5-6 pain points: multi-channel fragmentation (social + báo/banner/TV), high manual cost, inconsistent brand voice, complex Package/Campaign negotiation workflow, khó theo dõi hợp tác đối tác truyền thông thứ 3, lack of AI-assisted ideation
  - Số liệu thị trường VN nếu có

- **Source References:** `docs/ba/00-overview.md`, `docs/architecture/`

- **Dependencies:** Đọc R1 sample để khớp format

---

### DA-D05-02 — [R1 §3] Analyze 2 Existing Systems

- **Goal:** Phân tích 2 competitors (Buffer, Hootsuite hoặc local VN) — nhấn mạnh cả 2 đều CHỈ quản lý social, không có concept Media Package/Campaign đa kênh.

- **Acceptance Criteria:**
  - 2 systems: Description, Target Users, Features, Pros (3-4), Cons (3-4)
  - Screenshot website
  - Kết luận: BrandHub differentiator = mở rộng ra ngoài social (báo/banner/TV) qua module Third-party Collaborator + mô hình Package→Campaign→Task có đàm phán 2 bên

- **Source References:** Web research, `docs/ba/07-publishing-social-collaborator.md`

- **Dependencies:** DA-D05-01

---

### DA-D06-01 — [R1 §4] Write Business Opportunity

- **Goal:** Market opportunity — quy mô, xu hướng, gap analysis.

- **Acceptance Criteria:**
  - ~1 trang
  - VN marketing agency market size
  - Digital transformation + nhu cầu quản lý campaign xuyên kênh (social + truyền thống)
  - Gap: thiếu platform tích hợp AI + đa kênh (không chỉ social) cho SMB agency

- **Dependencies:** DA-D05-01, DA-D05-02

---

### DA-D06-02 — [R1 §5] Write Software Product Vision

- **Goal:** Vision statement: "For [target] who [need], BrandHub is a [category] that [benefit]."

- **Acceptance Criteria:**
  - ~0.5-1 trang
  - Core differentiators: AI content gen, Media Package/Campaign negotiation, Third-party Collaborator tracking, RAG brand voice, virtual ambassador
  - Target: marketing agency SMB Vietnam

- **Dependencies:** DA-D06-01

---

### DA-D07-01 — [R1 §6.1] Write Project Scope & Major Features

- **Goal:** Liệt kê feature groups với sub-features (FE-01 to FE-NN), theo 9 domain V2.

- **Acceptance Criteria:**
  - 9 feature groups: Authentication, Profile, Agency & Workspace Management, Media Package & Campaign, Content & Task Workflow, AI Features, Publishing & Third-party Collaborator, Subscription & Billing, Admin Management
  - Format: FE-XX: Name → sub-list, số FR mỗi domain khớp `docs/feature/`

- **Source References:** `docs/ba/00-overview.md`, `docs/feature/` (9 thư mục)

- **Dependencies:** DA-D02-01

---

### DA-D07-02 — [R1 §6.2] Write Limitations & Exclusions

- **Goal:** BrandHub scope boundary (LI-01 to LI-NN).

- **Acceptance Criteria:**
  - Limitations: web app (mobile limited), no in-house AI training, VN market focus, 4 social platform only (FB/IG/TikTok/Threads — KHÔNG Zalo OA), Third-party Collaborator là tracking thủ công (không tự động liên hệ/ký kết), Media Campaign KHÔNG sửa được sau khi approved, no real-time collaborative editing

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

- **Goal:** WBS table: work items, complexity, man-days, re-scope theo 125 FR / 9 domain. Dùng cho R2 §1.1.

- **Acceptance Criteria:**
  - Sprints + AI iterations → epics theo 9 domain V2
  - Mỗi item: WBS Item, Complexity (S/M/C), Est. Effort (man-days)
  - Sub-totals per sprint, grand total re-tính (KHÔNG copy số man-days V1 — scope đã đổi hẳn, đặc biệt domain Content & Task Workflow tăng mạnh do Approval Sequence phức tạp hơn)

- **Source References:** `docs/feature/` (125 spec.md)

- **Dependencies:** DA-D01-03, DA-D01-04

---

### DA-D08-02 — [R2 §1.2] Write Project Objectives

- **Goal:** 7 objectives với priority + quality metrics.

- **Acceptance Criteria:**
  - 7 objectives: Description + Priority (Very High/High/Medium)
  - Quality metrics table
  - Milestone timeliness target 95%, deadline mục tiêu cuối tháng 11/2026

- **Dependencies:** DA-D08-01

---

### DA-D08-03 — [R2 §1.3] Write Project Risks

- **Goal:** 8-10 risks với Impact, Possibility, Response.

- **Acceptance Criteria:**
  - Risks: AI API downtime, social platform policy changes, OAuth failures, data inconsistency, multi-tenancy leakage (Agency/Workspace/Client isolation), team skill gap, scope creep, cloud cost, **Package/Campaign negotiation loop không hội tụ** (rủi ro mới V2), **thiết kế sai reject-giữ-approval-cũ trong code** (rủi ro mới V2, xem `docs/ba/13` mục 4)
  - Mỗi risk: #, Description, Impact (H/M/L), Possibility, Response

- **Dependencies:** DA-D08-01, DA-D08-02

---

### DA-D09-01 — [R2 §2.1] Write Management Approach (Scrum)

- **Goal:** Scrum process: sprint activities + deliverables re-scope theo 9 domain.

- **Acceptance Criteria:**
  - Scrum roles, ceremonies, artifacts
  - Sprint 0 → Sprint N (số sprint re-tính theo WBS mới)
  - Mỗi sprint: Time, Activities, Deliverables
  - AI Parallel Track alignment
  - Nhúng Scrum Timeline figure (DA-D01-04)

- **Source References:** `docs/plan/sprints/README.md` (lịch sử — chỉ tham chiếu, không sửa)

- **Dependencies:** DA-D01-04

---

### DA-D09-02 — [R2 §2.2] Write Quality Management

- **Goal:** 5 levels of testing + defect prevention. (Không đổi so với V1 — quy trình kỹ thuật.)

- **Acceptance Criteria:**
  - Defect Prevention: coding standards, SonarQube, knowledge sharing
  - 5 levels: Code Review → Unit → Integration → System → UAT
  - Mỗi level: coverage %, tools, defect targets — thêm test case đặc thù: Task reject giữ approval cũ, Package 2-bên-approve reset khi 1 bên sửa lại

- **Dependencies:** DA-D08-02

---

### DA-D10-01 — [R2 §3] Write Project Deliverables

- **Goal:** Deliverables với due dates.

- **Acceptance Criteria:**
  - #, Deliverable, Due Date, Notes
  - Timeline khớp Sprint Timeline

- **Dependencies:** DA-D09-01

---

### DA-D10-02 — [R2 §5] Write Project Communications

- **Goal:** Communication matrix. (Không đổi so với V1.)

- **Acceptance Criteria:**
  - Table: Item, Who/Target, Purpose, When/Frequency, Type/Tool
  - Daily: Slack, Bi-weekly: team meeting, Weekly: mentor meeting

- **Dependencies:** None

---

### DA-D10-03 — [R2 §6] Write Configuration Management

- **Goal:** Document Mgmt (§6.1) + Source Code Mgmt (§6.2) + Tools (§6.3). (Không đổi so với V1.)

- **Acceptance Criteria:**
  - §6.1: Google Drive structure (figure from DA-D02-04), backup policy
  - §6.2: Git branching (figure from DA-D02-03), PR rules, CI/CD
  - §6.3: Tools & Infrastructures table

- **Dependencies:** DA-D02-03, DA-D02-04

---

### DA-D11-01 — [R2 §2.3] Write Training Plan

- **Goal:** Training Plan table. (Không đổi so với V1.)

- **Acceptance Criteria:**
  - 5-6 areas: Java Spring Boot, MongoDB/PostgreSQL, React/Next.js, Testing, Git/GitHub, Docker
  - Participants, Duration, Waiver Criteria

- **Dependencies:** None

---

### DA-D11-02 — [R2 §4] Write Responsibility Assignments

- **Goal:** D/R/S/I matrix: 5 members × N work items.

- **Acceptance Criteria:**
  - D=Do, R=Review, S=Support, I=Informed
  - Work items theo 9 domain V2 × 5 members

- **Source References:** bảng Workload Distribution Table (Phần 1)

- **Dependencies:** DA-D08-01

---

### DA-D11-03 — [R2 §6.3] Write Tools & Infrastructures Table

- **Goal:** Bảng công cụ & hạ tầng. (Không đổi so với V1.)

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
  - BrandHub summary, 6 role, core capabilities (nhấn mạnh đa kênh: social + truyền thống), tech stack
  - Nhúng Context Diagram (DA-D01-01), Architecture Diagram (DA-D01-02), Agency-Workspace-Package-Campaign-Task Flow (DA-D01-05)

- **Dependencies:** DA-D01-01, DA-D01-02, DA-D01-05

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
  - Entity rows theo `docs/ba/11-data-entities-glossary.md`
  - Format: #, Entity, Description
  - Nhúng ERD figure (DA-D02-02)
  - Ghi rõ 5 câu hỏi thiết kế còn mở là "pending" trong report, không tự chốt

- **Source References:** `docs/ba/11-data-entities-glossary.md`

- **Dependencies:** DA-D02-02

---

### DA-D12-04 — [R3 §1] Write Agency-Workspace-Package-Campaign-Task Flow Description (MỚI)

- **Goal:** Mô tả chi tiết luồng nghiệp vụ lõi V2 — không có ở R3 V1.

- **Acceptance Criteria:**
  - Giải thích rõ thứ tự: Workspace tạo trước → mời Client → đàm phán Package (2-bên approve) → Campaign (2-bên approve, immutable) → auto-gen Task
  - Giải thích Content Request là kênh bổ sung, tách biệt
  - Nhúng Flow Diagram (DA-D01-05)

- **Source References:** `docs/ba/01-organization-structure.md`, `docs/ba/04-media-package-campaign.md`, `docs/ba/13_Confirmations_Round2_2026-09-15.md`

- **Dependencies:** DA-D01-05

---

### DA-D13-01 — [R3 §2.1] Write Actors Description

- **Goal:** Mô tả 6 actors.

- **Acceptance Criteria:**
  - 6 actors: GUEST, CLIENT, CREATOR, MANAGER, OWNER, ADMIN
  - **Nhấn mạnh khác biệt V2:** OWNER/MANAGER/CREATOR/CLIENT gán **theo từng Workspace**, không phải role cố định của User — 1 User có thể mang nhiều role khác nhau ở các Workspace khác nhau cùng lúc

- **Source References:** `docs/ba/01-organization-structure.md`, `docs/ba/10-roles-permissions-matrix.md`

- **Dependencies:** DA-D02-01

---

### DA-D13-02 — [R3 §2.2.2] Write Use Case Descriptions — Authentication, Profile, Agency & Workspace

- **Goal:** UC cho FR 3.2–3.4 (34 FR: Authentication 9 + Profile 4 + Agency & Workspace 21).

- **Acceptance Criteria:**
  - Mỗi UC: ID, Use Case, Actors, Description
  - Format theo sample Table 3

- **Source References:** `docs/feature/authentication/*/spec.md`, `docs/feature/profile/*/spec.md`, `docs/feature/agency-workspace/*/spec.md`

- **Dependencies:** DA-D13-01, DA-D02-01

---

### DA-D13-03 — [R3 §2.2.2] Write Use Case Descriptions — Media Package/Campaign & Content Task Workflow

- **Goal:** UC cho FR 3.5–3.6 (45 FR: Package/Campaign 10 + Content & Task Workflow 35).

- **Acceptance Criteria:**
  - Format theo sample Table 3
  - Lưu ý UC "Approve Package/Campaign" phải ghi rõ điều kiện "cả 2 bên" trong Description

- **Source References:** `docs/feature/media-package-campaign/*/spec.md`, `docs/feature/content-task-workflow/*/spec.md`

- **Dependencies:** DA-D13-01, DA-D02-01

---

### DA-D13-04 — [R3 §2.2.2] Write Use Case Descriptions — AI, Publishing/Collaborator, Subscription, Admin

- **Goal:** UC cho FR 3.7–3.10 (46 FR: AI 12 + Publishing/Collaborator 16 + Subscription 7 + Admin 11).

- **Acceptance Criteria:**
  - Format theo sample Table 3

- **Source References:** `docs/feature/ai-features/*/spec.md`, `docs/feature/publishing-social/*/spec.md`, `docs/feature/subscription-billing/*/spec.md`, `docs/feature/admin-management/*/spec.md`

- **Dependencies:** DA-D13-01, DA-D02-01

---

### DA-D14-01 — [R3 §3.1.2] Write Screen Descriptions — Admin & Owner

- **Goal:** Screen Description table cho ADMIN + OWNER.

- **Acceptance Criteria:**
  - Format: #, Feature, Screen, Description
  - Bao gồm màn hình MỚI: Agency List, Agency Dashboard, Admin Console
  - Khớp Screen Flow diagrams

- **Source References:** DA-D03-01, DA-D03-02, `docs/wireframe/wireframe-blueprint.md`

- **Dependencies:** DA-D03-01, DA-D03-02

---

### DA-D14-02 — [R3 §3.1.2] Write Screen Descriptions — Manager & Creator

- **Goal:** Screen Description table cho MANAGER + CREATOR.

- **Acceptance Criteria:**
  - Format: #, Feature, Screen, Description
  - Bao gồm màn hình MỚI: Package/Campaign Negotiation, Task Board (Kanban theo Approval Sequence), Collaborator Directory
  - Khớp Screen Flow diagrams

- **Source References:** DA-D03-03, DA-D03-04, `docs/wireframe/wireframe-blueprint.md`

- **Dependencies:** DA-D03-03, DA-D03-04

---

### DA-D14-03 — [R3 §3.1.2] Write Screen Descriptions — Client & Guest

- **Goal:** Screen Description table cho CLIENT + GUEST.

- **Acceptance Criteria:**
  - Format: #, Feature, Screen, Description
  - Client Portal có Content Request riêng biệt Package/Campaign
  - Khớp Screen Flow diagrams

- **Source References:** DA-D03-05, DA-D03-06, `docs/wireframe/wireframe-blueprint.md`

- **Dependencies:** DA-D03-05, DA-D03-06

---

### DA-D14-04 — [R3 §3.1.4] Write Non-Screen Functions

- **Goal:** Background jobs, callbacks, cron schedules.

- **Acceptance Criteria:**
  - Format: #, Feature, System Function, Description
  - Functions: Welcome Email, Password Reset, JWT Cleanup, OAuth Token Refresh, Publishing Job, Publish Callback, Payment Confirmation (PayOS webhook), **Task auto-gen từ Campaign approved** (MỚI), **AI Credit monthly reset — không rollover** (MỚI, `docs/ba/13` mục 7), Trend Crawl, AI Usage Archive, Notification Delivery

- **Source References:** `docs/feature/media-package-campaign/*/spec.md`, `docs/feature/subscription-billing/*/spec.md`

- **Dependencies:** DA-D14-01 through DA-D14-03

---

### DA-D15-01 — [R3 §3.2] Write FR — Authentication group

- **Goal:** Mô tả đầy đủ 9 FR nhóm Authentication (FR 3.2.1–3.2.9).

- **Acceptance Criteria:**
  - Mỗi FR: Function Trigger → Description → Screen Layout → Data → Business Rules → Normal Flow → Abnormal Cases → Post-Conditions
  - FR: Sign Up, Sign In (Email), Sign In (Google OAuth), Verify OTP, Forgot Password, Reset Password, Change Password, Multi-method Login, Account Deactivation

- **Source References:** `docs/feature/authentication/` (9 spec.md)

- **Dependencies:** DA-D14-01 through DA-D14-03

---

### DA-D15-02 — [R3 §3.3] Write FR — Profile group

- **Goal:** Mô tả đầy đủ 4 FR nhóm Profile (FR 3.3.1–3.3.4).

- **Acceptance Criteria:**
  - FR: View Profile, Update Profile, Client Profile (tái sử dụng xuyên Agency/Workspace, email không đổi được), Avatar Upload
  - **[OPEN QUESTION]** FR 3.3.1 field list User Profile chưa xác định — ghi rõ trong report, không tự bịa field

- **Source References:** `docs/feature/profile/` (4 spec.md)

- **Dependencies:** DA-D15-01

---

### DA-D15-03 — [R3 §3.4] Write FR — Agency Management

- **Goal:** Mô tả 9 FR nhóm Agency Management (FR 3.4.1–3.4.9).

- **Acceptance Criteria:**
  - FR: List/Create/View/Update/Delete Agency, Invite Member, View Invitation Status, Remove Member
  - Nhấn mạnh: mỗi Agency đúng 1 Owner, Member Agency không có role gì ở cấp này

- **Source References:** `docs/feature/agency-workspace/` (9 spec.md đầu)

- **Dependencies:** DA-D15-02

---

### DA-D15-04 — [R3 §3.4] Write FR — Workspace Management

- **Goal:** Mô tả 12 FR nhóm Workspace Management (FR 3.4.10–3.4.21).

- **Acceptance Criteria:**
  - FR: List/Create/View/Update/Delete Workspace, Leave Workspace, Save Template, View/Add/Remove Member, Timezone Configuration
  - Nhấn mạnh: Workspace tạo trước, bắt buộc gán Manager (Owner tự làm được), mỗi Workspace đúng 1 Manager

- **Source References:** `docs/feature/agency-workspace/` (12 spec.md còn lại)

- **Dependencies:** DA-D15-03

---

### DA-D16-01 — [R3 §3.5] Write FR — Media Package group

- **Goal:** Mô tả FR nhóm Media Package (phần đầu FR 3.5.1–3.5.5).

- **Acceptance Criteria:**
  - FR: chọn Package Template/Custom, đàm phán (Client request đổi ↔ Manager counter-offer), Approve
  - Nhấn mạnh rule: ACTIVE chỉ khi CẢ HAI bên approve bản mới nhất; 1 bên sửa lại reset approve bên kia (`docs/ba/13` mục 3)

- **Source References:** `docs/feature/media-package-campaign/` (5 spec.md đầu)

- **Dependencies:** DA-D15-04

---

### DA-D16-02 — [R3 §3.5] Write FR — Media Campaign group

- **Goal:** Mô tả FR nhóm Media Campaign (FR 3.5.6).

- **Acceptance Criteria:**
  - FR: Approve Campaign → auto-gen Task backlog
  - Nhấn mạnh: Campaign **immutable** sau approve — thêm nội dung phải qua Content Request hoặc Manager add Task thủ công (`docs/ba/13` mục 6)

- **Source References:** `docs/feature/media-package-campaign/3-5-6-approve-media-campaign/spec.md`

- **Dependencies:** DA-D16-01

---

### DA-D16-03 — [R3 §3.5] Write FR — Content Request group

- **Goal:** Mô tả 4 FR nhóm Content Request (FR 3.5.7–3.5.10).

- **Acceptance Criteria:**
  - FR: Create, Track Status, Accept → auto-gen Task
  - Nhấn mạnh: `denied` là trạng thái **terminal**, Client không sửa lại được, phải tạo request mới (`docs/ba/13` mục 5)

- **Source References:** `docs/feature/media-package-campaign/` (4 spec.md cuối)

- **Dependencies:** DA-D16-02

---

### DA-D16-04 — [R3 §3.6] Write FR — Task Core

- **Goal:** Mô tả 10 FR nhóm Task Core (FR 3.6.1–3.6.10).

- **Acceptance Criteria:**
  - FR: Backlog, Identify Task Detail, Assign (optional QC + requiresClientApproval), Approval Sequence 4-bước (Creator→[QC]→Manager→[Client]), Manager add Task thủ công
  - **Rule quan trọng (SỬA 2026-09-15):** reject quay về `ASSIGNED` nhưng GIỮ approval các step trước đã pass — không xoá toàn bộ lịch sử duyệt (`docs/ba/13` mục 4, khác hẳn thiết kế ban đầu ghi "làm lại từ đầu")

- **Source References:** `docs/feature/content-task-workflow/` (10 spec.md đầu), `docs/ba/12-state-machines.md`

- **Dependencies:** DA-D16-03

---

### DA-D16-05 — [R3 §3.6] Write FR — Livestream & Material

- **Goal:** Mô tả 17 FR nhóm Livestream & Material (FR 3.6.11–3.6.27).

- **Acceptance Criteria:**
  - FR: Material Repository, Brand Collection, Hashtag Collection, Content Version, Livestream (PRE_LIVE→LIVE→POST_LIVE→DONE/CANCEL), Survey/Form

- **Source References:** `docs/feature/content-task-workflow/` (17 spec.md tiếp theo)

- **Dependencies:** DA-D16-04

---

### DA-D16-06 — [R3 §3.6] Write FR — Mail Template & Compliance

- **Goal:** Mô tả 8 FR nhóm Mail Template & Compliance (FR 3.6.28–3.6.35).

- **Acceptance Criteria:**
  - FR: Mail Template CRUD, Check Copyright Infringement
  - **[OPEN QUESTION]** role nhóm Mail Template chưa xác định trong CSV gốc — ghi TBD, không tự gán
  - **[OPEN QUESTION]** FR 3.6.34 Copyright check bản thân CSV ghi "cần làm rõ hơn" — AC/DoD giữ nguyên trạng thái chưa hoàn chỉnh trong report

- **Source References:** `docs/feature/content-task-workflow/` (8 spec.md cuối)

- **Dependencies:** DA-D16-05

---

### DA-D17-01 — [R3 §3.7] Write FR — Text/Caption Generation

- **Goal:** Mô tả FR 3.7.1–3.7.3.

- **Acceptance Criteria:** Format chuẩn FR, nguồn `docs/feature/ai-features/` (3 spec.md đầu)

- **Dependencies:** DA-D16-06

---

### DA-D17-02 — [R3 §3.7] Write FR — Image Generation

- **Goal:** Mô tả FR 3.7.4–3.7.6.

- **Acceptance Criteria:** Format chuẩn FR, nguồn `docs/feature/ai-features/` (3 spec.md tiếp)

- **Dependencies:** DA-D17-01

---

### DA-D17-03 — [R3 §3.7] Write FR — Video Generation & Virtual Ambassador

- **Goal:** Mô tả FR 3.7.7–3.7.9.

- **Acceptance Criteria:** Format chuẩn FR, nguồn `docs/feature/ai-features/` (3 spec.md tiếp)

- **Dependencies:** DA-D17-02

---

### DA-D17-04 — [R3 §3.7] Write FR — RAG Knowledge Base & Trend

- **Goal:** Mô tả FR 3.7.10–3.7.11.

- **Acceptance Criteria:** Format chuẩn FR, nguồn `docs/feature/ai-features/` (2 spec.md tiếp)

- **Dependencies:** DA-D17-03

---

### DA-D17-05 — [R3 §3.7] Write FR — Recommend Collaborator

- **Goal:** Mô tả FR 3.7.12.

- **Acceptance Criteria:**
  - AI chỉ gợi ý, không tự động liên hệ/ký kết
  - Gợi ý có thể thêm mới vào danh bạ `ThirdPartyCollaborator` cấp Agency hoặc link vào Campaign hiện tại qua `CampaignCollaborator` (`docs/ba/13` mục 8)

- **Source References:** `docs/feature/ai-features/3-7-12-recommend-collaborator/spec.md`

- **Dependencies:** DA-D17-04

---

### DA-D18-01 — [R3 §3.8] Write FR — Social Account Connection

- **Goal:** Mô tả FR 3.8.1–3.8.2.

- **Acceptance Criteria:**
  - FR: Connect/Disconnect Social Account
  - Platform hỗ trợ: Facebook, Instagram, TikTok, Threads — **KHÔNG Zalo OA** (loại khỏi scope)

- **Source References:** `docs/feature/publishing-social/` (2 spec.md đầu)

- **Dependencies:** DA-D16-06

---

### DA-D18-02 — [R3 §3.8] Write FR — Post Dashboard & Tracking

- **Goal:** Mô tả FR 3.8.3–3.8.8.

- **Acceptance Criteria:** Format chuẩn FR: View Dashboard Post, Post Track Detail, Comment Detail List, Preview Post, Schedule Platform Post, View Status Tracking

- **Source References:** `docs/feature/publishing-social/` (6 spec.md tiếp)

- **Dependencies:** DA-D18-01

---

### DA-D18-03 — [R3 §3.8] Write FR — Platform-specific Publish

- **Goal:** Mô tả FR 3.8.9–3.8.16 (8 FR — publish riêng từng platform/content-type).

- **Acceptance Criteria:**
  - FR: Facebook Post/Story/Reels, Instagram Post/Reels/Story, TikTok Video, Threads Post
  - Không có FR publish Zalo (đã loại)

- **Source References:** `docs/feature/publishing-social/` (8 spec.md cuối)

- **Dependencies:** DA-D18-02

---

### DA-D19-01 — [R3 §3.9] Write FR — Plan & Payment

- **Goal:** Mô tả FR 3.9.1–3.9.4.

- **Acceptance Criteria:** FR: Upgrade Plan, Downgrade Plan, Make Payment (PayOS — ACID compliant), View Invoice History

- **Source References:** `docs/feature/subscription-billing/` (4 spec.md đầu)

- **Dependencies:** DA-D18-03

---

### DA-D19-02 — [R3 §3.9] Write FR — AI Credit

- **Goal:** Mô tả FR 3.9.5–3.9.7.

- **Acceptance Criteria:**
  - FR: View AI Credit Tracking, Buy Credit, Set Credit
  - Rule: reset hàng tháng về hạn mức gốc, **KHÔNG rollover** credit dư (`docs/ba/13` mục 7)

- **Source References:** `docs/feature/subscription-billing/` (3 spec.md cuối)

- **Dependencies:** DA-D19-01

---

### DA-D19-03 — [R3 §3.10] Write FR — Admin User & Content Management

- **Goal:** Mô tả FR 3.10.1–3.10.6.

- **Acceptance Criteria:** Format chuẩn FR theo `docs/feature/admin-management/`

- **Source References:** `docs/feature/admin-management/` (6 spec.md đầu)

- **Dependencies:** DA-D19-02

---

### DA-D19-04 — [R3 §3.10] Write FR — Admin System Management

- **Goal:** Mô tả FR 3.10.7–3.10.9, 3.10.11–3.10.12 (giữ đúng gap đánh số 3.10.10 từ CSV gốc — không tự đánh số lại).

- **Acceptance Criteria:**
  - **[OPEN QUESTION]** FR 3.10.9 Deactive User: "Admin có xoá được Admin khác không?" chưa có câu trả lời chính thức — spec.md hiện tại tạm chặn (403) hành động Admin-deactivate-Admin, ghi rõ trong report là default an toàn tạm thời, không phải quyết định cuối cùng

- **Source References:** `docs/feature/admin-management/` (5 spec.md cuối)

- **Dependencies:** DA-D19-03

---

### DA-D20-01 — [R3 §4.2] Write Non-Functional Requirements

- **Goal:** NFR đầy đủ. (Cấu trúc không đổi so với V1, nội dung cập nhật theo entity/flow mới.)

- **Acceptance Criteria:**
  - §4.1 External Interfaces: PayOS (thay Stripe/VNPay nếu khác), OAuth, FCM, Email/SMS
  - §4.2 Quality Attributes: Usability, Reliability, Performance (đặc biệt: độ trễ khi đàm phán Package/Campaign real-time giữa Client-Manager), Security (multi-tenant Agency/Workspace/Client isolation), Compatibility, Maintainability, Legal

- **Dependencies:** DA-D19-04

---

### DA-D20-02 — [R3 §5.1] Compile Business Rules Appendix

- **Goal:** BR-01 through BR-NN từ toàn bộ `docs/ba/*.md`.

- **Acceptance Criteria:**
  - Bao gồm đầy đủ rule mới trong `docs/ba/13_Confirmations_Round2_2026-09-15.md` (Org 1-Owner, Manager 1/Workspace, Package approve 2-bên, Task reject giữ approval, CR denied terminal, Campaign immutable, AI Credit không rollover, Collaborator N-N)

- **Source References:** toàn bộ `docs/ba/`

- **Dependencies:** DA-D20-01

---

### DA-D20-03 — [R3 §5.3] Compile Message Lists Appendix

- **Goal:** MSG01 through MSG-NN. (Không đổi cấu trúc so với V1.)

- **Acceptance Criteria:** Code, Type, Context, Content — lấy từ mục "Error Handling" của từng spec.md trong `docs/feature/`

- **Dependencies:** DA-D20-02

---

### DA-D20-04 — [R3 §5.2] Compile Common Requirements

- **Goal:** Shared FR rules, common constraints, cross-cutting conventions.

- **Acceptance Criteria:** Rule dùng chung nhiều domain: soft-delete 30 ngày, workspace-scoped data isolation, role-check theo Workspace không theo User toàn cục

- **Dependencies:** DA-D20-02

---

### DA-D20-05 — [R3 §5.4] Compile Other Requirements Appendix

- **Goal:** Additional requirements chưa cover ở §5.1-5.3.

- **Acceptance Criteria:** Bao gồm 5 câu hỏi thiết kế DB còn mở (`docs/ba/11-data-entities-glossary.md`) dưới dạng "Pending Technical Decisions"

- **Dependencies:** DA-D20-04

---

## PHASE 5 — Review, Merge & Submit

---

### DA-D21-01 to DA-D21-13 — Cross-Review Reports

- **Goal:** Mỗi reviewer đọc độc lập, đối chiếu với `docs/ba/` và `docs/feature/*/spec.md` — KHÔNG đối chiếu với tài liệu V1 cũ (đã archive/xoá).

- **Acceptance Criteria (chung):**
  - Checklist: số liệu (role/FR/domain count) khớp `docs/ba/00-overview.md`
  - Không còn sót thuật ngữ V1 (PUBLISHER, ROLE_ACCOUNT, Zalo OA, "Content Editor" đơn lẻ, Workspace 1 tầng)
  - Feedback ghi vào file riêng, không sửa trực tiếp bản đang review

- **Dependencies:** tương ứng Phase 2-4 hoàn thành

---

### DA-D21-14 to DA-D21-18 — Address Review Feedback

- **Goal:** Fix theo feedback đã tổng hợp.

- **Acceptance Criteria:** Mỗi finding có evidence rõ ràng trước khi fix, không fix theo cảm tính

- **Dependencies:** DA-D21-01 through DA-D21-13

---

### DA-D22-01 to DA-D22-04 — Merge & Format

- **Goal:** Merge 3 report, format cuối. (Quy trình không đổi so với V1.)

- **Acceptance Criteria:**
  - TOC update, Record of Changes ghi rõ "V2 re-scope 2026-09-15"
  - Page numbers, header/footer, figure/table numbering, cross-references, English spelling/grammar, font consistency

- **Dependencies:** DA-D21-14 through DA-D21-18

---

### DA-D23-01, DA-D23-02 — Final Package & Presentation

- **Goal:** Đóng gói nộp bài + chuẩn bị thuyết trình.

- **Acceptance Criteria:**
  - 3 PDF + source docx trên Google Drive
  - Presentation summary nêu bật thay đổi lớn nhất: mô hình Agency→Workspace 3 tầng, Media Package/Campaign negotiation, mở rộng đa kênh ngoài social

- **Dependencies:** DA-D22-01 through DA-D22-04
