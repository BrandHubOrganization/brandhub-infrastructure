# Sprint Report — Hướng dẫn sử dụng thư mục này

Mỗi sprint có một folder riêng theo cấu trúc sau:

```
sprints/
├── sprint_sample/               ← Đọc folder này trước khi viết report
│   ├── README.md                ← File này — hướng dẫn tổng quan
│   ├── SPRINT_REPORT.md         ← Mẫu report tổng của cả team (Leader viết)
│   └── members/
│       ├── MEMBER_REPORT_TEMPLATE.md   ← Mẫu report cá nhân
│       ├── sample_trungle.md            ← Ví dụ điền đầy đủ (Leader)
│       └── sample_member.md             ← Ví dụ điền đầy đủ (Member)
│
├── sprint_03/
│   ├── SPRINT_REPORT.md         ← Report tổng Sprint 3
│   └── members/
│       ├── trungle.md
│       ├── tuannm.md
│       ├── phuocnc.md
│       ├── locnv.md
│       └── anha.md
│
├── sprint_04/                   ← Tạo khi Sprint 4 kết thúc
│   └── ...
```

---

## Quy trình nộp report cuối sprint

1. **Mỗi thành viên** copy `MEMBER_REPORT_TEMPLATE.md` → điền → đặt vào `sprint_XX/members/{tên}.md`
2. **Leader (Trung)** tổng hợp → viết `sprint_XX/SPRINT_REPORT.md`
3. Commit vào branch `docs/sprint-XX-report` → tạo PR → merge vào `develop`

**Deadline nộp:** Ngày cuối sprint (trước daily standup cuối cùng)

---

## Naming convention

| File | Tên |
|---|---|
| Report cá nhân | `{github_username}.md` hoặc `{tên_viết_thường}.md` |
| Report tổng | `SPRINT_REPORT.md` (chữ hoa) |
| Folder sprint | `sprint_XX` (số 2 chữ số: `sprint_03`, `sprint_10`) |
