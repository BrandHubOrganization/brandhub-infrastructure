# Implementation plan

1. Import the existing curated data using the original keys. Compare imported documents with the source before enabling publication reads.
2. Expose Admin-only draft, publish, and restore operations with revision checks. Expose published public content separately for web release builds.
3. Build the browser catalog, article files, HTML, sitemap, video sitemap, and feed from the same captured snapshot. Surface the release boundary in Admin.
4. Use the approved Academy UI plan. Preserve playback, existing progress and canonical routes.
5. Rehearse migration and restoration with isolated data before enabling the public release on the production workflow.

## Release procedure

Deploy the Business Service and API Gateway before enabling the Web workflow's `BRANDHUB_EDITORIAL_SNAPSHOT_URL` variable. Point it at the environment's `/api/v1/public/editorial/snapshot`. Use the matching environment's Admin credentials through the shell's secure environment configuration when importing.

```powershell
node scripts/import-editorial-content.mjs
node scripts/import-editorial-content.mjs --export ./editorial-source.local
node scripts/import-editorial-content.mjs --apply
```

Run these commands from `brandhub-web`. The apply step needs `BRANDHUB_EDITORIAL_API_ORIGIN` and `BRANDHUB_EDITORIAL_ADMIN_TOKEN`. It inserts missing content, preserves existing edits, checks exact source matches, and compares the complete public output. A mismatch halts initial cutover for review.

Admin publishes a saved revision to MongoDB. The next Web release captures the approved revisions through the snapshot URL and publishes the browser data, the article JSON, the HTML, and the search feeds together. A failed snapshot request stops the build. Restore a previous revision as a draft, publish it, then start the usual Web release when an editorial rollback is needed.
