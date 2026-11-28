# Project, API & UX Engineering Audit Logs (`docs/plan/audit/`)

> Navigation: [← Knowledge Base Hub](../../index.md) · [← Project Plans](../README.md) · [Master Plan](../brandhub-master-plan.md) · [BA 141-FR Baseline](../../ba/README.md) · [Workload Dashboard](../../dashboard.md)

This directory archives formal point-in-time engineering audits conducted across BrandHub's development sprints—covering Jira ticket hygiene, sprint velocity and workload rebalancing across the 5 engineers, backend REST controller completeness, and 27-screen frontend real-time input validation.

> **Historical Scope Note:** Point-in-time audit reports from July–September 2026 (`2026-07-11` through `2026-09-03`) preserve exact historical Jira ticket titles and V1 gap findings captured at the time of each audit (including tickets that were subsequently de-scoped or replaced during the V2 `SePay VietQR` / `141-FR` cutover). Always consult [ba/README.md](../../ba/README.md) and [feature/srs/README.md](../../feature/srs/README.md) for the active production baseline.

---

## 1. Chronological Audit Ledger

| Audit Date | Audit Report | Audited Scope & Outcome |
| :--- | :--- | :--- |
| `2026-07-11` | [jira-status-audit-2026-07-11.md](./jira-status-audit-2026-07-11.md) | **Post-Sprint 4 Jira & Workload Rebalance Audit**: Reconciled sprint ticket statuses against merged PRs and rebalanced cross-track blockers ahead of Sprint 5. |
| `2026-08-03` | [jira-status-audit-2026-08-03.md](./jira-status-audit-2026-08-03.md) | **Mid-Project Epic Completion Audit**: Verified mid-capstone milestone velocity across Core Backend, Web UI, Mobile, and AI Parallel Track epics. |
| `2026-09-03` | [jira-status-audit-2026-09-03.md](./jira-status-audit-2026-09-03.md) | **Pre-V2 Transition Backlog Audit**: Audited remaining V1 tickets, removed out-of-scope social adapters, and established the clean cutover baseline for the `Agency → Workspace → Package → Campaign → Task` V2 expansion. |
| `2026-09-03` | [jira-language-cleanup-tracking-2026-09-03.md](./jira-language-cleanup-tracking-2026-09-03.md) | **Jira Summary English Standardization**: Tracked and completed (`72/72` Done) rewriting legacy Vietnamese/mixed Jira issue summaries into canonical English `[DA-Exx-yy]` format. |
| `2026-09-03` | [backend-api-completeness-audit-2026-09-03.md](./backend-api-completeness-audit-2026-09-03.md) | **Backend REST API Completeness Audit**: Endpoint-by-endpoint gap review across `brandhub-business-service`, `brandhub-publisher-service`, and `brandhub-ai-service` prior to V2 SePay & multi-tenant billing implementation. |
| `2026-10-15` | [2026-10-15-ux-realtime-input-audit.md](./2026-10-15-ux-realtime-input-audit.md) | **27-Screen Frontend Real-Time UX Validation Audit**: Screen-by-screen audit of `brandhub-web` forms, modals, OTP/avatar flows, debounced validation, and destructive-action confirmation dialogs across `FR 3.3`–`3.4`. |

---

## 2. Live Jira Telemetry Refresh

- The interactive [Workload Dashboard](../../dashboard.md) joins [brandhub-master-plan.md](../brandhub-master-plan.md) with `docs/plan/jira-status.json` at runtime (`/raw/plan/*`).
- To refresh `docs/plan/jira-status.json` from Jira Cloud REST API v3, run `node scripts/jira/export-jira.js` following the credentials setup in `scripts/jira/README.md` and [guides/jira-claude-setup.md](../../guides/jira-claude-setup.md).

---

## 3. Related Governance References

- **Sprint Execution Roadmaps (`Sprints 1–16`)**: [sprint-plan-v2-overview.md](../sprint-plan-v2-overview.md)
- **8-Step Team Delivery Lifecycle**: [guides/team-workflow-guide.md](../../guides/team-workflow-guide.md)
- **Git Branch, Commit & PR Hygiene**: [rule/git-commit-convention.md](../../rule/git-commit-convention.md)
