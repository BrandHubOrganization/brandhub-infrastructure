# Agency invitation email language
## Objective / User story
Agency owners send clear invitation emails in their chosen language, with agency details shown once.
## Acceptance criteria / UI and states
- Two visible options: Tiếng Việt and English; default vi independently of interface language.
- Optional personal note starts empty. Short localized presets contain no agency, sender, workspace or role boilerplate. Editing workspace/role/name does not overwrite notes. Language switching preserves separate note drafts.
- Send one localized subject/body. Missing language defaults to vi for older clients; unsupported values fail validation.
- One agency profile block: logo or monogram fallback, name, tagline, localized industry and company size, phone, website, location. Hide absent values. Escape all dynamic HTML; only HTTP(S) logo URLs are embedded.
- Retain invitation permissions, workspace roles, token and expiry semantics. Show actual invitation expiry and inviter when available.
- i18n: parallel agency.members keys emailLanguageLabel, emailLanguageHelp, emailLanguageVi, emailLanguageEn, noteHelp, notePresetFormal, notePresetProject, notePresetCasual; update noteLabel/notePlaceholder in vi/en agency.json.
- Light/dark: existing semantic tokens and shared controls; visible keyboard focus and wrapping at 375/768/1440px.
## API contract
POST agency member invitation adds optional emailLanguage (vi|en); no database migration. Server passes language, inviter and expiry to mail rendering.
## Error handling / Edge cases
Existing request validation and toast flow. Blank notes omitted; seed logos become monograms; missing agency attributes omitted; user notes are never automatically translated.
## Definition of done / Tests
Frontend checks and backend invitation tests pass; verify language, optional note, metadata, escaping, responsive/theme behavior.
## Out of scope
Recipient-side language switching, browser translations, other mail types, sending real invitations during verification.
