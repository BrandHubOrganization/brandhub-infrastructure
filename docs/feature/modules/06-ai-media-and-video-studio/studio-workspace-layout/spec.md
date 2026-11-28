# Studio workspace layout and explicit library save

Latest user revision: remove the standalone model-generation tab. Keep three compact text-only workflow tabs (no icons, numbers or subtitles). Each workflow offers inline model generation below its model input, with a separate prompt; a generated model becomes the input without replacing the current output. Existing sessions referencing the removed tab open Ad Composer. Preserve explicit draft-to-library saving for generated models.

Use the available workspace width and height, with inputs and prompt beside a large output preview. Keep the existing responsive layout and semantic light/dark tokens. Remove the basic-mode aspect ratio, quality and suggested prompts; render the generate action without icons. Rename modes Basic / Cơ bản and Workflow / Sơ đồ; remove the duplicate canvas action from the workflow steps. Keep canvas node labels and status text localized in Vietnamese and English.

Generated images remain AI drafts. A material ID alone does not mean saved. Explicit Save to library reuses the draft, moves it into the workspace root folder `Brandhub AI Ambassador`, then promotes it. Failed saves must not appear successful. Existing saved assets are not uploaded again. Respect existing workspace permissions and optimistic versions.

Acceptance: all four image workflows work; no horizontal overflow at phone widths; both themes and languages render; generated drafts remain drafts until explicit save; save uses the existing material APIs and does not create duplicate image records. No schema migration is needed.
