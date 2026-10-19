# API hashtag suggestions
Creator requests hashtag suggestions using the current caption and first selected platform. Empty captions disable generation. Only API results are shown; empty/error/loading states are explicit. Selecting a suggestion adds it once to the Post, without adding it to the workspace collection. Collection workflow remains intact.
API: POST /api/v1/ai/content/hashtags through authenticated Business proxy; tenant context is server supplied. No database changes.
i18n: editor.hashtagInput.ai* keys in both vi/en. Light/dark use existing semantic tokens. Out of scope: automatic collection persistence and crawler changes.
