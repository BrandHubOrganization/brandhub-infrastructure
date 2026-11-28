# Mandatory Engineering & Team Rules (`docs/rule/`)

> Navigation: [← Knowledge Base Hub](../index.md) · [Developer Guides →](../guides/README.md) · [BA Baseline & Canonical Roles →](../ba/README.md)

This directory defines the **non-negotiable engineering standards, specification gates, Git conventions, and team SLA charter** enforced across all 7 repositories in the BrandHub polyrepo ecosystem (`brandhub-infrastructure`, `brandhub-api-gateway`, `brandhub-business-service`, `brandhub-ai-service`, `brandhub-publisher-service`, `brandhub-web`, and `brandhub-mobile-app`).

---

## 1. Core Governance Specifications

| Rule Document | Format | Mandatory Enforcement Scope |
| :--- | :---: | :--- |
| [Feature Workflow (`spec → plan → task → test`)](./feature-workflow.md) | Markdown | Requires every SRS FR (`docs/feature/srs/01..09-*/`) and cross-cutting module (`docs/feature/modules/*/`) to maintain all 4 lifecycle files (`spec.md`, `plan.md`, `task.md`, `test.md`), strict **6 Canonical Roles** (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`), bilingual `vi.json` + `en.json` keys, and semantic Light/Dark UI tokens. |
| [Git Commit, Branch & PR Convention](./git-commit-convention.md) | Markdown | Enforces lowercase hyphenated branches (`<type>/DA-<id>-<kebab-case>`), English conventional commit messages (`<type>(DA-<id>): <short summary>`), Gitleaks + `check_sensitive_paths.py` pre-commit/CI checks, and **Squash and merge** PRs targeting `develop`. |
| [Team Working Rules (`team-rules.html`)](/view?file=rule/team-rules.html) | Interactive HTML | Official 5-member team charter governing sprint ceremonies, deadline SLAs, shared fund accountability, communication response windows, daily async standups, cross-service handoffs, and retrospectives. |

---

## 2. Non-Negotiable Domain Guardrails (`AGENTS.md` Sync)

1. **6 Canonical Role Names Only**: `Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin` — never use `Agency Owner`, `Workspace Manager`, `Account Manager`, `Content Creator`, `Brand Client`, or `System Administrator`.
2. **141 Atomic CRUD FRs (`3.2.1`–`3.10.14`)**: Zero `"Manage ..."` or `"... Management"` titles; 1-to-1 traceability with `UC-001`–`UC-141`.
3. **Strict Platform & Billing Scope**: Exactly **4 social platforms** (**Facebook, Instagram, TikTok, Threads** — no Zalo OA), **SePay (VietQR)** upgrade-only billing (no downgrade flow, no VNPay/PayOS/Stripe), no Livestream features, and no plagiarism/copyright check FR.

---

## 3. Related Operational References

- **8-Step Developer Execution Playbook**: [guides/team-workflow-guide.md](../guides/team-workflow-guide.md)
- **Feature Specifications Hub (`141 SRS FRs` + `Modules`)**: [feature/README.md](../feature/README.md)
- **System Architecture & Service Boundaries**: [architecture/README.md](../architecture/README.md)
