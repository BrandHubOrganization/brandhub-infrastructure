# Implementation plan

1. Use one `DEFAULT_SCHEDULE_TIMEZONE` in the native crawler pipeline settings. Apply it to absent config/legacy schedule fields, scheduler fallback and management status. Preserve explicit zones; reject invalid zones.
2. Add a focused Admin timezone selector using `SelectMenu`, with localized Vietnam/UTC labels, IANA hints for other zones, accessible label and disabled state. Keep a saved zone outside presets selectable.
3. Normalize the initial settings form once; compare/reset against the same normalized value. Send `timezone` with the existing CAS revision and unchanged cron.
4. Invalidate the existing crawler-management health query after saving settings. Keep next-run rendering in the server-reported timezone.
5. Add parallel keys to `src/i18n/locales/{vi,en}/admin.json` for selected-zone guidance and correct legacy wording about server time.
6. Run existing crawler scheduler/settings tests, local-only timezone regression checks, Web CI and an isolated browser fixture. No changes to dirty `app/core/clients.py` or its local test.
