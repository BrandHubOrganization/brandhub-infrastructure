# Verification cases

1. Managed file credentials override stale env; rotated credentials are read after CLI run.
2. Missing refresh token, CLI failure and timeout fail closed without disclosing secrets.
3. Concurrent refresh requests serialize and reuse a successful probe; no overwriting auth.json.
4. Upstream 401 retries once after CLI refresh with new authorization; 403 and repeated 401 terminate.
5. Volume initialization preserves existing contents, rejects unsafe paths and checks runtime write access.
6. Compose mounts stable named volumes at Codex home, agy profile and keyring; CLI binaries available in image.
7. With real sessions: authenticated probe before restart, after restart and after force-recreate. Container ID changes on recreate, mount sources stay identical. Missing sessions = BLOCKED, never PASS.

Results (2026-11-27):

- New Linux auth/volume tests: 16 passed, including symlink rejection and concurrent probes.
- Windows focused auth/volume/deployment/Studio tests: 38 passed, 4 skipped (symlink permissions).
- Built Dockerfile cli-runtime target with Codex 0.172.0 and agy 1.5.18. Full AI-service image was not built or deployed in this run.
- Isolated Docker integration: PASS. Real profile files and Secret Service keyring entry survive restart and force-recreate; container ID changes. Test-created containers/volumes cleaned up. This is storage verification, not provider login verification.
- Flake8, compileall, YAML parsing, jq generation of SSM parameters, bash syntax check of generated SSM commands, git diff --check: PASS.
- Whole pytest suite: 1451 passed, 8 skipped, 5 failed. Failures outside changed auth paths: tests/integration/api/test_trends_s3_endpoint.py::{test_real_s3_latest_file_inspection,test_real_s3_query_params,test_real_s3_run_pipeline}; tests/server_video_edit/test_runtime.py::test_optional_tts_is_fixed_voice_and_opt_in (missing edge_tts); tests/unit/services/test_product_video.py::test_provider_readiness_requires_working_local_render_runtime (missing google.auth).
- EC2 read-only inspection: current image sha-1b71e06-117 has only data/cache mounts, neither CLI available on PATH, no Codex auth.json. No production container was changed. Authenticated lifecycle check is BLOCKED until updated image deployment and one-time provider login.
