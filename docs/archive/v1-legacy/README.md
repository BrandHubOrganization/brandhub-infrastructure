# V1 Legacy & Superseded Artifacts (`docs/archive/v1-legacy/`)

> Navigation: [← Knowledge Base Hub](../../index.md) · [← Archive Hub](../README.md) · [Active Architecture](../../architecture/README.md) · [Active BA Baseline](../../ba/README.md)

Historical V1 specifications, legacy `Uibrandhubs` Figma prototype reports, and pre-141-FR planning snapshots retained strictly for project evolution traceability. **Never use these files for active implementation**—always follow the canonical V2/V3 replacements linked below.

---

## 1. Superseded Architecture, Database & AI Drafts

| Archived Artifact | Historical Context | Canonical V2/V3 Replacement |
| :--- | :--- | :--- |
| [DA-E06-04-indexing-strategy.md](./DA-E06-04-indexing-strategy.md) | V1 indexing strategy (`15` PostgreSQL tables / `8` MongoDB collections) prior to introducing Agency, Media Package/Campaign, Billing V3, and Client Vault | [Database Hub](../../database/README.md) (`database/init/init-postgres-v2.sql` `97` tables & `database/init/init-mongo.js` `52` collections) |
| [ai-iteration-1-report-an.md](./ai-iteration-1-report-an.md) | Early draft of Ân's AI Iteration 1 research notes | [plan/iterations/iteration-1/members/anha.md](../../plan/iterations/iteration-1/members/anha.md) |
| [DA-RS256-jwt-flow.html](/view?file=archive/v1-legacy/DA-RS256-jwt-flow.html) | Legacy static HTML export of the RS256 JWT specification | [api/rs256-jwt-flow.md](../../api/rs256-jwt-flow.md) |
| [arch-reference-style.html](/view?file=archive/v1-legacy/arch-reference-style.html) | Legacy HTML diagram styling snippet | [architecture/README.md](../../architecture/README.md) |
| `system-architecture-v1.drawio` | Superseded V1 Draw.io topology source | [architecture/README.md](../../architecture/README.md) (`docs/architecture/system/system-architecture.drawio`) |

---

## 2. Archived V1 `Uibrandhubs` Prototype & Figma Reports (`DA-E08`)

| Archived Report | Historical Context | Canonical V2/V3 Replacement |
| :--- | :--- | :--- |
| [wireframe-overview-report.md](./wireframe-overview-report.md) | V1 7-screen low-to-mid fidelity Figma wireframe report (`DA-E08-01`) before adding Agency, Package/Campaign, Collaborators, and Admin Console | [wireframe/wireframe-blueprint.md](../../wireframe/wireframe-blueprint.md) |
| [components-report.md](./components-report.md) | V1 initial CSS token & 6-component report (`DA-E08-02`) | [wireframe/README.md](../../wireframe/README.md) & [wireframe-to-code-checklist.md](../../wireframe/wireframe-to-code-checklist.md) |
| [flows-report.md](./flows-report.md) | V1 3-flow Figma frame connector report (`DA-E08-03`) using pre-canonical V1 frame labels | [ba/12-state-machines.md](../../ba/12-state-machines.md) & [wireframe/wireframe-blueprint.md](../../wireframe/wireframe-blueprint.md) |
| [install-animate-report.md](./install-animate-report.md) | Early animation spike report from the retired `Uibrandhubs/` prototype directory | [wireframe/README.md](../../wireframe/README.md) (`brandhub-web` `motion` `12.43` + `gsap` `3.15`) |

---

## 3. Archived Pre-141-FR Planning Snapshots

| Archived Plan | Historical Context | Canonical V2/V3 Replacement |
| :--- | :--- | :--- |
| [document-plan.md](./document-plan.md) | Earlier 109/125-FR documentation inventory prior to locking the 141 Atomic FR baseline | [feature/README.md](../../feature/README.md) & [ba/README.md](../../ba/README.md) |
| [report2-fix-checklist.md](./report2-fix-checklist.md) | Historical Report 2 remediation checklist completed during V1→V2 alignment | [ba/README.md](../../ba/README.md) |
| [ai-features-spec-alignment-plan.md](./ai-features-spec-alignment-plan.md) | Transitional alignment plan for `3.7 AI Features` before completing all 19 AI FR specs | [ba/06-ai-features.md](../../ba/06-ai-features.md) & [feature/srs/06-ai-features/README.md](../../feature/srs/06-ai-features/README.md) |
