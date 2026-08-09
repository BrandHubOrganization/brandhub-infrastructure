#!/usr/bin/env python3
"""Create 3 Jira tasks for auth features found in backend code but missing
from Jira: Change Password, Facebook OAuth, GitHub OAuth. All under Epic
E12 (Authentication, DA-92).

Usage: python create_e12_auth_additions.py
"""

import json, urllib.request, urllib.error, base64, sys

EMAIL = "letritrung2605@gmail.com"
TOKEN = "ATATT3xFfGF0hOu_QP0K9NHqnGgsrxko4pKSzqkTXX2nm1YWWBm-g9KGqEEe0h1h90vbBdEskz9EoWDc3s2sB3WMnqNedf2RzztO0R0FwLqNs4vIotf4_r9kajvHL4p9G7W9PF_Z3qCkZP_21vJPbmbiul8PkiEdjpwr0AY3Cbt6O0nft6dvDtQ=080C74FD"
JIRA_API = "https://letritrung2605.atlassian.net/rest/api/3/issue"
AUTH = base64.b64encode(f"{EMAIL}:{TOKEN}".encode()).decode()

ASSIGNEE_TRUNG = "61bc48ad08e4e00069b20d6c"
TASK_TYPE = "10045"
PROJECT_KEY = "DA"
EPIC_E12 = "DA-92"

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

def api_call(method, url, body=None):
    data = json.dumps(body).encode() if body else None
    req = urllib.request.Request(url, data=data, method=method)
    req.add_header("Authorization", f"Basic {AUTH}")
    req.add_header("Content-Type", "application/json")
    try:
        with urllib.request.urlopen(req) as resp:
            body = resp.read().decode().strip()
            return resp.status, (json.loads(body) if body else {})
    except urllib.error.HTTPError as e:
        err = e.read().decode()[:500]
        return e.code, {"error": err}

def create_task(summary, description, epic_key, assignee_id=None):
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

def transition_to_done(issue_key):
    trans_url = f"{JIRA_API}/{issue_key}/transitions"
    status, resp = api_call("GET", trans_url)
    if status != 200:
        print(f"  ERROR fetching transitions for {issue_key}: {resp}")
        return
    done_id = None
    for t in resp.get("transitions", []):
        if t["name"].strip().lower() == "done":
            done_id = t["id"]
            break
    if not done_id:
        print(f"  WARN: no 'Done' transition found for {issue_key}, skipping")
        return
    status, resp = api_call("POST", trans_url, {"transition": {"id": done_id}})
    if status == 204:
        print(f"  {issue_key} -> Done")
    else:
        print(f"  ERROR transitioning {issue_key}: HTTP {status} {resp}")

TASKS = [
    {
        "summary": "[DA-E12-08] Implement Change Password (authenticated user updates their own password)",
        "title": "DA-E12-08 — Implement Change Password",
        "assignee_priority": "Assignee: Trung (Leader) | Priority: High",
        "goal": "Allow an authenticated user to change their own password, distinct from the Forgot/Reset Password flow (DA-E12-05) which is for users who cannot log in.",
        "criteria": [
            "POST /api/v1/auth/change-password requires a valid access token (Authorization header)",
            "ChangePasswordRequest DTO accepts currentPassword + newPassword, validates newPassword against the same strength rule as Register",
            "Verifies currentPassword matches the existing hash before allowing the change (401/400 if incorrect)",
            "Hashes newPassword with bcrypt cost=12, overwrites the current password",
            "Does not auto-logout other sessions (out of scope — password change only)",
        ],
        "notes": [
            "Code already implemented and committed (AuthController.changePassword, AuthService.changePassword, ChangePasswordRequest DTO).",
            "Commit message mistakenly referenced DA-160, which is actually the Forgot/Reset Password task (DA-E12-05) — a different feature. This task (DA-E12-08) is the correct Jira task for Change Password.",
        ],
        "deps": "Blocks: —. Blocked by: DA-E12-01, DA-E12-02.",
        "done": True,
    },
    {
        "summary": "[DA-E12-09] Implement Facebook OAuth login (callback, create user if not yet registered)",
        "title": "DA-E12-09 — Implement Facebook OAuth login",
        "assignee_priority": "Assignee: Trung (Leader) | Priority: High",
        "goal": "Allow users to sign in with their Facebook account, using the same backend-driven OAuthController/OAuthService flow shared with Google OAuth (DA-E12-06) and GitHub OAuth (DA-E12-10).",
        "criteria": [
            "GET /api/v1/auth/oauth/facebook redirects to Facebook's authorization URL",
            "GET /api/v1/auth/oauth/facebook/callback exchanges the code, creates a new user if the email doesn't exist, issues JWT + refresh cookie, redirects to FE /oauth-callback?token=...",
            "OAuthProvider enum has a FACEBOOK value (already existed prior to this change)",
            "An existing email registered via password login is linked to the Facebook account (merge, not duplicate)",
        ],
        "notes": [
            "Uses the shared OAuthController unified endpoint /api/v1/auth/oauth/{provider} — no per-provider controller.",
            "Configure OAuthProperties for Facebook's clientId/clientSecret/redirectUri in application.yml + .env.",
        ],
        "deps": "Blocks: —. Blocked by: DA-E12-01, DA-E12-02.",
        "done": False,
    },
    {
        "summary": "[DA-E12-10] Implement GitHub OAuth login (callback, create user if not yet registered)",
        "title": "DA-E12-10 — Implement GitHub OAuth login",
        "assignee_priority": "Assignee: Trung (Leader) | Priority: High",
        "goal": "Allow users to sign in with their GitHub account, using the same backend-driven OAuthController/OAuthService flow shared with Google OAuth (DA-E12-06) and Facebook OAuth (DA-E12-09).",
        "criteria": [
            "GET /api/v1/auth/oauth/github redirects to GitHub's authorization URL",
            "GET /api/v1/auth/oauth/github/callback exchanges the code, creates a new user if the email doesn't exist, issues JWT + refresh cookie, redirects to FE /oauth-callback?token=...",
            "OAuthProvider enum adds a GITHUB value (newly added in this change)",
            "An existing email registered via password login is linked to the GitHub account (merge, not duplicate)",
        ],
        "notes": [
            "Uses the shared OAuthController unified endpoint /api/v1/auth/oauth/{provider} — no per-provider controller.",
            "Configure OAuthProperties for GitHub's clientId/clientSecret/redirectUri in application.yml + .env.",
            "GitHub does not return email in the default token response if the user has it set to private — call GET /user/emails if email is null from the profile response.",
        ],
        "deps": "Blocks: —. Blocked by: DA-E12-01, DA-E12-02.",
        "done": False,
    },
]

if __name__ == "__main__":
    print("=" * 60)
    print("CREATING 3 AUTH TASKS UNDER EPIC E12 (DA-92)")
    print("=" * 60)

    created = []
    for task in TASKS:
        desc = build_description(
            task["title"], task["assignee_priority"], task["goal"],
            task["criteria"], task["notes"], task["deps"]
        )
        key = create_task(task["summary"], desc, EPIC_E12, ASSIGNEE_TRUNG)
        if key:
            created.append((key, task["done"]))

    print(f"\n-- Transitioning statuses --")
    for key, done in created:
        if done:
            transition_to_done(key)

    print(f"\n{'=' * 60}")
    print(f"DONE. Tasks created: {len(created)}/3")
    if len(created) < 3:
        print(f"MISSING: {3 - len(created)} tasks failed. Check errors above.")
    print(f"{'=' * 60}")
