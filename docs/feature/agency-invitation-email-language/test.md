# test

Check default vi even with English interface; two visible language options; blank optional note; short localized presets; language draft preservation; workspace/role changes preserve notes. Verify emailLanguage payload and unsupported-value validation. MIME subject/body use exactly one language, missing language defaults vi. Single agency contact block, translated category/size, missing-field omission, seed logo fallback, valid HTTPS image, HTML escaping and note line breaks. Check workspace/role, inviter, actual expiry. Run frontend CI and targeted backend tests. Check 375/768/1440px, vi/en, light/dark and keyboard. No real email sent.

## Results (2026-11-12)
- PASS: frontend npm run ci (lint/type-check/build); repository has existing lint and bundle-size warnings. Subsequent component checks pass.
- PASS: 69 targeted backend tests: AgencyControllerTest (2), AgencyServiceImplTest (58), MailServiceImplSendMessageTest (9). MIME checks cover one selected language, optional note, escaped data, seed logo fallback, metadata and expiry; DTO rejects unsupported language.
- PASS: browser with mocked APIs: vi default, independent drafts, English presets, keyboard selection, submitted payload and success reset, workspace/role/name changes preserve note; English interface still defaults email language to vi.
- PASS: 375/768/1440px light/dark overflow checks; localized email rendered at 375/900px. Screenshots and local verification scripts are under output/playwright in the workspace root; no real mail sent.
- Live frontend uses the changed source. Running business-service must be restarted/rebuilt to use the changed backend.
