# Verification

- A generated asset with a material ID but draft=true is not treated as saved.
- Saving a draft reuses the existing material, moves it to Brandhub AI Ambassador, reloads its version, and promotes it.
- A folder is reused; missing folders are created. Failed moves never promote the image; retries are possible.
- Already saved assets do not upload duplicate files.
- Basic layout uses workspace width; narrow screens stack without horizontal overflow.
- Generate has no icon; aspect/quality controls, prompt chips and duplicate canvas navigation are absent.
- Vietnamese and English mode/node labels resolve; light/dark colors use semantic tokens.
- Run focused Vitest, npm run type-check, ESLint on changed files, and npm run build.
