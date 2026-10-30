# Secret handling

Never commit live database snapshots, private keys, credential-bearing connection strings or real values in `.env.example`. Keep backups in private storage outside Git. Existing historical exposure requires credential rotation and coordinated history cleanup; a clean current tree alone does not revoke a key.

## Local protection

Install [Gitleaks 8.30.1](https://github.com/gitleaks/gitleaks/releases/tag/v8.30.1) and Python 3. From this repository run:

```sh
git config --local core.hooksPath .githooks
```

Gitleaks must be on PATH. A local executable can instead be selected with `git config --local brandhub.gitleaksPath /absolute/path/to/gitleaks`. The pre-push hook checks outgoing history as well, preventing an old clone from restoring removed snapshots or credentials. Fetch remote refs before pushing after a history cleanup. The pre-commit hook scans the staged diff and rejects database snapshots and private-credential paths, including binary files. CI also checks all tracked content and PR commits. The checks redact detected values. Hooks are local settings; each clone needs installation. Configure the `secrets` CI job as a required check in branch protection.

Do not bypass findings by ignoring whole source/test directories. Review narrowly scoped synthetic fixtures individually. A compromised AES encryption key needs ciphertext migration; changing its value alone can make stored tokens unreadable. Supply AES_SECRET_KEY from the environment; do not use a shared fallback.
