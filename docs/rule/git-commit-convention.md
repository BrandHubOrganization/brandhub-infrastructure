# Quy định Git Commit Convention — BrandHub

> Áp dụng bắt buộc cho toàn bộ thành viên dự án DA (Đồ Án FPT 2026).  
> Tuân thủ đúng giúp Jira tự động liên kết commit, branch, PR vào đúng task.

---

## 1. Cấu trúc Commit Message

```
<type>(DA-<id>): <mô tả ngắn>

[body - tuỳ chọn]
```

### Ví dụ hợp lệ

```
feat(DA-47): hoàn thiện schema bảng Users và Brands
fix(DA-58): sửa lỗi responsive trên màn hình mobile
docs(DA-2): cập nhật README hướng dẫn cài đặt môi trường
refactor(DA-87): tách API route auth thành module riêng
```

### Ví dụ KHÔNG hợp lệ (Jira sẽ không nhận diện được)

```
update code
fix bug
DA47 done          ← thiếu dấu gạch ngang: phải là DA-47
feat: add login    ← thiếu mã task
```

---

## 2. Các loại `type` được dùng

| Type       | Khi nào dùng                                      |
|------------|---------------------------------------------------|
| `feat`     | Thêm tính năng mới                                |
| `fix`      | Sửa bug                                           |
| `docs`     | Chỉnh tài liệu, README, comment                  |
| `style`    | Format code, không thay đổi logic                 |
| `refactor` | Tái cấu trúc code, không thêm feature/fix bug     |
| `test`     | Thêm hoặc sửa test                                |
| `chore`    | Cài package, config build, CI/CD                  |
| `perf`     | Tối ưu hiệu năng                                  |

---

## 3. Đặt tên Branch

```
<type>/DA-<id>-<mô-tả-ngắn-kebab-case>
```

### Ví dụ

```
feature/DA-58-ux-wireframe
fix/DA-39-functional-requirements
chore/DA-90-cicd-pipeline-setup
```

> **Quy tắc:** Chỉ dùng chữ thường, dùng dấu `-` thay khoảng trắng, không dùng ký tự đặc biệt.

---

## 4. Tiêu đề Pull Request

```
[DA-<id>] <Mô tả ngắn>
```

### Ví dụ

```
[DA-87] Implement API Design & Swagger Spec
[DA-58] UI/UX Wireframe — màn hình Dashboard và Profile
```

---

## 5. Cách Jira hiển thị sau khi sync

Sau khi push commit/branch/PR có chứa mã `DA-xx`, vào task tương ứng trên Jira:

- Panel **Development** (góc phải màn hình detail task) hiện:
  - Số commit liên quan
  - Branch đang làm việc
  - Trạng thái PR (Open / Merged / Declined)

Jira cập nhật tự động trong vòng vài phút sau khi push lên GitHub.

---

## 6. Workflow tổng quát

### Bước 1 — Nhận task trên Jira

Vào board Jira, kéo task sang **In Progress**. Ghi nhớ mã task (ví dụ `DA-47`).

> Không bắt đầu code khi task vẫn ở trạng thái **To Do** — Jira cần trạng thái đúng để team theo dõi tiến độ.

---

### Bước 2 — Cập nhật nhánh `develop` local

```bash
git checkout develop
git pull origin develop
```

> Luôn pull trước khi tạo branch mới để tránh conflict không cần thiết.

---

### Bước 3 — Tạo branch mới từ `develop`

```bash
git checkout -b feature/DA-47-user-schema
```

Cú pháp: `<type>/DA-<id>-<mô-tả-ngắn>`

| Trường hợp       | Ví dụ branch                              |
|------------------|-------------------------------------------|
| Làm tính năng    | `feature/DA-47-user-schema`               |
| Sửa bug          | `fix/DA-58-mobile-responsive`             |
| Cấu hình CI/CD   | `chore/DA-90-cicd-pipeline`               |
| Viết tài liệu    | `docs/DA-2-readme-setup`                  |

---

### Bước 4 — Code và commit từng phần nhỏ

Commit thường xuyên, mỗi commit là một đơn vị công việc có nghĩa:

```bash
# Sau khi tạo xong file schema
git add src/models/user.model.ts
git commit -m "feat(DA-47): tạo schema bảng Users với các trường cơ bản"

# Sau khi thêm validation
git add src/models/user.model.ts
git commit -m "feat(DA-47): thêm validation email và password cho schema Users"

# Sau khi viết unit test
git add src/models/__tests__/user.model.test.ts
git commit -m "test(DA-47): viết unit test cho User schema"
```

> **Không** dồn tất cả vào 1 commit lớn cuối ngày — khó review, khó rollback.

---

### Bước 5 — Push branch lên GitHub

```bash
# Lần đầu push branch mới
git push -u origin feature/DA-47-user-schema

# Các lần push tiếp theo
git push
```

Sau bước này, Jira đã nhận diện được branch và gán vào task `DA-47`.

---

### Bước 6 — Tạo Pull Request và tự merge

1. Vào GitHub → **Compare & pull request**
2. Đặt tiêu đề PR: `[DA-47] User Schema Implementation`
3. Chọn base branch là `develop`
4. Nhấn **Squash and merge**

> Dùng **Squash and merge** để giữ history `develop` gọn — tránh hàng chục commit nhỏ lẫn lộn.

---

### Bước 7 — Cập nhật Jira sau khi merge

1. Vào task `DA-47` trên Jira
2. Kéo sang **In Review**
3. Chờ lead/người được phân công review kết quả
4. Sau khi được duyệt → kéo sang **Done**
5. Panel **Development** hiển thị: branch đã merged, số commit, PR status = Merged

---

### Tóm tắt nhanh

```
Jira: kéo task → In Progress
Git:  pull develop → tạo branch feature/DA-47-xxx
Code: commit thường xuyên với feat(DA-47): ...
Push: git push -u origin feature/DA-47-xxx
PR:   tiêu đề [DA-47] ..., chọn reviewer
Merge: Squash and merge vào develop
Jira: kéo task → In Review → chờ duyệt → Done
```

---

## 7. Lưu ý

- Mã task **phân biệt hoa thường**: dùng `DA-47` không phải `da-47`.
- Một commit có thể gán nhiều task: `feat(DA-47)(DA-58): ...` — Jira nhận cả hai.
- Commit không có mã task vẫn hợp lệ cho Git, nhưng **không sync được vào Jira**.
- Merge commit tự động (`Merge pull request #xx`) không cần mã task.
