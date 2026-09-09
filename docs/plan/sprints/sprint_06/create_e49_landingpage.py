#!/usr/bin/env python3
"""
Create Epic E49 — Public Landing Page + 9 tasks on Jira.

E37 was already taken (Client Portal). Next available after E48 is E49.
The landing page code is already built (commit c697568, mistakenly tagged DA-305
instead of DA-407). This script creates a proper epic with full task breakdown.

Usage: python create_e49_landingpage.py
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

def adf_heading(level, text):
    return {"type": "heading", "attrs": {"level": level}, "content": [{"type": "text", "text": text}]}

def adf_para(text):
    return {"type": "paragraph", "content": [{"type": "text", "text": text}]}

def adf_list(items):
    return {"type": "bulletList", "content": [{"type": "listItem", "content": [{"type": "paragraph", "content": [{"type": "text", "text": item}]}]} for item in items]}

def build_description(title, assignee_priority, goal, criteria, notes, deps):
    content = [
        adf_heading(3, title),
        adf_para(assignee_priority),
        adf_heading(4, "Goal"),
        adf_para(goal),
        adf_heading(4, "Acceptance Criteria"),
        adf_list(criteria),
        adf_heading(4, "Technical Notes"),
    ]
    for n in notes:
        content.append(adf_para(n))
    content.append(adf_heading(4, "Dependencies"))
    content.append(adf_para(deps))
    return {"type": "doc", "version": 1, "content": content}

def api_call(method, body=None):
    data = json.dumps(body).encode() if body else None
    req = urllib.request.Request(JIRA_API, data=data, method=method)
    req.add_header("Authorization", f"Basic {AUTH}")
    req.add_header("Content-Type", "application/json")
    try:
        with urllib.request.urlopen(req) as resp:
            return resp.status, json.loads(resp.read().decode())
    except urllib.error.HTTPError as e:
        return e.code, {"error": e.read().decode()[:300]}

def create_epic(summary, description):
    body = {"fields": {"project": {"key": PROJECT_KEY}, "summary": summary, "description": description, "issuetype": {"id": EPIC_TYPE}}}
    status, resp = api_call("POST", body)
    if status in (200, 201):
        key = resp.get("key")
        print(f"  EPIC: {key} — {summary}")
        return key
    else:
        print(f"  ERROR epic: HTTP {status}: {resp.get('error', resp)}")
        return None

def create_task(summary, description, epic_key):
    body = {"fields": {"project": {"key": PROJECT_KEY}, "summary": summary, "description": description, "issuetype": {"id": TASK_TYPE}, "parent": {"key": epic_key}, "assignee": {"id": ASSIGNEE_TRUNG}}}
    status, resp = api_call("POST", body)
    if status in (200, 201):
        key = resp.get("key")
        print(f"  [{key}] {summary}")
        return key
    else:
        print(f"  FAILED: HTTP {status} — {resp.get('error', resp)}")
        return None

# ── Epic ──

EPIC_DESC = build_description(
    "E49 — Public Landing Page",
    "Assignee: Trung (Leader) | Priority: Critical",
    "Deliver a full public landing page for unauthenticated users (GUEST role). "
    "The landing page is the first touchpoint — it sells BrandHub before login. "
    "Includes cinematic hero animation, feature showcase, social proof, pricing, and conversion CTAs. "
    "All sections fully internationalized (EN + VI) with scroll-driven animations.",
    [
        "Landing page renders for unauthenticated users at / (root route)",
        "11 sections: Hero, LogoWall, Features, Stats, HowItWorks, Templates, Testimonials, Pricing, FAQ, CTA, Footer",
        "Cinematic hero: GSAP scroll-driven (IG→TT→FB→LI→BrandHub MacBook reveal→CTA)",
        "All text via i18n keys — ready for EN + VI translation",
        "Authenticated users redirected to role-based dashboard",
        "Responsive: mobile/tablet/desktop",
        "CTA buttons → /register and /login",
        "Stats counter animates 0→target on first scroll",
        "FAQ accordion with smooth expand/collapse",
        "Pricing highlights recommended Pro plan",
    ],
    [
        "Not in original 46-epic plan — built as phat sinh (originally DA-407 under E08 with wrong prefix DA-E010-07).",
        "All 9 tasks are already completed — set status to Done after creation.",
        "Code: brandhub-web-dashboard/src/components/landing/",
        "Entry: brandhub-web-dashboard/src/pages/DashboardPage.tsx (guest vs authenticated routing)",
        "Uses GSAP ScrollTrigger + framer-motion + react-i18next",
    ],
    "Blocks: — (self-contained). Blocked by: DA-E34-02, DA-E34-03, DA-E34-04, DA-E34-05 (Design System), DA-E35-01 (Login page CTA target)."
)

# ── 9 Tasks ──

TASKS = [
    {
        "summary": "[DA-E49-01] Build Cinematic Hero section (GSAP scroll animation: 4 platform posts → BrandHub MacBook reveal → CTA)",
        "title": "DA-E49-01 — Build Cinematic Hero section",
        "assignee_priority": "Assignee: Trung (Leader) | Priority: Critical",
        "goal": "Deliver the hero section — a scroll-driven cinematic animation: 4 platform posts (IG, TT, FB, LI) → BrandHub dashboard on MacBook Air → Register/Login CTA.",
        "criteria": [
            "GSAP ScrollTrigger timeline: IG(0-15%)→TT(15-35%)→FB(35-55%)→LI(55-75%)→BrandHub(75-90%)→CTA(90-100%), pin 3500px, scrub:1",
            "4 platform post components: InstagramPost, TikTokPost, FacebookPost, LinkedInPost — realistic social cards with platform styling",
            "MacBook Air M5 aluminum chassis + macOS Sonoma wallpaper + menubar (Apple logo, clock) + notch",
            "Safari browser: 4 interactive tabs (Overview/Content/Schedule/Analytics) — KPI cards+bar chart, post list+search, calendar grid+timeline, analytics+SVG line chart",
            "macOS Dock: 12 app icons as inline SVG glyphs (BrandHub, Finder, Launchpad, Safari, Messages, Mail, Maps, Photos, Calendar, Notes, Music | Downloads, Trash)",
            "Mini posts burst to 4 corners — staggered back.out easing, then idle drift (yoyo sine, out-of-phase delays)",
            "CTA buttons overlay after animation: Register (Rocket icon) + Login",
            "Locked forward-only — scroll-back does NOT reverse (clamped progress)",
            "Responsive: posts use xPercent/yPercent, no pixel hardcoding",
        ],
        "notes": [
            "pin:true, anticipatePin:1. Timeline eventCallback onComplete sets locked=true, onUpdate clamps progress(1).",
            "Platform posts ~100-160 lines each — realistic profile pics, content, engagement buttons, timestamps.",
            "Dashboard tabs use useState switching, remount on key change for GSAP enter animations.",
            "Mini post idle: gsap.to y:'+=6', yoyo:true, repeat:-1, delays 0/0.4/0.8/1.2s — never in lockstep.",
        ],
        "deps": "Blocks: —. Blocked by: DA-E34-02, DA-E34-03 (Design System foundation)."
    },
    {
        "summary": "[DA-E49-02] Build Features section (6 feature cards with icons, hover effects, scroll animations)",
        "title": "DA-E49-02 — Build Features section",
        "assignee_priority": "Assignee: Trung (Leader) | Priority: High",
        "goal": "Deliver 6-card feature grid: Planning (CalendarDays), Creation (FileEdit), Publishing (LayoutDashboard), Analytics (BarChart3), Collaboration (Users), Automation (Zap).",
        "criteria": [
            "6 cards responsive grid (1/2/3 cols): orange icon container (bg-brand-orange/10), title, description from i18n",
            "Hover: border orange-200, bg orange-50/30, shadow-lg, icon container scale 110%",
            "Scroll: fade in + slide up y:32→0, staggered 80ms via framer-motion whileInView once:true",
            "Dark mode: border zinc-800, bg zinc-900/50",
        ],
        "notes": ["Uses framer-motion, not GSAP. All text via i18n keys."],
        "deps": "Blocks: —. Blocked by: DA-E34-02."
    },
    {
        "summary": "[DA-E49-03] Build How It Works section (4-step timeline with alternating layout, scroll slide-in)",
        "title": "DA-E49-03 — Build How It Works section",
        "assignee_priority": "Assignee: Trung (Leader) | Priority: High",
        "goal": "Deliver 4-step timeline: Plan→Create→Schedule→Publish — alternating left/right cards with connecting line, scroll animations.",
        "criteria": [
            "4 numbered orange circles connected by vertical line (desktop center via lg:left-1/2, mobile left)",
            "Alternating layout: odd steps left (lg:mr-auto), even steps right (lg:ml-auto). Mobile: all left (ml-20)",
            "Each step: colored icon in orange square, title, description",
            "Scroll: cards slide in from left/right (x:±40→0), stagger 100ms, once:true",
            "Section bg: zinc-50 light / zinc-900/50 dark",
        ],
        "notes": ["Connecting line: absolute h-full w-0.5, hidden md:block."],
        "deps": "Blocks: —. Blocked by: DA-E34-02."
    },
    {
        "summary": "[DA-E49-04] Build Stats Counter + LogoWall sections (animated count-up + 12 trusted-by brand logos)",
        "title": "DA-E49-04 — Build Stats Counter + LogoWall sections",
        "assignee_priority": "Assignee: Trung (Leader) | Priority: Medium",
        "goal": "Deliver social proof: animated counters (1.2M+ contents, 50K+ brands, 12 platforms, 99.9% uptime) + 12 brand names as logo wall.",
        "criteria": [
            "Stats Counter: 4 stats on brand-orange bg, 2x2 mobile / 4-col desktop",
            "Custom useCountUp hook: requestAnimationFrame + cubic ease-out (1-(1-p)³), 2s duration, triggers on viewport enter",
            "Vietnamese locale formatting (1.284.000), decimal support (99.9%), suffix per stat",
            "LogoWall: 12 brands as bold text, staggered fade-in (0.1+0.04i s delay), 'Duoc tin dung boi' label above",
        ],
        "notes": ["useCountUp: useEffect + rAF ref, cancelAnimationFrame cleanup. Returns formatted string."],
        "deps": "Blocks: —. Blocked by: DA-E34-02."
    },
    {
        "summary": "[DA-E49-05] Build Templates + Testimonials sections (3 template cards + 3 customer quotes with stars)",
        "title": "DA-E49-05 — Build Templates + Testimonials sections",
        "assignee_priority": "Assignee: Trung (Leader) | Priority: Medium",
        "goal": "Deliver Templates showcase (Social, Blog, Email) with gradient previews + Testimonials (3 customer quotes, 5-star ratings, avatars).",
        "criteria": [
            "Templates: 3 cards (Smartphone/Monitor/Eye icons) — gradient-top bg (pink→orange, blue→cyan, emerald→teal), frosted icon circle, bottom white fade, hover shadow-xl + icon scale 110%",
            "Testimonials: 3 cards (Minh Nguyen/Content Director VCorp, Sarah Chen/Marketing Lead Global Brands, Tuan Le/Agency Owner CreativeHub) — 5 gold stars, quoted text with Quote watermark, avatar initials circle, name+role",
            "Responsive: 1 col mobile, 3 col desktop. Scroll: fade-in + slide up, staggered delays.",
        ],
        "notes": ["Avatar initials: name.split(' ').map(n=>n[0]).join(''). Quote SVG absolute top-right z-0."],
        "deps": "Blocks: —. Blocked by: DA-E34-02."
    },
    {
        "summary": "[DA-E49-06] Build Pricing section (3-tier plans: Starter, Pro, Enterprise with feature checklists)",
        "title": "DA-E49-06 — Build Pricing section",
        "assignee_priority": "Assignee: Trung (Leader) | Priority: High",
        "goal": "Deliver 3-tier pricing: Starter, Pro (highlighted with 'Pho bien nhat' badge), Enterprise — feature checklists with Check icons, CTAs to /register or /contact.",
        "criteria": [
            "3 plan cards responsive grid. Pro: ring-1 ring-brand-orange, shadow-xl shadow-orange-500/10, 'Pho bien nhat' badge pill (brand-orange, absolute -top-3 centered)",
            "Each card: plan name, price (4xl bold), /thang suffix (Enterprise: custom 'Lien he'), feature list (Check icons, text-sm), CTA button",
            "Features from i18n as string array (returnObjects:true)",
            "CTA: Starter/Pro → navigate('/register'), Enterprise → navigate('/contact')",
            "Pro CTA: solid brand-orange bg. Others: outline (border zinc-300, bg-white). Scroll: fade-in + slide up, 120ms stagger",
        ],
        "notes": ["Enterprise price shows custom text, no /thang. Key check: plan.key !== 'enterprise' for suffix."],
        "deps": "Blocks: —. Blocked by: DA-E34-02, DA-E35-01 (register route)."
    },
    {
        "summary": "[DA-E49-07] Build FAQ + CTA + Footer sections (accordion FAQ, conversion CTA banner, 5-column footer)",
        "title": "DA-E49-07 — Build FAQ + CTA + Footer sections",
        "assignee_priority": "Assignee: Trung (Leader) | Priority: High",
        "goal": "Deliver bottom-of-page sections: 5-item FAQ accordion, full-width CTA banner with orange corner glows, 5-column footer with social SVG icons.",
        "criteria": [
            "FAQ: 5 items — useState<string|null> tracks open key. AnimatePresence height:0→auto (250ms). ChevronDown rotates 180deg when open. Hover: bg-zinc-50",
            "CTA: dark bg (bg-zinc-900 dark:bg-black), centered heading+subtitle+2 buttons, 2 absolute corner divs (size-96, rounded-full, blur-[120px], brand-orange/20 and orange-500/10)",
            "Register button: brand-orange bg, shadow-lg shadow-orange-500/30, ArrowRight icon. Login: outline (border-zinc-700, bg-zinc-800/50, backdrop-blur)",
            "Footer: 5-col grid (col-span-2 brand + 3 link cols). Brand: logo square (brand-orange, 'B') + 'BrandHub' name + tagline + 3 social icons (GitHub/Twitter/LinkedIn as inline SVG components in bordered squares)",
            "Link cols: Product, Resources, Company — each with h4 heading (text-xs, uppercase, tracking-wider) + ul of links from i18n returnObjects",
            "Copyright bar: border-t, 'BrandHub {year}. All rights reserved.' from i18n, new Date().getFullYear()",
        ],
        "notes": [
            "FAQ AnimatePresence needs motion.div with initial/exit — height animation requires CSS overflow:hidden wrapper.",
            "CTA corner glows are decorative only — pointer-events-none implicit via absolute positioning.",
            "GitHubIcon/TwitterIcon/LinkedinIcon are hand-coded SVG path components (not lucide) for brand-accurate rendering.",
        ],
        "deps": "Blocks: —. Blocked by: DA-E34-02."
    },
    {
        "summary": "[DA-E49-08] Set up i18n translation keys for all landing page sections (EN + VI)",
        "title": "DA-E49-08 — Set up i18n translation keys",
        "assignee_priority": "Assignee: Trung (Leader) | Priority: High",
        "goal": "Define all landing.* i18n keys so the 11 landing page sections are fully translatable between English and Vietnamese without editing component code.",
        "criteria": [
            "All user-facing text uses t('landing.*') keys — no hardcoded Vietnamese strings remain in JSX (except LogoWall brand names and testimonial person names/roles which are proper nouns)",
            "Namespace structure: landing.trustedBy, landing.features.title/subtitle/items.*, landing.stats.*, landing.howItWorks.*, landing.templates.*, landing.testimonials.*, landing.pricing.*, landing.faq.*, landing.cta.*, landing.footer.*",
            "Hero CTA buttons converted from hardcoded 'Bat dau mien phi'/'Dang nhap' to t('landing.cta.start')/t('landing.cta.login')",
            "CinematicHero internal text (macOS menubar labels, Safari tab names, dashboard KPI labels) moved to i18n keys",
            "Both EN and VI translation JSON files have all keys with correct translations",
            "Footer link arrays and pricing feature arrays use returnObjects:true for array-typed i18n values",
        ],
        "notes": [
            "Current state: some CinematicHero text is hardcoded Vietnamese — menubar items (Te/Sua/Hien thi/Cua so/Tro giup), tab labels (Tong quan/Noi dung/Lich/Analytics), dashboard KPI labels. These need extraction.",
            "Pricing plan names and features are dynamic via i18n — plans array only has {key, featured} flags.",
        ],
        "deps": "Blocks: All landing page sections (consume these keys). Blocked by: DA-E34-05 (i18n setup)."
    },
    {
        "summary": "[DA-E49-09] Wire DashboardPage with auth-gating (guest → landing page, authenticated → role-based redirect)",
        "title": "DA-E49-09 — Wire DashboardPage with auth-gating",
        "assignee_priority": "Assignee: Trung (Leader) | Priority: Critical",
        "goal": "Integrate all 11 landing page sections into DashboardPage with authentication-aware routing: unauthenticated users see the full landing page; authenticated users are redirected to their role-specific page.",
        "criteria": [
            "Unauthenticated path: renders 11 sections in order — CinematicHero → LogoWall → Features → StatsCounter → HowItWorks → Templates → Testimonials → Pricing → FAQ → CTASection → Footer",
            "Authenticated AGENCY_OWNER/ACCOUNT_MANAGER/CONTENT_CREATOR: navigate('/workspace', {replace:true}) on mount",
            "Authenticated BRAND_CLIENT: navigate('/portal', {replace:true})",
            "Authenticated ADMIN: navigate('/admin', {replace:true})",
            "Fallback authenticated (other roles): renders dashboard view with welcome message ('Chao mung tro lai, {name}!'), KPI chart placeholder div, task checklist with checkboxes",
            "Uses useAuthStore() to read isAuthenticated + user.role; useNavigate() with replace:true so back button skips landing",
            "Landing page wrapper div applies style={{fontFamily:'var(--font-sans)'}} for consistent typography",
        ],
        "notes": [
            "DashboardPage.tsx serves dual purpose: landing page for guests + internal dashboard for authenticated users. No separate /landing route — root / serves both.",
            "Role redirect happens synchronously on render — authenticated users never see a flash of landing page content.",
            "Fallback dashboard is a simplified placeholder — real dashboard widgets are built in DA-E35-02 (Dashboard page).",
        ],
        "deps": "Blocks: —. Blocked by: DA-E35-01 (Login), DA-E35-05 (Register), DA-E35-02 (Dashboard), DA-E49-01 through DA-E49-08 (all landing sections)."
    },
]

# ── Main ──

if __name__ == "__main__":
    print("=" * 60)
    print("CREATING E49 EPIC + 9 LANDING PAGE TASKS")
    print("=" * 60)

    print("\n-- Step 1: Create Epic --")
    epic_key = create_epic("E49 — Public Landing Page", EPIC_DESC)
    if not epic_key:
        print("\nFATAL: Epic creation failed. Check token/network.")
        sys.exit(1)

    print(f"\n-- Step 2: Create 9 tasks under {epic_key} --")
    created = []
    for i, task in enumerate(TASKS, 1):
        desc = build_description(task["title"], task["assignee_priority"], task["goal"], task["criteria"], task["notes"], task["deps"])
        key = create_task(task["summary"], desc, epic_key)
        if key:
            created.append(key)

    print(f"\n{'=' * 60}")
    print(f"Epic: {epic_key} | Tasks: {len(created)}/9")
    if created:
        print(f"Keys: {', '.join(created)}")
    if len(created) < 9:
        print(f"MISSING: {9-len(created)}. Re-run or create manually.")
    print(f"Next: transition all to Done (code already committed)")
    print(f"{'=' * 60}")
