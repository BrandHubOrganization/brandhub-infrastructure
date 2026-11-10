# Kế hoạch kỹ thuật

## Thư viện thêm

`expo-linear-gradient`, `expo-haptics`, `expo-local-authentication`. `expo-notifications` đã có sẵn trong dependency nhưng trước đây chưa dùng. Cần build lại app native.

`app.json` thêm plugin và quyền `POST_NOTIFICATIONS`, `USE_BIOMETRIC`, thêm câu giải thích Face ID. `android/` là thư mục sinh ra và bị ignore, nên khi prebuild lại quyền sẽ lấy từ `app.json`.

## Thành phần

| Việc | File |
|---|---|
| Lưu cài đặt theo máy | `src/store/deviceFeaturesStore.ts` |
| Khoá ứng dụng | `src/utils/appLock.ts`, `src/components/common/AppLockGate.tsx` |
| Nhắc hạn | `src/services/taskReminders.ts`, `src/hooks/useTaskReminders.ts`, `src/navigation/rootNavigation.ts` |
| Báo mất mạng | `src/components/common/OfflineBanner.tsx` |
| Công tắc trong Cài đặt | `src/components/settings/DeviceFeaturesSettings.tsx` |
| Xúc giác | `src/utils/haptics.ts`, `src/components/ui/Button.tsx` |
| Dashboard | `src/utils/dashboardStats.ts`, `src/components/dashboard/DashboardCharts.tsx` (thay `MockDashboardCharts`) |
| Hiệu ứng | `src/components/ui/FadeIn.tsx`, `brandGradient` trong `src/theme/tokens.ts` |
| Đa ngôn ngữ | `src/i18n/locales/en.json` |

## Quyết định

- `AppLockGate` phủ lên trên thay vì gỡ màn phía dưới, để upload và bản nháp không mất.
- Chỉ tính giờ khi app vào `background`. Hộp xác minh của iOS đưa app qua `inactive`, nếu tính cả trạng thái này sẽ khoá lại ngay sau khi mở khoá.
- Cài đặt lưu theo máy, không theo tài khoản, và vẫn còn sau khi đăng xuất.
- `FadeIn` dùng `Animated` của React Native theo `utils/motion`, vì `reanimated` không chạy được trong jest của dự án.

## Rủi ro

- Lịch nhắc chỉ cập nhật khi mở app. Task đổi hạn lúc app đang đóng thì vẫn nhắc theo hạn cũ cho tới lần mở sau.
- Máy không có khoá màn hình mà tắt khoá sau khi đã bật: màn khoá báo không xác minh được và chỉ còn nút Đăng xuất. Đây là chủ ý.
