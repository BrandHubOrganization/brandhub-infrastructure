#!/usr/bin/env python3
"""Fix: recreate 15 tasks that failed due to wrong An account ID (c342 -> c942)."""
import json, urllib.request, urllib.error, base64, time, sys, io, os
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

EMAIL = "letritrung2605@gmail.com"
TOKEN = "ATATT3xFfGF0hOu_QP0K9NHqnGgsrxko4pKSzqkTXX2nm1YWWBm-g9KGqEEe0h1h90vbBdEskz9EoWDc3s2sB3WMnqNedf2RzztO0R0FwLqNs4vIotf4_r9kajvHL4p9G7W9PF_Z3qCkZP_21vJPbmbiul8PkiEdjpwr0AY3Cbt6O0nft6dvDtQ=080C74FD"
AUTH = base64.b64encode(f"{EMAIL}:{TOKEN}".encode()).decode()
JIRA_API = "https://letritrung2605.atlassian.net/rest/api/3/issue"
AN_ID = "712020:b501eda5-2140-417d-bc3a-c942db8310cc"

# Sequential D01=DA-615 through D23=DA-637
EPIC_KEYS = {f"D{i:02d}": f"DA-{614+i}" for i in range(1, 24)}

MISSING = [
    ("D07", "DA-D07-01", "[R1 §6.1] Write Project Scope & Major Features",
     "List ~22 feature groups with sub-features (FE-01 to FE-NN).",
     ["~22 feature groups covering all BrandHub capabilities", "Format: FE-XX: Feature Name", "Match all 46 epics"],
     "docs/plan/BrandHub_Master_Plan.md", "DA-D02-01"),
    ("D07", "DA-D07-02", "[R1 §6.2] Write Limitations & Exclusions",
     "BrandHub scope boundary with 5-7 limitations (LI-01 to LI-07).",
     ["5-7 limitations clearly stated", "Each with short explanation"],
     "N/A", "DA-D07-01"),
    ("D07", "DA-D07-03", "[R1 §7] Compile References",
     "Compile 5-10 references/citations for Report 1.",
     ["5-10 references", "Consistent citation format"],
     "N/A", "DA-D05-01 through DA-D07-02"),
    ("D11", "DA-D11-02", "[R2 §4] Write Responsibility Assignments (D/R/S/I Matrix)",
     "D/R/S/I matrix: 5 members x 15-20 work items.",
     ["D=Do, R=Review, S=Support, I=Informed", "15-20 work items x 5 members"],
     "docs/plan/BrandHub_Master_Plan.md", "DA-D08-01"),
    ("D11", "DA-D11-03", "[R2 §6.3] Write Tools & Infrastructures Table",
     "Comprehensive tools table for R2 §6.3.",
     ["Categories: Technology, Database, IDEs, Diagramming, Documentation, Version Control, Deployment, PM, AI/ML", "Tool name + version + purpose"],
     "N/A", "None"),
    ("D19", "DA-D19-01", "[R3 §3.24] Write FR — Subscription & Billing",
     "~5 functions: Plan Selection, Payment, Invoice History, AI Credit Tracking, Upgrade/Downgrade.",
     ["Each: Trigger, Description, Screen Layout, Data, Business Rules, Normal Flow, Abnormal Cases, Post-Conditions", "~5 functions"],
     "docs/plan/sprints/sprint_06/PLAN.md", "DA-D14-01 through DA-D14-04"),
    ("D19", "DA-D19-02", "[R3 §3.25] Write FR — Analytics & Reporting",
     "~5 functions: Content Performance, Platform Analytics, Team Productivity, Export PDF/Excel, Scheduled Reports.",
     ["Each: full function template", "~5 functions"],
     "docs/plan/sprints/sprint_13/PLAN.md", "DA-D14-01 through DA-D14-04"),
    ("D19", "DA-D19-03", "[R3 §3.26] Write FR — Admin Dashboard",
     "~5 functions: User Management, Content Moderation, System Health, Platform Stats.",
     ["Each: full function template", "~5 functions"],
     "docs/plan/sprints/sprint_14/PLAN.md", "DA-D14-01 through DA-D14-04"),
    ("D19", "DA-D19-04", "[R3 §3.27] Write FR — Mobile App Features",
     "~6 functions: Mobile Auth, Dashboard, Calendar, Push, Approval, Content Preview.",
     ["Each: full function template", "~6 functions"],
     "docs/plan/sprints/sprint_14/PLAN.md", "DA-D14-01 through DA-D14-04"),
    ("D20", "DA-D20-02", "[R3 §5.1] Compile Business Rules Appendix",
     "Compile BR-01 through BR-NN (~70-80 business rules) from all FR sections.",
     ["~70-80 rules", "Format: BR-XX, Rule Definition", "Grouped by feature", "No duplicates"],
     "All FR sections", "All FR writing tasks complete"),
    ("D20", "DA-D20-03", "[R3 §5.3] Compile Message Lists Appendix",
     "Compile MSG01 through MSG-NN (~100-120 application messages).",
     ["~100-120 messages", "Format: Code, Type, Context, Content", "English, professional"],
     "All FR sections", "All FR writing tasks complete"),
    ("D21", "DA-D21-04", "[R1] Review Report 1 — An",
     "Cross-check R1 content accuracy, consistency, completeness.",
     ["Read entire R1 report", "Check: accuracy, consistency, completeness", "Log feedback to tracking sheet"],
     "docs repo", "All R1 writing tasks complete"),
    ("D21", "DA-D21-08", "[R2] Review Report 2 — An",
     "Verify WBS matches Jira actuals, man-day estimates realistic.",
     ["Read entire R2 report", "WBS-Jira cross-check", "Man-day realism", "Log feedback to tracking sheet"],
     "Jira, docs repo", "All R2 writing tasks complete"),
    ("D21", "DA-D21-13", "[R3] Review Report 3 — An",
     "Verify FR matches implementation, UC flows consistent, screen flows match Figma.",
     ["Read entire R3 report", "FR-implementation cross-check", "UC-screen flow consistency", "Log feedback to tracking sheet"],
     "Figma, docs repo, source code", "All R3 writing tasks complete"),
    ("D21", "DA-D21-18", "Address Review Feedback — An",
     "Fix issues in An's sections: R1 §6-7, R2 §4, R2 §6.3, R3 §3.24-3.27, R3 §5.",
     ["All critical issues resolved", "Minor issues resolved or documented", "Tracking sheet updated"],
     "Consolidated feedback", "DA-D21-14 complete"),
]

def adf_p(text):
    return {"type": "paragraph", "content": [{"type": "text", "text": text}]}

def adf_h(level, text):
    return {"type": "heading", "attrs": {"level": level}, "content": [{"type": "text", "text": text}]}

def adf_list(items):
    return {"type": "bulletList", "content": [{"type": "listItem", "content": [{"type": "paragraph", "content": [{"type": "text", "text": i}]}]} for i in items]}

def adf_doc(content):
    return {"type": "doc", "version": 1, "content": content}

created = 0
failed = []

for epic_id, task_id, summary_title, goal, ac_list, source, deps in MISSING:
    epic_key = EPIC_KEYS.get(epic_id)
    if not epic_key:
        print(f"SKIP {task_id}: no epic key")
        continue

    desc = adf_doc([
        adf_h(2, summary_title),
        adf_p("👤 Ân"),
        adf_h(3, "🎯 Goal"),
        adf_p(goal),
        adf_h(3, "✅ Acceptance Criteria"),
        adf_list(ac_list),
        adf_h(3, "📚 Source References"),
        adf_p(source),
        adf_h(3, "🔗 Dependencies"),
        adf_p(deps),
    ])

    summary = f"[{task_id}] {summary_title}"
    body = {"fields": {"project": {"key": "DA"}, "summary": summary,
            "description": desc, "issuetype": {"id": "10045"},
            "parent": {"key": epic_key}, "assignee": {"id": AN_ID}}}
    data = json.dumps(body).encode()
    req = urllib.request.Request(JIRA_API, data=data, method="POST")
    req.add_header("Authorization", f"Basic {AUTH}")
    req.add_header("Content-Type", "application/json")
    try:
        with urllib.request.urlopen(req) as resp:
            result = json.loads(resp.read().decode())
            key = result.get("key")
            print(f"✅ {task_id} → {key}")
            created += 1
    except urllib.error.HTTPError as e:
        err = e.read().decode()[:300]
        print(f"❌ {task_id} FAILED [{e.code}]: {err}")
        failed.append(task_id)
    time.sleep(0.25)

print(f"\nDone: {created}/{len(MISSING)} created, {len(failed)} failed")
