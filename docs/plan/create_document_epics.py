#!/usr/bin/env python3
"""
Create 23 Document Epics (D01-D23) + ~86 Tasks for SEP490 Reports on Jira.
Source: Document_Plan.md — Phase 1-5: Diagrams, R1, R2, R3, Review/Merge/Submit.

Usage: python create_document_epics.py [--dry-run] [--epics-only] [--tasks-only] [--phase 1-5]
"""

import json, urllib.request, urllib.error, base64, sys, time, os

# ── CONFIG ──
EMAIL = "letritrung2605@gmail.com"
TOKEN = "ATATT3xFfGF0hOu_QP0K9NHqnGgsrxko4pKSzqkTXX2nm1YWWBm-g9KGqEEe0h1h90vbBdEskz9EoWDc3s2sB3WMnqNedf2RzztO0R0FwLqNs4vIotf4_r9kajvHL4p9G7W9PF_Z3qCkZP_21vJPbmbiul8PkiEdjpwr0AY3Cbt6O0nft6dvDtQ=080C74FD"
JIRA_API = "https://letritrung2605.atlassian.net/rest/api/3/issue"
AUTH = base64.b64encode(f"{EMAIL}:{TOKEN}".encode()).decode()
PROJECT_KEY = "DA"
EPIC_TYPE = "10048"
TASK_TYPE = "10045"

ASSIGNEES = {
    "Trung":  "61bc48ad08e4e00069b20d6c",
    "Phước": "712020:d2f784a1-44cf-468f-bb96-cd8930b1c135",
    "Ân":    "712020:b501eda5-2140-417d-bc3a-c942db8310cc",
    "Lộc":   "712020:5ec38295-3d34-4ff3-ae87-95279adf1dff",
    "Tuấn":  "712020:198f8574-4327-4e82-8674-275f3b950db0",
}

DRY_RUN = "--dry-run" in sys.argv
EPICS_ONLY = "--epics-only" in sys.argv
TASKS_ONLY = "--tasks-only" in sys.argv
PHASE_FILTER = None
for i, arg in enumerate(sys.argv):
    if arg == "--phase" and i+1 < len(sys.argv):
        PHASE_FILTER = int(sys.argv[i+1])

OUTPUT_FILE = os.path.join(os.path.dirname(__file__), "json", ".doc_epic_results.json")
TRACKING_FILE = os.path.join(os.path.dirname(__file__), "json", "Document_Upload_Tracking.md")

# ── API ──

def api_call(method, body=None):
    if DRY_RUN:
        summary = body.get("fields", {}).get("summary", "?") if body else ""
        return 201, {"key": f"DA-{abs(hash(summary)) % 900 + 100}"}
    data = json.dumps(body).encode() if body else None
    req = urllib.request.Request(JIRA_API, data=data, method=method)
    req.add_header("Authorization", f"Basic {AUTH}")
    req.add_header("Content-Type", "application/json")
    try:
        with urllib.request.urlopen(req) as resp:
            return resp.status, json.loads(resp.read().decode())
    except urllib.error.HTTPError as e:
        return e.code, {"error": e.read().decode()[:500]}

# ── ADF builders ──

def adf_doc(content):
    return {"type": "doc", "version": 1, "content": content}

def adf_h(level, text):
    return {"type": "heading", "attrs": {"level": level}, "content": [{"type": "text", "text": text}]}

def adf_p(text):
    return {"type": "paragraph", "content": [{"type": "text", "text": text}]}

def adf_list(items):
    return {"type": "bulletList", "content": [
        {"type": "listItem", "content": [{"type": "paragraph", "content": [{"type": "text", "text": item}]}]}
        for item in items
    ]}

def build_task_desc(section, goal, ac_list, source, deps, assignee, priority):
    return adf_doc([
        adf_h(2, section),
        adf_p(f"👤 {assignee} | {priority}"),
        adf_h(3, "🎯 Goal"),
        adf_p(goal),
        adf_h(3, "✅ Acceptance Criteria"),
        adf_list(ac_list),
        adf_h(3, "📚 Source References"),
        adf_p(source),
        adf_h(3, "🔗 Dependencies"),
        adf_p(deps),
    ])

def build_epic_desc(title, phase, task_count, assignees_set):
    return adf_doc([
        adf_h(2, title),
        adf_p(f"📦 Phase {phase} | {task_count} tasks | 👥 {', '.join(sorted(assignees_set))}"),
        adf_h(3, "Description"),
        adf_p(f"Document epic for SEP490 capstone reports. See Document_Plan.md for full task breakdown."),
    ])

# ── Create helpers ──

def create_epic(summary, description):
    body = {"fields": {"project": {"key": PROJECT_KEY}, "summary": summary,
            "description": description, "issuetype": {"id": EPIC_TYPE}}}
    status, resp = api_call("POST", body)
    if status in (200, 201):
        return resp.get("key")
    print(f"  ❌ EPIC FAILED [{status}]: {resp.get('error', resp)[:200]}")
    return None

def create_task(summary, description, epic_key, assignee_id):
    body = {"fields": {"project": {"key": PROJECT_KEY}, "summary": summary,
            "description": description, "issuetype": {"id": TASK_TYPE},
            "parent": {"key": epic_key}, "assignee": {"id": assignee_id}}}
    status, resp = api_call("POST", body)
    if status in (200, 201):
        return resp.get("key")
    print(f"  ❌ TASK FAILED [{status}]: {resp.get('error', resp)[:200]}")
    return None

# ── EPICS ──

EPICS = [
    ("D01", "EPIC D01 — Context & Architecture Diagrams", 1),
    ("D02", "EPIC D02 — Use Case, ERD & Config Diagrams", 1),
    ("D03", "EPIC D03 — Screen Flows, Authorization Matrix & Mockups", 1),
    ("D04", "EPIC D04 — Diagram Review", 1),
    ("D05", "EPIC D05 — R1 §2-3: Product Background & Existing Systems", 2),
    ("D06", "EPIC D06 — R1 §4-5: Business Opportunity & Vision", 2),
    ("D07", "EPIC D07 — R1 §6-7: Scope, Limitations & References", 2),
    ("D08", "EPIC D08 — R2 §1: Overview (WBS, Objectives, Risks)", 3),
    ("D09", "EPIC D09 — R2 §2: Management Approach & Quality", 3),
    ("D10", "EPIC D10 — R2 §3, §5, §6: Deliverables, Communications, Config", 3),
    ("D11", "EPIC D11 — R2 §2.3, §4, §6.3: Training, Responsibility, Tools", 3),
    ("D12", "EPIC D12 — R3 §1: Product Overview & System Context", 4),
    ("D13", "EPIC D13 — R3 §2: User Requirements (Actors & Use Cases)", 4),
    ("D14", "EPIC D14 — R3 §3.1: System Functional Overview", 4),
    ("D15", "EPIC D15 — R3 §3.2-3.5: FR — Auth & Core Business", 4),
    ("D16", "EPIC D16 — R3 §3.6-3.10: FR — Content & Workflow", 4),
    ("D17", "EPIC D17 — R3 §3.11-3.16: FR — AI Features", 4),
    ("D18", "EPIC D18 — R3 §3.17-3.23: FR — Publishing & Social", 4),
    ("D19", "EPIC D19 — R3 §3.24-3.27: FR — Sub, Analytics, Admin, Mobile", 4),
    ("D20", "EPIC D20 — R3 §4-5: NFR & Appendices", 4),
    ("D21", "EPIC D21 — Review & Feedback", 5),
    ("D22", "EPIC D22 — Merge & Format", 5),
    ("D23", "EPIC D23 — Final Package & Submission", 5),
]

# ── TASKS ──
# (epic, task_id, section_tag, title, goal, [ac], source, deps, assignee, priority)

TASKS = [
    # ═══ PHASE 1: DIAGRAMS ═══

    # D01: Context & Architecture
    ("D01", "DA-D01-01", "[R3 §1]", "Draw Context Diagram",
     "Draw context diagram showing BrandHub system boundary + 6 external services + 6 actor roles. Sets visual style for all diagrams. Used in R3 §1.",
     ["System boundary clear", "6 external services: Groq API, Stability AI, Google Veo, Facebook Graph API, TikTok Content API, Zalo OA API",
      "6 actors: ADMIN, AGENCY_OWNER, ACCOUNT_MANAGER, CONTENT_CREATOR, BRAND_CLIENT, GUEST",
      "Data flows labeled (REST API, RabbitMQ, OAuth 2.0)", "Consistent style (color, font, size)", "PNG + editable source (draw.io/StarUML)"],
     "docs/architecture/, docs/plan/BrandHub_Master_Plan.md", "None", "Tuấn", "🔴 Critical"),

    ("D01", "DA-D01-02", "[R3 §1]", "Draw System Architecture Diagram",
     "Draw layered microservices architecture: Client → Gateway → Services → Data. Used in R3 §1.",
     ["3 layers + data layer", "5 DBs: MongoDB, PostgreSQL, Redis, ChromaDB, RabbitMQ, AWS S3",
      "Protocols labeled (REST, gRPC, AMQP)", "7 GitHub repos, port numbers"],
     "docs/plan/BrandHub_Master_Plan.md, docs/architecture/", "DA-D01-01 (shared style)", "Phước", "🔴 Critical"),

    ("D01", "DA-D01-03", "[R2 §1.1]", "Draw WBS Tree Diagram",
     "WBS hierarchy: Project → Phase → Sprint → Epic with complexity color coding. Used in R2 §1.1.",
     ["3-4 levels: BrandHub → 3 Phases → 16 Sprints + 4 AI Iterations → 46 Epics",
      "Each node: label + man-days", "Color: Simple (green), Medium (yellow), Complex (red)", "Total ~860-900 man-days"],
     "docs/plan/BrandHub_Master_Plan.md, docs/plan/sprints/", "DA-D01-04 (sync timeline)", "Phước", "🔴 Critical"),

    ("D01", "DA-D01-04", "[R2 §2.1]", "Draw Scrum Sprint Timeline (Gantt)",
     "Gantt chart: 16 sprints + 4 AI iterations over 32 weeks. Used in R2 §2.1.",
     ["X-axis: Week 1–32", "16 sprint bars (2 weeks each), 4 AI iteration bars parallel",
      "Milestone markers per sprint", "Legend: Sprint (green), AI (orange), Milestone (red)"],
     "docs/plan/sprints/, docs/iterations/", "DA-D01-03", "Phước", "🔴 Critical"),

    # D02: Use Case, ERD & Config
    ("D02", "DA-D02-01", "[R3 §2.2]", "Draw Use Case Overview Diagram",
     "~60 use cases across 6 actors with include/extend relationships. Used in R3 §2.2.",
     ["6 actor stick figures", "~60 use case ovals grouped by functional area",
      "<<include>>, <<extend>> relationships", "System boundary box"],
     "docs/plan/sprints/sprint_02/PLAN.md, docs/api/endpoints/", "DA-D01-01", "Tuấn", "🔴 Critical"),

    ("D02", "DA-D02-02", "[R3 §3.1.3]", "Draw Entity Relationship Diagram (ERD)",
     "12 MongoDB collections + 5 PostgreSQL tables with relationships. Used in R3 §3.1.3.",
     ["Field names, types, required/optional", "Crow's foot notation",
      "Color: MongoDB (blue), PostgreSQL (purple)", "Entity description table"],
     "docs/plan/sprints/sprint_03/PLAN.md, docs/database/", "DA-D01-02", "Tuấn", "🔴 Critical"),

    ("D02", "DA-D02-03", "[R2 §6.2]", "Draw Git Branch Strategy Diagram",
     "Git-flow branching strategy for 7-repo polyrepo. Used in R2 §6.2.",
     ["Branches: main, develop, feature/<service>/<desc>, release/<ver>, hotfix/<desc>",
      "PR workflow: feature → develop → main", "CI/CD pipeline integration points"],
     "N/A", "None", "Lộc", "🟢 Medium"),

    ("D02", "DA-D02-04", "[R2 §6.1]", "Draw Repository & Folder Structure Diagram",
     "7 GitHub repos + Google Drive folder tree. Used in R2 §6.1.",
     ["7 repos in group box with descriptions", "Google Drive tree: Capstone Reports → R1-R7, Weekly Reports, Meeting Minutes",
      "Access permissions noted"],
     "N/A", "DA-D02-03", "Lộc", "🟢 Medium"),

    # D03: Screen Flows & Auth Matrix
    ("D03", "DA-D03-01", "[R3 §3.1.1]", "Draw Screen Flow — ADMIN Role",
     "Screen flow diagram for ADMIN (~15 screens). Used in R3 §3.1.1.",
     ["Each screen = rectangle node with label", "Navigation arrows between screens",
      "Start point marked", "Differentiate: public, authenticated, admin-only screens"],
     "Figma wireframes, docs/feature/*/spec.md", "DA-D02-01", "Lộc", "🔴 Critical"),

    ("D03", "DA-D03-02", "[R3 §3.1.1]", "Draw Screen Flow — AGENCY_OWNER Role",
     "Screen flow diagram for AGENCY_OWNER (~20 screens). Used in R3 §3.1.1.",
     ["Each screen = rectangle node with label", "Navigation arrows",
      "Start point marked", "Differentiate: public, authenticated, role-specific"],
     "Figma wireframes, docs/feature/*/spec.md", "DA-D02-01", "Lộc", "🔴 Critical"),

    ("D03", "DA-D03-03", "[R3 §3.1.1]", "Draw Screen Flow — ACCOUNT_MANAGER Role",
     "Screen flow diagram for ACCOUNT_MANAGER (~12 screens). Used in R3 §3.1.1.",
     ["Each screen = rectangle node", "Navigation arrows", "Start point marked",
      "Differentiate screen access levels"],
     "Figma wireframes, docs/feature/*/spec.md", "DA-D02-01", "Phước", "🔴 Critical"),

    ("D03", "DA-D03-04", "[R3 §3.1.1]", "Draw Screen Flow — CONTENT_CREATOR Role",
     "Screen flow diagram for CONTENT_CREATOR (~18 screens). Used in R3 §3.1.1.",
     ["Each screen = rectangle node", "Navigation arrows", "Start point marked",
      "Differentiate screen access levels"],
     "Figma wireframes, docs/feature/*/spec.md", "DA-D02-01", "Phước", "🔴 Critical"),

    ("D03", "DA-D03-05", "[R3 §3.1.1]", "Draw Screen Flow — BRAND_CLIENT Role",
     "Screen flow diagram for BRAND_CLIENT (~8 screens). Used in R3 §3.1.1.",
     ["Each screen = rectangle node", "Navigation arrows", "Start point marked",
      "Differentiate screen access levels"],
     "Figma wireframes, docs/feature/*/spec.md", "DA-D02-01", "Tuấn", "🔴 Critical"),

    ("D03", "DA-D03-06", "[R3 §3.1.1]", "Draw Screen Flow — GUEST Role",
     "Screen flow diagram for GUEST (~5 screens). Used in R3 §3.1.1.",
     ["Each screen = rectangle node", "Navigation arrows", "Start point marked",
      "Public vs authenticated differentiation"],
     "Figma wireframes, docs/feature/*/spec.md", "DA-D02-01", "Tuấn", "🔴 Critical"),

    ("D03", "DA-D03-07", "[R3 §3.1.2]", "Draw Screen Authorization Matrix",
     "Matrix: ~80+ screens × 6 roles (X / — / view-only). Used in R3 §3.1.2.",
     ["~80+ rows × 6 columns", "X = full access, — = no access, (view) = read-only",
      "Sorted by feature group", "Match screen flow diagrams exactly"],
     "N/A", "DA-D03-01 through DA-D03-06", "Lộc", "🟡 High"),

    ("D03", "DA-D03-08", "[R3 §3.1.1]", "Export & Annotate Screen Mockups from Figma",
     "Export 10+ key screen mockups with annotations. Used in R3 §3.1.1 and screen description sections.",
     ["10+ main screens with callout annotations", "Resolution readable when printed A4",
      "Consistent annotation style across all screens"],
     "Figma wireframes (Sprint 3)", "Figma wireframes complete", "Lộc", "🟡 High"),

    # D04: Diagram Review
    ("D04", "DA-D04-01", "", "Review All 16 Diagrams for Consistency",
     "Trung reviews all 16 diagrams for visual consistency, cross-reference accuracy, and completeness before team writes content.",
     ["All 16 diagrams checked: color, font, notation consistent",
      "Cross-reference check: screen flow → UC → FR → ERD",
      "Each diagram: title + figure number assigned",
      "Feedback documented in tracking sheet", "All fixes applied before Aug 18"],
     "DA-D01-01 through DA-D03-08", "All Phase 1 diagram tasks complete", "Trung", "🔴 Critical"),

    # ═══ PHASE 2: REPORT 1 ═══

    # D05: R1 §2-3 Background & Existing Systems
    ("D05", "DA-D05-01", "[R1 §2]", "Write Product Background",
     "Write Problem Statement — why marketing agencies need AI-powered multi-channel content platform. ~1 page English.",
     ["~1 page", "5-6 pain points: multi-platform fragmentation, high manual cost, inconsistent brand voice, complex approval workflows, difficulty tracking performance, lack of AI-assisted ideation",
      "VN market context included"],
     "docs/plan/BrandHub_Master_Plan.md, docs/architecture/", "Read R1 sample for format reference", "Lộc", "🟡 High"),

    ("D05", "DA-D05-02", "[R1 §3]", "Analyze 2 Existing Systems",
     "Analyze 2 competitors (Buffer, Hootsuite or local VN alternatives).",
     ["2 systems each: Description, Target Users, Features, Pros (3-4), Cons (3-4)",
      "Website screenshots", "Comparison table", "Conclusion: BrandHub advantages over both"],
     "Web research, docs/plan/BrandHub_Master_Plan.md", "DA-D05-01", "Lộc", "🟡 High"),

    # D06: R1 §4-5 Opportunity & Vision
    ("D06", "DA-D06-01", "[R1 §4]", "Write Business Opportunity",
     "Market opportunity — scale, trends, gap analysis. ~1 page.",
     ["~1 page", "VN marketing agency market size (with source)", "Digital transformation + AI adoption trends",
      "Multi-channel social media growth data", "Gap: no platform integrating AI + multi-channel publishing for SMB agencies"],
     "N/A", "DA-D05-01, DA-D05-02", "Tuấn", "🟡 High"),

    ("D06", "DA-D06-02", "[R1 §5]", "Write Software Product Vision",
     "Vision statement: For [target] who [need], BrandHub is a [category] that [benefit]. ~0.5-1 page.",
     ["~0.5-1 page", "Clear vision statement in standard format",
      "Core differentiators: AI content gen, multi-platform publishing, RAG brand voice, virtual ambassador",
      "Target: marketing agencies SMB Vietnam"],
     "N/A", "DA-D06-01", "Tuấn", "🟡 High"),

    # D07: R1 §6-7 Scope, Limitations, References
    ("D07", "DA-D07-01", "[R1 §6.1]", "Write Project Scope & Major Features",
     "List ~22 feature groups with sub-features (FE-01 to FE-NN).",
     ["~22 feature groups covering all BrandHub capabilities",
      "Format: FE-XX: Feature Name → sub-feature list",
      "Features grouped logically: Auth, User, Workspace, RBAC, Client, Social, AI Content/Image/Video, Ambassador, RAG, Trends, Content Request, Calendar, Approval, Publishing (5 platforms), Client Portal, Analytics, Subscription, Notifications, Admin, Mobile"],
     "docs/plan/BrandHub_Master_Plan.md (46 epics)", "DA-D02-01", "Ân", "🟡 High"),

    ("D07", "DA-D07-02", "[R1 §6.2]", "Write Limitations & Exclusions",
     "BrandHub scope boundary — 5-7 limitations (LI-01 to LI-07).",
     ["5-7 limitations clearly stated", "Each with short explanation",
      "Examples: web app only (mobile limited), no in-house AI model training, VN market focus, 5 platforms only, no offline payment, no real-time collaborative editing"],
     "N/A", "DA-D07-01", "Ân", "🟡 High"),

    ("D07", "DA-D07-03", "[R1 §7]", "Compile References",
     "Compile 5-10 references/citations for Report 1.",
     ["5-10 references", "FPT SEP490 materials, external API docs (Facebook, TikTok, Groq, Stability AI, Google Veo)",
      "Tech stack official docs", "Market research sources", "Consistent citation format"],
     "N/A", "DA-D05-01 through DA-D07-02", "Ân", "🟢 Medium"),

    # ═══ PHASE 3: REPORT 2 ═══

    # D08: R2 §1 Overview
    ("D08", "DA-D08-01", "[R2 §1.1]", "Write WBS with Complexity & Man-days",
     "WBS table: 16 sprints + 4 AI iterations → ~46 epics with complexity and man-day estimates. Include WBS Tree figure (DA-D01-03).",
     ["16 sprints + 4 AI iterations → ~46 epics", "Each item: WBS Item, Complexity (S/M/C), Est. Effort (man-days)",
      "Sub-totals per sprint", "Grand total ~860-900 man-days", "Embed WBS Tree figure"],
     "docs/plan/BrandHub_Master_Plan.md, docs/plan/Jira_Status_Audit_2026-07-11.md", "DA-D01-03, DA-D01-04", "Trung", "🔴 Critical"),

    ("D08", "DA-D08-02", "[R2 §1.2]", "Write Project Objectives",
     "7 SMART objectives with priority + quality metrics.",
     ["7 objectives: each with Description + Priority (Very High/High/Medium)",
      "Quality metrics table with measurable targets", "Milestone timeliness target ≥95%"],
     "N/A", "DA-D08-01", "Trung", "🟡 High"),

    ("D08", "DA-D08-03", "[R2 §1.3]", "Write Project Risks",
     "8-10 risks with Impact, Possibility, Response strategy.",
     ["8-10 risks identified", "Each: #, Description, Impact (H/M/L), Possibility (H/M/L), Response",
      "Cover: AI API downtime, social platform policy changes, OAuth failures, data inconsistency, multi-tenancy leakage, team skill gap, scope creep, cloud cost, microservice integration complexity, ChromaDB performance"],
     "N/A", "DA-D08-01, DA-D08-02", "Trung", "🟡 High"),

    # D09: R2 §2 Management Approach
    ("D09", "DA-D09-01", "[R2 §2.1]", "Write Management Approach (Scrum Process)",
     "Scrum process description: 16 sprints with activities + deliverables per sprint. Embed Sprint Timeline figure (DA-D01-04).",
     ["Scrum roles, ceremonies, artifacts described", "Sprint 0 → Sprint 1-15 → Sprint 16 breakdown",
      "Each sprint: Time period, Activities, Deliverables", "AI Parallel Track alignment explained", "Embed Sprint Timeline figure"],
     "docs/plan/sprints/README.md, docs/plan/sprints/sprint_*/PLAN.md", "DA-D01-04", "Phước", "🔴 Critical"),

    ("D09", "DA-D09-02", "[R2 §2.2]", "Write Quality Management",
     "5 levels of testing + defect prevention strategy.",
     ["Defect Prevention: coding standards, SonarQube, knowledge sharing",
      "5 testing levels: Code Review → Unit → Integration → System → UAT",
      "Each level: coverage %, tools used, defect targets"],
     "docs/plan/sprints/sprint_15/PLAN.md, docs/plan/sprints/sprint_04/PLAN.md", "DA-D08-02", "Phước", "🟡 High"),

    # D10: R2 §3, §5, §6 Deliverables, Comms, Config
    ("D10", "DA-D10-01", "[R2 §3]", "Write Project Deliverables",
     "21+ deliverables with due dates matching sprint timeline.",
     ["#, Deliverable, Due Date, Notes columns", "21+ deliverables covering all reports and artifacts",
      "Timeline matches Sprint Timeline (DA-D01-04)"],
     "N/A", "DA-D09-01", "Phước", "🟡 High"),

    ("D10", "DA-D10-02", "[R2 §5]", "Write Project Communications Plan",
     "Communication matrix: who, what, when, how.",
     ["Table: Item, Who/Target, Purpose, When/Frequency, Type/Tool",
      "Daily: Slack standups", "Bi-weekly: team meetings", "Weekly: mentor meetings"],
     "N/A", "None", "Phước", "🟢 Medium"),

    ("D10", "DA-D10-03", "[R2 §6]", "Write Configuration Management",
     "§6.1 Document Management + §6.2 Source Code Management + §6.3 Tools & Infrastructures.",
     ["§6.1: Google Drive structure (embed DA-D02-04), backup policy, versioning",
      "§6.2: Git branching strategy (embed DA-D02-03), PR rules, CI/CD pipeline",
      "§6.3: Tools & Infrastructures table"],
     "N/A", "DA-D02-03, DA-D02-04", "Phước", "🟢 Medium"),

    # D11: R2 Training, Responsibility, Tools
    ("D11", "DA-D11-01", "[R2 §2.3]", "Write Training Plan",
     "Training plan for 5-6 technology areas.",
     ["5-6 areas: Java Spring Boot, MongoDB/PostgreSQL, React/Next.js, Testing, Git/GitHub, Docker",
      "Each: Participants, Duration, Waiver Criteria"],
     "N/A", "None", "Tuấn", "🟢 Medium"),

    ("D11", "DA-D11-02", "[R2 §4]", "Write Responsibility Assignments (D/R/S/I Matrix)",
     "D/R/S/I matrix: 5 members × 15-20 work items.",
     ["D=Do, R=Review, S=Support, I=Informed legend",
      "15-20 work items × 5 members", "Clear accountability per deliverable"],
     "docs/plan/BrandHub_Master_Plan.md", "DA-D08-01", "Ân", "🟡 High"),

    ("D11", "DA-D11-03", "[R2 §6.3]", "Write Tools & Infrastructures Table",
     "Comprehensive tools table for R2 §6.3.",
     ["Categories: Technology, Database, IDEs, Diagramming, Documentation, Version Control, Deployment, PM, AI/ML",
      "Tool name + version + purpose per row"],
     "N/A", "None", "Ân", "🟢 Medium"),

    # ═══ PHASE 4: REPORT 3 ═══

    # D12: R3 §1 Product Overview
    ("D12", "DA-D12-01", "[R3 §1]", "Write Product Overview",
     "Product Overview for R3 §1. Embed Context Diagram + Architecture Diagram. ~1 page.",
     ["~1 page", "BrandHub summary: what it is, who it serves, core capabilities",
      "6 roles listed", "Tech stack overview", "Embed Context Diagram (DA-D01-01), Architecture Diagram (DA-D01-02)"],
     "N/A", "DA-D01-01, DA-D01-02", "Trung", "🔴 Critical"),

    ("D12", "DA-D12-02", "[R3 §1]", "Write Context Diagram Description",
     "Detailed text description of Context Diagram — each external entity and data flow explained.",
     ["System boundary described", "Each of 6 external services: interaction type, data exchanged, protocol",
      "Each of 6 actors: role, primary interactions"],
     "N/A", "DA-D12-01", "Trung", "🟡 High"),

    ("D12", "DA-D12-03", "[R3 §3.1.3]", "Write ERD Entity Descriptions",
     "Entity Descriptions table for ERD (~17 entities). Embed ERD figure. Used in R3 §3.1.3.",
     ["~17 entity rows (12 MongoDB + 5 PostgreSQL)", "Format: #, Entity, Description",
      "Embed ERD figure (DA-D02-02)"],
     "docs/plan/sprints/sprint_03/PLAN.md", "DA-D02-02", "Trung", "🟡 High"),

    # D13: R3 §2 User Requirements
    ("D13", "DA-D13-01", "[R3 §2.1]", "Write Actors Description",
     "Detailed description of 6 system actors.",
     ["6 actors: GUEST, BRAND_CLIENT, CONTENT_CREATOR, ACCOUNT_MANAGER, AGENCY_OWNER, ADMIN",
      "Each: Role description, Primary goals, Typical interactions, Permission level"],
     "docs/plan/BrandHub_Master_Plan.md, docs/database/DA-E06-08_Database_Access_Rules.md", "DA-D02-01", "Tuấn", "🔴 Critical"),

    ("D13", "DA-D13-02", "[R3 §2.2]", "Write Use Case Descriptions — Admin & Agency Owner",
     "~20 UC descriptions for ADMIN + AGENCY_OWNER actors.",
     ["Each UC: ID, Use Case Name, Actor(s), Description, Pre/Post conditions",
      "Format per FPT template Table 3", "Match UC diagram (DA-D02-01)"],
     "docs/plan/sprints/sprint_02/PLAN.md, docs/feature/*/spec.md", "DA-D13-01, DA-D02-01", "Lộc", "🔴 Critical"),

    ("D13", "DA-D13-03", "[R3 §2.2]", "Write Use Case Descriptions — AC, CC, BC, Guest",
     "~40 UC descriptions for ACCOUNT_MANAGER + CONTENT_CREATOR + BRAND_CLIENT + GUEST.",
     ["Each UC: ID, Use Case Name, Actor(s), Description, Pre/Post conditions",
      "Format per FPT template Table 3", "Match UC diagram (DA-D02-01)", "~40 UCs total"],
     "docs/plan/sprints/sprint_02/PLAN.md, docs/api/endpoints/", "DA-D13-01, DA-D02-01", "Tuấn", "🔴 Critical"),

    # D14: R3 §3.1 System Functional Overview
    ("D14", "DA-D14-01", "[R3 §3.1.1]", "Write Screen Descriptions — Admin & Agency Owner",
     "Screen Description table for ADMIN + AGENCY_OWNER (~35 screens). Used in R3 §3.1.2.",
     ["Format: #, Feature, Screen Name, Description", "~35 screens", "Match Screen Flow diagrams (DA-D03-01, DA-D03-02)"],
     "DA-D03-01, DA-D03-02, Figma", "DA-D03-01, DA-D03-02", "Lộc", "🟡 High"),

    ("D14", "DA-D14-02", "[R3 §3.1.1]", "Write Screen Descriptions — Account Manager & Content Creator",
     "Screen Description table for ACCOUNT_MANAGER + CONTENT_CREATOR (~30 screens). Used in R3 §3.1.2.",
     ["Format: #, Feature, Screen Name, Description", "~30 screens", "Match Screen Flow diagrams (DA-D03-03, DA-D03-04)"],
     "DA-D03-03, DA-D03-04, Figma", "DA-D03-03, DA-D03-04", "Phước", "🟡 High"),

    ("D14", "DA-D14-03", "[R3 §3.1.1]", "Write Screen Descriptions — Brand Client & Guest",
     "Screen Description table for BRAND_CLIENT + GUEST (~13 screens). Used in R3 §3.1.2.",
     ["Format: #, Feature, Screen Name, Description", "~13 screens", "Match Screen Flow diagrams (DA-D03-05, DA-D03-06)"],
     "DA-D03-05, DA-D03-06, Figma", "DA-D03-05, DA-D03-06", "Tuấn", "🟡 High"),

    ("D14", "DA-D14-04", "[R3 §3.1.4]", "Write Non-Screen Functions",
     "List & describe ~12-15 background jobs, callbacks, cron schedules. Used in R3 §3.1.5.",
     ["Format: #, Feature, System Function, Description",
      "~12-15 functions: Welcome Email, Password Reset, JWT Cleanup, OAuth Token Refresh, Publishing Job, Publish Callback, Payment Confirmation, Contract Expiry Check, Trend Crawl, AI Usage Archive, Notification Delivery, Content Auto-Archive"],
     "docs/plan/sprints/sprint_04/PLAN.md, docs/api/endpoints/", "DA-D14-01 through DA-D14-03", "Tuấn", "🟡 High"),

    # D15: FR — Auth & Core Business (§3.2-3.5)
    ("D15", "DA-D15-01", "[R3 §3.2]", "Write FR — Authentication & Authorization",
     "~10 functions: Register, Login (Email+Google), OAuth (5 platforms), 2FA, Forgot/Reset/Change Password, OTP Verify, Token Refresh, Sign Out. Per FPT function template.",
     ["Each function: Trigger → Description → Screen Layout → Data → Business Rules → Normal Flow → Abnormal Cases → Post-Conditions",
      "~10 functions total", "JWT RS256, BCrypt=12, OAuth 2.0 flows documented"],
     "docs/feature/auth/*/spec.md, docs/plan/sprints/sprint_05/PLAN.md, docs/api/endpoints/", "DA-D14-01 through DA-D14-04", "Trung", "🔴 Critical"),

    ("D15", "DA-D15-02", "[R3 §3.3]", "Write FR — User & Profile Management",
     "~5 functions: View/Update Profile, Avatar Upload, Identity Verification, Account Deactivation. Per FPT function template.",
     ["Each function: Trigger → Description → Screen Layout → Data → Business Rules → Normal Flow → Abnormal Cases → Post-Conditions",
      "~5 functions total"],
     "docs/plan/sprints/sprint_06/PLAN.md, docs/api/endpoints/", "DA-D14-01 through DA-D14-04", "Trung", "🟡 High"),

    ("D15", "DA-D15-03", "[R3 §3.4]", "Write FR — Workspace Management",
     "~6 functions: Create/Update/Delete Workspace, View/Invite/Remove Members, Multi-tenancy Data Isolation. Per FPT function template.",
     ["Each function: Trigger → Description → Screen Layout → Data → Business Rules → Normal Flow → Abnormal Cases → Post-Conditions",
      "~6 functions total", "Multi-tenancy isolation rules documented"],
     "docs/plan/sprints/sprint_06/PLAN.md, docs/database/DA-E06-08_Database_Access_Rules.md", "DA-D14-01 through DA-D14-04", "Trung", "🟡 High"),

    ("D15", "DA-D15-04", "[R3 §3.5]", "Write FR — RBAC (Role-Based Access Control)",
     "~4 functions: Assign/Revoke Role, View Permissions, Permission Check Middleware. Per FPT function template.",
     ["Each function: Trigger → Description → Screen Layout → Data → Business Rules → Normal Flow → Abnormal Cases → Post-Conditions",
      "~4 functions total", "Permission hierarchy: ADMIN > AGENCY_OWNER > ACCOUNT_MANAGER > CONTENT_CREATOR > BRAND_CLIENT > GUEST"],
     "docs/database/DA-E06-08_Database_Access_Rules.md, docs/plan/sprints/sprint_06/PLAN.md", "DA-D14-01 through DA-D14-04", "Trung", "🟡 High"),

    # D16: FR — Content & Workflow (§3.6-3.10)
    ("D16", "DA-D16-01", "[R3 §3.6]", "Write FR — Content Request Management",
     "~6 functions: Create Content Request, Assign Task to Creator, Track Status, Revise Request, Cancel Request. Per FPT function template.",
     ["Each function: Trigger → Description → Screen Layout → Data → Business Rules → Normal Flow → Abnormal Cases → Post-Conditions",
      "~6 functions total"],
     "docs/plan/sprints/sprint_10/PLAN.md, docs/api/endpoints/", "DA-D14-01 through DA-D14-04", "Lộc", "🟡 High"),

    ("D16", "DA-D16-02", "[R3 §3.7]", "Write FR — Content Calendar & Scheduling",
     "~5 functions: Day/Week/Month Calendar View, Drag-drop Schedule, Recurring Posts Config, Timezone Support. Per FPT function template.",
     ["Each function: Trigger → Description → Screen Layout → Data → Business Rules → Normal Flow → Abnormal Cases → Post-Conditions",
      "~5 functions total"],
     "docs/plan/sprints/sprint_10/PLAN.md, docs/api/endpoints/", "DA-D14-01 through DA-D14-04", "Lộc", "🟡 High"),

    ("D16", "DA-D16-03", "[R3 §3.8]", "Write FR — Approval Workflow",
     "~5 functions: Submit for Review, Approve/Reject with Comments, Revision Loop, Multi-level Approval Chain Config. Per FPT function template.",
     ["Each function: Trigger → Description → Screen Layout → Data → Business Rules → Normal Flow → Abnormal Cases → Post-Conditions",
      "~5 functions total"],
     "docs/plan/sprints/sprint_11/PLAN.md, docs/api/endpoints/", "DA-D14-01 through DA-D14-04", "Lộc", "🟡 High"),

    ("D16", "DA-D16-04", "[R3 §3.9]", "Write FR — Client Portal",
     "~5 functions: Client Login, View Content Calendar, Approve/Reject Content, View Analytics Dashboard, Leave Comments. Per FPT function template.",
     ["Each function: Trigger → Description → Screen Layout → Data → Business Rules → Normal Flow → Abnormal Cases → Post-Conditions",
      "~5 functions total"],
     "docs/plan/sprints/sprint_13/PLAN.md, docs/api/endpoints/", "DA-D14-01 through DA-D14-04", "Lộc", "🟡 High"),

    ("D16", "DA-D16-05", "[R3 §3.10]", "Write FR — Agency & Client Management",
     "~6 functions: CRUD Clients, Assign Account Manager, Client Onboarding Flow, Agency Settings. Per FPT function template.",
     ["Each function: Trigger → Description → Screen Layout → Data → Business Rules → Normal Flow → Abnormal Cases → Post-Conditions",
      "~6 functions total"],
     "docs/plan/sprints/sprint_10/PLAN.md, docs/api/endpoints/", "DA-D14-01 through DA-D14-04", "Lộc", "🟡 High"),

    # D17: FR — AI Features (§3.11-3.16)
    ("D17", "DA-D17-01", "[R3 §3.11]", "Write FR — AI Content Generation",
     "~4 functions: Text Gen (caption, blog, ad copy), Tone/Brand Voice Selection, Anti-Hallucination Guardrails, Generation History. Per FPT function template.",
     ["Each function: Trigger → Description → Screen Layout → Data → Business Rules → Normal Flow → Abnormal Cases → Post-Conditions",
      "~4 functions total", "Groq API integration details"],
     "docs/iterations/README.md, docs/plan/BrandHub_Master_Plan.md (AI01-AI11)", "DA-D14-01 through DA-D14-04", "Tuấn", "🟡 High"),

    ("D17", "DA-D17-02", "[R3 §3.12]", "Write FR — AI Image Generation",
     "~5 functions: Text-to-Image, Style Presets, Brand Asset Integration, Variations, Background Removal. Per FPT function template.",
     ["Each function: Trigger → Description → Screen Layout → Data → Business Rules → Normal Flow → Abnormal Cases → Post-Conditions",
      "~5 functions total", "Stability AI API integration details"],
     "docs/iterations/README.md", "DA-D14-01 through DA-D14-04", "Tuấn", "🟡 High"),

    ("D17", "DA-D17-03", "[R3 §3.13]", "Write FR — AI Video Generation",
     "~4 functions: Script-to-Video, Template Selection, Scene Mapping, Export Format Options. Per FPT function template.",
     ["Each function: Trigger → Description → Screen Layout → Data → Business Rules → Normal Flow → Abnormal Cases → Post-Conditions",
      "~4 functions total", "Google Veo API integration details"],
     "docs/iterations/README.md", "DA-D14-01 through DA-D14-04", "Tuấn", "🟡 High"),

    ("D17", "DA-D17-04", "[R3 §3.14]", "Write FR — Virtual Brand Ambassador",
     "~4 functions: Face Upload, InstantID Setup, Ambassador Video Generation, Ambassador Management Dashboard. Per FPT function template.",
     ["Each function: Trigger → Description → Screen Layout → Data → Business Rules → Normal Flow → Abnormal Cases → Post-Conditions",
      "~4 functions total"],
     "docs/iterations/README.md", "DA-D14-01 through DA-D14-04", "Tuấn", "🟡 High"),

    ("D17", "DA-D17-05", "[R3 §3.15]", "Write FR — RAG Knowledge Base",
     "~5 functions: Document Upload, Auto-chunking, Embedding Generation, Brand Voice Training, Knowledge Search. Per FPT function template.",
     ["Each function: Trigger → Description → Screen Layout → Data → Business Rules → Normal Flow → Abnormal Cases → Post-Conditions",
      "~5 functions total", "ChromaDB + embedding pipeline documented"],
     "docs/iterations/README.md, docs/plan/sprints/sprint_09/PLAN.md", "DA-D14-01 through DA-D14-04", "Tuấn", "🟡 High"),

    ("D17", "DA-D17-06", "[R3 §3.16]", "Write FR — Trend Crawler",
     "~4 functions: Keyword Configuration, Auto-crawl Schedule, Trending Topics Dashboard, Trend-to-Content Brief. Per FPT function template.",
     ["Each function: Trigger → Description → Screen Layout → Data → Business Rules → Normal Flow → Abnormal Cases → Post-Conditions",
      "~4 functions total"],
     "docs/iterations/README.md", "DA-D14-01 through DA-D14-04", "Tuấn", "🟡 High"),

    # D18: FR — Publishing & Social (§3.17-3.23)
    ("D18", "DA-D18-01", "[R3 §3.17]", "Write FR — Social Account Management",
     "~5 functions: Connect Account (OAuth), Disconnect, Token Status Monitoring, Token Refresh, Platform Rate Limit Display. Per FPT function template.",
     ["Each function: Trigger → Description → Screen Layout → Data → Business Rules → Normal Flow → Abnormal Cases → Post-Conditions",
      "~5 functions total", "OAuth flows for 5 platforms documented"],
     "docs/plan/sprints/sprint_07/PLAN.md, docs/api/endpoints/", "DA-D14-01 through DA-D14-04", "Phước", "🟡 High"),

    ("D18", "DA-D18-02", "[R3 §3.18]", "Write FR — Facebook Publishing",
     "~4 functions: Text/Image/Video Post, Carousel Post, Schedule & Preview, Publish Status Tracking. Per FPT function template.",
     ["Each function: Trigger → Description → Screen Layout → Data → Business Rules → Normal Flow → Abnormal Cases → Post-Conditions",
      "~4 functions total", "Facebook Graph API integration details"],
     "docs/plan/sprints/sprint_08/PLAN.md, docs/api/endpoints/", "DA-D14-01 through DA-D14-04", "Phước", "🔴 Critical"),

    ("D18", "DA-D18-03", "[R3 §3.19]", "Write FR — TikTok Publishing",
     "~3 functions: Video Upload with Caption/Hashtags, Schedule, Post Status Tracking. Per FPT function template.",
     ["Each function: Trigger → Description → Screen Layout → Data → Business Rules → Normal Flow → Abnormal Cases → Post-Conditions",
      "~3 functions total", "TikTok Content API integration details"],
     "docs/plan/sprints/sprint_08/PLAN.md, docs/api/endpoints/", "DA-D14-01 through DA-D14-04", "Phước", "🟡 High"),

    ("D18", "DA-D18-04", "[R3 §3.20]", "Write FR — Instagram & Threads Publishing",
     "~4 functions: Image/Reel Post, Carousel Post, Story Post, Thread Post. Per FPT function template.",
     ["Each function: Trigger → Description → Screen Layout → Data → Business Rules → Normal Flow → Abnormal Cases → Post-Conditions",
      "~4 functions total", "Instagram Graph API + Threads API integration"],
     "docs/plan/sprints/sprint_08/PLAN.md, docs/api/endpoints/", "DA-D14-01 through DA-D14-04", "Phước", "🟡 High"),

    ("D18", "DA-D18-05", "[R3 §3.21]", "Write FR — Zalo OA Publishing",
     "~3 functions: Text/Image Broadcast, Template Message, Schedule with Rate Limit Handling. Per FPT function template.",
     ["Each function: Trigger → Description → Screen Layout → Data → Business Rules → Normal Flow → Abnormal Cases → Post-Conditions",
      "~3 functions total", "Zalo OA API integration details"],
     "docs/plan/sprints/sprint_08/PLAN.md, docs/api/endpoints/", "DA-D14-01 through DA-D14-04", "Phước", "🟡 High"),

    ("D18", "DA-D18-06", "[R3 §3.22]", "Write FR — Publish Error Handling & Retry",
     "~4 functions: Auto-Retry (3x exponential backoff), Dead Letter Queue, Error Notifications, Manual Retry Dashboard. Per FPT function template.",
     ["Each function: Trigger → Description → Screen Layout → Data → Business Rules → Normal Flow → Abnormal Cases → Post-Conditions",
      "~4 functions total", "RabbitMQ DLQ pattern documented"],
     "docs/plan/sprints/sprint_11/PLAN.md, docs/api/endpoints/", "DA-D14-01 through DA-D14-04", "Phước", "🟡 High"),

    ("D18", "DA-D18-07", "[R3 §3.23]", "Write FR — Notifications System",
     "~5 functions: In-App Notifications, Email Notifications, Push Notifications (FCM), Notification Preferences, Notification Center UI. Per FPT function template.",
     ["Each function: Trigger → Description → Screen Layout → Data → Business Rules → Normal Flow → Abnormal Cases → Post-Conditions",
      "~5 functions total"],
     "docs/plan/sprints/sprint_13/PLAN.md, docs/api/endpoints/", "DA-D14-01 through DA-D14-04", "Phước", "🟡 High"),

    # D19: FR — Sub, Analytics, Admin, Mobile (§3.24-3.27)
    ("D19", "DA-D19-01", "[R3 §3.24]", "Write FR — Subscription & Billing",
     "~5 functions: Plan Selection (Free/Basic/Pro/Enterprise), Payment Processing, Invoice History, AI Credit Tracking, Upgrade/Downgrade Flow. Per FPT function template.",
     ["Each function: Trigger → Description → Screen Layout → Data → Business Rules → Normal Flow → Abnormal Cases → Post-Conditions",
      "~5 functions total"],
     "docs/plan/sprints/sprint_06/PLAN.md, docs/api/endpoints/", "DA-D14-01 through DA-D14-04", "Ân", "🟡 High"),

    ("D19", "DA-D19-02", "[R3 §3.25]", "Write FR — Analytics & Reporting",
     "~5 functions: Content Performance Dashboard, Platform Analytics, Team Productivity Metrics, Export PDF/Excel, Scheduled Reports. Per FPT function template.",
     ["Each function: Trigger → Description → Screen Layout → Data → Business Rules → Normal Flow → Abnormal Cases → Post-Conditions",
      "~5 functions total"],
     "docs/plan/sprints/sprint_13/PLAN.md, docs/api/endpoints/", "DA-D14-01 through DA-D14-04", "Ân", "🟡 High"),

    ("D19", "DA-D19-03", "[R3 §3.26]", "Write FR — Admin Dashboard",
     "~5 functions: User Management, Content Moderation Queue, System Health Monitoring, Platform Usage Stats, Configuration Management. Per FPT function template.",
     ["Each function: Trigger → Description → Screen Layout → Data → Business Rules → Normal Flow → Abnormal Cases → Post-Conditions",
      "~5 functions total"],
     "docs/plan/sprints/sprint_14/PLAN.md, docs/api/endpoints/", "DA-D14-01 through DA-D14-04", "Ân", "🟡 High"),

    ("D19", "DA-D19-04", "[R3 §3.27]", "Write FR — Mobile App Features",
     "~6 functions: Mobile Auth, Dashboard View, Content Calendar Mobile, Push Notification Handling, Approval on Mobile, Content Preview. Per FPT function template.",
     ["Each function: Trigger → Description → Screen Layout → Data → Business Rules → Normal Flow → Abnormal Cases → Post-Conditions",
      "~6 functions total"],
     "docs/plan/sprints/sprint_14/PLAN.md, docs/api/endpoints/", "DA-D14-01 through DA-D14-04", "Ân", "🟡 High"),

    # D20: NFR & Appendices (§4-5)
    ("D20", "DA-D20-01", "[R3 §4]", "Write Non-Functional Requirements",
     "§4.1 External Interfaces + §4.2 Quality Attributes (Usability, Reliability, Performance, Security, Compatibility, Maintainability, Legal).",
     ["§4.1: Payment Gateway, OAuth Providers, Maps API, FCM, Email/SMS gateways with performance thresholds",
      "§4.2: Usability (≤5 steps, ≤15 min onboarding, WCAG 2.1 AA), Reliability (99.5% uptime, MTTR ≤2h), Performance (<2s page load, <1s search, 1000 concurrent users), Security (JWT RS256, BCrypt=12, AES-256, RBAC, 2FA, audit logs), Compatibility (Chrome/Firefox/Safari/Edge latest 2 versions), Maintainability (≥80% test coverage), Legal (VN data privacy law, PCI DSS compliance)"],
     "docs/architecture/, docs/database/DA-E06-08_Database_Access_Rules.md", "All FR sections (§3.2-§3.27)", "Trung", "🔴 Critical"),

    ("D20", "DA-D20-02", "[R3 §5.1]", "Compile Business Rules Appendix",
     "Compile BR-01 through BR-NN (~70-80 business rules) from all FR sections into single appendix table.",
     ["Format: BR-XX, Rule Definition", "~70-80 rules", "Grouped by feature area",
      "No duplicates, no contradictions", "Cross-referenced to source FR section"],
     "All FR sections (§3.2-§3.27)", "All FR writing tasks complete", "Ân", "🟡 High"),

    ("D20", "DA-D20-03", "[R3 §5.3]", "Compile Message Lists Appendix",
     "Compile MSG01 through MSG-NN (~100-120 application messages) from all FR sections into single appendix table.",
     ["Format: Code, Type (Inline/Toast/In red), Context, Content",
      "~100-120 messages", "English, professional tone, actionable",
      "Grouped by feature area", "Cross-referenced to source FR section"],
     "All FR sections (§3.2-§3.27)", "All FR writing tasks complete", "Ân", "🟡 High"),

    # ═══ PHASE 5: REVIEW, MERGE & SUBMIT ═══

    # D21: Review & Feedback (13 review + 5 fix tasks)
    ("D21", "DA-D21-01", "[R1]", "Review Report 1 — Trung",
     "Cross-check R1 content accuracy, consistency, completeness against documentation.",
     ["Read entire R1 report (~10-15 pages)", "Check: technical accuracy (matches docs repo), terminology consistency, section completeness",
      "Log all feedback to tracking sheet", "Critical: wrong technical facts, missing features", "Minor: typo, format, wording"],
     "docs repo (all feature specs, architecture docs)", "All R1 writing tasks (D05-D07) complete", "Trung", "🔴 Critical"),

    ("D21", "DA-D21-02", "[R1]", "Review Report 1 — Lộc",
     "Cross-check R1 content accuracy, consistency, completeness against documentation.",
     ["Read entire R1 report", "Check: accuracy, consistency, completeness", "Log feedback to tracking sheet"],
     "docs repo", "All R1 writing tasks complete", "Lộc", "🔴 Critical"),

    ("D21", "DA-D21-03", "[R1]", "Review Report 1 — Tuấn",
     "Cross-check R1 content accuracy, consistency, completeness against documentation.",
     ["Read entire R1 report", "Check: accuracy, consistency, completeness", "Log feedback to tracking sheet"],
     "docs repo", "All R1 writing tasks complete", "Tuấn", "🔴 Critical"),

    ("D21", "DA-D21-04", "[R1]", "Review Report 1 — Ân",
     "Cross-check R1 content accuracy, consistency, completeness against documentation.",
     ["Read entire R1 report", "Check: accuracy, consistency, completeness", "Log feedback to tracking sheet"],
     "docs repo", "All R1 writing tasks complete", "Ân", "🔴 Critical"),

    ("D21", "DA-D21-05", "[R2]", "Review Report 2 — Trung",
     "Verify WBS matches Jira actuals, man-day estimates realistic, management plan complete.",
     ["Read entire R2 report (~15-20 pages)", "WBS ↔ Jira cross-check: every epic accounted for",
      "Man-day totals realistic vs actuals", "Log feedback to tracking sheet"],
     "Jira (all epics/tasks), docs repo", "All R2 writing tasks (D08-D11) complete", "Trung", "🔴 Critical"),

    ("D21", "DA-D21-06", "[R2]", "Review Report 2 — Phước",
     "Verify WBS matches Jira actuals, man-day estimates realistic, management plan complete.",
     ["Read entire R2 report", "WBS ↔ Jira cross-check", "Man-day realism", "Log feedback to tracking sheet"],
     "Jira, docs repo", "All R2 writing tasks complete", "Phước", "🔴 Critical"),

    ("D21", "DA-D21-07", "[R2]", "Review Report 2 — Tuấn",
     "Verify WBS matches Jira actuals, man-day estimates realistic, management plan complete.",
     ["Read entire R2 report", "WBS ↔ Jira cross-check", "Man-day realism", "Log feedback to tracking sheet"],
     "Jira, docs repo", "All R2 writing tasks complete", "Tuấn", "🔴 Critical"),

    ("D21", "DA-D21-08", "[R2]", "Review Report 2 — Ân",
     "Verify WBS matches Jira actuals, man-day estimates realistic, management plan complete.",
     ["Read entire R2 report", "WBS ↔ Jira cross-check", "Man-day realism", "Log feedback to tracking sheet"],
     "Jira, docs repo", "All R2 writing tasks complete", "Ân", "🔴 Critical"),

    ("D21", "DA-D21-09", "[R3]", "Review Report 3 — Trung",
     "Verify FR descriptions match implementation, UC flows consistent, screen flows match Figma.",
     ["Read entire R3 report (~150-180 pages)", "FR ↔ actual implementation cross-check",
      "UC descriptions match screen flows", "Screen flows consistent with Figma wireframes",
      "Business rules consistent across sections", "Log feedback to tracking sheet"],
     "Figma, docs repo, source code", "All R3 writing tasks (D12-D20) complete", "Trung", "🔴 Critical"),

    ("D21", "DA-D21-10", "[R3]", "Review Report 3 — Lộc",
     "Verify FR descriptions match implementation, UC flows consistent, screen flows match Figma.",
     ["Read entire R3 report", "FR ↔ implementation cross-check", "UC ↔ screen flow consistency",
      "Figma consistency", "Log feedback to tracking sheet"],
     "Figma, docs repo, source code", "All R3 writing tasks complete", "Lộc", "🔴 Critical"),

    ("D21", "DA-D21-11", "[R3]", "Review Report 3 — Phước",
     "Verify FR descriptions match implementation, UC flows consistent, screen flows match Figma.",
     ["Read entire R3 report", "FR ↔ implementation cross-check", "UC ↔ screen flow consistency",
      "Figma consistency", "Log feedback to tracking sheet"],
     "Figma, docs repo, source code", "All R3 writing tasks complete", "Phước", "🔴 Critical"),

    ("D21", "DA-D21-12", "[R3]", "Review Report 3 — Tuấn",
     "Verify FR descriptions match implementation, UC flows consistent, screen flows match Figma.",
     ["Read entire R3 report", "FR ↔ implementation cross-check", "UC ↔ screen flow consistency",
      "Figma consistency", "Log feedback to tracking sheet"],
     "Figma, docs repo, source code", "All R3 writing tasks complete", "Tuấn", "🔴 Critical"),

    ("D21", "DA-D21-13", "[R3]", "Review Report 3 — Ân",
     "Verify FR descriptions match implementation, UC flows consistent, screen flows match Figma.",
     ["Read entire R3 report", "FR ↔ implementation cross-check", "UC ↔ screen flow consistency",
      "Figma consistency", "Log feedback to tracking sheet"],
     "Figma, docs repo, source code", "All R3 writing tasks complete", "Ân", "🔴 Critical"),

    ("D21", "DA-D21-14", "", "Address Review Feedback — Trung (Coordinate)",
     "Trung consolidates all 13 reviewers' feedback, assigns fix tasks to responsible members, tracks resolution progress.",
     ["All 13 reviewers' feedback consolidated into single tracking sheet",
      "Fix tasks assigned to appropriate members per section ownership",
      "All critical issues resolved before merge", "Progress tracked daily"],
     "Review feedback from DA-D21-01 through DA-D21-13", "DA-D21-01 through DA-D21-13 complete", "Trung", "🔴 Critical"),

    ("D21", "DA-D21-15", "", "Address Review Feedback — Lộc",
     "Fix all issues in sections Lộc is responsible for (R1 §2-3, R3 §2.2 Admin/AO UCs, R3 §3.1 screens, R3 §3.6-3.10 FR).",
     ["All critical issues in Lộc's sections resolved", "Minor issues resolved or documented with reason",
      "Tracking sheet updated with fix status"],
     "Consolidated feedback from DA-D21-14", "DA-D21-14 complete", "Lộc", "🔴 Critical"),

    ("D21", "DA-D21-16", "", "Address Review Feedback — Phước",
     "Fix all issues in sections Phước is responsible for (R2 §2-3, R2 §5-6, R3 §3.1 screens, R3 §3.17-3.23 FR).",
     ["All critical issues in Phước's sections resolved", "Minor issues resolved or documented with reason",
      "Tracking sheet updated with fix status"],
     "Consolidated feedback from DA-D21-14", "DA-D21-14 complete", "Phước", "🔴 Critical"),

    ("D21", "DA-D21-17", "", "Address Review Feedback — Tuấn",
     "Fix all issues in sections Tuấn is responsible for (R1 §4-5, R3 §2.1 actors, R3 §2.2 AC/CC/BC/Guest UCs, R3 §3.1 screens, R3 §3.11-3.16 FR).",
     ["All critical issues in Tuấn's sections resolved", "Minor issues resolved or documented with reason",
      "Tracking sheet updated with fix status"],
     "Consolidated feedback from DA-D21-14", "DA-D21-14 complete", "Tuấn", "🔴 Critical"),

    ("D21", "DA-D21-18", "", "Address Review Feedback — Ân",
     "Fix all issues in sections Ân is responsible for (R1 §6-7, R2 §4, R2 §6.3, R3 §3.24-3.27 FR, R3 §5 appendices).",
     ["All critical issues in Ân's sections resolved", "Minor issues resolved or documented with reason",
      "Tracking sheet updated with fix status"],
     "Consolidated feedback from DA-D21-14", "DA-D21-14 complete", "Ân", "🔴 Critical"),

    # D22: Merge & Format
    ("D22", "DA-D22-01", "[R1]", "Merge Report 1",
     "Combine all R1 sections into single document. Generate TOC, Record of Changes, sequential numbering, cross-references.",
     ["All sections combined in correct order per FPT template",
      "Auto-generated Table of Contents", "Record of Changes filled",
      "Sequential figure/table numbering", "Cross-reference links verified",
      "Page numbers, header/footer consistent"],
     "All R1 sections from D05-D07", "DA-D21-14 through DA-D21-18 complete", "Trung", "🔴 Critical"),

    ("D22", "DA-D22-02", "[R2]", "Merge Report 2",
     "Combine all R2 sections into single document. Generate TOC, Record of Changes, sequential numbering, cross-references.",
     ["All sections combined in correct order per FPT template",
      "Auto-generated Table of Contents", "Record of Changes filled",
      "Sequential figure/table numbering", "Cross-reference links verified",
      "Page numbers, header/footer consistent"],
     "All R2 sections from D08-D11", "DA-D21-14 through DA-D21-18 complete", "Trung", "🔴 Critical"),

    ("D22", "DA-D22-03", "[R3]", "Merge Report 3",
     "Combine all R3 sections into single document (~180 pages). Generate TOC, Record of Changes, sequential numbering, cross-references.",
     ["All sections combined in correct order per FPT template",
      "Auto-generated Table of Contents", "Record of Changes filled",
      "Sequential figure/table numbering across all sections",
      "Cross-reference links verified (FR ↔ UC ↔ Screen Flow ↔ ERD)",
      "Page numbers, header/footer consistent"],
     "All R3 sections from D12-D20", "DA-D21-14 through DA-D21-18 complete", "Trung", "🔴 Critical"),

    ("D22", "DA-D22-04", "", "Final Format Check (All 3 Reports)",
     "Format consistency audit across all 3 reports: fonts, spacing, captions, spelling, cross-references, PDF bookmarks.",
     ["Font, size, line spacing, margins identical across R1/R2/R3",
      "Figure/table captions correct format", "English spelling & grammar check (Grammarly/Manual)",
      "All cross-references resolve correctly", "PDF output: bookmarks, clickable TOC, proper metadata"],
     "Merged R1, R2, R3 documents", "DA-D22-01 through DA-D22-03 complete", "Trung", "🔴 Critical"),

    # D23: Final Package & Submission
    ("D23", "DA-D23-01", "", "Prepare Final Submission Package",
     "Package all 3 reports into final submission: PDFs + source files → Google Drive → naming per FPT format.",
     ["3 PDFs + source docx files", "Upload to Google Drive 'Final Submission' folder",
      "File naming: SEP490_Report[N]_BrandHub_[Date].pdf per FPT convention",
      "Final check: all files openable, no corruption"],
     "Final R1, R2, R3 documents", "DA-D22-04 complete", "Trung", "🔴 Critical"),

    ("D23", "DA-D23-02", "", "Prepare Presentation Summary",
     "Create 5-8 slide summary covering key points from all 3 reports for Aug 28 defense presentation.",
     ["5-8 slides", "R1 summary (1-2 slides): Problem → Existing Solutions → Vision → Scope",
      "R2 summary (1-2 slides): Timeline → Team → Methodology → Deliverables",
      "R3 summary (2-3 slides): Key Features → Architecture → Tech Highlights → Demo screenshots",
      "Consistent branding, professional design"],
     "Final R1, R2, R3 documents", "DA-D23-01 complete", "Trung", "🟡 High"),
]

# ── MAIN ──

def main():
    # Fix cp1252 encoding issue on Windows
    import io
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
    print("=" * 70)
    print("BRANDHUB — CREATE DOCUMENT EPICS & TASKS ON JIRA")
    print(f"Source: Document_Plan.md | 23 Epics | {len(TASKS)} Tasks")
    if DRY_RUN: print("*** DRY RUN — no API calls ***")
    if EPICS_ONLY: print("*** EPICS ONLY ***")
    if TASKS_ONLY: print("*** TASKS ONLY ***")
    if PHASE_FILTER: print(f"*** PHASE {PHASE_FILTER} ONLY ***")
    print("=" * 70)

    results = {"epics": {}, "tasks": [], "errors": []}

    # If tasks-only, reload epic keys from saved JSON
    if TASKS_ONLY and os.path.exists(OUTPUT_FILE):
        with open(OUTPUT_FILE, "r", encoding="utf-8") as f:
            saved = json.load(f)
            results["epics"] = saved.get("epics", {})
            print(f"\n  Loaded {len(results['epics'])} epic keys from previous run")

    # Step 1: Epics
    if not TASKS_ONLY:
        print("\n── STEP 1: Creating Epics ──")
        for epic_id, epic_title, phase in EPICS:
            if PHASE_FILTER and phase != PHASE_FILTER:
                continue
            epic_tasks = [t for t in TASKS if t[0] == epic_id]
            epic_assignees = set(t[8] for t in epic_tasks)
            desc = build_epic_desc(epic_title, phase, len(epic_tasks), epic_assignees)
            key = create_epic(epic_title, desc)
            if key:
                results["epics"][epic_id] = {"key": key, "title": epic_title}
                print(f"  ✅ {epic_id} → {key} ({len(epic_tasks)} tasks)")
            else:
                results["errors"].append(f"Epic {epic_id} creation failed")
            time.sleep(0.3)

    # Step 2: Tasks
    if not EPICS_ONLY:
        print(f"\n── STEP 2: Creating Tasks ({len(TASKS)} total) ──")
        created = 0
        for i, t in enumerate(TASKS):
            epic_id, task_id, section, title, goal, ac_list, source, deps, assignee, priority = t

            epic_phase = next((p for e, _, p in EPICS if e == epic_id), None)
            if PHASE_FILTER and epic_phase != PHASE_FILTER:
                continue

            epic_info = results["epics"].get(epic_id)
            if not epic_info:
                print(f"  ⚠️ {task_id}: Epic {epic_id} not found — skip")
                results["errors"].append(f"Task {task_id}: epic {epic_id} not created")
                continue

            epic_key = epic_info["key"]
            assignee_id = ASSIGNEES.get(assignee)
            if not assignee_id:
                print(f"  ❌ {task_id}: Unknown assignee '{assignee}'")
                results["errors"].append(f"Task {task_id}: unknown assignee {assignee}")
                continue

            full_section = f"{section} {title}" if section else title
            summary = f"[{task_id}] {full_section}"
            desc = build_task_desc(full_section, goal, ac_list, source, deps, assignee, priority)
            key = create_task(summary, desc, epic_key, assignee_id)

            if key:
                results["tasks"].append({"task_id": task_id, "jira_key": key, "epic": epic_id, "assignee": assignee})
                created += 1
                print(f"  [{created}/{len(TASKS)}] ✅ {task_id} → {key} ({assignee})")
            else:
                results["errors"].append(f"Task {task_id} creation failed")

            time.sleep(0.25)

    # Step 3: Save
    print(f"\n── STEP 3: Saving Results ──")
    os.makedirs(os.path.dirname(OUTPUT_FILE), exist_ok=True)
    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        json.dump(results, f, ensure_ascii=False, indent=2)
    print(f"  JSON: {OUTPUT_FILE}")

    # Tracking markdown
    lines = [
        "# BrandHub — Document Tasks Jira Upload Tracking",
        f"> Generated: {time.strftime('%Y-%m-%d %H:%M')}",
        f"> **{len(results['epics'])} Epics | {len(results['tasks'])} Tasks**",
        "", "---", "", "## Epics", "",
    ]
    for eid in sorted(results["epics"].keys(), key=lambda x: int(x[1:])):
        info = results["epics"][eid]
        url = f"https://letritrung2605.atlassian.net/browse/{info['key']}"
        lines.append(f"- [ ] **EPIC {eid}** — [{info['key']}]({url}) — {info['title']}")

    lines += ["", "---", "", "## Tasks by Epic", ""]
    cur = None
    for t in results["tasks"]:
        if t["epic"] != cur:
            cur = t["epic"]
            ei = results["epics"].get(cur, {})
            ek = ei.get("key", "?")
            lines.append(f"### EPIC {cur} — [{ek}](https://letritrung2605.atlassian.net/browse/{ek})")
            lines.append("")
        url = f"https://letritrung2605.atlassian.net/browse/{t['jira_key']}"
        lines.append(f"- [ ] `{t['task_id']}` — [{t['jira_key']}]({url}) — {t['assignee']}")

    if results["errors"]:
        lines += ["", "---", "", "## Errors", ""]
        for e in results["errors"]:
            lines.append(f"- ❌ {e}")

    with open(TRACKING_FILE, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))
    print(f"  Tracking: {TRACKING_FILE}")

    # Summary
    print(f"\n{'=' * 70}")
    print(f"SUMMARY: {len(results['epics'])}/23 epics | {len(results['tasks'])}/{len(TASKS)} tasks | {len(results['errors'])} errors")
    if results["errors"]:
        for e in results["errors"]:
            print(f"  ❌ {e}")
    print(f"{'=' * 70}")

if __name__ == "__main__":
    main()
