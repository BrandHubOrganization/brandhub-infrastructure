# Project Planning, Sprint Roadmaps & Engineering Audits (`docs/plan/`)

> Navigation: [← Knowledge Base Hub](../index.md) · [Workload Dashboard](../dashboard.md) · [BA Baseline](../ba/README.md) · [Feature Specifications](../feature/README.md) · [V1 Legacy Archive](../archive/v1-legacy/README.md)

This directory governs BrandHub's active multi-sprint execution plan, the 5-iteration AI Parallel Track roadmap, machine-readable Jira progress telemetry (`jira-status.json`), and sprint/codebase audit trails.

---

## 1. Master Execution Plans & Live Telemetry

| Document / Artifact | Scope & Purpose |
| :--- | :--- |
| [sprint-plan-v2-overview.md](./sprint-plan-v2-overview.md) | High-level Sprint Plan V2 milestone timeline, team capacity allocation across the 5 members, and architectural transition summary (`Agency → Workspace → Media Package → Media Campaign → Task`). |
| [brandhub-master-plan.md](./brandhub-master-plan.md) | Authoritative task-by-task master plan (`DA-*` epics & subtasks) with acceptance criteria aligned to the **6 Canonical Roles** (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`), **4 social platforms** (**Facebook, Instagram, TikTok, Threads**), and **SePay (VietQR)** billing. |
| `docs/plan/jira-status.json` | Machine-readable Jira issue export generated via `scripts/jira/export-jira.js`, powering the interactive [Workload Dashboard](../dashboard.md). |

---

## 2. AI Parallel Track & Engineering Audits

| Subdirectory | Entry Point | Contents |
| :--- | :--- | :--- |
| **`iterations/`** | [iterations/README.md](./iterations/README.md) | **AI Parallel Track Iterations (`1`–`5`)**: Research & Evaluation (`AI-01`–`AI-02`), Hybrid GraphRAG & LLM (`AI-03`–`AI-05`), Image/Virtual Ambassador/Composition (`AI-06`–`AI-08`), Video Synthesis & Integration (`AI-09`–`AI-11`), and BM25 + Neo4j Trend Knowledge Graph V2, plus the completed [Iteration 1 Team & Member Reports](./iterations/iteration-1/iteration-report.md). |
| **`audit/`** | [audit/README.md](./audit/README.md) | **Sprint, API & UX Audits**: Chronological Jira status & rebalance audits (`2026-07-11`, `2026-08-03`, `2026-09-03`), 72-task English summary cleanup log, Backend REST API completeness audit, and 27-screen Frontend real-time UX validation audit (`2026-10-15`). |

---

## 3. Superseded Pre-141-FR Planning Snapshots

Early planning snapshots written before finalizing the **141 Atomic FR baseline** (`document-plan.md`, `report2-fix-checklist.md`, and `ai-features-spec-alignment-plan.md`) have been consolidated into the [V1 Legacy Archive](../archive/v1-legacy/README.md) for historical traceability.
