# Sequence Flow — Chat Realtime

> Supplements `spec.md` (FR 3.6.36). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **WorkspaceMember** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `WorkspaceChatUI`.
- **System** — `ChatController` / `ChatService`.

---

## Flow A — Luồng thực thi chính: Chat Realtime

1. workspacemember -> workspacechatui: `navigates to workspace chat page (/workspaces/:id/chat)`
2. workspacechatui -> chatcontroller: `GET /api/v1/workspaces/{workspaceId}/chat/messages?before=&limit=30`
3. chatcontroller -> chatservice: `getHistory(workspaceId, userId, before, limit=30)`
4. chatservice -> chatmessagerepositor: `findHistory(workspaceId, before, limit)`
5. chatmessagerepositor --> chatservice: `chatSlice`
6. chatservice --> chatcontroller: `ChatHistoryResponse`
7. chatcontroller --> workspacechatui: `200 OK (ChatHistoryResponse)`
8. workspacechatui --> workspacemember: `render message history list with context chips & sender alignment`
9. workspacemember ->> workspacechatui: `types message (content, optional context), presses Enter`
10. workspacechatui ->> chatcontroller: `STOMP SEND /app/workspaces/{workspaceId}/chat.send (ChatSendRequest: clientMessageId, content, contextType, contextId)`
11. chatcontroller ->> chatservice: `send(workspaceId, userId, request)`
12. chatservice --> chatcontroller: `throw BusinessException (403 WORKSPACE_ACCESS_DENIED)`
13. workspacechatui --> workspacemember: `show error toast ("Access denied to workspace chat")`
14. chatcontroller --> workspacechatui: `STOMP @SendToUser(/queue/chat-errors) ChatErrorResponse`
15. chatservice ->> chatmessagerepositor: `findByWorkspaceIdAndSenderUserIdAndClientMessageId(...)`
16. chatmessagerepositor --> chatservice: `existingMessage`
17. chatservice --> chatcontroller: `ChatMessageResponse (existing)`
18. chatcontroller ->> simpmessagingtemplat: `convertAndSend(/topic/workspaces/{workspaceId}/chat, ChatEventResponse)`
19. simpmessagingtemplat --> chatcontroller: `broadcast ChatEventResponse to workspace subscribers`
20. workspacechatui --> workspacemember: `keep message state updated`
21. chatcontroller --> workspacechatui: `acknowledge`
22. chatservice --> chatcontroller: `throw BusinessException (400 CHAT_MESSAGE_INVALID)`
23. chatcontroller --> workspacechatui: `STOMP @SendToUser(/queue/chat-errors) ChatErrorResponse`
24. workspacechatui --> workspacemember: `show validation error toast`
25. chatmessagerepositor --> chatservice: `existingMessage`
26. chatservice ->> chatmessagerepositor: `save(chatMessageDocument)`
27. chatservice --> chatcontroller: `ChatMessageResponse`
28. chatcontroller ->> simpmessagingtemplat: `convertAndSend(/topic/workspaces/{workspaceId}/chat, ChatEventResponse)`
29. simpmessagingtemplat --> chatcontroller: `broadcast ChatEventResponse to workspace subscribers`
30. chatcontroller --> workspacechatui: `acknowledge`
31. workspacechatui --> workspacemember: `keep message state updated`
32. workspacemember ->> workspacechatui: `views unread messages in chat viewport`
33. workspacechatui ->> chatcontroller: `PUT /api/v1/workspaces/{workspaceId}/chat/read (MarkChatReadRequest: lastReadMessageId)`
34. chatcontroller ->> chatservice: `markRead(workspaceId, userId, lastReadMessageId)`
35. chatservice ->> chatmessagerepositor: `updateLastReadState(workspaceId, userId, lastReadMessageId)`
36. chatmessagerepositor --> chatservice: `updatedState`
37. chatservice --> chatcontroller: `void`
38. chatcontroller --> workspacechatui: `200 OK`
39. workspacechatui --> workspacemember: `update unread counter badge to 0`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
