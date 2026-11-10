# Feature Workflow — spec → plan → task → test

> **Áp dụng cho toàn bộ các repo code trong hệ thống BrandHub:**
> `brandhub-ai-service`, `brandhub-api-gateway`, `brandhub-business-service`,
> `brandhub-mobile-app`, `brandhub-publisher-service`, `brandhub-web-dashboard`.
>
> File này là **nguồn sự thật duy nhất**. Mỗi repo khác chỉ có 1 pointer trỏ về đây
> (trong `CLAUDE.md`). Muốn sửa quy trình → sửa file này, không sửa từng repo.

## 1. Mục đích

Mọi tính năng phát triển trong hệ thống phải đi qua **4 tài liệu tuần tự** trước khi
viết code. Điều này đảm bảo: đúng nghiệp vụ, có kế hoạch rõ, có task phân rã, có test
kiểm chứng — trước khi Claude AI (hoặc dev) bắt tay vào làm. Tránh "code mò", tránh
làm lan man, tránh làm lại nhiều lần.

## 2. Cấu trúc thư mục feature

**Vị trí bắt buộc:** `brandhub-infrastructure/docs/feature/` — TẬP TRUNG, không
đặt trong `docs/feature/` của từng repo con (`brandhub-web-dashboard`,
`brandhub-mobile-app`, ...). Lý do giống `feature-workflow.md` — infra là
nguồn sự thật duy nhất, tránh doc phân tán và mất đồng bộ giữa các repo khi
nhiều người cùng làm feature liên quan nhiều service.

Thư mục tổ chức theo **domain → FR chuẩn** (141 FR, `3.2.1`–`3.10.14`, nguồn:
`brandhub-docs-portal/src/data/frs/domain-*.json`). Mục lục: [`docs/feature/README.md`](../feature/README.md).

```
brandhub-infrastructure/docs/feature/
├── README.md                                   # Mục lục domain → FR → tính năng
├── 3-6-content-task-workflow/                  # Domain: <mã domain>-<tên>
│   ├── <tài liệu chung của domain>.md
│   └── 3-6-9-approval-sequence-creator-manager-client/   # FR: <mã FR>-<slug tên FR chuẩn>
│       ├── spec.md plan.md task.md test.md     # Tài liệu FR gốc
│       ├── report3_spec.md report4_sequence.puml report5_unit_test.md  # Tài liệu report
│       └── subtask-role-workspaces/            # Tính năng mở rộng FR này
│           ├── spec.md
│           ├── plan.md
│           ├── task.md
│           └── test.md
├── _platform/<ten-viec>/                       # Hạ tầng, CI, deploy, seed, việc xuyên nhiều FR
└── _archive/                                   # descoped/ (FR đã bỏ), legacy-numbering/ (bản đánh số cũ)
```

- **Tính năng mới** đặt làm thư mục con trong **FR chính** mà nó mở rộng (kebab-case,
  tiếng Anh, vd `chat-attachments` trong `3-6-35-chat-realtime/`). Chạm nhiều FR → đặt ở
  FR chính, ghi các FR liên quan ở đầu `spec.md`.
- Việc không gắn FR nào (CI, deploy, seed, monitoring, sửa lỗi runtime) → `_platform/`.
- Tên thư mục FR phải khớp đúng mã + tên trong danh sách 141 FR; không tạo thư mục FR
  trùng số hoặc theo số cũ. FR bị bỏ khỏi phạm vi → `_archive/descoped/`.
- Mỗi thư mục tính năng chứa đúng 4 file bắt buộc `spec.md`, `plan.md`, `task.md`, `test.md`.
  Test unit theo Report5 đặt tên `report5_unit_test.md`, không dùng `test.md`.
- Mỗi file có **trách nhiệm duy nhất**, không trộn lẫn.

## 3. Nội dung từng file

### spec.md — Đặc tả nghiệp vụ
Trả lời **LÀM CÁI GÌ và VÌ SAO**. Tham chiếu mẫu:
`BienSoDep/docs/features/mvp/UC01-danh-sach-tim-kiem/spec.md`.

Gồm: Objective, User Story, Acceptance Criteria, UI/UX, API Contract, Error
Handling, Edge Cases, UI States, Test Cases (sơ bộ), Definition of Done, Out of
Scope.

**Với mọi feature có UI** (`brandhub-web-dashboard`, `brandhub-mobile-app`), spec.md
BẮT BUỘC có thêm 2 mục sau trong Acceptance Criteria / UI States — không được bỏ qua:

- **Đa ngôn ngữ (i18n):** liệt kê toàn bộ text hiển thị mới sẽ dùng key nào (namespace,
  vd `landing.features.demoLabel`), xác nhận key được thêm đồng thời vào **cả**
  `vi.json` và `en.json` (key-parallel), không hardcode chuỗi tiếng Việt/Anh trong JSX.
- **Light/Dark mode:** xác nhận UI mới hoạt động đúng ở cả 2 theme — dùng token/biến
  theme hoặc class `dark:` variant sẵn có, không hardcode màu cố định (hex/rgb) không
  có cặp dark tương ứng. Nêu rõ nếu có màu đặc thù cần thêm token mới.

`plan.md` phải liệt kê các file i18n locale sẽ đổi; `task.md` phải có task riêng
"cập nhật vi.json + en.json" và "kiểm tra light/dark mode"; `test.md` phải có test
case xác nhận đổi ngôn ngữ không vỡ UI và chuyển theme không vỡ contrast/màu sắc.

### plan.md — Kế hoạch kỹ thuật
Trả lời **LÀM THẾ NÀO**. Phân rã giải pháp kỹ thuật dựa trên spec:
thành phần, file chạm tới, DB schema thay đổi, luồng dữ liệu, thứ tự build, rủi ro.

### task.md — Phân rã công việc
Trả lời **TỪNG BƯỚC CỤ THỂ**. Checklist thực thi theo thứ tự, mỗi task nhỏ, độc lập,
có thể tick. Mỗi task ánh xạ tới phần trong plan.

### test.md — Kịch bản kiểm chứng
Trả lời **KIỂM TRA GÌ**. Kịch bản test theo Acceptance Criteria trong spec.
Nêu test case, input, mong đợi. Dùng làm checklist pass/fail khi hoàn thành.

## 4. Tuần tự bắt buộc

```
spec.md  →  plan.md  →  task.md  →  test.md  →  Claude AI đọc & code
   ①          ②           ③          ④                ⑤
```

- **①→④ phải hoàn thành theo đúng thứ tự** trước khi ⑤ code.
- Không được nhảy cóc: chưa có spec thì không viết plan; chưa có plan thì không
  tách task; chưa có task thì không viết test.
- Claude AI (hoặc dev) **chỉ được bắt đầu code sau khi đã đọc đủ cả 4 file**.

## 5. Vòng lặp khi có sai sót

Nếu trong lúc code (hoặc sau khi code, test fail) phát hiện **sai nghiệp vụ /
thiếu sót / hiểu sai yêu cầu**:

```
        ┌─────────────  QUAY LẠI BƯỚC 1  ─────────────┐
        │                                             │
spec.md (sửa lại cho ĐÚNG) → plan.md (sửa lại) → task.md (sửa lại) → test.md (sửa lại) → code
   ①                                ②              ③                ④               ⑤
```

- **Luôn sửa từ `spec.md` trước** vì spec là gốc rễ của sai lệch.
- Sau khi sửa spec → **refactor lại lần lượt** `plan → task → test` cho khớp spec mới.
- Không được "vá code" lúc ⑤ rồi bỏ qua việc cập nhật 4 tài liệu. Tài liệu phải là
  nguồn phản ánh đúng code.

## 6. Quy tắc cho Claude AI khi làm

- Đọc đủ 4 file (`spec.md`, `plan.md`, `task.md`, `test.md`) trước khi viết code.
- Làm đúng theo thứ tự task trong `task.md`.
- Sau khi code xong, chạy đối chiếu `test.md` để tự verify.
- Nếu thấy spec/plan không khớp thực tế → **dừng lại**, báo, và làm theo vòng lặp mục 5,
  không tự ý đổi nghiệp vụ trong lúc code.
