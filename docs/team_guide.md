# Team Guide — Quy trình phát triển tính năng BrandHub

> Hướng dẫn chuẩn cho toàn bộ thành viên khi nhận và hoàn thành một task Jira.
> Đọc kỹ trước khi bắt đầu. Mọi bước có tài liệu gốc tham chiếu đều ghi rõ đường dẫn.

---

## 1. Bối cảnh

- Các task mới đã được thêm lên Jira. Công việc **phụ thuộc lẫn nhau nhiều** và sprint 8
  đã gần hết, nên nếu có chồng chéo thì phần chưa làm được chuyển sang sprint sau.
- Vì thời gian gấp và việc cấn nhau, **phân task trên Jira chỉ là một phần** — ai thấy task
  nào có thể làm trước thì chủ động làm để đẩy nhanh tiến độ.
- **Trước khi bắt đầu:** pull code mới nhất của `develop` (cả `brandhub-infrastructure` và
  `brandhub-business-service`).

---

## 2. Quy trình 8 bước

### Bước 1 — Nhận task trên Jira

Mở Jira, xem task được giao, ghi nhớ mã task (ví dụ `DA-47`), kéo task sang **In Progress**.

**Nếu công việc phát sinh chưa có task trên Jira** (ví dụ phát hiện qua audit/review, hoặc bug ngoài scope task đang làm):

1. Tạo task Jira mới (Task hoặc Bug tùy loại), đặt tên theo đúng pattern `[DA-Exx-yy] <Mô tả>` — số `yy` nối tiếp task cuối cùng của epic đó (không trùng số).
2. **Gán vào đúng Epic** (field `parent`) và **gán đúng Sprint hiện tại đang active** (field Sprint) — không để task mồ côi không epic/không sprint.
3. Ghi rõ trong description: `Ghi chú: Không có trong plan gốc — phát sinh từ <lý do>. Docs: <đường dẫn liên quan>.`
4. Bổ sung ngay task đó vào `brandhub-master-plan.md` — thêm dòng vào bảng Epic tương ứng + mục chi tiết theo mẫu các task `_(phát sinh, ngoài plan gốc)_` đã có sẵn (xem EPIC E12 làm ví dụ).

### Bước 2 — Làm tài liệu Report 3 (SRS) và Report 4 (SDD)

Mỗi task/FR cần cập nhật **2 tài liệu report**:

- **Report 3 — SRS** (`FormReportDA/reports/BrandHub_Report3_Software_Requirement_Specification.docx`):
  viết **spec cho FR** theo mẫu chuẩn (xem [§3](#3-mẫu-spec-fr-cho-report-3-srs)). Screenshot FE
  sẽ chèn sau khi code xong ở Bước 7.
- **Report 4 — SDD** (`FormReportDA/reports/BrandHub_Report4_Software_Design_Document.docx`):
  vẽ **Sequence diagram** cho FR.

Report 1 và Report 2 đã được hoàn thiện (Trung + Phước phụ trách), thành viên **không cần
động vào**:
- `FormReportDA/reports/BrandHub_Report1_Project_Introduction.docx`
- `FormReportDA/reports/BrandHub_Report2_Project_Management_Plan.docx`

### Bước 3 — Đọc tài liệu nghiệp vụ (spec + BA)

1. Vào `brandhub-infrastructure/docs/feature/<tên-feature>/`.
2. Đọc file `spec.md` (đặc tả ban đầu của feature). File này có liên kết tới thư mục phân tích
   nghiệp vụ `brandhub-infrastructure/docs/ba/` — **đọc qua toàn bộ phần BA liên quan trước**.
3. Nếu phát hiện spec/BA **sai hoặc thiếu** → chỉnh lại spec cho đúng, hoặc làm chi tiết hơn nếu cần.

### Bước 4 — Viết 3 tài liệu còn lại theo mẫu

Mẫu đặt tại `brandhub-infrastructure/docs/feature/definition/`. Mỗi feature phải có đủ 4 file:

| File | Vai trò | Trả lời câu hỏi |
|------|---------|-----------------|
| `spec.md` | Đặc tả nghiệp vụ (đã có ở Bước 3) | **Làm gì, cho ai, đúng ra sao** |
| `plan.md` | Kế hoạch triển khai kỹ thuật | **Làm thế nào** |
| `task.md` | Checklist phân rã công việc | **Làm từng bước gì, xong chưa** |
| `test.md` | Kịch bản test case | **Kiểm tra gì để biết đúng** |

- Tuân thủ đúng thứ tự `spec → plan → task → test` trước khi viết code.
- Thư mục feature đặt theo **kebab-case tiếng Anh** (ví dụ `multi-method-login`).
- Quy tắc viết và ranh giới giữa 4 file xem tại `brandhub-infrastructure/docs/rule/feature-workflow.md`.

### Bước 5 — Viết code theo đúng tài liệu (tách BE / FE)

Code đúng theo tài liệu đã viết ở Bước 3–4, không tự suy diễn nghiệp vụ ngoài spec. Test bắt
buộc phủ đủ **happy case** và **unhappy case** (edge case, error case).

**Backend (`brandhub-business-service`)**:
- Entity, controller, service interface đã triển khai sẵn → chỉ cần **implement service impl**.
- Viết test cho phần logic nghiệp vụ.
- **Bắt buộc tuân thủ** `brandhub-business-service/rule.md` — package structure, API
  response format (`ApiResponse<T>`), ErrorCode enum, JPA/transaction convention, JWT/BCrypt
  security, clean code (method ≤30 dòng, ≤3 params, không magic number/string), test coverage
  (≥80% service layer). Checklist đầy đủ ở §13 file đó — chạy qua trước khi mở PR.

**Frontend (`brandhub-web-dashboard` / `brandhub-mobile-app`)**:
- Code UI theo spec, đảm bảo **responsive** trên các kích thước màn hình.
- **Bắt buộc tuân thủ** `brandhub-web-dashboard/rule.md` — theme light/dark (token semantic,
  không hardcode hex), i18n (`t()`, key song song vi/en), component dùng chung (Button/Input/
  Spinner, không tự chế), TypeScript nghiêm ngặt (không `any`), kiến trúc feature-based
  (`pages/[feature]/components/`, orchestrator <150 dòng), clean code (hàm ≤30 dòng, file
  ≤300 dòng). Checklist đầy đủ ở §12 file đó — chạy qua trước khi mở PR.

> Làm cẩn thận, check kỹ. Không làm ẩu bằng AI — sửa lại tốn công hơn nhiều.

### Bước 6 — Commit theo chuẩn

Commit đúng theo `brandhub-infrastructure/docs/rule/git-commit-convention.md`.

- **Không cần** đặt tên nhánh trùng mã Jira.
- **Điều quan trọng:** message commit phải chứa đúng mã task Jira, ví dụ `feat(DA-47): ...`.

### Bước 7 — Đóng task trên Jira

1. Kéo task **In Progress → In Review**, chờ lead/người duyệt.
2. Sau khi được duyệt → kéo sang **Done**.
3. Chụp màn hình **FE của màn hình đó**, chèn vào **Report 3 (SRS)**.

### Bước 8 — Cập nhật trạng thái FR trên Excel

Cập nhật cột **`Hiện trạng`** trong file
`brandhub-infrastructure/docs/Các FR của hệ thống - Feature_Function Requirement.csv`
để cả team nắm được tiến độ.

---

## 3. Mẫu spec FR cho Report 3 (SRS)

> Trích từ `FormReportDA/report_drafts/DA-763_R3_S3.2.1_FR_Register_Email.md`.
> Thay `DA-xxx`, `§x.y.z`, tên FR và nội dung cho khớp task của mình.

### Header

```markdown
# DA-xxx — [<mã cha>] [R3 §x.y.z] Write FR — <Tên FR>

> Report: Report 3 — SRS | Section: §x.y.z | Assignee: <tên>
> Source: <Controller.java>, <ServiceImpl.java>, <Request.java>
```

### Các mục bắt buộc

| Mục | Nội dung |
|------|----------|
| **Function Trigger** | Điều gì kích hoạt hàm (role nào + hành động trên route nào). |
| **Function Description** | Actors/Roles, Purpose (mục đích), Interface (màn hình), Data Processing (xử lý dữ liệu). |
| **Screen Layout** | Mô tả màn hình + **chèn screenshot FE** (sau khi code xong). |
| **Data Specifications** | Input required, System data, Output, Errors (mã + message). |
| **Business Rules** | Danh sách `BR-01`, `BR-02`, … (ràng buộc nghiệp vụ). |
| **Validation** | Từng field lỗi → hiển thị message gì. |
| **Normal Flow** | Các bước xử lý đúng chuẩn (đánh số). |
| **Abnormal Cases** | Case ngoại lệ + cách xử lý (lỗi, trùng, fail…). |
| **Post-Conditions** | Trạng thái dữ liệu sau khi hàm hoàn tất. |

---

## 4. Tài liệu tham chiếu

| Nội dung | Đường dẫn |
|----------|-----------|
| Quy trình 4 file feature | `brandhub-infrastructure/docs/rule/feature-workflow.md` |
| Git commit convention | `brandhub-infrastructure/docs/rule/git-commit-convention.md` |
| Chuẩn code Backend | `brandhub-business-service/rule.md` |
| Chuẩn code Frontend | `brandhub-web-dashboard/rule.md` |
| Mẫu spec/plan/task/test | `brandhub-infrastructure/docs/feature/definition/` |
| Đặc tả từng feature | `brandhub-infrastructure/docs/feature/<tên-feature>/` |
| Phân tích nghiệp vụ (BA) | `brandhub-infrastructure/docs/ba/` |
| Mẫu spec FR (Report 3) | `FormReportDA/report_drafts/DA-763_R3_S3.2.1_FR_Register_Email.md` |
| FR danh sách (Excel) | `brandhub-infrastructure/docs/Các FR của hệ thống - Feature_Function Requirement.csv` |
| Report 1–4 | `FormReportDA/reports/BrandHub_Report{1..4}_*.docx` |

---

## 5. Tóm tắt nhanh

```
Pull develop (infra + business)
  → B1: check Jira, kéo In Progress
  → B2: Report 3 (spec FR) + Report 4 (Sequence diagram)
  → B3: đọc spec.md + BA, sửa nếu sai/thiếu
  → B4: viết plan.md + task.md + test.md (theo mẫu definition)
  → B5: code — BE (implement service impl + test) / FE (UI + responsive)
  → B6: commit đúng mã DA-xx
  → B7: In Review → Done + chụp FE chèn Report 3
  → B8: cập nhật cột "Hiện trạng" trên Excel
```
