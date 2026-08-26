# Danh sách FR KHÔNG có màn hình (không chụp được ảnh thật)

> Các FR này **không có giao diện UI** nên không thể chụp ảnh màn hình thể hiện chức năng.
> Đã kiểm tra lại toàn bộ thư mục `screenshots/` (2026-08-26).

## 1. KHÔNG có file ảnh nào (thiếu hoàn toàn)

| FR | Chức năng | Lý do |
|---|---|---|
| **DA-D15-10** | Token Refresh (JWT RS256) | Backend thuần — tự động refresh token, không có màn hình. Không tồn tại file `DA-D15-10.png`. |

## 2. Có file ảnh nhưng là placeholder (back-end thuần, không có UI thật)

| FR | Chức năng | Lý do |
|---|---|---|
| DA-D15-23 | Multi-tenancy Isolation | Backend — phân tách dữ liệu theo workspace, không có UI riêng. |
| DA-D15-27 | Permission Check Enforcement | Backend — kiểm tra quyền ở API layer, không có UI riêng. |
| DA-D17-05 | Anti-hallucination (RAG) | Backend — gắn kết kết quả AI với nguồn, không có UI riêng. |
| DA-D17-21 | Chunking (RAG) | Backend — chia nhỏ tài liệu, không có UI riêng. |
| DA-D17-22 | Embedding (RAG) | Backend — nhúng vector, không có UI riêng. |

## 3. Ngoài phạm vi — app Mobile riêng, không có UI web

| FR | Chức năng |
|---|---|
| DA-D19-16 → DA-D19-21 | Các chức năng dành riêng cho mobile app (không nằm trong web dashboard). |

## Ghi chú cập nhật

- **DA-D18-25 (Retry)** và **DA-D18-26 (DLQ)**: trước đây bị liệt kê là "NO UI" (back-end). **Đã bổ sung UI** — trang `/publish` hiển thị dòng FAILED với nút Retry (D18-25) và dòng FAILED + badge DLQ (D18-26). Đã chụp lại ảnh mới.
