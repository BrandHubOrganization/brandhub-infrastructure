# Team Guide — Quy trình phát triển tính năng BrandHub

> Navigation: [← Knowledge Base Hub](../index.md) · [← Guides Index](./README.md) · [Feature Workflow](../rule/feature-workflow.md) · [Git Convention](../rule/git-commit-convention.md)
>
> Hướng dẫn chuẩn cho toàn bộ 5 thành viên khi nhận và hoàn thành một task Jira (`DA-xxx`).
> Đọc kỹ trước khi bắt đầu. Mọi bước có tài liệu gốc tham chiếu đều ghi rõ đường dẫn.

---

## 1. Bối cảnh & Nguyên tắc chung

- Hệ thống chuẩn hóa **141 Functional Requirements (`3.2.1`–`3.10.14`)** tương ứng **141 Use Cases (`UC-001`–`UC-141`)** trên **9 functional domains** và **6 Canonical System Roles** (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
- Công việc giữa các service phụ thuộc lẫn nhau chặt chẽ, nên ai hoàn thành sớm hoặc thấy task có thể mở khóa cho đồng đội thì chủ động nhận trên Jira để đẩy nhanh tiến độ.
- **Trước khi bắt đầu:** pull code mới nhất của nhánh `develop` trên các repo liên quan (`brandhub-infrastructure`, `brandhub-business-service`, `brandhub-ai-service`, `brandhub-publisher-service`, `brandhub-web`, `brandhub-mobile-app`).

---

## 2. Quy trình 8 bước thực thi

### Bước 1 — Nhận task trên Jira

Mở Jira, xem task được giao, ghi nhớ mã task (ví dụ `DA-47`), kéo task sang **In Progress**.

**Nếu công việc phát sinh chưa có task trên Jira** (ví dụ phát hiện qua audit/review, hoặc bug ngoài scope task đang làm):

1. Tạo task Jira mới (Task hoặc Bug tùy loại), đặt tên theo đúng pattern `[DA-Exx-yy] <Mô tả>` — số `yy` nối tiếp task cuối cùng của epic đó (không trùng số).
2. **Gán vào đúng Epic** (field `parent`) và **gán đúng Sprint hiện tại đang active** (field Sprint) — không để task mồ côi không epic/không sprint.
3. Ghi rõ trong description: `Ghi chú: Không có trong plan gốc — phát sinh từ <lý do>. Docs: <đường dẫn liên quan>.`
4. Bổ sung ngay task đó vào [brandhub-master-plan.md](../plan/brandhub-master-plan.md) — thêm dòng vào bảng Epic tương ứng + mục chi tiết theo mẫu các task phát sinh.

### Bước 2 — Cập nhật tài liệu Report 3 (SRS) và Report 4 (SDD)

Mỗi task/FR thuộc baseline 141 FR cần đồng bộ với kho báo cáo chính thức `brandhub-final_report`:

- **Report 3 — SRS** (`brandhub-final_report/report3/report3_official.docx`):
  viết hoặc cập nhật **spec cho FR** theo chuẩn 141 FR (xem [§3](#3-mẫu-spec-fr-cho-report-3-srs)). Tuân thủ nghiêm ngặt 6 Canonical Roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`), đánh số lại `Normal Flow` từ `1.`, tham chiếu `MSG01`–`MSG60` và `BR-01`–`BR-65` không kèm mã HTTP thô. Screenshot FE chèn ở Bước 7 kèm chú thích `Figure X - <Function Name>`.
- **Report 4 — SDD** (`brandhub-final_report/report4/`):
  cập nhật **Sequence Diagram / Class Design** tương ứng cho FR.

Report 1 (`brandhub-final_report/report1/`) và Report 2 (`brandhub-final_report/report2/`) đã được chốt baseline quản lý dự án; khi cần đối chiếu phạm vi hãy kiểm tra trước với nhóm trưởng.

### Bước 3 — Đọc tài liệu nghiệp vụ (`spec.md` + BA)

1. Mở thư mục feature tương ứng tại [docs/feature/README.md](../feature/README.md):
   - Nếu là 1 trong 141 FR chuẩn của SRS: vào `docs/feature/srs/<01..09-domain>/<3-x-y-slug>/`.
   - Nếu là module nền tảng / cross-cutting / mobile: vào `docs/feature/modules/<kebab-case>/`.
2. Đọc file `spec.md` và đối chiếu trực tiếp với bộ tài liệu phân tích nghiệp vụ tại [docs/ba/README.md](../ba/README.md).
3. Nếu phát hiện `spec.md` hoặc BA thiếu sót / lệch nghiệp vụ → báo lên kênh chung của nhóm để chốt lại trước khi sửa.

### Bước 4 — Viết đủ 4 tài liệu theo chuẩn `spec → plan → task → test`

Mỗi thư mục feature bắt buộc có đủ 4 file theo quy định tại [docs/rule/feature-workflow.md](../rule/feature-workflow.md):

| File | Vai trò | Trả lời câu hỏi |
|------|---------|-----------------|
| `spec.md` | Đặc tả nghiệp vụ (đã rà soát ở Bước 3) | **Làm gì, cho ai, đúng ra sao** |
| `plan.md` | Kế hoạch triển khai kỹ thuật | **Làm thế nào** |
| `task.md` | Checklist phân rã công việc | **Làm từng bước gì, xong chưa** |
| `test.md` | Kịch bản test case | **Kiểm tra gì để biết đúng** |

**Quy định bắt buộc — áp dụng cho cả 141 FR chuẩn lẫn mọi thay đổi lên code đang chạy:**

1. **`spec.md`** — đối chiếu với [docs/ba/README.md](../ba/README.md) và file baseline `Các FR của hệ thống  - Feature_Function Requirement.csv`. Không tự ý sửa lệch nghiệp vụ một mình khi chưa thống nhất với nhóm. Với mọi màn hình UI (`brandhub-web`, `brandhub-mobile-app`), bắt buộc khai báo key đa ngôn ngữ (`vi.json` + `en.json`) và hỗ trợ Light/Dark theme.
2. **`plan.md`** — chỉ viết sau khi `spec.md` đã chốt.
3. **`task.md`** — phân rã từng bước nhỏ từ `plan.md`.
4. **`test.md`** — viết kịch bản kiểm thử phủ đủ happy case và unhappy/edge case trước hoặc song song với lúc code.
5. **Code** — triển khai đúng theo 4 file. Nếu phát hiện vướng mắc nghiệp vụ lúc code, quay lại cập nhật từ `spec.md`.

### Bước 5 — Viết code theo đúng tài liệu (tách BE / FE)

- **Backend (`brandhub-business-service` / `brandhub-ai-service` / `brandhub-publisher-service`)**:
  - Tuân thủ chuẩn kiến trúc dịch vụ tại [docs/architecture/README.md](../architecture/README.md) và chuẩn API response `ApiResponse<T>` tại [docs/api/api-response-format.md](../api/api-response-format.md).
  - Tuân thủ `brandhub-business-service/rule.md` (package structure, ErrorCode enum, JPA/transaction convention, RS256 JWT/BCrypt security, clean code, unit/integration test coverage).
- **Frontend (`brandhub-web` / `brandhub-mobile-app`)**:
  - Đảm bảo responsive, semantic theme tokens (Light/Dark mode, không hardcode mã màu hex), đa ngôn ngữ song song (`vi.json` / `en.json`), TypeScript strict (không dùng `any`), kiến trúc component sạch theo `brandhub-web/rule.md`.

### Bước 6 — Tạo nhánh, Commit & Mở PR theo chuẩn

Tuân thủ nghiêm ngặt [docs/rule/git-commit-convention.md](../rule/git-commit-convention.md):

- **Tên nhánh (bắt buộc):** `<type>/DA-<id>-<kebab-case>` (ví dụ `feat/DA-47-user-schema`, `fix/DA-58-mobile-responsive`, `docs/DA-2-readme-setup`). Chỉ dùng chữ thường và dấu gạch ngang `-`.
- **Commit message (bắt buộc bằng tiếng Anh):** `<type>(DA-<id>): <short description>` (ví dụ `feat(DA-47): implement workspace member role validation`).
- **Pull Request:** mở PR về nhánh `develop`, tiêu đề chứa mã `DA-<id>`, kiểm tra hết conflict và dùng **Squash and merge**.

### Bước 7 — Đóng task trên Jira & Chụp màn hình

1. Kéo task **In Progress → In Review**, chờ review kết quả.
2. Sau khi được duyệt → kéo sang **Done**.
3. Chụp màn hình UI thực tế lưu vào kho minh chứng ([docs/screenshots/README.md](../screenshots/README.md)) và chèn vào `brandhub-final_report/report3/report3_official.docx`.

### Bước 8 — Cập nhật trạng thái trên bảng theo dõi 141 FR

Cập nhật các cột tiến độ (`Chạy được`, `Đầy đủ UI + Xong case`, `Tài liệu`) trong file chuẩn ở thư mục gốc workspace:
`Các FR của hệ thống  - Feature_Function Requirement.csv` (141 FR từ `3.2.1` đến `3.10.14`).

---

## 3. Mẫu spec FR cho Report 3 (SRS)

> Đồng bộ với cấu trúc chuẩn trong `brandhub-final_report/report3/report3_official.docx`.

### Các mục bắt buộc của mỗi FR (`3.2.1`–`3.10.14`)

| Mục | Nội dung chuẩn |
|-----|----------------|
| **Function Trigger** | Sự kiện kích hoạt chức năng (Actor nào + thao tác trên màn hình/route nào). |
| **Function Description** | `Actors / Roles:` (chỉ dùng tổ hợp 6 tên chuẩn: `Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`), `Purpose`, `Interface`, `Data Processing`. Không chèn dòng `Related Use Case & Artefacts`. |
| **Screen Layout** | Ảnh chụp màn hình thực tế kèm dòng chú thích in nghiêng căn giữa `Figure X - <Function Name>`. |
| **Data Specifications** | Input fields, System-generated data, Output, và Message codes (`MSG01`–`MSG60`, không ghi mã HTTP thô). |
| **Business Rules** | Liên kết các quy tắc nghiệp vụ áp dụng (`BR-01`–`BR-65`). |
| **Normal Flow** | Danh sách bước xử lý chính, luôn bắt đầu đánh số lại từ `1.`. |
| **Abnormal Cases** | Các luồng ngoại lệ và mã thông báo `MSGxx` tương ứng. |
| **Post-Conditions** | Trạng thái hệ thống và dữ liệu sau khi hoàn tất. |

---

## 4. Tài liệu tham chiếu nhanh

| Nội dung | Đường dẫn |
|----------|-----------|
| Quy trình 4 file feature (`spec → plan → task → test`) | [docs/rule/feature-workflow.md](../rule/feature-workflow.md) |
| Quy chuẩn Git Branch, Commit & PR | [docs/rule/git-commit-convention.md](../rule/git-commit-convention.md) |
| Quy định làm việc nhóm | [docs/rule/team-rules.html](/view?file=rule/team-rules.html) |
| Chuẩn code Backend | `brandhub-business-service/rule.md` |
| Chuẩn code Frontend Web | `brandhub-web/rule.md` |
| Kho đặc tả Feature (`srs/` & `modules/`) | [docs/feature/README.md](../feature/README.md) |
| Phân tích nghiệp vụ BA & 141 Use Cases | [docs/ba/README.md](../ba/README.md) |
| Danh sách 141 FR gốc của hệ thống (CSV) | `Các FR của hệ thống  - Feature_Function Requirement.csv` (workspace root) |
| Báo cáo chính thức Report 1–7 | `brandhub-final_report/` (`report3/report3_official.docx`, `report4/`, ...) |
| Tài liệu thiết kế Database | [docs/database/README.md](../database/README.md) |
| Script khởi tạo DB (tạo mới từ đầu) | `database/init/init-postgres-v2.sql`, `database/init/init-mongo.js` |
| Script Migration DB (cập nhật DB đang chạy) | `database/migrations/postgres/`, `database/migrations/mongodb/`, `database/migrations/neo4j/` |

---

## 5. Tóm tắt luồng thực thi

```text
Pull develop (infra + service repos)
  → B1: Nhận task Jira (DA-xxx), kéo sang In Progress
  → B2: Đồng bộ đặc tả vào brandhub-final_report (Report 3 SRS + Report 4 SDD)
  → B3: Đọc spec.md (trong docs/feature/srs/ hoặc modules/) + docs/ba/
  → B4: Hoàn thiện đủ 4 file spec.md → plan.md → task.md → test.md
  → B5: Triển khai code BE / FE + viết test happy/unhappy cases
  → B6: Tạo nhánh <type>/DA-<id>-<kebab-case>, commit tiếng Anh, mở PR về develop
  → B7: Kéo Jira sang In Review → Done + bổ sung screenshot vào Report 3
  → B8: Cập nhật trạng thái trên file CSV 141 FR ở gốc workspace
```

---

## 6. Quy định cập nhật & migrate Database

Toàn bộ script vận hành cơ sở dữ liệu đặt tại thư mục cấp cao nhất `database/` của `brandhub-infrastructure` (tách biệt với tài liệu thiết kế trong [docs/database/README.md](../database/README.md)). Hệ thống duy trì **2 điểm vào song song** và bắt buộc cập nhật **cả hai** mỗi khi thay đổi schema:

| Điểm vào | Đối tượng sử dụng | Vị trí trong `brandhub-infrastructure` |
|----------|-------------------|----------------------------------------|
| **File Migration riêng** | Thành viên / môi trường **đã có DB đang chạy** — chỉ chạy phần thay đổi tăng thêm mà không mất dữ liệu hiện có. | `database/migrations/postgres/<YYYY-MM-DD>-<slug>.sql`<br>`database/migrations/mongodb/<YYYY-MM-DD>-<slug>.js`<br>`database/migrations/neo4j/<YYYY-MM-DD>-<slug>.cypher` |
| **File Init gốc** | Máy mới, Docker local mới hoặc môi trường CI/test **khởi tạo DB từ đầu** — chạy 1 lần tạo ra đầy đủ schema mới nhất (97 bảng PG / 52 collection Mongo). | `database/init/init-postgres-v2.sql`<br>`database/init/init-mongo.js` |

**Quy trình bắt buộc khi thay đổi schema (thêm/sửa/xóa cột, bảng, collection, index, constraint):**

1. Tạo file migration mới trong `database/migrations/{postgres,mongodb,neo4j}/` theo định dạng ngày `YYYY-MM-DD-<kebab-case>` và viết câu lệnh idempotent (`IF NOT EXISTS` / `IF EXISTS`) để chạy lại không gây lỗi.
2. Cập nhật **đúng thay đổi tương ứng** vào `database/init/init-postgres-v2.sql` (hoặc `database/init/init-mongo.js`) để schema khởi tạo mới khớp 100% với schema sau khi chạy toàn bộ lịch sử migration.
3. Nếu thay đổi liên quan đến cấu trúc thực thể cốt lõi, cập nhật tài liệu thiết kế tại [docs/database/README.md](../database/README.md).
4. Ghi rõ tên file migration trong mô tả PR và thông báo trên kênh Slack để các thành viên khác pull về chạy cập nhật. Không sửa hoặc xóa các file migration cũ đã được merge vào `develop`.
