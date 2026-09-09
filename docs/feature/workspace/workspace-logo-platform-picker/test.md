# Test — Workspace Logo Upload + Platform Icon Picker

## Backend Unit Test
| Case | Input | Expected |
|---|---|---|
| updateLogo hợp lệ | PNG 2MB, role OWNER | `logoUrl` mới trong response, `deleteFile` gọi nếu có logo cũ |
| updateLogo sai type | file .txt | `BusinessException(WORKSPACE_LOGO_INVALID_TYPE)`, 400 |
| updateLogo quá size | file 6MB | `BusinessException(WORKSPACE_LOGO_TOO_LARGE)`, 400 |
| updateLogo sai role | role CREATOR gọi | 403 (chặn bởi `@RequireRole` trước khi vào service) |

## Frontend Manual (Chrome DevTools)
1. Mở `/workspace/:id/settings` với role OWNER — thấy nút upload logo.
2. Chọn file png <5MB — nếu S3 local có credentials: `logoUrl` cập nhật,
   toast success. Nếu thiếu credentials (giới hạn đã biết): lỗi 500, xác nhận
   đúng nguyên nhân qua Network tab, không phải lỗi FE.
3. Chọn file .txt — toast lỗi ngay, không có request network nào bắn ra.
4. Chọn file 6MB — toast lỗi ngay, không có request network.
5. Click icon Facebook → viền/nền đổi màu brand-orange. Click lại → về trạng
   thái mặc định.
6. Bật Facebook + TikTok, bấm "Lưu thay đổi" — Network tab: request PATCH
   `/settings` có `defaultPlatforms: ["facebook","tiktok"]`.
7. Đăng nhập role ACCOUNT/CREATOR/CLIENT (hoặc giả lập) — không thấy nút upload logo (chỉ OWNER/MANAGER).
8. Toggle dark/light — icon picker + avatar block đọc được, tương phản ổn.
9. Đổi ngôn ngữ vi/en — label logo/nút upload đổi theo, không sót tiếng Việt
   hardcode.
10. `npx tsc --noEmit` và `npx eslint` trên các file đã sửa: 0 lỗi.

## Pass Criteria
Tất cả case trên PASS, trừ case 2 khi môi trường local thiếu AWS credentials
(được coi là giới hạn môi trường, ghi rõ trong báo cáo, không tính là fail
tính năng).
