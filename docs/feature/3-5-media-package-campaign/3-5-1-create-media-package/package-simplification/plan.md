# Implementation plan

1. Update existing vi/en mediaPackage service labels and multiline OfferingEditor inputs without changing payloads.
2. Centralize confirmed service-unit defaults and validate new-contract creation on server; make units read-only, preserve legacy snapshots. Old API callers remain compatible.
3. Remove classification UI and decouple duration/budget/deliverables validation. Keep compatible readers and legacy monthly guards.
4. User approved physical removal. Migration `2026-10-16-remove-media-package-classification.sql` drops only the two columns and unused native enum using RESTRICT, in a transaction with lock timeout. Fresh init removes the same definitions. Stop old Business writers, inventory and rehearse before applying. Package/Campaign rows and JSON history stay unchanged. Older migrations/seeds are historical and must not be rerun afterward.
5. Verify create, clone, select, negotiate, approve, detail/diff and Campaign regression. No shared Atlas mutation, commit or push in this task without instruction.

Files first slice: web/src/i18n/locales/{vi,en}/mediaPackage.json and web/src/pages/media-package/components/OfferingEditor.tsx.
