**3.6.15 Apply Watermark**

**Function Trigger**

A Creator opens the watermark tool embedded in a Task Detail (type Post), after a material has already been retouched.

**Function Description**

- **Actors / Roles**: Creator.
- **Purpose**: Let a Creator stamp a brand watermark (a Client-supplied logo) onto a finished image before publishing, similar to img2go, so the publication carries visible attribution/copyright marking.
- **Interface**: A watermark tool embedded in Task Detail with a live preview before applying.
- **Data Processing**: The system takes an already-retouched material plus a logo chosen from the Client's Brand Collection, composites them at a chosen position/opacity, and outputs a new file (never overwriting the original).

**Screen Layout**

Figure — Apply Watermark Tool:

- Image preview panel showing the retouched material with the watermark overlaid live.
- Logo picker sourced from the Client's Brand Collection.
- Position and opacity controls.
- Apply / Cancel actions.

**Function Details**
- **Data Specifications**
    - **Input required**: `materialId` (the retouched image), `logoAssetId` (from the Client's Brand Collection), `position`, `opacity`.
    - **Input optional**: none beyond position/opacity tuning.
    - **System data**: the material record and the Client's Brand Collection logo assets.
    - **Output**: `{id, url}` of the newly generated watermarked file.

- **Business Rules**
    - The watermarked output is a new file — the original image is never overwritten.
    - Only images are in scope (video watermarking is out of scope, same as img2go).

- **Validation**
    - `logoAssetId` not found in the Client's Brand Collection → 400 `LOGO_NOT_FOUND`.
    - Client's Brand Collection has no logo at all → the tool blocks apply and tells the user to upload a logo first, rather than allowing an empty watermark.

**Functionalities**
- **Normal Flow**
    - 1. A Creator opens the watermark tool from a Task Detail (Post) after retouching.
    - 2. The Creator picks a logo from the Client's Brand Collection and adjusts position/opacity, previewing the result.
    - 3. The system applies the watermark and outputs a new file, leaving the original untouched.

- **Abnormal Cases**
    - 2.a1: Chosen `logoAssetId` doesn't exist in the Brand Collection → 400 `LOGO_NOT_FOUND`.
    - 2.b1: Client's Brand Collection is empty → the tool warns the Creator to have the Client upload a logo first, blocking an empty-watermark apply.

**Post-Conditions**

- A new watermarked file is created and linked to the material/Task, with the original image left unmodified.
