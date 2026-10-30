#!/usr/bin/env python3
"""Block private credentials and database snapshots by path, including binary files."""
import subprocess
import sys
from pathlib import PurePosixPath


def blocked(path):
    path = path.replace("\\", "/")
    parts = PurePosixPath(path).parts
    name = parts[-1].lower() if parts else ""
    if name == ".env" or (name.startswith(".env.") and name != ".env.example"):
        return True
    if name.endswith((".dump", ".rdb", ".p12", ".pfx", ".jks")):
        return True
    if "backups" in parts and name.endswith((".sql", ".ejson", ".bson", ".archive", ".gz", ".zip")):
        return True
    if name.endswith((".pem", ".key")) and name != "public.pem" and "test" not in parts:
        return True
    return False


def main():
    if "--history" in sys.argv:
        index = sys.argv.index("--history")
        if index + 1 >= len(sys.argv):
            return 2
        revision = sys.argv[index + 1]
        import re
        if not re.fullmatch(r"[0-9a-f]{40,64}(?:\.\.[0-9a-f]{40,64})?", revision):
            return 2
        output = subprocess.check_output(["git", "rev-list", "--objects", revision, "--"])
        paths = [line.partition(" ")[2] for line in output.decode("utf-8", errors="replace").splitlines() if " " in line]
    else:
        staged = "--staged" in sys.argv
        args = ["git", "diff", "--cached", "--name-only", "--diff-filter=ACMR", "-z"] if staged else ["git", "ls-files", "-z"]
        paths = subprocess.check_output(args).decode("utf-8", errors="replace").split("\0")
    hits = [p for p in paths if p and blocked(p)]
    for path in hits:
        print("Sensitive path blocked: " + path, file=sys.stderr)
    return 1 if hits else 0


if __name__ == "__main__":
    sys.exit(main())
