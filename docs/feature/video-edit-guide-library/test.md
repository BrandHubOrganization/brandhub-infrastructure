# Tests

1. Catalogue lists metadata without loading whole document bodies into the model prompt; filters/pagination are bounded.
2. Read known guide returns exact verified text; exact heading selection and offset pages work, including non-ASCII text.
3. Unknown id, path traversal, symlink escape, malformed manifest, edited bytes/hash mismatch and excessive output fail without exposing paths/secrets.
4. Per-job read budget caps repeated reads; reader errors are normal tool errors, never shell execution or provider retries.
5. Fake agent calls list/read and receives the requested section through tool results; existing submit/preview/fence behavior remains unchanged.
6. Bundle contains no media, environment/credential files, executables or dependency/cache trees; public roots retain verified licenses/notices. Private-only entries stay outside the public image.
7. Existing server agent/contract/runtime tests appropriate to changed code pass. No paid/cloud generation in these tests; a real visual comparison is a separate result.

Evidence: RESULT.md. Initial full worker69 passed; final focused guides9 passed, CI-selected lint passed, all884 hashes verified, Compose override valid. Fake agent list/read/submit proof passed. Reloaded idle local worker health200/caps200/count884/unauth401. No new priced run, no subjective new-video quality claim.
