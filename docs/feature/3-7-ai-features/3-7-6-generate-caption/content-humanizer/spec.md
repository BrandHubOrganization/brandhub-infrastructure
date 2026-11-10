# Content Humanizer

## Objective

Apply blader/humanizer to BrandHub's AI content so captions read naturally in Vietnamese and English while keeping the creator's message and verified product facts.

## User story

As a creator, I generate or revise content through the existing forms and receive publishable copy without chatbot introductions, empty hype, or an editing report.

## Acceptance criteria

- Install the upstream skill for Codex and retain its pinned source and MIT notice in the AI service.
- Use a compact adaptation in caption generation, refinement, platform adaptation, and both topic and prompt modes of the content endpoint.
- Draft and review within the existing model request. Do not introduce another provider request, endpoint, dependency, credit operation, or UI control.
- Preserve verified names, numbers, offers, dates, URLs, quotations, intent, requested language, brand voice, platform limits, CTA, and hashtag requirements. Writing samples guide style, not factual claims.
- Keep deliberate humor, slang, hooks, and approved brand expression. Never invent personal experience or endorsements to sound human.
- Return only the existing text or JSON contract, without drafts, critique, or Humanizer instructions.
- Existing provider routing, fact checks, moderation, and failure handling still run.

## UI/UX and API contract

Existing forms, routes, request models, and response models stay in use. No new displayed text, locale keys, or theme styles are needed; VI/EN and light/dark UI behavior are unaffected.

## Error handling and edge cases

Existing provider errors and malformed JSON rejection apply. Humanizer is prompt guidance, not a deterministic guarantee of writing quality or factual accuracy. Missing facts must be omitted, not invented; a marketing CTA must not be mistaken for chatbot residue.

## Definition of done

Focused mocked tests verify one generation call per operation, Humanizer guidance on each path, and preserved response/fact-check behavior. No paid provider call is needed for implementation verification.

## Out of scope

Video worker integration, changes to trend analysis or image prompts, AI-detector evasion, model training, and unrelated pending repository changes.
