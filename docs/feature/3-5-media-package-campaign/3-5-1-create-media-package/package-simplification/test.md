# Verification

First slice: vi/en keys remain parallel; renamed services retain enum values; description and acceptance accept multiline text with maxLength 2000 and unique associated labels. No request payload or saved data changes.

Following slices: POST unit defaults correctly; service switch preserves entered text; Client cannot edit protected fields; old snapshot unit remains unchanged; invalid quantity/unit rejected; budget/duration rules follow confirmed BA; cloning preserves content; stale terms version rejected; both approvals reset on changes; Campaign keeps approved quantities and legacy monthly guard.

UI manual checks: 375/768/1440px, light/dark, keyboard focus, failed submit retains input, pending submit cannot discard.

## Verification 2026-10-16

- Backend: clean build and 24 MediaPackageServiceImpl tests passed; subsequent run including 3 simplification tests passed (27 total).
- Scoped ESLint passed for changed package components/helpers.
- Whole Web type-check remains blocked by errors in content-writing/useTaskContentSync, editor/MediaDropzone, workspace/dashboard and AppRoutes; no errors reported in modified package files. These unrelated files were not changed.
- Browser, light/dark and full live create/approve/Campaign flow not verified in this slice.
- Initial compatibility-only slice did not change DB. Subsequent user-approved cleanup removed both columns/native enum using `2026-10-16-remove-media-package-classification.sql` on local PostgreSQL.

## Classification cleanup verification

- 44 focused Backend tests passed: MediaPackageServiceImplTest (24), PackageOfferingSimplificationTest (3), PackageVersionGuardTest (7), MediaPackageControllerTest (10).
- API response omits type/offeringModel; request compatibility keys ignored. New selection snapshots use quantityBasis TOTAL and do not introduce classification keys.
- Client protected-field checks and saving structured negotiations no longer depend on offeringModel being present. Old snapshot keys are left intact.
- Transactional migration rollback rehearsal passed; actual apply verified checksums of all remaining package fields and entire Workspace agreement/Campaign rows unchanged: 15/81/80 records.
- Full fresh init succeeded in separate brandhub_package_init_check_20261016; media_packages column metadata matches migrated local DB. Migration rerun passed; disposable DB removed.
