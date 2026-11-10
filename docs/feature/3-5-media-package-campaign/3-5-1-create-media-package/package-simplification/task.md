# Checklist

- [x] Update vi/en service labels.
- [x] Multiline description/acceptance with accessible labels.
- [x] Verify first-slice lint and translations.
- [x] Confirm service-unit mapping and requiredness.
- [x] Decouple classification create contract and validation, preserve compatibility.
- [x] Migration and canonical docs/database/init-postgres-v2.sql remove legacy columns/enum; entity and API response no longer expose them. Develop removed duplicate scripts/init-postgres-v2.sql; do not restore it.
- [x] Applied local migration after rollback rehearsal and 44 passing regression tests. Content checksum unchanged for all 15 packages/81 agreements/80 Campaigns.
- [x] Fresh init succeeded in disposable PostgreSQL database; media_packages column definitions match live migrated DB; migration rerun is safe. Disposable DB removed afterward.
- [x] Automatic unit UX implemented; preserve saved units in negotiation and normalize only newly copied packages.
- [ ] Browser create/negotiation regression.
- [ ] Check light/dark, keyboard and responsive layout.
