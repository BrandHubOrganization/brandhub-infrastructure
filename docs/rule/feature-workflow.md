# Feature Workflow — spec → plan → task → test

> Navigation: [← Knowledge Base Hub](../index.md) · [← Rules Index](./README.md) · [Feature Specs Hub →](../feature/README.md)
>
> **Áp dụng cho toàn bộ các repo code trong hệ thống BrandHub:**
> `brandhub-ai-service`, `brandhub-api-gateway`, `brandhub-business-service`,
> `brandhub-mobile-app`, `brandhub-publisher-service`, `brandhub-web`.
>
> File này là **nguồn sự thật duy nhất**. Mỗi repo khác chỉ có 1 pointer trỏ về đây
> (trong `CLAUDE.md` / `AGENTS.md`). Muốn sửa quy trình → sửa file này, không sửa từng repo.

## 1. Mục đích

Mọi tính năng phát triển trong hệ thống phải đi qua **4 tài liệu tuần tự** trước khi
viết code. Điều này đảm bảo: đúng nghiệp vụ (khớp 141 FR và 6 Canonical Roles: `Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`), có kế hoạch rõ, có task phân rã, có test
kiểm chứng — trước khi AI agent hoặc dev bắt tay vào làm. Tránh "code mò", tránh
làm lan man, tránh làm lại nhiều lần.

## 2. Cấu trúc thư mục `docs/feature/` (2 nhánh chuẩn)

**Vị trí bắt buộc:** tập trung tại [docs/feature/README.md](../feature/README.md) trong `brandhub-infrastructure`, **không** đặt phân tán trong `docs/feature/` của từng repo con (`brandhub-web`, `brandhub-mobile-app`, ...). Lý do: `brandhub-infrastructure` là nguồn sự thật duy nhất khi nhiều thành viên cùng phối hợp trên một tính năng liên quan nhiều microservice.

Thư mục `docs/feature/` được tổ chức sạch sẽ thành **2 nhánh rõ ràng**:

```text
brandhub-infrastructure/docs/feature/
├── README.md
├── srs/                                     # Nhánh 1: 141 FR chuẩn của SRS (chia theo 9 domain)
│   ├── 01-authentication/                   # 3.2.1 – 3.2.9   (9 FRs)
│   ├── 02-profile/                          # 3.3.1 – 3.3.4   (4 FRs)
│   ├── 03-agency-workspace/                 # 3.4.1 – 3.4.26  (26 FRs)
│   ├── 04-media-package-campaign/           # 3.5.1 – 3.5.13  (13 FRs)
│   ├── 05-content-task-workflow/            # 3.6.1 – 3.6.35  (35 FRs)
│   ├── 06-ai-features/                      # 3.7.1 – 3.7.19  (19 FRs)
│   ├── 07-publishing-social/                # 3.8.1 – 3.8.15  (15 FRs)
│   ├── 08-subscription-billing/             # 3.9.1 – 3.9.6   (6 FRs)
│   └── 09-admin-functions/                  # 3.10.1 – 3.10.14 (14 FRs)
│       └── <3-x-y-slug>/                    # Vd: 3-2-1-sign-up/
│           ├── spec.md                      # Đặc tả nghiệp vụ — LÀM TRƯỚC
│           ├── plan.md                      # Kế hoạch triển khai kỹ thuật
│           ├── task.md                      # Phân rã công việc (checklist thực thi)
│           └── test.md                      # Kịch bản / test case kiểm chứng
└── modules/                                 # Nhánh 2: 26 module mở rộng / mobile hợp nhất (chia theo 8 nhóm)
    ├── 01-identity-gateway/
    ├── 02-agency-studio-plans/
    ├── 03-campaign-package-delivery/
    ├── 04-task-chat-vault/
    ├── 05-ai-rag-and-crawler/
    ├── 06-ai-media-and-video-studio/
    ├── 07-billing-publisher-and-observability/
    └── 08-mobile-application/
        └── <kebab-case>/                    # Vd: mobile-auth/, mobile-creator-upload/
            ├── spec.md
            ├── plan.md
            ├── task.md
            └── test.md
```

- **Nhánh [`docs/feature/srs/`](../feature/srs/README.md)**: Dành cho **141 Functional Requirements (`3.2.1`–`3.10.14`)** của baseline SRS, gom vào đúng 1 trong 9 domain (`01-authentication` đến `09-admin-functions`), đặt tên thư mục theo `<3-x-y-slug>` (kebab-case, tiếng Anh).
- **Nhánh [`docs/feature/modules/`](../feature/modules/README.md)**: Dành cho các module nền tảng dùng chung (cross-cutting), cải tiến UI/UX tổng thể, tích hợp hạ tầng hoặc luồng đặc thù trên `brandhub-mobile-app`, gom vào đúng 1 trong 8 thư mục chuyên đề (`01-identity-gateway` đến `08-mobile-application`) và đặt tên theo `<kebab-case>`.
- Mỗi thư mục tính năng chứa đúng **4 file bắt buộc** (`spec.md`, `plan.md`, `task.md`, `test.md`), mỗi file có **trách nhiệm duy nhất**, không trộn lẫn.

## 3. Nội dung từng file

### `spec.md` — Đặc tả nghiệp vụ
Trả lời **LÀM CÁI GÌ và VÌ SAO**. Đối chiếu trực tiếp với [Phân tích nghiệp vụ BA](../ba/README.md).

Gồm: Objective, Canonical Actors (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`), User Story, Acceptance Criteria, UI/UX, API Contract, Error Handling, Edge Cases, UI States, Test Cases (sơ bộ), Definition of Done, Out of Scope.

**Với mọi feature có UI** (`brandhub-web`, `brandhub-mobile-app`), `spec.md`
BẮT BUỘC có thêm 2 mục sau trong Acceptance Criteria / UI States — không được bỏ qua:

- **Đa ngôn ngữ (i18n):** liệt kê toàn bộ text hiển thị mới sẽ dùng key nào (namespace,
  vd `landing.features.demoLabel`), xác nhận key được thêm đồng thời vào **cả**
  `vi.json` và `en.json` (key-parallel), không hardcode chuỗi tiếng Việt/Anh trong JSX/TSX.
- **Light/Dark mode:** xác nhận UI mới hoạt động đúng ở cả 2 theme — dùng token/biến
  theme hoặc class `dark:` variant sẵn có, không hardcode màu cố định (hex/rgb) không
  có cặp dark tương ứng. Nêu rõ nếu có màu đặc thù cần thêm token mới.

`plan.md` phải liệt kê các file i18n locale sẽ đổi; `task.md` phải có task riêng
"cập nhật `vi.json` + `en.json`" và "kiểm tra light/dark mode"; `test.md` phải có test
case xác nhận đổi ngôn ngữ không vỡ UI và chuyển theme không vỡ contrast/màu sắc.

### `plan.md` — Kế hoạch kỹ thuật
Trả lời **LÀM THẾ NÀO**. Phân rã giải pháp kỹ thuật dựa trên spec:
thành phần, repo/file chạm tới, DB schema thay đổi (xem [Database Architecture](../database/README.md)), luồng dữ liệu, thứ tự build, rủi ro.

### `task.md` — Phân rã công việc
Trả lời **TỪNG BƯỚC CỤ THỂ**. Checklist thực thi theo thứ tự, mỗi task nhỏ, độc lập,
có thể tick. Mỗi task ánh xạ tới phần trong `plan.md`.

### `test.md` — Kịch bản kiểm chứng
Trả lời **KIỂM TRA GÌ**. Kịch bản test theo Acceptance Criteria trong `spec.md` (đủ cả happy case và unhappy/edge case).
Nêu test case, input, mong đợi. Dùng làm checklist pass/fail khi hoàn thành.

## 4. Tuần tự bắt buộc

```text
spec.md  →  plan.md  →  task.md  →  test.md  →  Đọc đủ 4 file & triển khai code
   ①          ②           ③          ④                        ⑤
```

- **①→④ phải hoàn thành theo đúng thứ tự** trước khi ⑤ viết code.
- Không được nhảy cóc: chưa có `spec.md` thì không viết `plan.md`; chưa có `plan.md` thì không
  tách `task.md`; chưa có `task.md` thì không viết `test.md`.
- AI agent (hoặc dev) **chỉ được bắt đầu code sau khi đã đọc đủ cả 4 file**.

## 5. Vòng lặp khi có sai sót

Nếu trong lúc code (hoặc sau khi code, test fail) phát hiện **sai nghiệp vụ /
thiếu sót / hiểu sai yêu cầu**:

```text
        ┌─────────────  QUAY LẠI BƯỚC 1  ─────────────┐
        │                                             │
spec.md (sửa lại cho ĐÚNG) → plan.md (sửa lại) → task.md (sửa lại) → test.md (sửa lại) → code
   ①                                ②              ③                ④               ⑤
```

- **Luôn sửa từ `spec.md` trước** vì `spec.md` là gốc rễ của sai lệch (nếu ảnh hưởng nghiệp vụ chung cần thống nhất với cả nhóm và đồng bộ với [docs/ba/](../ba/README.md)).
- Sau khi sửa `spec.md` → **refactor lại lần lượt** `plan.md → task.md → test.md` cho khớp `spec.md` mới.
- Không được "vá code" lúc ⑤ rồi bỏ qua việc cập nhật 4 tài liệu. Tài liệu phải luôn phản ánh đúng code.

## 6. Quy tắc cho AI Agent & Developer khi thực thi

- Đọc đủ 4 file (`spec.md`, `plan.md`, `task.md`, `test.md`) trước khi viết code.
- Làm đúng theo thứ tự task trong `task.md`.
- Sau khi code xong, chạy đối chiếu `test.md` để tự verify.
- Nếu thấy `spec.md`/`plan.md` không khớp thực tế → **dừng lại**, báo nhóm, và làm theo vòng lặp mục 5,
  không tự ý đổi nghiệp vụ trong lúc code.
- Commit và mở PR tuân thủ [Git Commit Convention](./git-commit-convention.md).
