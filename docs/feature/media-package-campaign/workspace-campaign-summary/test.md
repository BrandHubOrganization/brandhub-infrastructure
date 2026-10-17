# Cases

Loading does not display old Workspace Campaign. One record displays translated name/status/version/plan count with one plan link. Zero records shows guidance and Manager action only. Failure shows retry, never an empty/create state. Multiple records show inconsistency instead of arbitrary first item. Workspace switch ignores previous request completion. Correct /campaigns route for every action. Real Campaign count 0/1; no mock fallback. Check vi/en, 375/768/1440 and light/dark; preserve all other Dashboard sections and report existing type-check blockers.

## Results 2026-10-17

9 mocked render tests passed with Vitest native config loader (four statuses, loading, failure, Manager empty, Client empty, duplicate records). Scoped ESLint passed for new component/test; vi/en keys checked parallel. Full TypeScript reports the same pre-existing errors in Content Writing, Editor, Dashboard's untouched Task/PageWrapper sections and AppRoutes; none in new component. No database/API mutation, no browser responsive/theme claim. Runner configLoader failed on CommonJS dependency; native loader worked with worker process permissions; shared configuration unchanged.
