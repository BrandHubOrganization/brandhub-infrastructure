# spec

Objective: make saved Agency profile match the edit live preview, then align invitation email agency information with that view. Acceptance: shared profile card with soft cover, logo beside name/tagline, industry/size/founded badges, About description, Contact & Socials (website/phone/location/social links). Read mode uses full descriptions and wrapping names/URLs; compact edit preview shares the same structure. Owner Edit action retained; permissions, edit/upload/save workflow unchanged. Email includes the same saved fields once, in the same order, using email-compatible tables, safe image URLs and escaped/sanitized HTML; missing data omitted. vi/en email language selection remains unchanged. i18n: reuse agency.create.previewAbout/previewContact/previewNameFallback/previewSubtitleFallback/emptyDescription and agency.detail.bannerEmptyLabel; add no unpaired keys. Light/dark: existing semantic tokens; 375/768/1440px wrapping and keyboard links. Out of scope: other profile types, other mail templates, recipient language switching.

Social branding refinement: Facebook blue, LinkedIn cyan/sky blue and Instagram pink, each with a matching soft background and readable dark-mode variant; retain these brand colors in saved view, shared preview and email.

Email social chips must include their authentic network icons and brand colors. Embed PNG MIME images without JavaScript or remote icon hosts.

Default-cover refinement: replace the no-cover text with one shared default cover image across saved profile, edit/create preview and invitation email. Uploaded agency covers take precedence. The default is a presentation fallback and must not be persisted as agency data. On profile load failure, fall back to the default cover. Email embeds the default cover as a JPEG MIME part.

Gmail icon repair: use RFC-shaped globally unique Content-ID addresses per email, identical cid references and inline image headers, and a single multipart/related body. Keep genuine PNG assets and brand colors. Inspect serialized MIME instead of relying on browser previews with substituted data URLs. Do not claim delivery verification in Gmail without sending a new test message.
