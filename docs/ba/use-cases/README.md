# Use Cases — Master Catalog & Actor Traceability (`UC-001` – `UC-141`)

> Navigation: [← Knowledge Base Hub](../../index.md) · [← BA Overview & Baseline](../README.md) · [Feature Specifications (`srs/`) →](../../feature/README.md)

This directory contains the canonical **141 Atomic Use Case Specifications (`UC-001` – `UC-141`)**, aligned 1-to-1 with the **141 Functional Requirements (`3.2.1` – `3.10.14`)** in `Các FR của hệ thống  - Feature_Function Requirement.csv` and `brandhub-final_report/report3/report3_official.docx`.

---

## 1. Canonical Use Case Standards

- **6 Canonical Actors Only**: `Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin` (never use legacy or generic names such as `Agency Owner`, `Workspace Manager`, `Account Manager`, `Content Creator`, `Brand Client`, `System Administrator`, or `Authenticated User`).
- **Zero `"Manage"` Rule**: Every Use Case represents a single, independent, atomic user/system action.
- **4 Social Platforms**: **Facebook, Instagram, TikTok, and Threads**.
- **Payment Gateway**: **SePay (VietQR)** (`Upgrade Plan` `UC-122` · `Make Payment (SePay)` `UC-123` · `Buy Credit` `UC-126`).

---

## 2. Domain Specification Index (`UC-001` – `UC-141`)

| Specification File | SRS Domain(s) | FR Range | Use Case Range | Count |
| :--- | :--- | :-: | :-: | :-: |
| [01-authentication-profile.md](./01-authentication-profile.md) | `3.2 Authentication & Authorization`<br/>`3.3 User & Client Profile` | `3.2.1` – `3.2.9`<br/>`3.3.1` – `3.3.4` | `UC-001` – `UC-009`<br/>`UC-010` – `UC-013` | **13** *(9 + 4)* |
| [02-agency-workspace.md](./02-agency-workspace.md) | `3.4 Agency & Workspace` *(incl. `Personal Studio`)* | `3.4.1` – `3.4.26` | `UC-014` – `UC-039` | **26** |
| [03-media-package-campaign.md](./03-media-package-campaign.md) | `3.5 Media Package & Media Campaign` | `3.5.1` – `3.5.13` | `UC-040` – `UC-052` | **13** |
| [04-content-task-workflow.md](./04-content-task-workflow.md) | `3.6 Content & Workflow` *(8 `TaskType`s & `TaskSection`s)* | `3.6.1` – `3.6.35` | `UC-053` – `UC-087` | **35** |
| [05-ai-features.md](./05-ai-features.md) | `3.7 AI Features` *(Trends, Brand RAG, AI Studio, Collaborators)* | `3.7.1` – `3.7.19` | `UC-088` – `UC-106` | **19** |
| [06-publishing-social.md](./06-publishing-social.md) | `3.8 Publishing & Social` *(Facebook, Instagram, TikTok, Threads)* | `3.8.1` – `3.8.15` | `UC-107` – `UC-121` | **15** |
| [07-subscription.md](./07-subscription.md) | `3.9 Subscription & Billing` *(SePay VietQR & AI Credit Wallets)* | `3.9.1` – `3.9.6` | `UC-122` – `UC-127` | **6** |
| [08-admin-functions.md](./08-admin-functions.md) | `3.10 Admin Functions` | `3.10.1` – `3.10.14` | `UC-128` – `UC-141` | **14** |
| **Total** | **9 Canonical Functional Domains** | **`3.2.1` – `3.10.14`** | **`UC-001` – `UC-141`** | **141** |

---

## 3. Actor Participation Traceability Matrix (6 Canonical Roles)

| Canonical Actor | Enum Constant | Participating UCs | Exact Use Case Coverage |
| :--- | :---: | :-: | :--- |
| **`Guest`** | `GUEST` | **5** | `UC-001` – `UC-004`, `UC-006` *(plus public `ShareLink` `/s/:token` viewing and public survey submission)* |
| **`Owner`** | `OWNER` | **126** | `UC-002` – `UC-099`, `UC-101` – `UC-127`, `UC-137` |
| **`Manager`** | `MANAGER` | **108** | `UC-002` – `UC-014`, `UC-016` – `UC-017`, `UC-021` – `UC-023`, `UC-025` – `UC-026`, `UC-028` – `UC-029`, `UC-031`, `UC-036` – `UC-039`, `UC-041` – `UC-099`, `UC-101` – `UC-121`, `UC-125` |
| **`Creator`** | `CREATOR` | **76** | `UC-002` – `UC-011`, `UC-014`, `UC-016` – `UC-017`, `UC-021` – `UC-023`, `UC-025` – `UC-026`, `UC-028`, `UC-031`, `UC-036`, `UC-045`, `UC-053`, `UC-055` – `UC-066`, `UC-070` – `UC-077`, `UC-079` – `UC-090`, `UC-093` – `UC-099`, `UC-101`, `UC-109` – `UC-121` |
| **`Client`** | `CLIENT` | **58** | `UC-002` – `UC-014`, `UC-017`, `UC-021` – `UC-023`, `UC-025` – `UC-026`, `UC-028`, `UC-031`, `UC-036`, `UC-041` – `UC-043`, `UC-045` – `UC-047`, `UC-049` – `UC-053`, `UC-055` – `UC-061`, `UC-063` – `UC-064`, `UC-067` – `UC-069`, `UC-071`, `UC-074`, `UC-078`, `UC-087`, `UC-090` – `UC-092`, `UC-107` – `UC-111`, `UC-113` |
| **`Admin`** | `ADMIN` | **27** | `UC-002` – `UC-011`, `UC-014`, `UC-089`, `UC-100`, `UC-128` – `UC-141` |
