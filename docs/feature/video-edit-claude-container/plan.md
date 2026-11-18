# Plan
1. `scripts/stage_video_edit_context.py` (stdlib): copy allowlist từ DemoVideo và skill (`~/.claude/skills/fk-*`, `~/.claude/plugins/cache/hyperframes/hyperframes/<mới nhất>/skills`) vào `.video-edit-context/` (gitignored); quét secret.
2. `Dockerfile.video-edit`: thêm stage Node 22, cài CLI, named build context `videoctx` với workspace và skill, venv DemoVideo, `video-env.cmd` bản Linux (`tools/video-edit/video-env.sh`), `CLAUDE_CONFIG_DIR` cùng `.claude.json` chứa EditAtlas.
3. `compose.video-edit.yml`: `additional_contexts`, biến môi trường Claude, volume cho config/session/cache, `host.docker.internal`.
4. Test: build; `claude --version`; `claude mcp list`; selftest `./video-env.cmd python tools/edit/edit.py selftest`; gọi `-p` thật một lần; health 8094; chạy thử 1 job edit end-to-end từ web.
