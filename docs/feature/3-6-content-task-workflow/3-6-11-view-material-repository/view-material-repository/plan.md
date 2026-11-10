# View + Update Material — Implementation Plan
Read both user-provided specs. Implement View first, then Update on shared ACL/response seams.
1. Query DTO + validation, scoped Mongo active/Trash predicate and ancestor ACL before
   count/page; prefix NFC search, stable sort, bounded results, no per-item HEAD.
2. Enrich DTO with caller capabilities/rawWarning/display names (batch PostgreSQL lookups),
   safe preview allowlist, detail/refresh reauthorization, quota-neutral workspace usage.
3. Add staged Mongo indexes while preserving Trash validator, provider+key uniqueness,
   and no TTL. Existing migrations stay staged; no live database changes.
4. Add validated PATCH record, Unicode/canonical-extension policy, ownership and
   Manager-only audience validation. One Mongo transaction CASes version, fences ancestors,
   restricts recursive descendants, and writes audit intent. Reuse audit receipt delivery
   for UPDATE/PERMISSION_CHANGE with old/new snapshots. No storage/quota write.
5. Web listPage + abort signals, debounced filters/pagination/usage, server capabilities,
   badges/statuses, detail preview refresh and inline metadata editor with conflict reload.
   Preserve current Trash/upload/watermark paths. Reuse UI primitives and theme tokens.
   Change locales src/i18n/locales/vi/library.json and en/library.json in parallel.
6. Tests at the spec-selected service/API + real disposable Mongo/PG and Playwright seams;
   focused red/green slices, regular compile/typecheck, full suites at end. Review from
   initial HEAD on both axes; fix findings and commit on the existing branch.
Risks: ancestor permission races and presigned URL lifetime; transaction fences and
current ACL reads address future issuance. No Redis or raw legacy URL fallback.
