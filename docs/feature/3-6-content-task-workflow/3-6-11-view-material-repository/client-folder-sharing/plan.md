1. Extend share request with sourceWorkspaceId; prevalidate target/source role/profile and ownership/source folder grants for the entire batch before writing.
2. Route workspace client folder creation through ClientVaultService and issue folder grant, without circular service dependency. Keep Drive import origin grants explicit.
3. Replace file chooser share UI with source-workspace folder chooser; disable selecting files; add folder creation for clients in their library.
4. Regression tests: folder only, no partial write, owner isolation, source workspace access, dynamic inherited read and revoked/outside descendant denial. Frontend build/lint and Chrome flow verification.

Add shareAll boolean and WORKSPACE collection grant. Validate no source folders and at least one READY owned source file server-side. Apply the same owner/source matching in list and read authorization. UI offers an explicit share-all checkbox only at empty-folder source root.

Replace share sheet with existing Dialog components, compact header/source/selection/recipient/footer layout. Rename visible action/CTA in both locales. Verify actual Chrome desktop/mobile and theme without creating new grants.

Use shared Input + Button and searchable workspace rows instead of browser select. Verify search/no-results, source change, selection reset, keyboard, narrow viewport and source/content steps in Chrome.
