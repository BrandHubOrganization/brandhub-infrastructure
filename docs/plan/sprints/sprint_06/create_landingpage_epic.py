#!/usr/bin/env python3
"""
Create Epic E37 — Public Landing Page + 9 tasks on Jira.

The landing page was already built (commit c697568, mistakenly tagged DA-305
instead of DA-407). This script creates a proper epic with full task breakdown
covering every section/feature of the landing page.

Usage: python create_landingpage_epic.py
"""

import json, urllib.request, urllib.error, base64, sys

EMAIL = "letritrung2605@gmail.com"
TOKEN = "ATATT3xFfGF0hOu_QP0K9NHqnGgsrxko4pKSzqkTXX2nm1YWWBm-g9KGqEEe0h1h90vbBdEskz9EoWDc3s2sB3WMnqNedf2RzztO0R0FwLqNs4vIotf4_r9kajvHL4p9G7W9PF_Z3qCkZP_21vJPbmbiul8PkiEdjpwr0AY3Cbt6O0nft6dvDtQ=080C74FD"
JIRA_API = "https://letritrung2605.atlassian.net/rest/api/3/issue"
AUTH = base64.b64encode(f"{EMAIL}:{TOKEN}".encode()).decode()

ASSIGNEE_TRUNG = "61bc48ad08e4e00069b20d6c"
EPIC_TYPE = "10048"
TASK_TYPE = "10045"
PROJECT_KEY = "DA"

# ── ADF helpers ──

def adf_heading(level, text):
    return {"type": "heading", "attrs": {"level": level}, "content": [{"type": "text", "text": text}]}

def adf_para(text):
    return {"type": "paragraph", "content": [{"type": "text", "text": text}]}

def adf_list(items):
    return {
        "type": "bulletList",
        "content": [
            {"type": "listItem", "content": [{"type": "paragraph", "content": [{"type": "text", "text": item}]}]}
            for item in items
        ]
    }

def build_description(title, assignee_priority, goal, acceptance_criteria, technical_notes, dependencies):
    content = [
        adf_heading(3, title),
        adf_para(assignee_priority),
        adf_heading(4, "Goal"),
        adf_para(goal),
        adf_heading(4, "Acceptance Criteria"),
        adf_list(acceptance_criteria),
        adf_heading(4, "Technical Notes"),
    ]
    for note in technical_notes:
        content.append(adf_para(note))
    content.append(adf_heading(4, "Dependencies"))
    content.append(adf_para(dependencies))
    return {"type": "doc", "version": 1, "content": content}

# ── API helpers ──

def api_call(method, url, body=None):
    """Make a Jira API call. Returns (status_code, response_body)."""
    data = json.dumps(body).encode() if body else None
    req = urllib.request.Request(url, data=data, method=method)
    req.add_header("Authorization", f"Basic {AUTH}")
    req.add_header("Content-Type", "application/json")
    try:
        with urllib.request.urlopen(req) as resp:
            return resp.status, json.loads(resp.read().decode())
    except urllib.error.HTTPError as e:
        err = e.read().decode()[:500]
        return e.code, {"error": err}

def create_epic(summary, description):
    """Create an Epic issue. Returns the epic key or None."""
    body = {
        "fields": {
            "project": {"key": PROJECT_KEY},
            "summary": summary,
            "description": description,
            "issuetype": {"id": EPIC_TYPE},
        }
    }
    status, resp = api_call("POST", JIRA_API, body)
    if status in (200, 201):
        key = resp.get("key")
        print(f"  Epic created: {key} — {summary}")
        return key
    else:
        print(f"  ERROR creating epic: HTTP {status}: {resp.get('error', resp)}")
        return None

def create_task(summary, description, epic_key, assignee_id=None):
    """Create a Task under an epic. Returns the task key or None."""
    body = {
        "fields": {
            "project": {"key": PROJECT_KEY},
            "summary": summary,
            "description": description,
            "issuetype": {"id": TASK_TYPE},
            "parent": {"key": epic_key},
        }
    }
    if assignee_id:
        body["fields"]["assignee"] = {"id": assignee_id}
    status, resp = api_call("POST", JIRA_API, body)
    if status in (200, 201):
        key = resp.get("key")
        print(f"  Task created: {key} — {summary}")
        return key
    else:
        print(f"  ERROR creating task: HTTP {status}: {resp.get('error', resp)}")
        return None

# ── Epic description ──

EPIC_DESC = build_description(
    "E37 — Public Landing Page",
    "Assignee: Trung (Leader) | Priority: Critical",
    "Deliver a full public landing page for unauthenticated users (GUEST role). "
    "The landing page is the first touchpoint — it sells BrandHub before login. "
    "Includes cinematic hero animation, feature showcase, social proof, pricing, and conversion CTAs. "
    "All sections fully internationalized (EN + VI) with scroll-driven animations.",
    [
        "Landing page renders for unauthenticated users at / (root route)",
        "11 sections: Hero, LogoWall, Features, Stats, HowItWorks, Templates, Testimonials, Pricing, FAQ, CTA, Footer",
        "Cinematic hero: GSAP scroll-driven animation (IG→TT→FB→LI→BrandHub MacBook reveal→CTA)",
        "All text content sourced from i18n keys — ready for EN + VI translation",
        "Authenticated users are redirected away from landing page to their role-based dashboard",
        "Responsive layout — all sections adapt to mobile/tablet/desktop",
        "CTA buttons (Register / Login) navigate to /register and /login routes",
        "Stats counter animates from 0 to target on first scroll into view",
        "FAQ accordion with smooth expand/collapse animation",
        "Pricing section highlights recommended Pro plan",
    ],
    [
        "Landing page is NOT part of the original 46-epic plan — it was built as a phat sinh task (originally DA-407 under E08 with wrong prefix DA-E010-07).",
        "This epic formalizes the work into proper task breakdown matching what was actually built.",
        "All 9 tasks below represent work already completed — status should be set to Done.",
        "Code location: brandhub-web-dashboard/src/components/landing/",
        "Entry point: brandhub-web-dashboard/src/pages/DashboardPage.tsx (guest vs authenticated routing)",
        "Uses GSAP (ScrollTrigger) for cinematic hero + framer-motion for other section animations",
        "Uses react-i18next for all text strings",
    ],
    "Blocks: — (landing page is self-contained). Blocked by: DA-E34-02, DA-E34-03, DA-E34-04, DA-E34-05 (Design System foundation), DA-E35-01 (Login page — for CTA link target)."
)

# ── 9 Task definitions ──

TASKS = [
    {
        "summary": "[DA-E37-01] Build Cinematic Hero section (GSAP scroll animation: 4 platform posts → BrandHub MacBook reveal → CTA)",
        "title": "DA-E37-01 — Build Cinematic Hero section",
        "assignee_priority": "Assignee: Trung (Leader) | Priority: Critical",
        "goal": "Deliver the hero section — a scroll-driven cinematic animation that walks through 4 social media platform posts (Instagram, TikTok, Facebook, LinkedIn) before revealing the BrandHub dashboard on a MacBook Air mockup, ending with Register/Login CTAs.",
        "criteria": [
            "GSAP ScrollTrigger timeline: Instagram post (0-15% scroll) → TikTok (15-35%) → Facebook (35-55%) → LinkedIn (55-75%) → BrandHub reveal (75-90%) → CTA buttons (90-100%)",
            "4 platform post components: InstagramPost, TikTokPost, FacebookPost, LinkedInPost — each a realistic social media card with platform-specific styling",
            "BrandHub dashboard background: MacBook Air M5 aluminum chassis, macOS Sonoma wallpaper, menubar with Apple logo + clock, Safari browser window with 4 interactive dashboard tabs (Overview, Content, Schedule, Analytics)",
            "Safari Overview tab: KPI cards + animated bar chart + top channel activity bars",
            "Safari Content tab: searchable post list with status badges + Create Post button interaction",
            "Safari Schedule tab: calendar grid (August 2026) with selectable dates + daily timeline",
            "Safari Analytics tab: stat cards + animated SVG line chart + channel distribution bars",
            "macOS Dock: 12 app icons rendered as inline SVG glyphs",
            "Mini posts in 4 corners after reveal — scale/fade in with staggered back.out easing, idle drift animation (yoyo sine)",
            "CTA buttons: Register + Login with Rocket icon",
            "Timeline locks forward-only after completion — scroll-back does NOT reverse",
        ],
        "notes": [
            "GSAP ScrollTrigger with pin: section pinned for 3500px scroll distance, scrub: 1",
            "Each platform post component ~100-160 lines with realistic layouts",
            "Safari tabs use useState-driven page switching — clicking tabs changes content",
            "MacBook bezel includes notch, traffic-light buttons, address bar",
            "Idle animation: 4 corner mini-cards drift +/-6px out of phase (0s/0.4s/0.8s/1.2s delays)",
        ],
        "deps": "Blocks: —. Blocked by: DA-E34-02 (design tokens), DA-E34-03 (shadcn/ui setup)."
    },
    {
        "summary": "[DA-E37-02] Build Features section (6 feature cards with icons, hover effects, scroll animations)",
        "title": "DA-E37-02 — Build Features section",
        "assignee_priority": "Assignee: Trung (Leader) | Priority: High",
        "goal": "Deliver a 6-card feature grid showcasing BrandHub core capabilities with Lucide icons, orange accent hover states, and scroll-triggered fade-in animations.",
        "criteria": [
            "6 feature cards: Planning, Creation, Publishing, Analytics, Collaboration, Automation — responsive grid (1/2/3 cols)",
            "Each card: orange icon container, title, description — all from i18n keys",
            "Hover: border orange-200, bg orange-50/30, shadow-lg, icon scale 110%",
            "Scroll-triggered: cards fade in + slide up (y:32→0) with staggered 80ms delay",
            "Dark mode: border zinc-800, bg zinc-900/50",
        ],
        "notes": [
            "Uses framer-motion whileInView with once:true",
        ],
        "deps": "Blocks: —. Blocked by: DA-E34-02 (design tokens), DA-E37-01 (page structure)."
    },
    {
        "summary": "[DA-E37-03] Build How It Works section (4-step timeline with alternating layout, scroll slide-in)",
        "title": "DA-E37-03 — Build How It Works section",
        "assignee_priority": "Assignee: Trung (Leader) | Priority: High",
        "goal": "Deliver a 4-step 'How It Works' timeline: Plan → Create → Schedule → Publish, with alternating left/right card layout on desktop.",
        "criteria": [
            "4 steps with numbered orange circles connected by vertical timeline line",
            "Desktop: alternating layout — odd steps left, even steps right",
            "Mobile: all cards left-aligned, line on left edge",
            "Each step: colored icon, title, description",
            "Scroll: cards slide in from left/right (x: +/-40→0) with 100ms stagger",
        ],
        "notes": [
            "Connecting line: absolute div, 0.5px wide, hidden on mobile",
        ],
        "deps": "Blocks: —. Blocked by: DA-E34-02 (design tokens)."
    },
    {
        "summary": "[DA-E37-04] Build Stats Counter + LogoWall sections (animated count-up + 12 trusted-by brand logos)",
        "title": "DA-E37-04 — Build Stats Counter + LogoWall sections",
        "assignee_priority": "Assignee: Trung (Leader) | Priority: Medium",
        "goal": "Deliver social proof: animated stat counters (1.2M+ contents, 50K+ brands, 12 platforms, 99.9% uptime) + logo wall of 12 brand names.",
        "criteria": [
            "Stats: 4 counters on brand-orange bg — contents, brands, platforms, uptime",
            "Custom useCountUp hook: requestAnimationFrame with cubic ease-out, 2s duration",
            "Counter formatting: Vietnamese locale (1.284.000), decimal support for uptime (99.9%)",
            "LogoWall: 12 brand names as bold text with staggered fade-in, 'Duoc tin dung boi' label",
        ],
        "notes": [
            "useCountUp hook: useEffect + rAF, cleanup with cancelAnimationFrame. Returns string.",
            "LogoWall uses text (not images) — brand names as bold zinc-300",
        ],
        "deps": "Blocks: —. Blocked by: DA-E34-02 (design tokens)."
    },
    {
        "summary": "[DA-E37-05] Build Templates + Testimonials sections (3 template cards + 3 customer quotes with stars)",
        "title": "DA-E37-05 — Build Templates + Testimonials sections",
        "assignee_priority": "Assignee: Trung (Leader) | Priority: Medium",
        "goal": "Deliver Templates showcase (Social, Blog, Email) and Testimonials (3 quotes with 5-star ratings, avatars, roles).",
        "criteria": [
            "Templates: 3 cards with gradient-top preview, frosted icon circle, hover shadow-xl",
            "Testimonials: 3 cards with 5 gold stars, quoted text, avatar initials circle, name + role",
            "Testimonial Quote icon watermark at top-right",
            "Responsive: 1 col mobile, 3 col desktop",
            "Scroll animations: fade in + slide up with staggered delays",
        ],
        "notes": [
            "Avatar initials: split name, take first char, join",
        ],
        "deps": "Blocks: —. Blocked by: DA-E34-02 (design tokens)."
    },
    {
        "summary": "[DA-E37-06] Build Pricing section (3-tier plans: Starter, Pro, Enterprise with feature checklists)",
        "title": "DA-E37-06 — Build Pricing section",
        "assignee_priority": "Assignee: Trung (Leader) | Priority: High",
        "goal": "Deliver 3-tier pricing: Starter, Pro (highlighted), Enterprise — with feature checklists and CTAs.",
        "criteria": [
            "3 plan cards in responsive grid",
            "Pro card: ring-1 ring-brand-orange, shadow-xl, 'Pho bien nhat' badge",
            "Each: plan name, price (4xl bold), feature list with green Check icons, CTA button",
            "Features from i18n as string array",
            "CTAs: Starter/Pro → /register, Enterprise → /contact",
            "Scroll: cards fade in + slide up with 120ms stagger",
        ],
        "notes": [
            "Enterprise uses custom text (not /thang suffix)",
        ],
        "deps": "Blocks: —. Blocked by: DA-E34-02, DA-E35-01 (register route target)."
    },
    {
        "summary": "[DA-E37-07] Build FAQ + CTA + Footer sections (accordion FAQ, conversion CTA banner, 5-column footer)",
        "title": "DA-E37-07 — Build FAQ + CTA + Footer sections",
        "assignee_priority": "Assignee: Trung (Leader) | Priority: High",
        "goal": "Deliver bottom-of-page: 5-item FAQ accordion, full-width CTA banner, 5-column footer with social icons.",
        "criteria": [
            "FAQ: 5 items accordion — AnimatePresence height animation, ChevronDown rotates 180deg when open",
            "CTA: dark bg, centered heading + subtitle + 2 buttons (Register/Login), orange glow blurs at corners",
            "Footer: 5-col grid — Brand (logo+tagline+social icons), Product links, Resources, Company, copyright",
            "Social icons: GitHub, Twitter, LinkedIn as inline SVG components in bordered squares",
            "Footer links via i18n returnObjects, copyright year from new Date()",
        ],
        "notes": [
            "FAQ uses useState<string|null> — open key tracks expanded item",
            "CTA corner glows: absolute divs (size-96, blur-[120px])",
            "GitHub icon is full SVG path (not lucide import)",
        ],
        "deps": "Blocks: —. Blocked by: DA-E34-02 (design tokens)."
    },
    {
        "summary": "[DA-E37-08] Set up i18n translation keys for all landing page sections (EN + VI)",
        "title": "DA-E37-08 — Set up i18n translation keys for all landing page sections",
        "assignee_priority": "Assignee: Trung (Leader) | Priority: High",
        "goal": "Define all i18n translation keys consumed by the 11 landing page sections for EN+VI translatability.",
        "criteria": [
            "All user-facing text uses t('landing.*') keys — no hardcoded Vietnamese in JSX",
            "Namespace: landing.{section}.{key}",
            "Key groups: trustedBy, features.*, stats.*, howItWorks.*, templates.*, testimonials.*, pricing.*, faq.*, cta.*, footer.*",
            "Hero CTA button text uses i18n keys (currently hardcoded Vietnamese)",
            "Both EN and VI translation files have all keys",
        ],
        "notes": [
            "CinematicHero menubar labels, tab names, dashboard labels are currently hardcoded Vietnamese — move to i18n",
            "Footer link arrays and pricing features use returnObjects:true",
        ],
        "deps": "Blocks: All landing page sections. Blocked by: DA-E34-05 (i18n setup)."
    },
    {
        "summary": "[DA-E37-09] Wire DashboardPage with auth-gating (guest → landing page, authenticated → role-based redirect)",
        "title": "DA-E37-09 — Wire DashboardPage with auth-gating",
        "assignee_priority": "Assignee: Trung (Leader) | Priority: Critical",
        "goal": "Integrate all landing page sections into DashboardPage with authentication-aware routing.",
        "criteria": [
            "Unauthenticated: renders 11 landing sections in order (Hero→LogoWall→Features→Stats→HowItWorks→Templates→Testimonials→Pricing→FAQ→CTA→Footer)",
            "AGENCY_OWNER/ACCOUNT_MANAGER/CONTENT_CREATOR: navigate('/workspace', {replace:true})",
            "BRAND_CLIENT: navigate('/portal', {replace:true})",
            "ADMIN: navigate('/admin', {replace:true})",
            "Fallback roles: dashboard view with welcome + KPI placeholder + task checklist",
            "Uses useAuthStore() + useNavigate() with replace:true",
            "Landing page fontFamily: var(--font-sans)",
        ],
        "notes": [
            "DashboardPage.tsx serves dual purpose: landing page (guest) + internal dashboard (authenticated)",
            "No separate /landing route — root / serves both audiences",
            "Role redirect happens on mount — no flash of landing page for authenticated users",
        ],
        "deps": "Blocks: —. Blocked by: DA-E35-01, DA-E35-05, DA-E35-02, DA-E37-01 through DA-E37-08."
    },
]

# ── Execute ──

if __name__ == "__main__":
    print("=" * 60)
    print("CREATING EPIC E37 + 9 LANDING PAGE TASKS")
    print("=" * 60)

    # Step 1: Create the epic
    print("\n-- Step 1: Creating Epic --")
    epic_key = create_epic(
        "E37 — Public Landing Page",
        EPIC_DESC
    )
    if not epic_key:
        print("\nFATAL: Could not create epic. Check token/network.")
        sys.exit(1)

    # Step 2: Create all tasks
    print(f"\n-- Step 2: Creating 9 tasks under {epic_key} --")
    created = []
    for i, task in enumerate(TASKS, 1):
        desc = build_description(
            task["title"], task["assignee_priority"], task["goal"],
            task["criteria"], task["notes"], task["deps"]
        )
        key = create_task(task["summary"], desc, epic_key, ASSIGNEE_TRUNG)
        if key:
            created.append(key)

    print(f"\n{'=' * 60}")
    print(f"DONE. Epic: {epic_key}. Tasks created: {len(created)}/9")
    if len(created) < 9:
        print(f"MISSING: {9 - len(created)} tasks failed. Check errors above.")
    print(f"\nNext: Manually transition these tasks to 'Done' on Jira")
    print(f"      (code is already committed)")
    print(f"{'=' * 60}")
