# Implementation

1. Snapshot the current Admin source and capture baseline light/dark overview screenshots.
2. Update `brandhub-web/src/pages/admin` and `src/components/layout/AdminSidebar.tsx` only for typography, action colors and status presentation. Reuse `globals.css`, shared Button/Badge and existing status tokens; do not modify global primitives.
3. Verify a production build, lint changed files and run existing Admin browser coverage, including language/theme/responsive cases. Review screenshots after the changes.

Locale files: none, because all existing VI/EN keys and text stay unchanged. Database and API changes: none.

Review changes against the task-specific source snapshot because the workspace already contains an uncommitted upstream merge. Preserve that merge and all existing work.
