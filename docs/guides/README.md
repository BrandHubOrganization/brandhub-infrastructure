# Developer & Team Operational Guides (`docs/guides/`)

> Navigation: [← Knowledge Base Hub](../index.md) · [← Engineering Rules](../rule/README.md) · [Architecture Decisions →](../adr/README.md) · [Operations Runbooks →](../operations/README.md)

Step-by-step execution playbooks for all 5 BrandHub engineers covering the full Jira ticket lifecycle (`DA-xxx`), official capstone report synchronization (`Report 3 SRS` & `Report 4 SDD`), dual-track database migrations, and Jira REST / MCP automation.

---

## 1. Authoritative Engineering Playbooks

| Guide | Audience | Scope & Key Checkpoints |
| :--- | :---: | :--- |
| [Team Workflow Guide — 8-Step Feature Lifecycle](./team-workflow-guide.md) | All BE, FE, Mobile & AI Engineers | Mandatory 8-step delivery pipeline: (1) Jira pickup & ad-hoc ticket rules → (2) `brandhub-final_report` SRS/SDD sync → (3) BA & `spec.md` review → (4) `spec → plan → task → test` authoring → (5) BE/FE implementation (`ApiResponse<T>`, `vi.json`/`en.json`, Light/Dark tokens) → (6) English conventional commits & squash PR to `develop` → (7) UI screenshot capture (`Figure X - <Function Name>`) → (8) 141-FR CSV baseline update + Dual-track DB migration governance (`database/init/` + `database/migrations/`). |
| [Jira + Claude Code Setup Guide](./jira-claude-setup.md) | All Team Members | Configuring Atlassian API tokens, MCP server integration, direct Jira REST v3 `curl` workflows, custom sprint fields, and verified Jira Account IDs for all 5 project members (`Trung`, `Lộc`, `Tuấn`, `Ân`, `Phước`). |

---

## 2. Mandatory Pre-PR Verification Checklist

1. **Specification & Role Alignment:** Every FR or module change updates its corresponding `spec.md → plan.md → task.md → test.md` chain under [feature/README.md](../feature/README.md) using strictly the **6 Canonical Roles** (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
2. **Dual-Track Schema Discipline:** Any PostgreSQL, MongoDB, or Neo4j schema modification updates both the fresh-bootstrap script in `database/init/` and an incremental migration script in `database/migrations/` (see [database/README.md](../database/README.md)).
3. **Secret & Sensitive Path Hygiene:** Local `.githooks/pre-commit` (`gitleaks` + `scripts/security/check_sensitive_paths.py`) passes with zero findings before pushing to GitHub.
4. **Docs Portal Integrity:** Any newly added or renamed Markdown file inside `docs/` passes `npm run build` inside `docs-site/` with zero broken links.

---

## 3. Quick Governance Cross-References

- **4-Document Feature Specification Standard**: [rule/feature-workflow.md](../rule/feature-workflow.md)
- **Git Branch, Commit & PR Naming Standard**: [rule/git-commit-convention.md](../rule/git-commit-convention.md)
- **Interactive Team Rules Visual Board**: [Team Rules Board](/view?file=rule/team-rules.html)
- **6 Canonical Roles & 141 Atomic FR Baseline**: [ba/README.md](../ba/README.md)
- **Polyglot Database & Migration Architecture**: [database/README.md](../database/README.md)
