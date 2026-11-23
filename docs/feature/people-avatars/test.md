# test — People avatars
| # | Kịch bản | Mong đợi |
|---|---|---|
| 1 | User có avatarUrl được gán task | Board card, list, timeline hiện ảnh thật |
| 2 | User không có avatarUrl | Hiện minh họa; cùng user giống nhau ở task list, chat, members |
| 3 | avatarUrl trỏ ảnh 404 | Tự chuyển sang minh họa, không icon ảnh vỡ |
| 4 | Task chưa gán | Vẫn hiện icon nét đứt "chưa gán" |
| 5 | Chat: tin nhắn, mention picker, tạo kênh, chi tiết kênh | Ảnh/minh họa |
| 6 | Comment task | Tác giả có ảnh nếu đã upload (API trả `authorAvatarUrl`) |
| 7 | GET members / chat directory | JSON có `avatarUrl` |
| 8 | Collaborators | Mỗi đối tác có hình khối riêng |
| 9 | Đổi ngôn ngữ VI ↔ EN | Không vỡ layout, không chuỗi thiếu |
| 10 | Đổi light ↔ dark | Avatar rõ, viền/khung đúng theme |
| 11 | Network tab | Không request tới domain DiceBear/bên ngoài |

## Kết quả 2026-11-21
- 1, 2, 4, 5, 7, 9, 10, 11: pass (Playwright + Chrome, Manager demo; tasks, chat, members, light/dark; không request DiceBear ra ngoài).
- 6: API comment/workflow/members trả field avatar (kiểm tra response). Chưa chụp màn comment có ảnh thật.
- 3 (ảnh 404 → minh họa): theo code `onError`, chưa thử bằng URL hỏng thật.
- 8: chưa chụp trang Collaborators (cần role Owner agency).
- Backend: 205 test liên quan xanh. Web: 319/321 unit, 2 fail có sẵn (`tasksAudit` `!rounded-[16px]`).
