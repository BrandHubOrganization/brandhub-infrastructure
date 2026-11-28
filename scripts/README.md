# Operational, Security & Workspace Automation Scripts (`scripts/`)

Authoritative manual for BrandHub's workspace bootstrap, database schema baseline checks, Jira workload synchronization, S3 repository envelope-encryption migration, and sensitive-path Git/CI guards.

- Back to [Infrastructure Hub](../README.md)
- Secret Scanning & Cryptographic Policy: [`../SECURITY.md`](../SECURITY.md)
- Local Docker Compose Launchers (`run_dev.bat`, `run_dev_ai.bat`): [`../docker/README.md`](../docker/README.md)

> **Lifecycle Note**: Local infrastructure startup is handled by [`../docker/run_dev.bat`](../docker/run_dev.bat), [`../docker/run_dev_ai.bat`](../docker/run_dev_ai.bat), and the sibling `run-brandhub` desktop controller. Legacy `start-all.*`, `start-no-mobile.*`, and `repository-migrate.ps1` scripts were retired.

---

## 1. Directory Layout

```text
scripts/
├── README.md                                           # Complete scripts manual (this file)
├── workspace/
│   └── clone-all.bat                                   # Clones or pulls all 7 BrandHubOrganization repositories
├── database/
│   └── check-media-package-baseline.ps1                # Guards init-postgres-v2.sql against retired Media Package columns
├── security/
│   └── check_sensitive_paths.py                        # Blocks .env, private keys & DB dumps in .githooks/ and CI
├── jira/
│   ├── README.md                                       # Jira REST API v3 sync & VitePress Workload Dashboard guide
│   └── export-jira.js                                  # Exports [DA-*] tasks to docs/plan/jira-status.json
└── repository-encryption/
    ├── README.md                                       # Pre-S3 AWS Encryption SDK architecture & operator runbook
    └── EncryptExistingRepository.java                  # Dry-run-first S3 ciphertext migration with SHA-256 + If-Match
```

---

## 2. Multi-Repository Workspace Sync (`workspace/clone-all.bat`)

[`workspace/clone-all.bat`](workspace/clone-all.bat) resolves the parent workspace folder (`%~dp0..\..\..`, e.g., `d:\ProjectCode\BrandHub`) and clones (if absent) or runs `git pull` across all **7 core `BrandHubOrganization` repositories**:

1. `brandhub-ai-service` (Python 3.11+ FastAPI AI, RAG, Trend & Video Director)
2. `brandhub-api-gateway` (Java 21 Spring Cloud Gateway WebFlux)
3. `brandhub-business-service` (Java 21 Spring Boot Core Domain, RBAC & SePay Billing)
4. `brandhub-infrastructure` (Terraform, Docker Compose, DB DDL/Migrations, GPU Workers & Docs)
5. `brandhub-mobile-app` (Expo SDK 58 / React Native 0.88 Mobile Client)
6. `brandhub-publisher-service` (Java 21 Spring Boot RabbitMQ Consumer & 4 Social Adapters)
7. `brandhub-web` (React 19 / Vite 8 / Tailwind CSS 4 Web SPA)

*(Note: `brandhub-crawl` and `run-brandhub` can also sit alongside these siblings when working on crawler runtime or desktop runner tooling.)*

```cmd
scripts\workspace\clone-all.bat
```

- Exits non-zero (`exit /b 1`) if Git is missing, if a target folder exists without `.git`, or if any `git clone` / `git pull` fails.

---

## 3. Database Schema Baseline Guard (`database/check-media-package-baseline.ps1`)

[`database/check-media-package-baseline.ps1`](database/check-media-package-baseline.ps1) validates [`../database/init/init-postgres-v2.sql`](../database/init/init-postgres-v2.sql) against schema regressions:

- Confirms `CREATE TABLE IF NOT EXISTS media_packages` defines `offering_details JSONB`.
- Rejects accidental re-introduction of retired `package_type` / `offering_model` columns or `CREATE TYPE package_type`.
- Asserts that retired duplicate SQL files (`docs/database/init-postgres-v2.sql`, `scripts/init-postgres-v2.sql`, `docs/database/seeds/2026-10-07-refresh-admin-media-templates.sql`, `docs/database/migrations/2026-10-06-media-package-offering-model.sql`) do not exist in the working tree.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/database/check-media-package-baseline.ps1
```

---

## 4. Sensitive Path & Binary Snapshot Blocker (`security/check_sensitive_paths.py`)

Regex-based secret scanners skip binary archives or unindexed keystores. [`security/check_sensitive_paths.py`](security/check_sensitive_paths.py) complements **Gitleaks 8.30.1** ([`../.gitleaks.toml`](../.gitleaks.toml)) by inspecting file paths directly across three execution modes:

| Invocation Mode | Command | Enforced By |
| :--- | :--- | :--- |
| **Tracked Repository Files** | `python3 scripts/security/check_sensitive_paths.py` | GitHub Actions CI ([`../.github/workflows/secret-scanning.yml`](../.github/workflows/secret-scanning.yml)) |
| **Staged Index (`ACMR`)** | `python3 scripts/security/check_sensitive_paths.py --staged` | Local [`.githooks/pre-commit`](../.githooks/pre-commit) |
| **Commit History Range** | `python3 scripts/security/check_sensitive_paths.py --history <base_sha>..<head_sha>` | Local [`.githooks/pre-push`](../.githooks/pre-push) |

### Blocked Path Rules (`blocked(path)`)

1. **Environment Files**: Any `.env` or `.env.*` file anywhere in the tree **except** `.env.example`.
2. **Database & Keystore Binaries**: Any `*.dump`, `*.rdb`, `*.p12`, `*.pfx`, or `*.jks` file.
3. **Backup Snapshots**: Any file under a `backups/` path segment ending in `.sql`, `.ejson`, `.bson`, `.archive`, `.gz`, or `.zip`.
4. **Private Asymmetric Keys**: Any `*.pem` or `*.key` file **except** `public.pem` or synthetic fixtures inside a `test/` directory segment.

---

## 5. Specialized Tooling Subdirectories

- **Jira Workload Dashboard Exporter (`jira/`)**: Node.js zero-dependency Jira REST API v3 exporter generating `docs/plan/jira-status.json` — see [`jira/README.md`](jira/README.md).
- **S3 Repository Pre-Encryption Migration (`repository-encryption/`)**: AWS Encryption SDK (`aws-esdk-v1`) in-place S3 migration utility for `repository/*` and `client-vault/*` — see [`repository-encryption/README.md`](repository-encryption/README.md).
