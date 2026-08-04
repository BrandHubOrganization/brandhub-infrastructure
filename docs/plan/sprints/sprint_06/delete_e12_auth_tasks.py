#!/usr/bin/env python3
"""Delete the 3 auth tasks created earlier (DA-609/610/611) so create_e12_auth_additions.py can be re-run cleanly.

Usage: python delete_e12_auth_tasks.py
"""

import urllib.request, urllib.error, base64

EMAIL = "letritrung2605@gmail.com"
TOKEN = "ATATT3xFfGF0hOu_QP0K9NHqnGgsrxko4pKSzqkTXX2nm1YWWBm-g9KGqEEe0h1h90vbBdEskz9EoWDc3s2sB3WMnqNedf2RzztO0R0FwLqNs4vIotf4_r9kajvHL4p9G7W9PF_Z3qCkZP_21vJPbmbiul8PkiEdjpwr0AY3Cbt6O0nft6dvDtQ=080C74FD"
AUTH = base64.b64encode(f"{EMAIL}:{TOKEN}".encode()).decode()
BASE = "https://letritrung2605.atlassian.net/rest/api/3/issue"

KEYS = ["DA-609", "DA-610", "DA-611"]

def delete(key):
    req = urllib.request.Request(f"{BASE}/{key}", method="DELETE")
    req.add_header("Authorization", f"Basic {AUTH}")
    try:
        with urllib.request.urlopen(req) as resp:
            print(f"  DELETED {key}: HTTP {resp.status}")
    except urllib.error.HTTPError as e:
        print(f"  FAIL {key}: HTTP {e.code} {e.read().decode()[:200]}")

if __name__ == "__main__":
    print("Deleting 3 auth tasks...")
    for key in KEYS:
        delete(key)
    print("Done.")
