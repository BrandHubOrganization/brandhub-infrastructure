# Sprint 4 — Individual Report

---

## 1. Thông tin cá nhân

| Field | Value |
|---|---|
| Họ tên | Nguyễn Thành Lộc |
| GitHub | [@Loc20904] |
| Role | Frontend Developer / AI Infra |
| Sprint | Sprint 4 |
| Ngày nộp | 2026-07-14 |

---

## 2. Tasks được giao trong sprint này

| Task ID | Jira Link | Mô tả | Priority | Status cuối sprint |
|---|---|---|---|---|
| DA-E10-04 | [DA-140](https://letritrung2605.atlassian.net/browse/DA-140) | GitHub Actions CI for web-dashboard (lint + build + deploy) | 🟡 High | ✅ Done |
| DA-E09-10 | [DA-418](https://letritrung2605.atlassian.net/browse/DA-418) | Frontend key | 🟡 High | ✅ Done |
| DA-E09-12 | [DA-423](https://letritrung2605.atlassian.net/browse/DA-423) | Register brandhub domain | 🟡 High | ✅ Done |
| DA-AI02-01 | [DA-235](https://letritrung2605.atlassian.net/browse/DA-235) | Khởi tạo brandhub-ai-service project: FastAPI + Python 3.13 + folder structure | 🔴 Critical | ✅ Done |
| DA-AI02-03 | [DA-268](https://letritrung2605.atlassian.net/browse/DA-268) | Configure AWS S3 client với boto3, viết 3 helper functions | 🔴 Critical | ✅ Done |
| DA-AI02-05 | [DA-223](https://letritrung2605.atlassian.net/browse/DA-223) | Viết Dockerfile cho ai-service + thêm service ai-service vào docker-compose.yml | 🔴 Critical | ✅ Done |

**Tổng:** 6 tasks | Done: 6 | In Review: 0 | Chưa hoàn thành: 0

---

## 3. Chi tiết công việc đã làm

### [DA-E10-04] — GitHub Actions CI for web-dashboard

**Jira status:** Done  
**Branch:** `develop` / `fea/DA-140-ci-web-dashboard`  
**Commit chính:** `fea140b` — `feat(DA-140): add github actions workflow for web-dashboard`  
**File tạo ra / thay đổi:**
- `brandhub-web/.github/workflows/ci.yml` — Định nghĩa quy trình CI (eslint + tsc + build)
- `brandhub-web/package.json` — Thêm script `"type-check": "tsc --noEmit"` để kiểm tra lỗi TypeScript

**Mô tả công việc đã làm:**
- Thiết lập quy trình tích hợp liên tục (CI) cho dự án frontend `brandhub-web` sử dụng GitHub Actions.
- Viết file cấu hình `.github/workflows/ci.yml` tự động kích hoạt khi push lên branch `develop`, `main` và khi tạo pull request nhắm tới `develop`.
- Triển khai các step trong workflow bao gồm: Checkout mã nguồn, cài đặt Node.js v20 (bật cache npm), chạy kiểm tra cú pháp (`npm run lint`), chạy kiểm tra kiểu dữ liệu tĩnh (`npm run type-check`), và thực hiện build Vite (`npm run build`).
- Cấu hình cho workflow tự động dừng và trả về trạng thái thất bại (fail) nếu bất kỳ bước nào trong chuỗi bị lỗi, ngăn chặn code lỗi lọt vào nhánh tích hợp.

**Kết quả đạt được:**
- [x] Tạo thành công workflow CI tự động cho web-dashboard giúp quản lý chất lượng code.
- [x] Tích hợp kiểm soát lỗi kiểu TypeScript trước khi build trên môi trường CI.
- [x] Tối ưu hóa thời gian chạy CI thông qua cơ chế cache npm giúp giảm thời gian build xuống còn dưới 1.5 phút.

**Thời gian thực tế:** ~6 giờ

---

### [DA-E09-10] — Frontend key

**Jira status:** Done  
**Branch:** `docs/DA-418-Create-Frontend-env`  
**Commit chính:** `105b6a7` — `docs(DA-418): Init env.example file`  
**File tạo ra / thay đổi:**
- `brandhub-web/.env.example` — Định nghĩa các biến môi trường mẫu cho frontend
- `brandhub-web/.env` — Lưu trữ API key và cấu hình kết nối internal thực tế (local setup)

**Mô tả công việc đã làm:**
- Thiết lập cơ chế cấu hình và API key xác thực internal cho ứng dụng client (Frontend key) để giao tiếp an toàn thông qua API Gateway.
- Cấu hình hệ thống đọc biến môi trường trong Vite, định nghĩa đầy đủ các key mẫu và hướng dẫn tích hợp trong `.env.example`.
- Tích hợp bảo mật, quản lý các token khóa bí mật trên GitHub Secrets cho môi trường build/deploy.

**Kết quả đạt được:**
- [x] Tách biệt cấu hình bảo mật ra khỏi mã nguồn thông qua biến môi trường.
- [x] Đảm bảo kết nối an toàn từ frontend tới các services bên dưới qua Gateway nhờ kiểm tra key hợp lệ.

**Thời gian thực tế:** ~3 giờ

---

### [DA-E09-12] — Register brandhub domain

**Jira status:** Done  
**Branch:** `develop`  
**Commit chính:** `e2d0f94` — `chore(DA-203): write env.example` (cập nhật thông số domain cấu hình)  
**File tạo ra / thay đổi:**
- Cấu hình domain được tích hợp trong `.env.example` và các file cấu hình DNS/Gateway setup.

**Mô tả công việc đã làm:**
- Đăng ký tên miền phục vụ dự án BrandHub để chuẩn bị cho việc deploy ứng dụng lên môi trường production.
- Cấu hình các bản ghi DNS cần thiết (A record trỏ về địa chỉ IP của VPS/EC2, CNAME cho các sub-domains của Gateway và API Services).
- Thiết lập và kiểm tra tính hợp lệ của domain trỏ về nginx gateway của hệ thống.

**Kết quả đạt được:**
- [x] Đăng ký thành công domain dự án.
- [x] Cấu hình DNS phân giải đúng địa chỉ IP máy chủ của hệ thống.

**Thời gian thực tế:** ~2 giờ

---

### [DA-AI02-01] — Khởi tạo brandhub-ai-service project

**Jira status:** Done  
**Branch:** `feat/DA-235-init-brandhub-ai-service`  
**Commit chính:** `8fe0bf6` — `feat(DA-235): init brandhub-ai-service with FastAPI, Python 3.13 and folder structure`  
**File tạo ra / thay đổi:**
- `app/main.py` — File chạy chính của dịch vụ FastAPI
- `app/api/v1/router.py` — Quản lý định tuyến API
- `requirements.txt` — Danh sách thư viện dependencies
- Các thư mục cấu trúc: `app/api/`, `app/services/`, `app/models/`, `app/utils/`

**Mô tả công việc đã làm:**
- Khởi tạo cấu trúc dự án `brandhub-ai-service` sử dụng ngôn ngữ Python 3.13 và framework FastAPI.
- Tổ chức cấu trúc thư mục chuẩn hóa giúp phân tách logic rõ ràng (Endpoints, Core Config, Models, Services, Utilities, Tests), hỗ trợ tốt cho việc phát triển song song nhiều nhánh AI độc lập.
- Thiết lập router, endpoint `/health` kiểm tra trạng thái hoạt động của service.

**Kết quả đạt được:**
- [x] Khởi tạo thành công service FastAPI chạy ổn định ở local port 8082.
- [x] Cấu trúc dự án sạch, sẵn sàng tích hợp logic nghiệp vụ.

**Thời gian thực tế:** ~6 giờ

---

### [DA-AI02-03] — Configure AWS S3 client với boto3, viết các helper functions

**Jira status:** Done  
**Branch:** `feat/DA-268-aws-s3-APIs`  
**Commit chính:** `05a1150` — `feat(DA-268): connect project with aws-s3 and test by moto`  
**File tạo ra / thay đổi:**
- `app/utils/s3.py` — Triển khai AWS S3 client và các helper functions
- `tests/test_s3.py` — Viết unit tests cho module S3

**Mô tả công việc đã làm:**
- Sử dụng thư viện `boto3` để cấu hình kết nối tới AWS S3, đọc credentials an toàn từ biến môi trường.
- Triển khai 3 helper functions cốt lõi: `upload_file()` (hỗ trợ upload dữ liệu file cục bộ hoặc dạng byte trực tiếp), `get_presigned_url()` (sinh link tạm thời có thời hạn truy cập bảo mật), và `delete_file()`.
- Thiết lập bộ unit tests đầy đủ tại `tests/test_s3.py` sử dụng thư viện `moto` để chạy mock S3, giúp chạy test độc lập trong CI/CD mà không cần AWS key thật.

**Kết quả đạt được:**
- [x] AWS S3 client và các hàm upload/delete/presign hoạt động ổn định.
- [x] Unit test đạt 100% test coverage cho module S3.

**Thời gian thực tế:** ~6 giờ

---

### [DA-AI02-05] — Viết Dockerfile cho ai-service và tích hợp vào docker-compose.yml

**Jira status:** Done  
**Branch:** `feat/DA-223-docker-file-ai-service`  
**Commit chính:** `e0a926f` — `docs(DA-223): udpate docker file for AI service`  
**File tạo ra / thay đổi:**
- `Dockerfile` (brandhub-ai-service) — Cấu hình Docker image cho dịch vụ AI
- `docker-compose.apps.yml` (brandhub-infrastructure) — Cấu hình container orchestrator

**Mô tả công việc đã làm:**
- Viết `Dockerfile` tối ưu hóa thông qua cơ chế multi-stage build giúp giảm tối đa dung lượng file chạy cuối cùng.
- Trong stage build, cài đặt gói `torch==2.5.1+cpu` từ repository chính thức của PyTorch để tránh tải bản GPU quá nặng (giảm dung lượng image đi ~2GB).
- Tích hợp service `ai-service` chạy trên cổng 8082 vào file điều phối `docker-compose.apps.yml`, cấu hình liên kết mạng docker network với `chromadb` và `redis`.

**Kết quả đạt được:**
- [x] Docker image build thành công và chạy container ổn định trong 3 phút.
- [x] Giảm đáng kể dung lượng image nhờ Torch CPU và multi-stage build.

**Thời gian thực tế:** ~4 giờ

---

## 4. Tasks chưa hoàn thành

*Không có task nào chưa hoàn thành.*

---

## 5. Đóng góp ngoài tasks chính

- Hỗ trợ team setup Docker Compose môi trường cục bộ để tích hợp chung các dịch vụ.
- Giải quyết lỗi cài đặt dependencies và config base path cho VitePress site trên GitHub Pages.

---

## 6. Học được gì trong sprint này

1. **Cấu hình CI/CD tối ưu bằng GitHub Actions:** Tận dụng cache của Node/npm để tăng tốc thời gian build CI, giảm thiểu lãng phí tài nguyên của github runner.
2. **Cơ chế biên dịch của Vite:** Hiểu rõ tại sao `vite build` mặc định không check TypeScript error và sự cần thiết của việc chạy check type tĩnh độc lập trên CI.
3. **AWS S3 Mocking với Moto:** Học cách viết unit tests hiệu quả cho các dịch vụ đám mây mà không phát sinh chi phí hoặc rủi ro rò rỉ key.
4. **Tối ưu hóa Docker Image:** Kỹ thuật multi-stage build và cấu hình thư viện PyTorch CPU giúp tối ưu hóa dung lượng disk của container AI.

---

## 7. Feedback & Đề xuất

### 7.1 Về quy trình làm việc của team
Khuyến nghị team bật chế độ required status check cho workflow CI này trên branch protection rules của github để đảm bảo code sạch trước khi merge vào develop.

---

## 8. Self-assessment

| Tiêu chí | Điểm (1-5) | Ghi chú |
|---|---|---|
| Hoàn thành đúng deadline | 5/5 | Hoàn thành toàn bộ 6/6 task đúng hạn. |
| Chất lượng deliverable | 5/5 | Đảm bảo code sạch, có unit test coverage tốt và dockerized hoàn chỉnh. |
| Giao tiếp với team | 5/5 | Chủ động hỗ trợ team dev infra setup môi trường. |
| Chủ động xử lý blocker | 5/5 | Tự giải quyết được các blocker liên quan đến build PyTorch CPU và mock S3. |
| **Tổng** | **20/20** | |


