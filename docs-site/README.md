# BrandHub Internal Documentation Site (`docs-site/`)

> **Navigation:** [← Infrastructure Root](../README.md) · [Knowledge Base Home (`docs/index.md`)](../docs/index.md)

`docs-site/` là cổng tra cứu tài liệu kỹ thuật nội bộ của hệ thống BrandHub, được xây dựng bằng **VitePress** và tự động đọc toàn bộ kho tri thức Markdown/HTML tại [`../docs/`](../docs/index.md).

> **Phân biệt rõ vai trò giữa các repo:**
> - **`brandhub-web`**: Ứng dụng Web SPA chính thức dành cho người dùng cuối (`Owner`, `Manager`, `Creator`, `Client`, `Admin`).
> - **`brandhub-docs-portal`**: Cổng tra cứu báo cáo tốt nghiệp & SRS/SDD tương tác phục vụ bảo vệ đồ án.
> - **`brandhub-infrastructure/docs-site/`**: Cổng tài liệu kỹ thuật nội bộ (Architecture, ADRs, 141 Feature Specs `spec → plan → task → test`, Database Design, Operations & Workload Dashboard), tự động deploy qua [`.github/workflows/docs-site-deploy.yml`](../.github/workflows/docs-site-deploy.yml).

---

## 1. Cấu trúc Thư mục

```text
docs-site/
├── .vitepress/
│   ├── config.js                    # Cấu hình VitePress, kiểm tra dead-links & copy raw HTML/MD khi build
│   └── theme/
│       ├── index.js                 # Đăng ký custom layout slots & HtmlViewer
│       ├── brandhub.css             # Hệ màu BrandHub Orange (#f05a28) hỗ trợ Light/Dark mode
│       └── components/
│           ├── BrandTitle.vue       # Logo & tiêu đề thanh điều hướng
│           ├── DocsTree.vue         # Thanh tìm kiếm & cây thư mục tài liệu động
│           ├── DocsTreeItem.vue     # Node đệ quy hiển thị thư mục, file .md và .html
│           └── HtmlViewer.vue       # Khung nhúng tài liệu HTML độc lập qua /view?file=...
├── public/
│   ├── logo.svg                     # Biểu tượng BrandHub
│   └── dashboard/
│       ├── index.html               # Giao diện Workload Dashboard
│       └── dashboard.js             # Bộ phân tích tiến độ từ brandhub-master-plan.md & jira-status.json
├── generate-tree.js                 # Quét ../docs/ (.md, .html) sinh ra docs-tree.json (gitignored)
├── package.json                     # Scripts dev, build, preview
└── vercel.json                      # Cấu hình cleanUrls cho môi trường preview/deploy
```

---

## 2. Chạy & Kiểm tra Local

```bash
cd docs-site
npm ci
npm run dev       # Chạy VitePress dev server (mặc định http://localhost:5173)
npm run build     # Sinh docs-tree.json, kiểm tra toàn bộ liên kết Markdown & xuất tĩnh ra .vitepress/dist
npm run preview   # Kiểm tra bản build production tĩnh tại local
```

- **Biến môi trường tùy chọn:** Đặt `VITEPRESS_BASE=/brandhub-infrastructure/` khi build cho GitHub Pages dưới subpath repository (mặc định `VITEPRESS_BASE=/` cho custom domain hoặc Vercel).
- **Cập nhật dữ liệu Jira trên Dashboard:** Xem hướng dẫn tại [`../scripts/jira/README.md`](../scripts/jira/README.md).
