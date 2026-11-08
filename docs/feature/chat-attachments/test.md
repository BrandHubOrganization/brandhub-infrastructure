# Chat attachments verification

## Regression coverage

- Text-only, file-only and mixed messages in DM, channel and thread.
- Scheduled send/retry with attachments; preserve draft after failed requests.
- Up to five JPEG/PNG/WebP/PDF files, 10 MiB per file; reject unsupported/oversized files.
- Upload failure/retry/remove; paste and drag/drop.
- Repository paging/search/folders, immutable version selection and unavailable-file handling.
- Sender permission checked independently; denied recipients receive no file metadata or binary.
- Scope changes clear attachment drafts; DM mentions remain restricted.
- Responsive picker, keyboard focus, read-only mode, Vietnamese/English and light/dark variants.
- Additive migration/index/validator parity with fresh init and seeders; no content reset.

## Results

Repository-independent browser QA: 23/23 passed using real UI components with mocked API/storage. No external API calls occurred. Picker clipping and menu-close focus regression were corrected with shared Popover primitives and available-height constraints.

Web lint, TypeScript and build checks passed for the attachment implementation. Backend compile and isolated regression checks passed. New test fixtures, scripts, screenshots and environment receipts are excluded from shared commits.

## Remaining integration verification

Real storage upload/download and Repository authorization must be verified in an environment with valid storage credentials and the required Repository schema/encryption configuration. Mock results do not establish storage availability or server authorization. Keep deployment-specific diagnosis and credentials outside this document.
