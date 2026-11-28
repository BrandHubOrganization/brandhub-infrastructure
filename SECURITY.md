# Security Policy, Secret Scanning & Cryptographic Architecture

Authoritative security policy covering Git secret prevention, CI gates, asymmetric JWT authentication, social token encryption, S3 envelope cryptography, and incident/key-rotation procedures across **BrandHub**.

- Back to [Infrastructure Hub](README.md) · [Operational Scripts](scripts/README.md) · [Storage & KMS Terraform](prod/terraform/04-storage/README.md)

---

## 1. Secret Hygiene & ProhibitedTracked Artifacts

Never commit live database snapshots, private cryptographic keys, OAuth client secrets, API tokens, or credential-bearing URIs into Git or `.env.example` templates ([`.env.example`](.env.example), [`docker/compose/.env.example`](docker/compose/.env.example)).
- Local snapshots (`.dump`, `.ejson`, `.sql`, `.bson`, `.rdb`) belong strictly in private out-of-band storage; only gitignored local copies may sit inside `database/backups/` during local restores.
- **Exposure Rule**: Removing a leaked secret in a new commit does **not** revoke it. Any historical credential exposure requires **immediate upstream credential rotation** followed by coordinated Git history scrubbing.

---

## 2. Multi-Layer Secret Scanning (`Gitleaks 8.30.1` + `check_sensitive_paths.py`)

BrandHub enforces two complementary scanners across developer workstations and GitHub Actions:

1. **Path & Binary Blocker ([`scripts/security/check_sensitive_paths.py`](scripts/security/check_sensitive_paths.py))**: Rejects `.env` / `.env.*` (except `.env.example`), `*.dump`, `*.rdb`, `*.p12`, `*.pfx`, `*.jks`, `backups/*.{sql,ejson,bson,archive,gz,zip}`, and non-test private `*.pem` / `*.key` files (allowing `public.pem`), catching binary dumps that regex scanners skip.
2. **Content & Commit History Scanner ([`.gitleaks.toml`](.gitleaks.toml) with [Gitleaks 8.30.1](https://github.com/gitleaks/gitleaks/releases/tag/v8.30.1))**: Extends the default Gitleaks ruleset with custom rule `mongodb-embedded-password` (`mongodb(+srv)://user:pass@host`) and narrowly scoped `condition = "AND"` documentation fixture allowlists. All findings run with `--redact=100` so secret values never print in terminal or CI logs.

### Enabling Local Git Hooks (Mandatory on Every Clone)

Install **Python 3** and **Gitleaks 8.30.1**, then configure the repository's tracked `.githooks/` directory:

```bash
git config --local core.hooksPath .githooks

# Optional if gitleaks is not on system PATH:
git config --local brandhub.gitleaksPath /absolute/path/to/gitleaks
```

| Enforcement Gate | Implementation | What It Scans |
| :--- | :--- | :--- |
| **Local Pre-Commit** | [`.githooks/pre-commit`](.githooks/pre-commit) | Runs `check_sensitive_paths.py --staged` + `gitleaks protect --staged --config .gitleaks.toml --redact=100` on staged changes |
| **Local Pre-Push** | [`.githooks/pre-push`](.githooks/pre-push) | Computes `<remote_sha>..<local_sha>` (or `merge-base` against `origin/main` / `origin/develop`) and runs `check_sensitive_paths.py --history` + `gitleaks detect --log-opts` so stale clones cannot re-push scrubbed history |
| **GitHub Actions CI** | [`.github/workflows/secret-scanning.yml`](.github/workflows/secret-scanning.yml) | Verifies Gitleaks `8.30.1` binary SHA-256 (`551f6fc8...`), scans `git archive HEAD` + `check_sensitive_paths.py`, and scans `BASE_SHA..HEAD_SHA` on every PR targeting `main` or `develop` (required branch-protection check `secrets`) |

> **Allowlist Governance**: Never silence a Gitleaks alert by allowlisting broad source or documentation directories. Only review and allowlist exact synthetic placeholder lines (`condition = "AND"` pairing exact file path + anchored line regex in [`.gitleaks.toml`](.gitleaks.toml)).

---

## 3. Runtime Cryptographic Controls

| Security Boundary | Codebase Implementation | Key Material & Architectural Separation |
| :--- | :--- | :--- |
| **Asymmetric RS256 JWT Auth** | `JwtUtil` & `JwtAuthenticationFilter` (`brandhub-business-service`) ↔ `JwtAuthFilterGatewayFilterFactory` (`brandhub-api-gateway`) | **Strict Private/Public Split**: Only `brandhub-business-service` holds `JWT_PRIVATE_KEY` (RSA-2048 PKCS#8) to sign access (`15m`) and refresh (`30d`) tokens. `brandhub-api-gateway` holds **only** `JWT_PUBLIC_KEY` (`X.509`) to verify signatures at the edge and strip spoofed inbound identity headers via `InboundSecurityWebFilter`. |
| **Internal Service-to-Service Auth** | `X-Internal-Key` header across `business-service`, `ai-service`, `publisher-service`, and `crawl-service` | Validated with constant-time comparison (`INTERNAL_SERVICE_KEY`); internal ports (`8081`–`8084`) are additionally isolated by VPC Security Groups ([`prod/terraform/03-backend/security.tf`](prod/terraform/03-backend/security.tf)). |
| **Social OAuth Token Encryption (`AES-256-GCM`)** | `CryptoUtils` (`brandhub-business-service` & `brandhub-publisher-service`) | Encrypts Facebook, Instagram, TikTok, and Threads access/refresh tokens in MongoDB `social_accounts` using `AES_SECRET_KEY` (`v2:` format: `SHA-256("token-enc:" + secretKey)` 256-bit key, 12-byte random IV, 128-bit GCM auth tag). Never hardcode a fallback key. |
| **Workspace Repository & Client Vault Envelope Encryption** | `RepositoryEnvelopeCrypto` (`brandhub-business-service`) + AWS KMS CMK `alias/brandhub-repository-media-prod` | Pre-encrypts private S3 payloads (`repository/*`, `client-vault/*`) using AWS Encryption SDK (`ALG_AES_256_GCM_HKDF_SHA512_COMMIT_KEY`, commitment policy required) bound to `{format, scope, mime, bytes}` encryption context with `REPOSITORY_ENCRYPTION_KEY_V1` — see [`scripts/repository-encryption/README.md`](scripts/repository-encryption/README.md). |
| **AWS CI/CD & Wake Credentials** | OIDC `brandhub-github-actions` + IMDSv2 `brandhub-ec2-ecr-pull` (`http_tokens = "required"`) | Zero static AWS IAM access keys on EC2 or GitHub Actions; only the external Vast.ai GPU worker uses a prefix-jailed IAM user (`brandhub-image-worker-prod` limited to `ai/*` and `qwen-ambassador/*`). |

---

## 4. Credential Rotation Procedures

1. **RS256 `JWT_PRIVATE_KEY` / `JWT_PUBLIC_KEY`**: Generate a new 2048-bit RSA keypair offline, deploy the new public/private pair to `business-service` and `api-gateway` simultaneously during a brief maintenance window, and clear active refresh sessions if rotating due to compromise.
2. **`AES_SECRET_KEY` (Social OAuth Tokens)**: Changing `AES_SECRET_KEY` without migrating stored ciphertexts renders existing `social_accounts` tokens undecryptable (`TOKEN_EXPIRED` / re-auth required). Either run a decrypt-then-re-encrypt migration script or require workspace `Owner`/`Manager` users to reconnect the 4 social platforms.
3. **`REPOSITORY_ENCRYPTION_KEY_V*` (S3 Envelope Keys)**: Add the new 32-byte base64 key (e.g., `REPOSITORY_ENCRYPTION_KEY_V2`) to `repository.encryption.keys`, flip `REPOSITORY_ENCRYPTION_ACTIVE_KEY_ID=v2` for new writes, and **retain `v1`** in the keyring until all `v1` S3 objects are re-encrypted.
4. **Database, Redis, RabbitMQ, Backup & Worker Tokens**: Update `~/brandhub/ecr/env/*.env` (`chmod 600`) on `core`, `ai`, `gateway`, `crawl`, and `edit-video` via AWS SSM Session Manager and restart the affected Compose services.
