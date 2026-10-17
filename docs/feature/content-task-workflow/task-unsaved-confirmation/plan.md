# Plan

Make TaskWorkflowProvider.canLeave asynchronous, resolve via a Task-specific Dialog and coalesce repeated attempts by rejecting subsequent requests while one confirmation is open. Preserve pending-write toast and recheck before discarding. Resolve outstanding request false on unmount. Update all Task callers to await guard; ignore obsolete URL-effect completions. Capture dirty internal-link navigation and resume through React Router only after confirmation; skip modified clicks, target and download links. Preserve existing beforeunload protection.

Add TaskDiscardDialog using shared primitives without changing defaults. Change vi/en tasks.json together. Verify isolated mocked browser flow and lint/typecheck; preserve unrelated dirty files.

Session discard generation resets mounted inline drafts/errors as well as dirty flags, so confirming discard for a view/filter change cannot leave old edits onscreen.
