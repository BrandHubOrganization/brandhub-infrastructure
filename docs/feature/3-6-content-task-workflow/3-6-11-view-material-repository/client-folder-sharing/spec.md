# Client folder sharing
Client selects a source workspace A and their own folder there to share into current workspace B. B receives a live folder grant including descendants and future changes, without copying bytes or transferring ownership. New cross-workspace shares accept folders only. Client must have CLIENT membership and a profile in both workspaces. A folder owned by another client, not exposed in A, deleted, empty selection or A=B is rejected before any grant write. Existing origin upload/legacy file grants remain readable; no bulk migration or widening of old grants.
UI: choose source workspace, navigate folders, select folders, share. Files may be shown as read-only context but cannot be selected. Creating a client folder in a workspace grants that folder to that workspace. Existing staff folder behavior remains.
VI/EN keys stay parallel; existing semantic colors support light/dark.

Whole-workspace fallback: when the source has no active shared client folders, the owner may explicitly share all their own original client-vault files in that source workspace as a live collection. The receiving grant is owner + source-workspace scoped, never all users or internal files. Future owned source uploads are included, bytes are not copied; re-shared files from unrelated origins are not forwarded. Existing folder-only default remains.

UX revision: compact centered dialog for the short reuse action; label action as using files rather than ambiguous sharing direction. Show source selector and receiving workspace name, explicit selection and one primary action. Keep live grant behavior and explicit consent unchanged. Keyboard, VI/EN, light/dark and narrow screens supported.

Presentation revision: replace native source select with a searchable list of workspace buttons, followed by content selection with an explicit Change workspace action. Source changes clear selections. Hide the submit CTA until a source is chosen. Keep receiving workspace visible.

User presentation preference: right sidebar replaces centered dialog. Full viewport height, scrollable body, fixed bottom actions; mobile uses full width. Searchable workspace selection and content flow unchanged.
