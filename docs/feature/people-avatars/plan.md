# plan — People avatars

## Web (`brandhub-web`)
- Dep mới: `@dicebear/core`, `@dicebear/notionists`, `@dicebear/shapes` (9.4.x, chạy offline).
- `src/components/shared/UserAvatar.tsx`: `UserAvatar` (ảnh thật → fallback minh họa, xử lý `onError`), `generatedAvatarUrl(name)`, `PartnerAvatar`. Cache data URI theo seed.
- Thay render chữ viết tắt bằng `UserAvatar` ở: tasks (board card, list/Jira subtask, calendar timeline, comments, filter options, assignee avatars), campaign timeline picker, chat (message row, composer mention, channel form, channel details, media lightbox), agency (members, member drawer, org chart), credit member panel, workspace invite pickers, requests, admin (accounts, recent users, moderation), dashboard activity feed; collaborators + campaign partner picker dùng `PartnerAvatar`.
- Không đổi locale file (không có text mới).

## Backend (`brandhub-business-service`)
- `WorkspaceMemberResponse` + `avatarUrl` (từ `User.avatarUrl`).
- `ChatDirectoryMemberResponse` + `avatarUrl`.
- `TaskCommentResponse` + `authorAvatarUrl` (tra `users` theo `authorId` lúc đọc; Mongo không lưu ảnh để ảnh luôn mới), `TaskCommentResponse.Member` + `avatarUrl`.
- Không đổi schema DB.

## Rủi ro
Bundle tăng (~vài chục KB gzip cho style notionists). Seed theo tên (đổi tên đổi hình).
