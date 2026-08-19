#!/usr/bin/env python3
"""
Fix DA-574 through DA-583 on Jira:
  1. Summary: add [DA-E35-xx] or [DA-E36-xx] prefix
  2. Epic: link to DA-117 (E35) or DA-119 (E36)
  3. Description: proper ADF format matching DA-366 template

Usage: python fix_jira_10tasks.py
"""

import json, urllib.request, urllib.error, base64

EMAIL = "letritrung2605@gmail.com"
TOKEN = "ATATT3xFfGF0hOu_QP0K9NHqnGgsrxko4pKSzqkTXX2nm1YWWBm-g9KGqEEe0h1h90vbBdEskz9EoWDc3s2sB3WMnqNedf2RzztO0R0FwLqNs4vIotf4_r9kajvHL4p9G7W9PF_Z3qCkZP_21vJPbmbiul8PkiEdjpwr0AY3Cbt6O0nft6dvDtQ=080C74FD"
JIRA = "https://letritrung2605.atlassian.net/rest/api/3/issue"
AUTH = base64.b64encode(f"{EMAIL}:{TOKEN}".encode()).decode()

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

def update_issue(key, summary, epic_key, description):
    body = {"fields": {"summary": summary, "parent": {"key": epic_key}, "description": description}}
    data = json.dumps(body).encode()
    req = urllib.request.Request(f"{JIRA}/{key}", data=data, method="PUT")
    req.add_header("Authorization", f"Basic {AUTH}")
    req.add_header("Content-Type", "application/json")
    try:
        with urllib.request.urlopen(req) as resp:
            return resp.status
    except urllib.error.HTTPError as e:
        return f"HTTP {e.code}: {e.read().decode()[:200]}"

# ── 10 Task definitions (from BrandHub_Master_Plan.md + PLAN.md) ──

TASKS = [
    {
        "key": "DA-574",
        "summary": "[DA-E35-05] Build Register page (account creation form, validation, redirect to dashboard)",
        "epic": "DA-117",
        "title": "DA-E35-05 — Build Register page",
        "assignee_priority": "Assignee: Trung (Leader) | Priority: Critical",
        "goal": "Deliver account creation page with full form validation, inline error states, and seamless redirect after successful registration.",
        "criteria": [
            "Register form: full name, email, password, confirm password — all fields validated with react-hook-form + zod",
            "Password strength meter shows real-time strength indicator (weak/medium/strong)",
            "Submit calls POST /api/v1/auth/register; on success, stores tokens in authStore and redirects to role-based landing page",
            "API errors (email already exists, validation failures) shown as inline form error messages below each field",
            "Redirects authenticated users away — if already logged in, skip to role-based landing page",
            "Loading spinner on submit button; button disabled during API call to prevent double-submit"
        ],
        "notes": [
            "Use react-hook-form + zod for form validation — consistent with Login page (DA-E35-01)",
            "Password strength meter reuses PasswordStrengthMeter component from shared auth UI",
            "Redirect to Verify OTP page if email verification is required (configurable per workspace settings)"
        ],
        "deps": "Blocks: —. Blocked by: DA-E34-02, DA-E34-03, DA-E34-04, DA-E34-05 (Design System foundation)."
    },
    {
        "key": "DA-575",
        "summary": "[DA-E35-06] Build Google OAuth button + callback page (OAuth flow, handle new vs existing user)",
        "epic": "DA-117",
        "title": "DA-E35-06 — Build Google OAuth button + callback page",
        "assignee_priority": "Assignee: Trung (Leader) | Priority: Critical",
        "goal": "Deliver Google OAuth integration — a Sign in with Google button on the Login page and a callback page that handles the OAuth response, distinguishing new vs existing users.",
        "criteria": [
            "Google OAuth button on Login page opens OAuth flow via GET /api/v1/auth/google",
            "Callback page at /auth/callback extracts authorization code from URL params and exchanges for tokens via POST /api/v1/auth/google/callback",
            "New user (first Google login): redirect to complete profile or create workspace",
            "Existing user: store tokens in authStore, redirect to role-based landing page",
            "Error states: OAuth cancelled, token exchange failed, account not found — each with clear user-facing message",
            "Loading state shown during token exchange (spinner with 'Signing in with Google…' message)"
        ],
        "notes": [
            "Server-side OAuth flow — frontend only opens URL and handles callback; no client-side Google SDK needed",
            "Google OAuth state parameter stored in localStorage to prevent CSRF",
            "Callback page is a thin React component — renders loading/error/success states, performs API call, redirects"
        ],
        "deps": "Blocks: —. Blocked by: DA-E34-02, DA-E34-03 (AuthGuard + Design System), DA-E10-01 (Google OAuth backend)."
    },
    {
        "key": "DA-576",
        "summary": "[DA-E35-07] Build Workspace Settings page (timezone selector, default platforms, report frequency)",
        "epic": "DA-117",
        "title": "DA-E35-07 — Build Workspace Settings page",
        "assignee_priority": "Assignee: Trung (Leader) | Priority: High",
        "goal": "Deliver workspace configuration UI for AGENCY_OWNER to set timezone, default social platforms, and report frequency preferences.",
        "criteria": [
            "Timezone selector: dropdown with IANA timezone list, defaults to Asia/Ho_Chi_Minh",
            "Default platforms: checkbox group (Facebook, Instagram, TikTok, LinkedIn, Threads, Zalo) — preselected platforms apply to all new content",
            "Report frequency: radio buttons — weekly, bi-weekly, monthly",
            "Save button calls PUT /api/v1/workspaces/{id}/settings; shows success toast on save",
            "All fields show current saved values on mount (fetched from GET /api/v1/workspaces/mine)"
        ],
        "notes": [
            "Settings page nested under workspace section (sidebar: Workspace > Settings)",
            "Use react-hook-form for form state; pre-fill from workspace data",
            "Timezone list can use Intl.supportedValuesOf('timeZone') (Chrome 92+) or a static JSON list for broader support"
        ],
        "deps": "Blocks: —. Blocked by: DA-E35-03 (Create Workspace page — workspace must exist), DA-E15-05 (Workspace settings API)."
    },
    {
        "key": "DA-577",
        "summary": "[DA-E35-08] Build Workspace Members page (member table, invite button, remove action with confirm)",
        "epic": "DA-117",
        "title": "DA-E35-08 — Build Workspace Members page",
        "assignee_priority": "Assignee: Trung (Leader) | Priority: Critical",
        "goal": "Deliver member management UI with table view, invite flow, and remove capability for AGENCY_OWNER to manage their workspace team.",
        "criteria": [
            "Member table: columns — name, email, role badge (color-coded: AGENCY_OWNER=red, ACCOUNT_MANAGER=blue, CONTENT_CREATOR=green), joined date",
            "Search bar: filter members by name or email (client-side for <50 members)",
            "Invite button opens modal: email input + role dropdown (ACCOUNT_MANAGER, CONTENT_CREATOR); calls POST /api/v1/workspaces/{id}/members",
            "Remove member: click remove icon → confirmation modal → DELETE /api/v1/workspaces/{id}/members/{userId}",
            "AGENCY_OWNER cannot remove themselves — remove button hidden for own row",
            "Table shows loading skeleton on initial fetch; errors shown as inline error state with retry button"
        ],
        "notes": [
            "Member data fetched via GET /api/v1/workspaces/{id}/members on mount",
            "Role selector only shows roles the caller can assign (AGENCY_OWNER cannot invite another AGENCY_OWNER)",
            "Invitation email handled server-side — frontend only displays success/failure toast"
        ],
        "deps": "Blocks: —. Blocked by: DA-E35-03 (Create Workspace), DA-E15-03, DA-E15-04 (Member invite/remove APIs)."
    },
    {
        "key": "DA-578",
        "summary": "[DA-E35-09] Build Create Client page (form: name, industry, brand color picker, logo upload)",
        "epic": "DA-117",
        "title": "DA-E35-09 — Build Create Client page",
        "assignee_priority": "Assignee: Phuoc (Publisher) | Priority: Critical",
        "goal": "Deliver client creation form enabling AGENCY_OWNER to onboard a new brand client with name, industry, brand color, and logo.",
        "criteria": [
            "Form fields: client name (text), industry (dropdown — Retail, F&B, Tech, Finance, Healthcare, Education, Other), brand color (color picker), logo (file upload with preview)",
            "All fields validated — name required (min 2 chars), industry required, brand color required (valid hex), logo optional (max 5MB, PNG/JPG/SVG)",
            "Submit calls POST /api/v1/clients; on success redirects to Client List page with success toast",
            "API errors (duplicate client name, validation failures) shown as inline error messages",
            "Brand color picker shows live preview of selected color on a sample card"
        ],
        "notes": [
            "Logo upload: POST /api/v1/media/upload → returns S3 URL → sent as logoUrl in client creation payload",
            "Industry dropdown sourced from a constant enum; future: can be a server-side GET /api/v1/config/industries",
            "Use react-hook-form + zod validators"
        ],
        "deps": "Blocks: DA-E35-10, DA-E35-11. Blocked by: DA-E16-01 (POST /clients API), DA-E35-04 (Client List page — for redirect target)."
    },
    {
        "key": "DA-579",
        "summary": "[DA-E35-10] Build Edit Client page (pre-filled form: name, industry, brand color, logo)",
        "epic": "DA-117",
        "title": "DA-E35-10 — Build Edit Client page",
        "assignee_priority": "Assignee: Phuoc (Publisher) | Priority: High",
        "goal": "Deliver client edit page with form pre-filled from existing client data, allowing AGENCY_OWNER or ACCOUNT_MANAGER to update client details.",
        "criteria": [
            "Page loads client data via GET /api/v1/clients/{id} and pre-fills all form fields",
            "Same form fields as Create Client page (name, industry, brand color, logo) — reuse shared form component",
            "Submit calls PUT /api/v1/clients/{id}; on success, redirects to Client List page with success toast",
            "Unsaved changes warning if user navigates away with dirty form (beforeunload or React Router blocker)",
            "Loading skeleton shown during data fetch; error state with retry if client not found"
        ],
        "notes": [
            "Reuse the same form component as DA-E35-09 (Create Client) — toggle mode between create/edit",
            "Client ID from URL params (e.g., /clients/:id/edit)"
        ],
        "deps": "Blocks: —. Blocked by: DA-E35-09 (Create Client — shared form component), DA-E16-01 (POST /clients), DA-E16-04 (GET /clients)."
    },
    {
        "key": "DA-580",
        "summary": "[DA-E35-11] Build Client Service Package page (posts/month input, platform checkboxes, AI credits slider)",
        "epic": "DA-117",
        "title": "DA-E35-11 — Build Client Service Package page",
        "assignee_priority": "Assignee: Phuoc (Publisher) | Priority: High",
        "goal": "Deliver service package configuration UI to set posting limits, platform access, and AI credit allocation per client.",
        "criteria": [
            "Posts per month: number input (min 1, max 500), with slider for quick adjustment",
            "Platform checkboxes: Facebook, Instagram, TikTok, LinkedIn, Threads, Zalo — at least one required",
            "AI credits per month: slider (0-1000, step 10) with numeric display",
            "Save calls PUT /api/v1/clients/{id}/service-package; success toast on save",
            "Validation: posts/month must not exceed workspace subscription limit (shown as info banner)",
            "Current package values pre-loaded from GET /api/v1/clients/{id} on mount"
        ],
        "notes": [
            "Client-level service package is separate from workspace subscription — client limit <= workspace limit",
            "Use shadcn/ui Slider component for posts/month and AI credits",
            "Platform checkboxes use shadcn/ui Checkbox group"
        ],
        "deps": "Blocks: —. Blocked by: DA-E35-09 (Create Client), DA-E16-03 (PUT service-package API)."
    },
    {
        "key": "DA-581",
        "summary": "[DA-E36-06] Build AI Generate Panel (call ai-service, display caption + hashtag + image, regenerate with feedback)",
        "epic": "DA-119",
        "title": "DA-E36-06 — Build AI Generate Panel",
        "assignee_priority": "Assignee: Phuoc (Publisher) | Priority: Critical",
        "goal": "Deliver AI-powered content generation panel integrated into the Content Editor, enabling one-click caption/hashtag/image generation with regenerate capability.",
        "criteria": [
            "Generate with AI button in Content Editor sidebar/panel triggers POST /api/v1/posts/ai-generate with topic and platform context",
            "Loading state: skeleton/spinner with estimated time (~10s); progress indicator if streaming is available",
            "Result display: generated caption (editable text), hashtags (as tag chips), generated image (thumbnail with expand)",
            "Regenerate button with optional feedback text input ('Make it more professional', 'Shorter caption', etc.)",
            "Use this button inserts all generated content into the Content Editor form fields (caption, hashtags, image)",
            "Error states: AI service unavailable, rate limited, generation failed — each with clear message and retry"
        ],
        "notes": [
            "AI call is async — poll or use WebSocket for progress updates if generation takes >10s",
            "Generated image from Stability AI; displayed as thumbnail with lightbox expand",
            "Regenerate passes previousOutput + userFeedback to AI service for iterative improvement"
        ],
        "deps": "Blocks: —. Blocked by: DA-E36-02 (Content Editor — insertion target), DA-AI04-01, DA-AI04-02, DA-AI04-03 (AI prompt system + Llama 3 + Claude fallback)."
    },
    {
        "key": "DA-582",
        "summary": "[DA-E36-07] Build Template Browser page (saved drafts list, search, preview, use template)",
        "epic": "DA-119",
        "title": "DA-E36-07 — Build Template Browser page",
        "assignee_priority": "Assignee: Phuoc (Publisher) | Priority: High",
        "goal": "Deliver a browsable library of saved post templates/drafts that users can search, preview, and reuse as starting points for new content.",
        "criteria": [
            "Template grid/list: card per template showing title, preview caption snippet (first 100 chars), platform badges, last used date",
            "Search bar: filter templates by title or caption content (debounced, 300ms)",
            "Template preview: click card opens detail modal showing full caption, hashtags, platform target, and preview image",
            "Use template button in preview modal → loads template data into Content Editor form",
            "Empty state: 'No templates yet. Save a draft from the Content Editor to see it here.'",
            "Pagination or infinite scroll if >20 templates"
        ],
        "notes": [
            "Templates fetched via GET /api/v1/templates?page=0&size=20&search={query}",
            "Reuse shadcn/ui Card, Dialog (for preview modal), and Input (for search)",
            "Template is essentially a saved Content Draft with isTemplate=true flag"
        ],
        "deps": "Blocks: —. Blocked by: DA-E36-02 (Content Editor — source of saved drafts)."
    },
    {
        "key": "DA-583",
        "summary": "[DA-E36-08] Build Hashtag Groups page (CRUD hashtag groups, assign to posts)",
        "epic": "DA-119",
        "title": "DA-E36-08 — Build Hashtag Groups page",
        "assignee_priority": "Assignee: Phuoc (Publisher) | Priority: High",
        "goal": "Deliver hashtag group management — create, edit, delete groups of hashtags and assign them to content posts for quick insertion.",
        "criteria": [
            "Group list: card/table showing group name, hashtag count, and preview of hashtags as chips",
            "Create group: button opens modal → name input + hashtag textarea (comma or newline separated) → POST /api/v1/hashtag-groups",
            "Edit group: click edit on existing group → pre-filled modal → PUT /api/v1/hashtag-groups/{id}",
            "Delete group: click delete → confirmation modal → DELETE /api/v1/hashtag-groups/{id}",
            "In Content Editor, hashtag input has a 'Load from Group' dropdown to load all hashtags from a saved group",
            "Validation: group name required (unique), at least 1 hashtag required, max 50 hashtags per group"
        ],
        "notes": [
            "Hashtag groups stored per workspace — all members share the same groups",
            "Hashtag input supports both manual entry and group selection — toggle between modes",
            "Use optimistic UI for CRUD operations with toast feedback on completion"
        ],
        "deps": "Blocks: —. Blocked by: DA-E36-02 (Content Editor — integration point for 'Load from Group' dropdown)."
    }
]

# ── Execute ──

if __name__ == "__main__":
    print("=" * 50)
    print("FIXING 10 JIRA TASKS (DA-574 to DA-583)")
    print("=" * 50)
    for i, task in enumerate(TASKS, 1):
        desc = build_description(
            task["title"], task["assignee_priority"], task["goal"],
            task["criteria"], task["notes"], task["deps"]
        )
        result = update_issue(task["key"], task["summary"], task["epic"], desc)
        print(f"[{i:2d}/10] {task['key']}: HTTP {result}")
    print("=" * 50)
    print("DONE. Summary prefix + epic link + full ADF description for all 10 tasks.")
