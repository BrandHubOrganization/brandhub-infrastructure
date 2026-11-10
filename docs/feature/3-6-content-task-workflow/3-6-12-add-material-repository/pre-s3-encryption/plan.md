# Plan
1. Add encryption/keyring config and AWS Encryption SDK codec; test roundtrip, tampering, wrong scope/key and truncated ciphertext.
2. Add bounded verified plaintext temp cache for efficient repeated validators/range reads. Encrypt all put/putFile calls, preserve logical Head metadata; copy ciphertext with original encryption context (scope remains stable); proxy URLs for new uploads and encrypted reads.
3. Add signed encrypted capabilities and streaming HTTP GET/PUT endpoint; wire Gateway public capability route/rate limits/redacted logs and Business security. Keep MIME/length checks and byte-range semantics.
4. Test router/controller/gateway; run builds. Generate backend key once in ignored .env, never rotate silently.
5. Restart local services with updated dependency classpath. Verify real upload/import, S3 bytes unreadable, app preview/download correct.
6. Inventory existing repository objects/versions, execute verified encryption migration if no irreversible-version deletion is needed. Record residual versions if deletion needs review.

Execution update: bulk migration needs explicit approval per automatic review. New encryption runtime is active and legacy read compatibility explicitly enabled. With all current application writers now encrypting, the conditional migration can be performed online; pending reads may need retry if ETag changes. No need to stop services for the remaining migration.
