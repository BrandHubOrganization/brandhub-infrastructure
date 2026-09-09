#!/usr/bin/env python3
"""Assign unassigned Jira tasks in non-AI, post-Sprint6 epics per BrandHub_Master_Plan.md.

Excludes E23/E24 (AI Service wiring, kept unassigned for Loc's AI team) and E48
(AI iteration reports). Covers E17-E22, E28-E33, E37-E46. "All (Team)" tasks in
the plan are assigned to Trung as team representative, per user decision.

Usage: python assign_post_sprint6_epics.py
"""

import json, urllib.request, urllib.error, base64

EMAIL = "letritrung2605@gmail.com"
TOKEN = "ATATT3xFfGF0hOu_QP0K9NHqnGgsrxko4pKSzqkTXX2nm1YWWBm-g9KGqEEe0h1h90vbBdEskz9EoWDc3s2sB3WMnqNedf2RzztO0R0FwLqNs4vIotf4_r9kajvHL4p9G7W9PF_Z3qCkZP_21vJPbmbiul8PkiEdjpwr0AY3Cbt6O0nft6dvDtQ=080C74FD"
AUTH = base64.b64encode(f"{EMAIL}:{TOKEN}".encode()).decode()
BASE = "https://letritrung2605.atlassian.net/rest/api/3/issue"

TRUNG = "61bc48ad08e4e00069b20d6c"
PHUOC = "712020:d2f784a1-44cf-468f-bb96-cd8930b1c135"
AN = "712020:b501eda5-2140-417d-bc3a-c942db8310cc"
LOC = "712020:5ec38295-3d34-4ff3-ae87-95279adf1dff"
TUAN = "712020:198f8574-4327-4e82-8674-275f3b950db0"

ASSIGNMENTS = {
    TRUNG: [215, 230, 247, 228, 232, 250, 267, 283, 359, 293, 307, 322, 335,
            300, 317, 363, 301, 314, 329, 340, 348, 364, 378, 385, 379,
            399, 395, 382, 390, 396, 402, 383, 403, 384,
            # "All (Team)" tasks -> Trung
            388, 400, 377, 389, 404, 376, 391, 401],
    PHUOC: [212, 244, 280, 259, 275, 216, 282, 245, 264, 349, 365, 302, 318,
            333, 347, 361, 304, 321, 357, 362, 369, 315, 331, 370, 394,
            398, 374, 380, 386, 393, 397, 372, 387, 392, 381],
    AN: [263, 354, 371],
    LOC: [334, 350, 375],
    TUAN: [373],
}

def api_call(method, url, body=None):
    data = json.dumps(body).encode() if body else None
    req = urllib.request.Request(url, data=data, method=method)
    req.add_header("Authorization", f"Basic {AUTH}")
    req.add_header("Content-Type", "application/json")
    try:
        with urllib.request.urlopen(req) as resp:
            return resp.status, (resp.read().decode() or "{}")
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode()[:300]

def assign(issue_num, account_id, name):
    key = f"DA-{issue_num}"
    url = f"{BASE}/{key}/assignee"
    status, body = api_call("PUT", url, {"accountId": account_id})
    if status == 204:
        print(f"  OK   {key} -> {name}")
    else:
        print(f"  FAIL {key} -> {name}: HTTP {status} {body}")

if __name__ == "__main__":
    names = {TRUNG: "Trung", PHUOC: "Phuoc", AN: "An", LOC: "Loc", TUAN: "Tuan"}
    total = sum(len(v) for v in ASSIGNMENTS.values())
    print(f"Assigning {total} tasks across 5 people...")
    for account_id, issues in ASSIGNMENTS.items():
        name = names[account_id]
        print(f"\n-- {name} ({len(issues)} tasks) --")
        for num in issues:
            assign(num, account_id, name)
    print("\nDone.")
