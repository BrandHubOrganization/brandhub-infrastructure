"""
Generate 3 BrandHub SEP490 report frameworks (.docx) from FPT templates.
Each section has: header, [Assignee: Name] tag, placeholder instructions.
Team members open their assigned sections and write content.
"""
from docx import Document
from docx.shared import Inches, Pt, Cm, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT
from docx.oxml.ns import qn
from docx.oxml import OxmlElement
import os

OUT = r"d:\ProjectCode\BrandHub\1_SEP490\reports"


def set_cell_shading(cell, color):
    tc = cell._tc
    tcPr = tc.get_or_add_tcPr()
    shading = OxmlElement('w:shd')
    shading.set(qn('w:fill'), color)
    shading.set(qn('w:val'), 'clear')
    tcPr.append(shading)


def add_cover_page(doc, report_num, report_title):
    for _ in range(6):
        doc.add_paragraph()
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run = p.add_run("CAPSTONE PROJECT REPORT")
    run.bold = True
    run.font.size = Pt(26)
    run.font.name = "Times New Roman"
    p2 = doc.add_paragraph()
    p2.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run2 = p2.add_run(f"Report {report_num} \u2013 {report_title}")
    run2.bold = True
    run2.font.size = Pt(18)
    run2.font.name = "Times New Roman"
    for _ in range(4):
        doc.add_paragraph()
    p3 = doc.add_paragraph()
    p3.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run3 = p3.add_run("BrandHub \u2014 AI-Powered Multi-Channel Content Platform")
    run3.font.size = Pt(14)
    run3.font.name = "Times New Roman"
    doc.add_paragraph()
    p4 = doc.add_paragraph()
    p4.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run4 = p4.add_run("SEP490 \u2013 Capstone Project\nFPT University")
    run4.font.size = Pt(13)
    run4.font.name = "Times New Roman"
    for _ in range(4):
        doc.add_paragraph()
    p5 = doc.add_paragraph()
    p5.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run5 = p5.add_run("\u2013 Da Nang, August 2026 \u2013")
    run5.font.size = Pt(13)
    run5.font.name = "Times New Roman"
    doc.add_page_break()


def add_record_of_changes(doc):
    h = doc.add_heading("I. Record of Changes", level=1)
    doc.add_paragraph("*A - Added  M - Modified  D - Deleted").italic = True
    table = doc.add_table(rows=2, cols=5)
    table.style = 'Table Grid'
    table.alignment = WD_TABLE_ALIGNMENT.CENTER
    headers = ["Date", "A*/M/D", "In charge", "Change Description", "Section"]
    for i, header in enumerate(headers):
        cell = table.rows[0].cells[i]
        cell.text = header
        for p in cell.paragraphs:
            p.alignment = WD_ALIGN_PARAGRAPH.CENTER
            for run in p.runs:
                run.bold = True
                run.font.size = Pt(10)
        set_cell_shading(cell, "D9E2F3")
    row = table.rows[1]
    row.cells[0].text = "DD/MM/2026"
    row.cells[1].text = "A"
    row.cells[2].text = "[Name]"
    row.cells[3].text = "[Describe change]"
    row.cells[4].text = "[Section]"
    doc.add_paragraph()
    p = doc.add_paragraph("Table 1 - Record of Changes")
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.runs[0].italic = True
    return table


def heading_with_assignee(doc, text, level, assignee):
    h = doc.add_heading(text, level=level)
    p = doc.add_paragraph()
    run = p.add_run(f"[Assignee: {assignee}]")
    run.bold = True
    run.font.color.rgb = RGBColor(0, 100, 200)
    run.font.size = Pt(10)
    return h


def add_placeholder(doc, text):
    p = doc.add_paragraph()
    run = p.add_run(text)
    run.italic = True
    run.font.color.rgb = RGBColor(128, 128, 128)
    run.font.size = Pt(10)


def add_toc_placeholder(doc):
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run = p.add_run("[TABLE OF CONTENTS \u2014 Update before final submission]")
    run.bold = True
    run.font.size = Pt(12)
    doc.add_page_break()


# =====================================================================
# REPORT 1
# =====================================================================
def build_report1():
    doc = Document()
    section = doc.sections[0]
    for attr in ['top_margin', 'bottom_margin', 'left_margin', 'right_margin']:
        setattr(section, attr, Cm(2.54))
    style = doc.styles['Normal']
    style.font.name = "Times New Roman"
    style.font.size = Pt(13)
    style.paragraph_format.line_spacing = 1.5

    add_cover_page(doc, 1, "Project Introduction")
    add_toc_placeholder(doc)
    add_record_of_changes(doc)
    doc.add_page_break()

    doc.add_heading("II. Project Introduction", level=1)

    doc.add_heading("1. Overview", level=2)
    doc.add_heading("1.1 Project Information", level=3)
    add_placeholder(doc, "[Assignee: Trung]")
    add_placeholder(doc, "Fill in: Project name, Project code, Group name, Software type.")
    add_placeholder(doc, "Project name: BrandHub \u2014 AI-Powered Multi-Channel Content Platform")
    add_placeholder(doc, "Project code: BRANDHUB")
    add_placeholder(doc, "Group name: SEP490_GROUP_XX")
    add_placeholder(doc, "Software type: Web application + Mobile application (React Native)")

    doc.add_heading("1.2 Project Team", level=3)
    add_placeholder(doc, "[Assignee: Trung]")
    add_placeholder(doc, "Team table: Full Name, Role, Email, Mobile (5 members + supervisor)")

    heading_with_assignee(doc, "2. Product Background", 2, "L\u1ed9c")
    add_placeholder(doc, "Summarize the rationale for BrandHub. Describe the situation that leads to building this product.")
    add_placeholder(doc, "Key pain points of marketing agencies:")
    add_placeholder(doc, "1. Multi-platform content fragmentation (Facebook, TikTok, Instagram, Threads, Zalo)")
    add_placeholder(doc, "2. High cost & time of manual content creation")
    add_placeholder(doc, "3. Inconsistent brand voice across platforms")
    add_placeholder(doc, "4. Complex approval workflows between agency and client")
    add_placeholder(doc, "5. Difficulty tracking content performance across channels")
    add_placeholder(doc, "6. Lack of AI-assisted content ideation and generation")
    add_placeholder(doc, "Source: docs/plan/BrandHub_Master_Plan.md, docs/architecture/")

    heading_with_assignee(doc, "3. Existing Systems", 2, "L\u1ed9c")
    doc.add_heading("3.1 System 1: [Competitor Name]", level=3)
    add_placeholder(doc, "Brief description, link, actors, features, pros (3-4), cons (3-4).")
    add_placeholder(doc, "Suggested: Buffer, Hootsuite, Later, or SocialPilot.")
    doc.add_heading("3.2 System 2: [Competitor Name]", level=3)
    add_placeholder(doc, "Brief description, link, actors, features, pros (3-4), cons (3-4).")
    add_placeholder(doc, "Conclusion: What BrandHub does better than both.")

    heading_with_assignee(doc, "4. Business Opportunity", 2, "Tu\u1ea5n")
    add_placeholder(doc, "Describe the market opportunity. Key points:")
    add_placeholder(doc, "- Vietnam marketing agency market size and growth")
    add_placeholder(doc, "- Digital transformation trends in marketing")
    add_placeholder(doc, "- AI adoption in content creation (2024-2026)")
    add_placeholder(doc, "- Multi-channel social media growth in Vietnam")
    add_placeholder(doc, "- Gap: No integrated AI + multi-channel publishing platform for SMB agencies")

    heading_with_assignee(doc, "5. Software Product Vision", 2, "Tu\u1ea5n")
    add_placeholder(doc, "Vision statement template: \"For [target customers] who [need], BrandHub is a [product category] that [key benefit]. Unlike [competitors], BrandHub [primary differentiation].\"")
    add_placeholder(doc, "Target: Marketing agencies (SMB) in Vietnam who need multi-channel content at scale.")
    add_placeholder(doc, "Differentiators: AI content gen (text/image/video), 5-platform publishing, RAG brand voice, virtual ambassador, approval workflows.")

    heading_with_assignee(doc, "6. Project Scope & Limitations", 2, "\u00c2n")

    doc.add_heading("6.1 Major Features", level=3)
    add_placeholder(doc, "List all feature groups with sub-features. Format: FE-XX: Feature Name \u2192 sub-list.")
    features_r1 = [
        "FE-01: Authentication & Authorization (Register, Login, OAuth, 2FA, Password Reset)",
        "FE-02: User & Profile Management",
        "FE-03: Workspace Management (Multi-tenancy)",
        "FE-04: RBAC (Role-Based Access Control)",
        "FE-05: Agency & Client Management",
        "FE-06: Social Account Management (OAuth Facebook/TikTok/Instagram/Zalo)",
        "FE-07: AI Content Generation (Text: caption, blog, ad copy, brand voice)",
        "FE-08: AI Image Generation (Text-to-Image, style presets, variations)",
        "FE-09: AI Video Generation (Script-to-Video, templates)",
        "FE-10: Virtual Brand Ambassador (InstantID, face upload)",
        "FE-11: RAG Knowledge Base (Document upload, embedding, semantic search)",
        "FE-12: Trend Crawler (Auto-crawl, trending topics dashboard)",
        "FE-13: Content Request & Task Management",
        "FE-14: Content Calendar & Scheduling (Day/Week/Month, drag-drop, recurring)",
        "FE-15: Approval Workflow (Multi-level: Creator->Manager->Client)",
        "FE-16: Facebook Publishing (Text/Image/Video, Carousel, Schedule)",
        "FE-17: TikTok Publishing (Video, Caption, Hashtags, Schedule)",
        "FE-18: Instagram & Threads Publishing (Image/Reel, Story, Thread)",
        "FE-19: Zalo OA Publishing (Broadcast, Template, Schedule)",
        "FE-20: Client Portal (Calendar, Approve/Reject, Analytics view)",
        "FE-21: Analytics & Reporting (Performance, Platform, Export PDF/Excel)",
        "FE-22: Subscription & Billing (Free/Basic/Pro/Enterprise, AI Credits)",
        "FE-23: Admin Dashboard (User Mgmt, Moderation, System Health)",
        "FE-24: Mobile App (Dashboard, Calendar, Push, Approval on mobile)",
    ]
    for f in features_r1:
        add_placeholder(doc, f)
    add_placeholder(doc, "Source: docs/plan/BrandHub_Master_Plan.md (all 46 epics)")

    doc.add_heading("6.2 Limitations & Exclusions", level=3)
    limitations = [
        "LI-01: Web application primarily; Mobile (React Native) has limited features vs web.",
        "LI-02: No in-house AI model training \u2014 uses 3rd-party APIs (Groq, Stability AI, Google Veo).",
        "LI-03: Vietnam market focus \u2014 Vietnamese + English, 5 social platforms.",
        "LI-04: Limited to Facebook, TikTok, Instagram, Threads, Zalo OA (no YouTube, LinkedIn, X).",
        "LI-05: No offline/cash payment \u2014 online gateways only (VNPay, Momo).",
        "LI-06: No real-time collaborative editing on content.",
        "LI-07: AI quality depends on 3rd-party API availability and performance.",
    ]
    for li in limitations:
        add_placeholder(doc, li)

    heading_with_assignee(doc, "7. References", 2, "\u00c2n")
    refs = [
        "1. FPT University \u2014 SEP490 Capstone Project Course Materials, Fall 2026",
        "2. Facebook Graph API Documentation \u2014 https://developers.facebook.com/docs/graph-api",
        "3. TikTok Content API Documentation \u2014 https://developers.tiktok.com/",
        "4. Instagram Graph API Documentation \u2014 https://developers.facebook.com/docs/instagram-api",
        "5. Zalo OA API Documentation \u2014 https://oa.zalo.me/docs",
        "6. Groq API Documentation \u2014 https://console.groq.com/docs",
        "7. Stability AI API Documentation \u2014 https://platform.stability.ai/docs",
        "8. Google Veo API Documentation",
        "9. Spring Boot 3 Documentation \u2014 https://docs.spring.io/spring-boot/",
        "10. MongoDB Documentation \u2014 https://www.mongodb.com/docs/",
    ]
    for r in refs:
        add_placeholder(doc, r)

    doc.add_page_break()
    path = os.path.join(OUT, "BrandHub_Report1_Project_Introduction.docx")
    doc.save(path)
    print(f"OK: Report 1 -> {path}")
    return path


# =====================================================================
# REPORT 2
# =====================================================================
def build_report2():
    doc = Document()
    section = doc.sections[0]
    for attr in ['top_margin', 'bottom_margin', 'left_margin', 'right_margin']:
        setattr(section, attr, Cm(2.54))
    style = doc.styles['Normal']
    style.font.name = "Times New Roman"
    style.font.size = Pt(13)
    style.paragraph_format.line_spacing = 1.5

    add_cover_page(doc, 2, "Project Management Plan")
    add_toc_placeholder(doc)
    add_record_of_changes(doc)
    doc.add_page_break()

    doc.add_heading("II. Project Management Plan", level=1)
    doc.add_heading("1. Overview", level=2)

    heading_with_assignee(doc, "1.1 Scope & Estimation", 3, "Trung")
    add_placeholder(doc, "Create WBS table: #, WBS Item, Complexity (Simple/Medium/Complex), Est. Effort (man-days).")
    add_placeholder(doc, "Cover: 16 sprints + 4 AI iterations, ~46 epics, ~406 tasks.")
    add_placeholder(doc, "Grand total: ~860-900 man-days (5 members x 32 weeks).")
    add_placeholder(doc, "Insert WBS Tree Diagram (DA-D01-03).")
    add_placeholder(doc, "Source: docs/plan/BrandHub_Master_Plan.md, docs/plan/Jira_Status_Audit_2026-07-11.md")

    heading_with_assignee(doc, "1.2 Project Objectives", 3, "Trung")
    add_placeholder(doc, "7 objectives with priority levels (Very High/High/Medium).")
    add_placeholder(doc, "Quality metrics table: test coverage targets, defect distribution.")
    add_placeholder(doc, "Milestone Timeliness target: 95%.")
    add_placeholder(doc, "Effort distribution: Requirements 20%, Design 15%, Coding 35%, Testing 20%, PM 10%.")

    heading_with_assignee(doc, "1.3 Project Risks", 3, "Trung")
    add_placeholder(doc, "List 8-10 risks: #, Description, Type, Impact (H/M/L), Possibility, Mitigation/Response.")
    risks = [
        "1. AI API rate limit/downtime (Groq, Stability AI, Google Veo)",
        "2. Social platform API policy changes (Facebook, TikTok)",
        "3. OAuth token expiration/failure for 5 platforms",
        "4. MongoDB-PostgreSQL data inconsistency",
        "5. Multi-tenancy data leakage (workspace isolation)",
        "6. Team skill gap (React Native, AI/ML, WebFlux)",
        "7. Scope creep from mentor feedback",
        "8. Cloud/AWS cost overrun",
        "9. Microservice integration complexity",
        "10. ChromaDB/RAG search performance degradation",
    ]
    for risk in risks:
        add_placeholder(doc, risk)

    doc.add_heading("2. Management Approach", level=2)

    heading_with_assignee(doc, "2.1 Project Process", 3, "Ph\u01b0\u1edbc")
    add_placeholder(doc, "Describe Scrum methodology: roles, ceremonies, artifacts.")
    add_placeholder(doc, "Sprint breakdown: Sprint 0 (Setup) -> Sprint 1-15 (Development) -> Sprint 16 (Closure).")
    add_placeholder(doc, "Each sprint: Time (2 weeks), Activities, Deliverables.")
    add_placeholder(doc, "AI Parallel Track: 4 iterations alongside main sprints.")
    add_placeholder(doc, "Insert Scrum Sprint Timeline (DA-D01-04).")
    add_placeholder(doc, "Source: docs/plan/sprints/README.md, docs/iterations/README.md")

    heading_with_assignee(doc, "2.2 Quality Management", 3, "Ph\u01b0\u1edbc")
    add_placeholder(doc, "2.2.1 Defect Prevention: Coding standards, SonarQube, knowledge sharing.")
    add_placeholder(doc, "2.2.2 Reviewing: Mandatory PR review, peer review checklist.")
    add_placeholder(doc, "2.2.3 Unit Testing: JUnit 5 (Java), pytest (Python), Jest (React) \u2014 >80% coverage.")
    add_placeholder(doc, "2.2.4 Integration Testing: API contract tests, multi-service tests.")
    add_placeholder(doc, "2.2.5 System Testing: End-to-end, performance, security testing.")
    add_placeholder(doc, "2.2.6 Acceptance Testing (UAT): Mentor review, demo to supervisor.")
    add_placeholder(doc, "Source: docs/plan/sprints/sprint_15/PLAN.md, docs/plan/sprints/sprint_04/PLAN.md#epic-e10")

    heading_with_assignee(doc, "2.3 Training Plan", 3, "Tu\u1ea5n")
    add_placeholder(doc, "Training table: Training Area, Participants, Duration, Waiver Criteria.")
    training = [
        "Java Spring Boot 3 + WebFlux (Reactive programming)",
        "MongoDB + PostgreSQL (Data modeling, aggregation)",
        "React 18 + shadcn/ui + Tailwind CSS",
        "React Native (Mobile development)",
        "AI/ML APIs (Groq, Stability AI, Google Veo, ChromaDB)",
        "Testing (JUnit, pytest, Jest, Playwright)",
        "Docker & AWS Deployment",
    ]
    for t in training:
        add_placeholder(doc, f"- {t}")
    add_placeholder(doc, "Source: docs/plan/sprints/sprint_01/PLAN.md#epic-e01")

    heading_with_assignee(doc, "3. Project Deliverables", 2, "Ph\u01b0\u1edbc")
    add_placeholder(doc, "List 21+ deliverables: #, Deliverable, Due Date, Notes.")
    add_placeholder(doc, "Include: 7 Capstone reports (R1-R7), software packages, source code, demo materials.")

    heading_with_assignee(doc, "4. Responsibility Assignments", 2, "\u00c2n")
    add_placeholder(doc, "D/R/S/I matrix: 5 members x N work items.")
    add_placeholder(doc, "D=Do, R=Review, S=Support, I=Informed.")
    add_placeholder(doc, "Source: docs/plan/BrandHub_Master_Plan.md#workload-distribution-table")

    heading_with_assignee(doc, "5. Project Communications", 2, "Ph\u01b0\u1edbc")
    add_placeholder(doc, "Communication matrix: Item, Who/Target, Purpose, When/Frequency, Type/Tool.")
    add_placeholder(doc, "Daily: Slack, Bi-weekly: Team meeting (Sun+Thu, Google Meet), Weekly: Mentor meeting (Wed).")

    heading_with_assignee(doc, "6. Configuration Management", 2, "Ph\u01b0\u1edbc")
    doc.add_heading("6.1 Document Management", level=3)
    add_placeholder(doc, "Google Drive structure, naming convention, version control, backup policy.")
    add_placeholder(doc, "Insert Folder Structure Diagram (DA-D02-04).")

    doc.add_heading("6.2 Source Code Management", level=3)
    add_placeholder(doc, "GitHub Organization with 7 repos (polyrepo).")
    add_placeholder(doc, "Branching: main, develop, feature/<svc>/<desc>, release/<ver>, hotfix/<desc>.")
    add_placeholder(doc, "PR rules: mandatory review, CI checks pass, no direct push to main.")
    add_placeholder(doc, "Insert Git Branch Strategy (DA-D02-03).")

    doc.add_heading("6.3 Tools & Infrastructures", level=3)
    add_placeholder(doc, "[Assignee: \u00c2n]")
    add_placeholder(doc, "Tools table: Category, Tools.")
    add_placeholder(doc, "Categories: Technology, Database, IDE, Diagramming, Documentation, Version Control, Deployment, PM, AI/ML.")
    add_placeholder(doc, "Source: docs/plan/BrandHub_Master_Plan.md#tech-stack-summary")

    doc.add_page_break()
    path = os.path.join(OUT, "BrandHub_Report2_Project_Management_Plan.docx")
    doc.save(path)
    print(f"OK: Report 2 -> {path}")
    return path


# =====================================================================
# REPORT 3
# =====================================================================
def build_report3():
    doc = Document()
    section = doc.sections[0]
    for attr in ['top_margin', 'bottom_margin', 'left_margin', 'right_margin']:
        setattr(section, attr, Cm(2.54))
    style = doc.styles['Normal']
    style.font.name = "Times New Roman"
    style.font.size = Pt(13)
    style.paragraph_format.line_spacing = 1.5

    add_cover_page(doc, 3, "Software Requirement Specification")
    add_toc_placeholder(doc)
    add_record_of_changes(doc)
    doc.add_page_break()

    doc.add_heading("II. Software Requirement Specification", level=1)

    heading_with_assignee(doc, "1. Product Overview", 2, "Trung")
    add_placeholder(doc, "Overall description of BrandHub with Context Diagram.")
    add_placeholder(doc, "6 roles: ADMIN, AGENCY_OWNER, MANAGER, CREATOR, BRAND_CLIENT, GUEST.")
    add_placeholder(doc, "Core capabilities: AI content gen, 5-platform publishing, RAG, virtual ambassador, approval workflow, client portal, analytics.")
    add_placeholder(doc, "Tech stack: Java Spring Boot 3 (WebFlux), Python FastAPI, React 18, React Native, MongoDB, PostgreSQL, Redis, ChromaDB, RabbitMQ, AWS S3.")
    add_placeholder(doc, "Insert Context Diagram (DA-D01-01).")
    add_placeholder(doc, "Insert System Architecture Diagram (DA-D01-02).")
    add_placeholder(doc, "Source: docs/plan/BrandHub_Master_Plan.md, docs/architecture/")

    doc.add_heading("2. User Requirements", level=2)

    heading_with_assignee(doc, "2.1 Actors", 3, "Tu\u1ea5n")
    add_placeholder(doc, "Actor descriptions table: #, Actor, Description.")
    actors = [
        "1. GUEST: Unauthenticated. View landing page, register, login.",
        "2. BRAND_CLIENT: Client of agency. View calendar, approve/reject content, view analytics.",
        "3. CONTENT_CREATOR: Agency staff. Create AI content, manage knowledge base, schedule posts.",
        "4. MANAGER: Agency staff. Manage clients, review content, send reports.",
        "5. AGENCY_OWNER: Agency admin. Workspace setup, team management, billing.",
        "6. ADMIN: System admin. User management, content moderation, system config.",
    ]
    for a in actors:
        add_placeholder(doc, a)
    add_placeholder(doc, "Source: docs/plan/BrandHub_Master_Plan.md#roles, docs/database/DA-E06-08_Database_Access_Rules.md")

    heading_with_assignee(doc, "2.2 Use Cases", 3, "Tu\u1ea5n + L\u1ed9c")
    add_placeholder(doc, "Insert Use Case Overview Diagram (DA-D02-01).")
    add_placeholder(doc, "[Assignee: L\u1ed9c] UC Descriptions: ADMIN + AGENCY_OWNER (~20 UCs).")
    add_placeholder(doc, "[Assignee: Tu\u1ea5n] UC Descriptions: MANAGER + CREATOR + BRAND_CLIENT + GUEST (~40 UCs).")
    add_placeholder(doc, "Format: UC ID, Use Case Name, Actors, Description (Main Flow, Alternative Flows).")
    add_placeholder(doc, "Source: docs/plan/sprints/sprint_02/PLAN.md#epic-e03, docs/feature/*/spec.md, docs/api/endpoints/")

    doc.add_heading("3. Functional Requirements", level=2)

    heading_with_assignee(doc, "3.1 System Functional Overview", 3, "Multiple (see sub-sections)")

    doc.add_heading("3.1.1 Screens Flow", level=4)
    add_placeholder(doc, "Insert Screen Flow diagrams (DA-D03-01 through DA-D03-06).")

    heading_with_assignee(doc, "3.1.2 Screen Descriptions", 4, "L\u1ed9c + Ph\u01b0\u1edbc + Tu\u1ea5n")
    add_placeholder(doc, "[Assignee: L\u1ed9c] ADMIN + AGENCY_OWNER screens (~35 screens).")
    add_placeholder(doc, "[Assignee: Ph\u01b0\u1edbc] MANAGER + CREATOR screens (~30 screens).")
    add_placeholder(doc, "[Assignee: Tu\u1ea5n] BRAND_CLIENT + GUEST screens (~13 screens).")
    add_placeholder(doc, "Format table: #, Feature, Screen, Description.")

    heading_with_assignee(doc, "3.1.3 Screen Authorization", 4, "L\u1ed9c")
    add_placeholder(doc, "Authorization matrix: all screens (rows) x 6 roles (columns).")
    add_placeholder(doc, "X = access, -- = no access, (view) = read-only.")
    add_placeholder(doc, "Insert Screen Authorization Matrix (DA-D03-07).")

    heading_with_assignee(doc, "3.1.4 Non-Screen Functions", 4, "Tu\u1ea5n")
    add_placeholder(doc, "List ~12-15 non-screen functions: #, Feature, System Function, Description.")
    ns_funcs = [
        "Welcome Email, Password Reset Email, JWT Blacklist Cleanup",
        "OAuth Token Refresh Job, Publishing Job (RabbitMQ consumer)",
        "Publish Status Callback, Payment Confirmation Webhook",
        "Contract Expiry Scheduler, Trend Crawl Scheduler",
        "AI Usage Log Archival, Notification Delivery Service",
        "Content Auto-Archive Scheduler",
    ]
    for f in ns_funcs:
        add_placeholder(doc, f"- {f}")
    add_placeholder(doc, "Source: docs/plan/sprints/sprint_04/PLAN.md#epic-e11, docs/api/endpoints/")

    heading_with_assignee(doc, "3.1.5 Entity Relationship Diagram", 4, "Trung")
    add_placeholder(doc, "Insert ERD (DA-D02-02).")
    add_placeholder(doc, "Entity descriptions table: #, Entity, Description (12 MongoDB + 5 PostgreSQL).")
    add_placeholder(doc, "Source: docs/plan/sprints/sprint_03/PLAN.md#epic-e06")

    # FR sections 3.2 - 3.27
    fr_sections = [
        ("3.2", "Authentication & Authorization", "Trung", [
            "Register (Email + Google)", "Login (Email + Google)",
            "OAuth Connect (Facebook, TikTok, Instagram, Zalo)", "2FA (TOTP via Email/App)",
            "Forgot Password", "Reset Password", "Change Password",
            "OTP Verify", "Token Refresh (JWT RS256)", "Sign Out (Token Blacklist)"
        ], "docs/feature/auth/*/spec.md, docs/plan/sprints/sprint_05/PLAN.md, docs/api/endpoints/"),
        ("3.3", "User & Profile Management", "Trung", [
            "View Profile", "Update Profile", "Avatar Upload",
            "Identity Verification", "Account Deactivation"
        ], "docs/plan/sprints/sprint_06/PLAN.md, docs/api/endpoints/"),
        ("3.4", "Workspace Management", "Trung", [
            "Create Workspace", "Update Workspace", "Delete Workspace",
            "View Members", "Invite Member", "Remove Member",
            "Multi-tenancy Data Isolation"
        ], "docs/plan/sprints/sprint_06/PLAN.md, docs/database/DA-E06-08_Database_Access_Rules.md"),
        ("3.5", "RBAC (Role-Based Access Control)", "Trung", [
            "Assign Role", "Revoke Role", "View Permissions", "Permission Check Enforcement"
        ], "docs/database/DA-E06-08_Database_Access_Rules.md, docs/plan/sprints/sprint_06/PLAN.md"),
        ("3.6", "Content Request Management", "L\u1ed9c", [
            "Create Content Request", "Assign Task to Creator", "Track Request Status",
            "Revise Request", "Cancel Request"
        ], "docs/plan/sprints/sprint_10/PLAN.md, docs/api/endpoints/"),
        ("3.7", "Content Calendar & Scheduling", "L\u1ed9c", [
            "Calendar View (Day/Week/Month)", "Drag-drop Schedule Post",
            "Recurring Posts", "Timezone Configuration", "Calendar Filter by Platform/Status"
        ], "docs/plan/sprints/sprint_10/PLAN.md, docs/api/endpoints/"),
        ("3.8", "Approval Workflow", "L\u1ed9c", [
            "Submit Content for Review", "Approve Content", "Reject with Comments",
            "Revision Loop", "Approval Chain (Creator -> Manager -> Client)"
        ], "docs/plan/sprints/sprint_11/PLAN.md, docs/api/endpoints/"),
        ("3.9", "Client Portal", "L\u1ed9c", [
            "Client Login", "View Content Calendar", "Approve/Reject Content",
            "View Analytics Dashboard", "Add Comments on Content"
        ], "docs/plan/sprints/sprint_13/PLAN.md, docs/api/endpoints/"),
        ("3.10", "Agency & Client Management", "L\u1ed9c", [
            "Create Client", "Update Client Info", "Delete/Archive Client",
            "Assign Account Manager", "Client Onboarding Flow", "Client Settings/Preferences"
        ], "docs/plan/sprints/sprint_10/PLAN.md, docs/api/endpoints/"),
        ("3.11", "AI Content Generation", "Tu\u1ea5n", [
            "Text Generation (Caption)", "Text Generation (Blog/Article)",
            "Text Generation (Ad Copy)", "Tone/Brand Voice Selection",
            "Anti-Hallucination Guard", "Content History & Reuse"
        ], "docs/iterations/README.md, docs/plan/BrandHub_Master_Plan.md (AI01-AI11), docs/plan/sprints/sprint_09/PLAN.md"),
        ("3.12", "AI Image Generation", "Tu\u1ea5n", [
            "Text-to-Image Generation", "Style Presets", "Brand Asset Upload for Reference",
            "Image Variations", "Background Removal"
        ], "docs/iterations/README.md"),
        ("3.13", "AI Video Generation", "Tu\u1ea5n", [
            "Script-to-Video Generation", "Template Selection",
            "Scene Mapping", "Export Format Selection (MP4/GIF/WebM)"
        ], "docs/iterations/README.md"),
        ("3.14", "Virtual Brand Ambassador", "Tu\u1ea5n", [
            "Face Upload for Ambassador", "InstantID Model Setup",
            "Ambassador Video Generation", "Ambassador Management (Create/Edit/Delete)"
        ], "docs/iterations/README.md"),
        ("3.15", "RAG Knowledge Base", "Tu\u1ea5n", [
            "Document Upload (PDF/DOCX/TXT)", "Document Chunking",
            "Embedding Generation (ChromaDB)", "Brand Voice Training",
            "Knowledge Base Search (Semantic)"
        ], "docs/iterations/README.md, docs/plan/sprints/sprint_09/PLAN.md"),
        ("3.16", "Trend Crawler", "Tu\u1ea5n", [
            "Keyword Configuration", "Auto-Crawl Schedule",
            "Trending Topics Dashboard", "Trend-to-Content Suggestions"
        ], "docs/iterations/README.md"),
        ("3.17", "Social Account Management", "Ph\u01b0\u1edbc", [
            "Connect Social Account (OAuth)", "Disconnect Account", "View Token Status",
            "Refresh Token", "Platform Rate Limit Display"
        ], "docs/plan/sprints/sprint_07/PLAN.md, docs/api/endpoints/"),
        ("3.18", "Facebook Publishing", "Ph\u01b0\u1edbc", [
            "Text Post to Facebook Page", "Image Post", "Video Post",
            "Carousel Post", "Schedule Post", "Post Preview", "Publish Status Tracking"
        ], "docs/plan/sprints/sprint_08/PLAN.md, docs/api/endpoints/"),
        ("3.19", "TikTok Publishing", "Ph\u01b0\u1edbc", [
            "Video Upload to TikTok", "Caption + Hashtags", "Schedule Post", "Publish Status Tracking"
        ], "docs/plan/sprints/sprint_08/PLAN.md, docs/api/endpoints/"),
        ("3.20", "Instagram & Threads Publishing", "Ph\u01b0\u1edbc", [
            "Image/Reel Post to Instagram", "Carousel Post", "Instagram Story", "Threads Post"
        ], "docs/plan/sprints/sprint_08/PLAN.md, docs/api/endpoints/"),
        ("3.21", "Zalo OA Publishing", "Ph\u01b0\u1edbc", [
            "Text Broadcast to Zalo OA", "Image Broadcast", "Template Message", "Schedule Broadcast"
        ], "docs/plan/sprints/sprint_08/PLAN.md, docs/api/endpoints/"),
        ("3.22", "Publish Error Handling", "Ph\u01b0\u1edbc", [
            "Retry Logic (3x Exponential Backoff)", "Dead Letter Queue (RabbitMQ)",
            "Error Notification to User", "Manual Retry from Dashboard"
        ], "docs/plan/sprints/sprint_11/PLAN.md, docs/api/endpoints/"),
        ("3.23", "Notification System", "Ph\u01b0\u1edbc", [
            "In-App Notification", "Email Notification", "Push Notification (FCM)",
            "Notification Preferences", "Notification Center (Bell Icon UI)"
        ], "docs/plan/sprints/sprint_13/PLAN.md, docs/api/endpoints/"),
        ("3.24", "Subscription & Billing", "\u00c2n", [
            "Plan Selection (Free/Basic/Pro/Enterprise)", "Payment Integration (VNPay/Momo)",
            "Invoice History", "AI Credit Tracking", "Upgrade/Downgrade Plan"
        ], "docs/plan/sprints/sprint_06/PLAN.md, docs/api/endpoints/"),
        ("3.25", "Analytics & Reporting", "\u00c2n", [
            "Content Performance Dashboard", "Platform Analytics (per platform)",
            "Team Productivity Report", "Export as PDF", "Export as Excel", "Scheduled Reports"
        ], "docs/plan/sprints/sprint_13/PLAN.md, docs/api/endpoints/"),
        ("3.26", "Admin Dashboard", "\u00c2n", [
            "User Management (Verify/Disable/Delete)", "Content Moderation Queue",
            "System Health Monitoring", "Platform Statistics Overview"
        ], "docs/plan/sprints/sprint_14/PLAN.md, docs/api/endpoints/"),
        ("3.27", "Mobile App Features", "\u00c2n", [
            "Mobile Authentication", "Mobile Dashboard", "Content Calendar (Mobile)",
            "Push Notification Handling", "Approve/Reject on Mobile", "Content Preview (Mobile)"
        ], "docs/plan/sprints/sprint_14/PLAN.md, docs/api/endpoints/"),
    ]

    for sec_num, name, assignee, functions, source in fr_sections:
        heading_with_assignee(doc, f"{sec_num} {name}", 3, assignee)
        add_placeholder(doc, f"Feature group: {name}. Functions to describe (~{len(functions)} functions):")
        for fn in functions:
            add_placeholder(doc, f"  \u2022 {fn}")
        add_placeholder(doc, "")
        add_placeholder(doc, "Format each function as:")
        add_placeholder(doc, "  Function Trigger \u2192 Function Description (Actors, Purpose, Interface, Data Processing)")
        add_placeholder(doc, "  \u2192 Screen Layout (mock-up reference) \u2192 Function Details (Data, Business Rules, Validation)")
        add_placeholder(doc, "  \u2192 Functionalities: Normal Flow (step-by-step), Abnormal Cases, Post-Conditions")
        add_placeholder(doc, f"Source: {source}")
        add_placeholder(doc, "=" * 50)

    heading_with_assignee(doc, "4. Non-Functional Requirements", 2, "Trung")

    doc.add_heading("4.1 External Interfaces", level=3)
    add_placeholder(doc, "External interfaces with performance/availability thresholds:")
    add_placeholder(doc, "- Payment Gateway: VNPay, Momo integration")
    add_placeholder(doc, "- OAuth Providers: Google, Facebook, TikTok, Instagram, Zalo")
    add_placeholder(doc, "- Google Maps API, FCM (Firebase Cloud Messaging)")
    add_placeholder(doc, "- Email Service (SMTP), SMS Gateway (OTP/alerts)")

    doc.add_heading("4.2 Quality Attributes", level=3)
    add_placeholder(doc, "4.2.1 Usability: \u22645 steps/task, \u226415 min onboarding, WCAG 2.1 AA.")
    add_placeholder(doc, "4.2.2 Reliability: 99.5% uptime, MTTR \u22642h, backup every 24h.")
    add_placeholder(doc, "4.2.3 Performance: <2s page load (P95), <1s search, 1000 concurrent, API <500ms.")
    add_placeholder(doc, "4.2.4 Security: JWT RS256 (15min access), refresh cookie (HttpOnly/Secure/SameSite=Strict), BCrypt=12, RBAC, 2FA, AES-256, audit logs, OWASP Top 10.")
    add_placeholder(doc, "4.2.5 Compatibility: Chrome/Firefox/Safari/Edge (last 2), iOS 15+/Android 12+.")
    add_placeholder(doc, "4.2.6 Maintainability: Modular microservices, \u226580% coverage, OpenAPI 3.0 docs.")
    add_placeholder(doc, "4.2.7 Legal & Ethics: Vietnam Data Privacy Law, PCI DSS, GDPR-ready.")
    add_placeholder(doc, "Source: docs/architecture/, docs/plan/sprints/sprint_04/PLAN.md")

    doc.add_heading("5. Requirement Appendix", level=2)

    heading_with_assignee(doc, "5.1 Business Rules", 3, "\u00c2n")
    add_placeholder(doc, "Compile BR-01 through BR-NN (~70-80 rules). Format: BR-XX, Rule Definition.")
    add_placeholder(doc, "Group by feature area. No duplicates. No contradictions.")
    add_placeholder(doc, "Each FR section writer lists their business rules in their section. This is the merged appendix.")

    doc.add_heading("5.2 Common Requirements", level=3)
    add_placeholder(doc, "Common requirements shared across features.")
    add_placeholder(doc, "Examples: all forms have validation, all APIs show loading, all errors display friendly messages, etc.")

    heading_with_assignee(doc, "5.3 Application Messages List", 3, "\u00c2n")
    add_placeholder(doc, "Compile MSG01 through MSG-NN (~100-120 messages).")
    add_placeholder(doc, "Format: Message Code, Type (In line/Toast/In red), Context, Content.")
    add_placeholder(doc, "All in English, professional, actionable. Group by feature area.")

    doc.add_heading("5.4 Other Requirements", level=3)
    add_placeholder(doc, "Any additional requirements not covered above (if any).")

    doc.add_page_break()
    path = os.path.join(OUT, "BrandHub_Report3_Software_Requirement_Specification.docx")
    doc.save(path)
    print(f"OK: Report 3 -> {path}")
    return path


if __name__ == "__main__":
    print("Generating BrandHub SEP490 Report Frameworks...")
    print("=" * 60)
    build_report1()
    build_report2()
    build_report3()
    print("=" * 60)
    print(f"Done. Files in: {OUT}")
