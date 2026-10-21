# Admin UI consistency

Match the existing BrandHub typography and colors across Admin pages, navigation, dialogs and charts. Preserve the current layout, API contracts, routes, permissions and all business behavior.

Acceptance: use the existing Inter sans font for ordinary UI, standard typography sizes and shared brand-primary actions. Keep monospace for identifiers, URLs, cron and shell commands. Retain meaningful success, warning and destructive colors using existing theme tokens/components. Do not introduce a palette or dependencies.

UI states: retain loading, empty, error and disabled states. Vietnamese and English use existing keys unchanged; no new text or locale keys are required. Light/dark themes and desktop/mobile must remain readable without page overflow.

Out of scope: authentication, backend changes, redesigning workflows, migrations, commits and pushes.
