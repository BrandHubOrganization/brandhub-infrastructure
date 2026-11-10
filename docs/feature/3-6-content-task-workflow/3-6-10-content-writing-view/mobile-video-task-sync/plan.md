# Mobile video → Task sync — Plan

## Backend (`brandhub-business-service`)
- `MaterialListRequest`, `MaterialRepositoryQuery`: tham số `taskId`.
- `MaterialUploadPolicy`: TASK nhận video và ảnh.
- `MaterialContentValidator`: MP4 và QuickTime cùng họ ISO BMFF, chấp nhận cả hai chiều.
- `MaterialUploadCoordinator`: TTL TASK 3600s.
- `MaterialPostReferences.url`: media đã ghim vào bài được ký URL cho người đã đọc được bài, kể cả Client.
- `PostServiceImpl`: response trả `materialId` để client lưu lại bài không mất tham chiếu.

## Web (`brandhub-web`)
- `MaterialFilters.taskId`; `TaskPhoneMedia` trong `TaskWorkflowContent`, polling 15s, dùng lại `materialService.preview`.
- Nút đưa vào bài dùng `taskPostService`.
- Locale `vi`, `en`.

## Mobile (`brandhub-mobile-app`)
- `mediaSyncService`: một pipeline duy nhất; lưu queue ra file; khóa ghi; copy tệp vào thư mục bền; phân loại lỗi; tự chạy lại.
- `useMediaSyncRunner` trong `App`: chạy theo AppState, NetInfo, enqueue.
- `UploadScreen`: chỉ hiển thị tiến độ. `TaskUploadScreen`, `MediaLibraryScreen`: tự chạy, lọc đúng task được giao, HEIC → JPEG.
- `TaskDetailScreen`: nút quay theo assignee, khu take và đưa vào bài.
- `CameraRecordScreen`: VisionCamera, tải lười để Expo Go và web không vỡ.
- Dependency: `react-native-vision-camera`, `react-native-nitro-modules`, `react-native-nitro-image`, `@react-native-community/netinfo`, `expo-image-manipulator`.

## Rủi ro
- VisionCamera bắt buộc dev build. iPhone trên Windows phải build qua EAS và cần tài khoản Apple Developer.
- Compile native không kiểm được trên máy này vì không có Android SDK hay Xcode.
