# Backend-Held Pre-S3 Envelope Encryption (`scripts/repository-encryption/`)

- Back to [Scripts Manual](../README.md) · [Infrastructure Hub](../../README.md) · [Security Policy](../../SECURITY.md)
- S3 & KMS Terraform Stack: [`../../prod/terraform/04-storage/README.md`](../../prod/terraform/04-storage/README.md)
- Migration Tool Source: [`EncryptExistingRepository.java`](EncryptExistingRepository.java)

Documents BrandHub's application-layer pre-S3 encryption architecture (`RepositoryEnvelopeCrypto` in `brandhub-business-service`) and the dry-run-first migration tool ([`EncryptExistingRepository.java`](EncryptExistingRepository.java)) used to convert legacy plaintext S3 objects into verified AWS Encryption SDK ciphertext.

---

## 1. Cryptographic Architecture (`RepositoryEnvelopeCrypto`)

Workspace Material Repository and `Client` Personal Vault objects (`repository/*`, `repository-staging/*`, `staging/*`, and `client-vault/*` inside `brandhub-media-134875421878`) are encrypted **before** bytes ever leave `brandhub-business-service`:

- **Algorithm & Commitment**: AWS Encryption SDK (`Format = "aws-esdk-v1"`) with `CommitmentPolicy.RequireEncryptRequireDecrypt` and `CryptoAlgorithm.ALG_AES_256_GCM_HKDF_SHA512_COMMIT_KEY` backed by 256-bit `JceMasterKey` (`AES/GCM/NoPadding`, namespace `"brandhub-repository"`).
- **Authenticated Encryption Context (AAD)**: Every ciphertext stream binds `{"format": "aws-esdk-v1", "scope": "<workspaceOrVaultId>", "mime": "<contentType>", "bytes": "<plaintextLength>"}`. Decryption verifies exact context inclusion and exact byte length before releasing data, preventing cross-workspace object substitution (`s3_key` swapping) or truncation attacks.
- **Capability Sealing**: Upload (`PUT`) and preview/download/publisher (`GET` with `Range` support) URLs use short-lived backend capability tokens sealed with `AES-256-GCM` (`12`-byte random IV + `128`-bit tag + purpose AAD, formatted `<keyId>.<base64url>`). Plaintext never touches S3; a bounded local verified plaintext temp cache expires after `60s` idle.
- **Untouched Public Prefix**: Non-sensitive avatars, logos, and banners under `image/*` remain unencrypted public S3 objects (`AES256` SSE-S3).

---

## 2. Runtime Environment Configuration (`brandhub-business-service`)

```dotenv
REPOSITORY_ENCRYPTION_ENABLED=true
REPOSITORY_ENCRYPTION_ALLOW_LEGACY_READS=false
REPOSITORY_ENCRYPTION_ACTIVE_KEY_ID=v1
REPOSITORY_ENCRYPTION_KEY_V1=<base64-encoded-32-random-bytes>
REPOSITORY_MEDIA_PUBLIC_BASE_URL=https://api.brandhub.id.vn
```

> **Key Custody Warning**: Back up `REPOSITORY_ENCRYPTION_KEY_V1` (and any rotated `v2`, `v3` keys) in an offline operator secret vault outside S3. During key rotation, keep prior key IDs registered in `repository.encryption.keys` so historical objects remain decryptable; losing all wrapping keys permanently renders encrypted repository/vault assets unrecoverable.

---

## 3. Running `EncryptExistingRepository.java` (Maintenance Window)

### Safety Guarantees Built into [`EncryptExistingRepository.java`](EncryptExistingRepository.java)

1. **Dry-Run by Default**: Omit `--apply` to inventory matching objects (`repository/`, `repository-staging/`, `staging/`, `client-vault/`) and count already-encrypted (`bh-encryption: aws-esdk-v1`) vs unencrypted objects with zero S3 writes.
2. **Versioned-Bucket Refusal**: Calls `GetBucketVersioning` first and aborts if S3 versioning is enabled (so plaintext historical versions cannot linger silently).
3. **Double SHA-256 Verification + Encrypted Local Backup**:
   - Downloads source object with `If-Match: <ETag>`, computes `originalHash` (`SHA-256`), encrypts to temp file, and test-decrypts locally to verify hash equality **before** uploading.
   - Writes `<uuid>.cipher` + `<uuid>.json` manifest into `REPOSITORY_ENCRYPTION_MIGRATION_BACKUP_DIR`.
   - Uploads ciphertext (`Content-Type: application/octet-stream`) with metadata `bh-encryption=aws-esdk-v1`, `bh-plaintext-bytes`, `bh-plaintext-mime`, `bh-key-id`, preserved S3 object tags, and conditional header `If-Match: <previousETag>`.
   - Re-downloads the newly written S3 object, decrypts it from scratch, and verifies `SHA-256 == originalHash` **after** write.

### Execution Steps

Stop all `brandhub-business-service` writers, load the backend environment variables into your shell (never pass keys on CLI arguments), compile against the `brandhub-business-service` classpath, and run dry-run first:

```bash
# 1. Build classpath in brandhub-business-service
cd ../brandhub-business-service
./mvnw -q test-compile dependency:build-classpath -Dmdep.outputFile=/tmp/bh.cp

# 2. Compile & run DRY-RUN inventory
javac -cp "target/classes:$(cat /tmp/bh.cp)" \
  ../brandhub-infrastructure/scripts/repository-encryption/EncryptExistingRepository.java \
  -d /tmp
java -cp "/tmp:target/classes:$(cat /tmp/bh.cp)" EncryptExistingRepository

# 3. Apply migration (requires REPOSITORY_ENCRYPTION_MIGRATION_BACKUP_DIR set in environment)
export REPOSITORY_ENCRYPTION_MIGRATION_BACKUP_DIR=/var/tmp/bh-repo-cipher-backup
java -cp "/tmp:target/classes:$(cat /tmp/bh.cp)" EncryptExistingRepository --apply
```
