# Task unsaved-change confirmation

Replace Task window.confirm with an application Dialog. Keep editing (default focus, Escape, outside click) cancels the attempted action and retains drafts. Discard proceeds only with explicit confirmation. Pending writes cannot be discarded. Cover switching/closing Task, row editor, filters/views/reload and internal links. Do not modify other modules or auth/approval behavior.

Use shared Dialog/Button, semantic theme tokens in light/dark, keyboard focus restoration, and parallel vi/en tasks.inline.discardTitle, discardChanges, keepEditing keys. Reuse discardWarning text. Native beforeunload protection for browser refresh/tab-close remains: browsers do not support asynchronous custom confirmation there.

No API/database changes. No automatic save retry or destructive data writes.
