# edit-video

`brandhub-edit-video` (`i-0ec7bf59c53fb7d0b`, 172.31.20.80, m7i-flex.large). Host dir: `~/brandhub/edit-video`.

| File | Role |
| --- | --- |
| `compose.prod.yml` | copy of `Edit_Video/compose.prod.yml` (source of truth is that repo) |
| `.env` | `EDIT_VIDEO_IMAGE` (ECR `brandhub/edit-video`) |
| `env/edit-video.env` | `EDIT_API_KEY`, `CLAUDE_CODE_OAUTH_TOKEN` from SSM `/brandhub/edit-video/*`, plus limits |

```bash
cd ~/brandhub/edit-video && docker compose -f compose.prod.yml up -d --wait
```

Reached only through the gateway (`/edit-video/` → 8095). Stops itself when idle (`../_shared/idle-sleep/`);
the gateway waker starts it again. See [../../docs/wake-on-request.md](../../docs/wake-on-request.md).
