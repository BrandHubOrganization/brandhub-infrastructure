# Deploy provider migration
Replace Gemini text/context provider with Deploy in hashtags, caption and image understanding, trend-fit and pipeline labeling. Existing Groq paths remain; fallback switches to Deploy. Read DEPLOY_API_KEY, DEPLOY_MODEL and DEPLOY_BASE_URL only on server. Remove Gemini text/model config; Veo continues with dedicated GOOGLE_VEO_API_KEY. Preserve hashtag relevance order, lifecycle logs, trusted internal auth and definitive credit failure codes. No changes to stored posts or reservations.

Admin replay warning must identify Deploy, not Gemini. Add parallel vi/en admin.trendReplay.providerCostTitle and update costWarning. Preserve existing layout/theme and keyboard controls.
