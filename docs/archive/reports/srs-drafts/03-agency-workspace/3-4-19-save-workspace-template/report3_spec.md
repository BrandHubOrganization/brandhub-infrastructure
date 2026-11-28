**3.4.17 Save Workspace Template**

**Function Trigger**

Begins when a signed-in Agency member saves the configuration of an existing Workspace as a template.

**Function Description**

- **Actors / Roles**: Any signed-in member of the Agency; no specific role restriction is applied.
- **Purpose**: Lets a member store a Workspace configuration as a reusable template so similar Workspaces can be created faster later.
- **Interface**: A "Save as Template" modal opened from Workspace settings, plus a "View all templates" link to a separate templates list page. There is no separate detail route/page - the templates list implements detail as an inline expand row.
- **Data Processing**: The system stores the template with the configuration snapshot captured from the Workspace, scoped automatically to the caller's Agency, with creator identity taken from the authenticated session.

**Screen Layout**

Figure - Save Workspace Template Screen:

- A "Save as Template" button plus a "View all templates" link, both inside Workspace settings, shown only when the caller can manage.
- The "Save as Template" action opens a modal with a template name input; the configSnapshot is built automatically from the current Workspace's timezone, defaultPlatforms, and reportFrequency - there is no free-form configSnapshot input and no sourceWorkspaceId picker.
- The templates list page shows each template's name and creation date; clicking the name toggles an inline expand showing the raw configSnapshot text; a delete button removes it.

**Function Details**
- **Data Specifications**
    - **Input required**: name; configSnapshot (a JSON snapshot of the Workspace configuration).
    - **Input optional**: sourceWorkspaceId.
    - **System data**: the caller's authenticated identity; the Agency the caller belongs to; the creation timestamp.
    - **Output**: the stored template - id, agencyId, name, sourceWorkspaceId, configSnapshot, createdBy, createdAt.

- **Business Rules**
    - **BR-29**: The Agency and the creator of the template are taken automatically from the caller's session and never from the request payload; a template is scoped to the caller's Agency.
    - **BR-02**: Templates are a standalone resource, not nested inside an Agency or a Workspace; available actions are create, list, delete, and inline-expand-to-view.
    - **BR-03**: name or configSnapshot empty -> 400 VALIDATION_ERROR.
    - **BR-04**: Requesting or deleting a template that does not exist -> 404 NOT_FOUND.
    - **BR-05**: No specific role restriction is currently applied to these actions.
    - **BR-06**: A template is independent of its source Workspace - it remains available even after that Workspace is deleted.
    - getTemplate and deleteTemplate both enforce that the caller owns the template's Agency; otherwise 403 FORBIDDEN.

- **Validation**
    - name must not be empty; otherwise 400 VALIDATION_ERROR, **MSG02**.
    - configSnapshot must not be empty; otherwise 400 VALIDATION_ERROR, **MSG02**.
    - The template must exist for delete/get; otherwise 404 NOT_FOUND, toast **MSG38**.
    - Getting or deleting a template belonging to a different Agency -> 403 FORBIDDEN.

**Functionalities**
- **Normal Flow**
    1. Member opens Workspace settings and clicks "Save as Template", opening a modal.
    2. Member fills in the template name; the configSnapshot is built automatically from the current Workspace's timezone/defaultPlatforms/reportFrequency, and sourceWorkspaceId is set to the current workspace's id.
    3. System validates that the name and snapshot are not empty.
    4. System resolves the caller's owned Agency and attaches agencyId/createdBy automatically.
    5. System stores the template and returns it; a success toast is shown and the modal closes.
    6. Member can later open the templates list to expand one inline and view its configSnapshot, or delete it.

- **Abnormal Cases**
    - 3.a1: name empty -> 400 VALIDATION_ERROR, Display: **MSG02**. 3.a2: The user supplies a name and resubmits.
    - 3.b1: configSnapshot empty -> 400 VALIDATION_ERROR, Display: **MSG02**. 3.b2: The user captures the configuration and resubmits (cannot happen in the current UI since configSnapshot is always auto-built).
    - 6.a1: Delete/get requested for a template that does not exist -> 404 NOT_FOUND, toast **MSG38**. 6.a2: The user returns to the template list, which no longer shows that entry.
    - 6.b1: The source Workspace is deleted after the template was saved -> no error is raised. 6.b2: The template still exists and remains listable.
    - 6.c1: Delete requested for a template belonging to another Agency -> 403 FORBIDDEN. 6.c2: The user has no access; the template is unaffected.

**Post-Conditions**

- A template exists within the caller's Agency with the captured configuration snapshot.
- The template remains available independently of the source Workspace.
